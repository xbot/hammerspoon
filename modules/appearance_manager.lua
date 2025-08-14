---
-- Generic Appearance Manager
-- Watches for system appearance changes (Dark/Light Mode) and calls registered handlers.
---
local manager = {}
local commons = require('modules/commons')
local MODULE_NAME = 'appearance_manager'
commons.logger.registerModule(MODULE_NAME)
local watcher

-- --- Configuration ---
-- If nvr is not in your standard PATH, specify the full path to the executable here.
-- e.g., local nvr_executable_path = '/opt/homebrew/bin/nvr'
local nvr_executable_path = '/opt/homebrew/bin/nvr'

local handlers = {}

-- --- App-specific Handlers ---

local function switchKittyTheme(isDark)
    local lightThemePath = os.getenv('HOME') .. '/.config/kitty/colorscheme/light.conf'
    local darkThemePath = os.getenv('HOME') .. '/.config/kitty/colorscheme/dark.conf'
    local themePath = isDark and darkThemePath or lightThemePath

    local f = io.open(themePath, "r")
    if not f then
        commons.logger.error(MODULE_NAME, "Kitty theme file not found: " .. themePath)
        return
    end
    f:close()

    local userName = os.getenv("USER")
    local findCommand = string.format('ls /tmp/kitty-%s-* 2>/dev/null | head -1', userName)
    local handle = io.popen(findCommand)
    local socketFile = ""
    if handle then
        socketFile = handle:read("*l")
        handle:close()
    end

    if not socketFile or socketFile == "" then
        commons.logger.debug(MODULE_NAME, "No kitty socket found, skipping theme switch.")
        return
    end

    local socketPath = "unix:" .. socketFile
    local command = string.format('/Applications/kitty.app/Contents/MacOS/kitty @ --to %s set-colors --all --configured "%s"', socketPath, themePath)

    hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            commons.logger.info(MODULE_NAME, "Successfully switched Kitty to " .. (isDark and "dark" or "light") .. " theme.")
        else
            commons.logger.error(MODULE_NAME, "Failed to switch Kitty theme: " .. (stdErr or "Unknown error"))
        end
    end, {"-c", command}):start()
end

local function switchNeovimTheme(isDark)
    local command = string.format('%s -s --nostart -c "lua vim.g.is_dark = %s; _G.SwitchTheme()"', nvr_executable_path, tostring(isDark))
    hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            commons.logger.info(MODULE_NAME, "Successfully sent theme switch command to Neovim.")
        else
            commons.logger.debug(MODULE_NAME, "Could not send command to Neovim (maybe no instance is running?): " .. (stdErr or ""))
        end
    end, {"-c", command}):start()
end

-- --- Core Manager Logic ---

function manager.register_handler(handler_func)
    table.insert(handlers, handler_func)
end

local function onAppearanceChange()
    local script = [[
        tell application "System Events"
            tell appearance preferences
                return dark mode
            end tell
        end tell
    ]]
    local ok, isDark = hs.applescript(script)
    if not ok then
        commons.logger.error(MODULE_NAME, "Failed to get system appearance.")
        return
    end

    commons.logger.info(MODULE_NAME, "System appearance changed. Dark mode: " .. tostring(isDark))
    for _, handler in ipairs(handlers) do
        handler(isDark)
    end
end

function manager:start()
    if watcher then
        watcher:stop()
    end
    
    -- Register the built-in handlers
    self.register_handler(switchKittyTheme)
    self.register_handler(switchNeovimTheme)
    
    watcher = hs.distributednotifications.new(function(name, object, userInfo)
        commons.logger.info(MODULE_NAME, "System appearance change detected: " .. tostring(name))
        hs.timer.doAfter(0.5, onAppearanceChange)
    end, "AppleInterfaceThemeChangedNotification")

    watcher:start()

    -- Initial check on start
    onAppearanceChange()

    commons.logger.info(MODULE_NAME, "Appearance Manager started with " .. #handlers .. " handlers.")
end

function manager:stop()
    if watcher then
        watcher:stop()
        watcher = nil
    end
end

return manager
