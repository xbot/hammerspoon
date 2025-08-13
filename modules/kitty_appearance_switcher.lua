---
-- Automatically switch kitty terminal theme based on system appearance (Dark/Light Mode).
---
local switcher = {}
local commons = require('modules/commons')
local MODULE_NAME = 'kitty_appearance_switcher'
commons.logger.registerModule(MODULE_NAME)
local watcher

local lightThemePath = os.getenv('HOME') .. '/.config/kitty/colorscheme/light.conf'
local darkThemePath = os.getenv('HOME') .. '/.config/kitty/colorscheme/dark.conf'

local function getCurrentAppearance()
    local script = [[
        tell application "System Events"
            tell appearance preferences
                return dark mode
            end tell
        end tell
    ]]
    local ok, result = hs.applescript(script)
    return ok and result
end

local function switchKittyTheme(isDark)
    local themePath = isDark and darkThemePath or lightThemePath

    -- Check if the theme file exists
    local f = io.open(themePath, "r")
    if not f then
        commons.logger.error(MODULE_NAME, "Theme file not found: " .. themePath)
        return
    end
    f:close()

    -- Dynamically find the correct Unix socket path
    local userName = os.getenv("USER")
    -- Use io.popen to find the socket file more directly
    local findCommand = string.format('ls /tmp/kitty-%s-* 2>/dev/null | head -1', userName)
    local handle = io.popen(findCommand)
    local socketFile = ""
    if handle then
        socketFile = handle:read("*l")
        handle:close()
    end

    if not socketFile or socketFile == "" then
        commons.logger.error(MODULE_NAME, "No kitty socket found matching pattern: /tmp/kitty-" .. userName .. "-*")
        return
    end

    local socketPath = "unix:" .. socketFile
    local command = string.format('/Applications/kitty.app/Contents/MacOS/kitty @ --to %s set-colors --all --configured "%s"', socketPath, themePath)

    hs.task.new("/bin/bash", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            local themeType = isDark and "dark" or "light"
            commons.logger.info(MODULE_NAME, "Successfully switched to " .. themeType .. " theme")
        else
            commons.logger.error(MODULE_NAME, "Failed to switch theme: " .. (stdErr or "Unknown error"))
        end
    end, {"-c", command}):start()
end

local function onAppearanceChange()
    local isDark = getCurrentAppearance()
    switchKittyTheme(isDark)
end

function switcher:start()
    -- Ensure watcher is not started multiple times
    if watcher then
        watcher:stop()
    end
    -- Use distributednotifications to listen for theme changes
    watcher = hs.distributednotifications.new(function(name, object, userInfo)
        commons.logger.info(MODULE_NAME, "System appearance change detected: " .. tostring(name))
        -- Add a delay to ensure the system theme has completely switched
        hs.timer.doAfter(0.5, onAppearanceChange)
    end, "AppleInterfaceThemeChangedNotification")

    watcher:start()

    onAppearanceChange()

    commons.logger.info(MODULE_NAME, "Kitty theme auto-switcher started")
end

function switcher:stop()
    if watcher then
        watcher:stop()
        watcher = nil
    end
end

return switcher