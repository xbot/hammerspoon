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
local builtInHandlersRegistered = false
local lastAppearance
local pendingAppearanceTimer
local neovimThemeGeneration = 0
local neovimThemeTaskRunning = false

-- --- App-specific Handlers ---

local function switchHammerspoonConsoleTheme(isDark)
    -- Hammerspoon console supports dark mode natively on macOS
    -- This will automatically switch based on system appearance
    hs.console.darkMode(isDark)

    commons.logger.info(MODULE_NAME, "Switched Hammerspoon console to " .. (isDark and "dark" or "light") .. " theme.")
end

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
    local kittyTask = hs.task.new('/Applications/kitty.app/Contents/MacOS/kitty', function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            commons.logger.info(MODULE_NAME, "Successfully switched Kitty to " .. (isDark and "dark" or "light") .. " theme.")
        else
            commons.logger.error(MODULE_NAME, "Failed to switch Kitty theme: " .. (stdErr or "Unknown error"))
        end
    end, {"@", "--to", socketPath, "set-colors", "--all", "--configured", themePath})

    if kittyTask then
        kittyTask:start()
    else
        commons.logger.error(MODULE_NAME, 'Failed to create Kitty theme task.')
    end
end

local function switchNeovimTheme(isDark)
    if neovimThemeTaskRunning then
        commons.logger.debug(MODULE_NAME, 'A Neovim theme switch is already in progress.')
        return
    end

    neovimThemeTaskRunning = true
    local taskGeneration = neovimThemeGeneration
    local serverListTask = hs.task.new(nvr_executable_path, function(exitCode, stdOut, stdErr)
        if taskGeneration ~= neovimThemeGeneration then
            return
        end

        if exitCode ~= 0 or not stdOut or stdOut == "" then
            neovimThemeTaskRunning = false
            commons.logger.debug(MODULE_NAME, "No nvim servers found or error listing servers: " .. (stdErr or ""))
            return
        end

        local seenSocketPaths = {}
        local duplicateSocketCount = 0
        local socketPaths = {}

        for socketPath in stdOut:gmatch("[^\n]+") do
            if socketPath ~= "" and not seenSocketPaths[socketPath] then
                seenSocketPaths[socketPath] = true
                table.insert(socketPaths, socketPath)
            elseif socketPath ~= "" then
                duplicateSocketCount = duplicateSocketCount + 1
            end
        end

        if duplicateSocketCount > 0 then
            commons.logger.debug(MODULE_NAME,
                'Skipped ' .. duplicateSocketCount .. ' duplicate Neovim socket entries from nvr --serverlist.'
            )
        end

        local seenProcessIds = {}
        local pendingDiscoveryTasks = #socketPaths
        local pendingThemeTasks = 0
        local themeCommand = 'lua vim.g.is_dark = ' .. tostring(isDark) .. '; _G.SwitchTheme()'

        local function finish_if_idle()
            if taskGeneration == neovimThemeGeneration and pendingDiscoveryTasks == 0 and pendingThemeTasks == 0 then
                neovimThemeTaskRunning = false
            end
        end

        if pendingDiscoveryTasks == 0 then
            finish_if_idle()
            return
        end

        for _, socketPath in ipairs(socketPaths) do
            local serverPath = socketPath
            local discoveryTask = hs.task.new(nvr_executable_path, function(innerExitCode, innerStdOut, innerStdErr)
                if taskGeneration ~= neovimThemeGeneration then
                    return
                end

                pendingDiscoveryTasks = pendingDiscoveryTasks - 1

                local processId = innerExitCode == 0 and (innerStdOut or ''):match('(%d+)') or nil
                if not processId then
                    commons.logger.debug(MODULE_NAME,
                        'Failed to identify Neovim instance at ' .. serverPath .. ': ' .. (innerStdErr or '')
                    )
                elseif not seenProcessIds[processId] then
                    seenProcessIds[processId] = true
                    pendingThemeTasks = pendingThemeTasks + 1

                    local themeTask = hs.task.new(nvr_executable_path, function(themeExitCode, themeStdOut, themeStdErr)
                        if taskGeneration ~= neovimThemeGeneration then
                            return
                        end

                        pendingThemeTasks = pendingThemeTasks - 1
                        if themeExitCode == 0 then
                            commons.logger.info(MODULE_NAME,
                                'Successfully sent theme switch command to Neovim instance ' .. processId .. ' at ' .. serverPath
                            )
                        else
                            commons.logger.debug(MODULE_NAME,
                                'Failed to send command to Neovim instance ' .. processId .. ' at ' .. serverPath .. ': ' .. (themeStdErr or '')
                            )
                        end
                        finish_if_idle()
                    end, {"--servername", serverPath, "--nostart", "-c", themeCommand})

                    if themeTask then
                        themeTask:start()
                    else
                        pendingThemeTasks = pendingThemeTasks - 1
                        commons.logger.error(MODULE_NAME, 'Failed to create Neovim theme task for ' .. serverPath)
                    end
                end

                finish_if_idle()
            end, {"--servername", serverPath, "--nostart", "--remote-expr", "getpid()"})

            if discoveryTask then
                discoveryTask:start()
            else
                pendingDiscoveryTasks = pendingDiscoveryTasks - 1
                commons.logger.error(MODULE_NAME, 'Failed to create Neovim discovery task for ' .. serverPath)
            end
        end

        -- Handles discovery task creation failures before any callback runs.
        finish_if_idle()
    end, {"--serverlist"})

    if serverListTask then
        serverListTask:start()
    else
        if taskGeneration == neovimThemeGeneration then
            neovimThemeTaskRunning = false
        end
        commons.logger.error(MODULE_NAME, 'Failed to create Neovim server discovery task.')
    end
end


-- --- Core Manager Logic ---

function manager.register_handler(handlerFunc)
    table.insert(handlers, handlerFunc)
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

    if lastAppearance == isDark then
        commons.logger.debug(MODULE_NAME, 'Ignoring duplicate appearance notification.')
        return
    end

    lastAppearance = isDark
    commons.logger.info(MODULE_NAME, 'System appearance set. Dark mode: ' .. tostring(isDark))
    for _, handler in ipairs(handlers) do
        handler(isDark)
    end
end

function manager:start()
    self:stop()
    lastAppearance = nil

    -- Synchronize all built-in handlers at startup. Neovim socket entries are
    -- deduplicated before remote commands are sent.
    if not builtInHandlersRegistered then
        self.register_handler(switchHammerspoonConsoleTheme)
        self.register_handler(switchKittyTheme)
        self.register_handler(switchNeovimTheme)
        builtInHandlersRegistered = true
    end

    watcher = hs.distributednotifications.new(function(name, object, userInfo)
        commons.logger.info(MODULE_NAME, "System appearance change detected: " .. tostring(name))
        if pendingAppearanceTimer then
            pendingAppearanceTimer:stop()
        end
        pendingAppearanceTimer = hs.timer.doAfter(0.5, function()
            pendingAppearanceTimer = nil
            onAppearanceChange()
        end)
    end, "AppleInterfaceThemeChangedNotification")

    watcher:start()

    -- Initial check on start
    onAppearanceChange()

    commons.logger.info(MODULE_NAME, "Appearance Manager started with " .. #handlers .. " handlers.")
end

function manager:stop()
    neovimThemeGeneration = neovimThemeGeneration + 1
    neovimThemeTaskRunning = false

    if pendingAppearanceTimer then
        pendingAppearanceTimer:stop()
        pendingAppearanceTimer = nil
    end

    if watcher then
        watcher:stop()
        watcher = nil
    end
end

return manager
