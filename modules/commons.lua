--
-- Provides common utilities, settings management, and a centralized logger.
-- This module follows a start/stop lifecycle pattern.
---

local commons = {}
local MODULE_NAME = 'commons'

commons.menubarItem = nil
commons.settings = {}
commons.logger = {}

local config_file = '~/.hammerspoon/data/Config.json'
local config_file_template = '~/.hammerspoon/data/initConfig.json'
local version = 'v0.6.1'

local LOG_LEVELS = { error = 1, warn = 2, info = 3, debug = 4, verbose = 5 }

local function get_log_level_name(levelNum)
    for name, num in pairs(LOG_LEVELS) do
        if num == levelNum then
            return name
        end
    end
    return tostring(levelNum)
end

-- --- Logger Implementation ---
local loggers = {}

local rebuild_main_menu -- Forward declaration

local function toggle_log_level(name)
    loggers[MODULE_NAME].d("Toggling log level for " .. name)
    local currentLevelNum = loggers[name].getLogLevel()
    local newLevelNum
    local newLevelName

    if currentLevelNum == LOG_LEVELS.info then
        newLevelNum = LOG_LEVELS.debug
        newLevelName = "debug"
    else
        newLevelNum = LOG_LEVELS.info
        newLevelName = "info"
    end

    -- 1. Set it on the logger object
    loggers[name].setLogLevel(newLevelNum)

    -- 2. Persist the setting
    if commons.settings[1] and not commons.settings[1].logLevels then
        commons.settings[1].logLevels = {}
    end
    if commons.settings[1] then
        commons.settings[1].logLevels[name] = newLevelName
        hs.json.write(commons.settings, config_file, true, true)
        loggers[MODULE_NAME].d("Saved log level for " .. name .. " as " .. newLevelName)
    else
        loggers[MODULE_NAME].e("Cannot save log level, commons.settings not initialized.")
    end

    -- 3. Rebuild the menu to reflect the change
    rebuild_main_menu()
end

-- This function is local as it should only be called from within this module
rebuild_main_menu = function()
    -- Since this function can be called from within a logger function,
    -- we need to access the 'commons' logger directly to avoid loops.
    -- Also handle case where commons logger is not yet initialized or doesn't have debug method
    loggers[MODULE_NAME].d("Rebuilding Main Menu")

    if not commons.menubarItem then
        loggers[MODULE_NAME].d("commons.menubarItem is nil. Aborting menu rebuild.")
        return
    end

    -- 1. Build the debug submenu first
    local debugSubMenu = {}
    local moduleNames = {}
    for name, _ in pairs(loggers) do
        table.insert(moduleNames, name)
    end
    table.sort(moduleNames)

    loggers[MODULE_NAME].d("Registered modules for submenu: " .. table.concat(moduleNames, ", "))

    if #moduleNames == 0 then
        table.insert(debugSubMenu, { title = "No modules registered", disabled = true })
    end

    for _, name in ipairs(moduleNames) do
        local levelNum = loggers[name].getLogLevel()
        local levelStr = get_log_level_name(levelNum)
        table.insert(debugSubMenu, {
            title = name .. " (" .. levelStr .. ")",
            checked = (levelNum == LOG_LEVELS.debug),
            fn = function()
                toggle_log_level(name)
            end
        })
    end

    -- 2. Build the main menu, inserting the debug submenu
    local mainMenuData = {
        { title = 'Reload Settings', fn = function() hs.reload() end },
        { title = 'Open console', fn = function() hs.openConsole() end },
        { title = 'Relaunch', fn = function() hs.relaunch() end },
        { title = '-' },
        { title = '屏幕取色', fn = function() open_color_picker() end },
        { title = '咖啡因：' .. commons.getOption('caffeine', 'off'), fn = function() toggle_caffeine() end },
        { title = '格式化剪贴板 JSON ：' .. commons.getOption('json_beautifier', 'off'), fn = function() toggle_json_beautifier() end },
        { title = '自动添加 OmniFocus 任务：' .. commons.getOption('watch_omnifocus_sensible_data', 'off'), fn = function() toggle_omnifocus_sensible_data_watcher() end },
        { title = '-' },
        { title = 'Debug Log Levels', menu = debugSubMenu },
        { title = '-' },
        {
            title = '关于',
            fn = function()
                if hs.dialog.blockAlert('当前版本：' .. version, '整理了一些能够提高效率的脚本，打开主页查看详细说明。', '确定', '取消', 'informational') == '确定' then
                    hs.urlevent.openURL('https://github.com/xbot/hammerspoon')
                end
            end,
        },
    }

    commons.menubarItem:setMenu(mainMenuData)
    loggers[MODULE_NAME].d("Finished Rebuilding Main Menu")
end

function commons.logger.registerModule(name)
    if not loggers[name] then
        -- First, create the logger for the new module so it definitely exists.
        loggers[name] = hs.logger.new(name, 'info')

        -- Apply any persisted log level from settings
        if commons.settings[1] and commons.settings[1].logLevels and commons.settings[1].logLevels[name] then
            local savedLevelName = commons.settings[1].logLevels[name]
            local savedLevelNum = LOG_LEVELS[savedLevelName]
            if savedLevelNum then
                loggers[name].setLogLevel(savedLevelNum)
                if loggers[MODULE_NAME] then
                    loggers[MODULE_NAME].d("Applied saved log level '" .. savedLevelName .. "' for module: " .. name)
                end
            end
        end

        -- Now, we can safely use the 'commons' logger (if it exists) to log the registration.
        if loggers[MODULE_NAME] then
            loggers[MODULE_NAME].d("Registered module: " .. name)
        end

        rebuild_main_menu()
    end
end

function commons.logger.info(module, ...)
    if loggers[module] then
        loggers[module].i(...)
    else
        print(string.format("[WARN] Module '%s' is not registered with the logger. Message: %s", module, table.concat({...}, '\t')))
    end
end

function commons.logger.debug(module, ...)
    if loggers[module] then
        loggers[module].d(...)
    else
        print(string.format("[WARN] Module '%s' is not registered with the logger. Message: %s", module, table.concat({...}, '\t')))
    end
end

function commons.logger.error(module, ...)
    if loggers[module] then
        loggers[module].e(...)
    else
        print(string.format("[ERROR] Module '%s' is not registered with the logger. Message: %s", module, table.concat({...}, '\t')))
    end
end
-- --- End Logger Implementation ---

function commons.getOption(option, default_value)
    if commons.settings[1] == nil or commons.settings[1][option] == nil then
        return default_value
    end
    return commons.settings[1][option]
end

local function file_exists(path)
    local file = hs.fs.pathToAbsolute(path)
    return file ~= nil
end

local function copy_file(source, destination)
    local sourcefile = io.open(source, 'r')
    local destinationfile = io.open(destination, 'w')
    destinationfile:write(sourcefile:read('*all'))
    sourcefile:close()
    destinationfile:close()
end

local function toggle_caffeine()
    if commons.settings[1].caffeine == 'on' then
        commons.settings[1].caffeine = 'off'
    else
        commons.settings[1].caffeine = 'on'
    end
    hs.json.write(commons.settings, config_file, true, true)
    hs.reload()
end

local function toggle_json_beautifier()
    if commons.settings[1].json_beautifier == 'on' then
        commons.settings[1].json_beautifier = 'off'
    else
        commons.settings[1].json_beautifier = 'on'
    end
    hs.json.write(commons.settings, config_file, true, true)
    hs.reload()
end

local function toggle_omnifocus_sensible_data_watcher()
    if commons.settings[1].watch_omnifocus_sensible_data == 'on' then
        commons.settings[1].watch_omnifocus_sensible_data = 'off'
    else
        commons.settings[1].watch_omnifocus_sensible_data = 'on'
    end
    hs.json.write(commons.settings, config_file, true, true)
    hs.reload()
end

local function open_color_picker()
    local color_dialog = hs.dialog.color
    hs.openConsole(true)
    color_dialog.show()
    color_dialog.mode('RGB')
    color_dialog.callback(function(a, b)
        if b then
            hs.closeConsole()
        end
    end)
    hs.closeConsole()
end

-- Lifecycle Functions
function commons:start()
    hs.console.clearConsole()
    -- Register commons module itself for logging.
    commons.logger.registerModule(MODULE_NAME)

    commons.logger.info(MODULE_NAME, "Starting commons module.")

    if not file_exists(config_file) then
        local source = hs.fs.pathToAbsolute(config_file_template)
        local destination = string.gsub(source, 'initConfig.json$', 'Config.json')
        copy_file(source, destination)
    end

    if hs.json.read(config_file) ~= nil then
        commons.settings = hs.json.read(config_file)
    end

    -- Ensure the logLevels table exists in the settings
    if commons.settings[1] and not commons.settings[1].logLevels then
        commons.settings[1].logLevels = {}
    end

    -- Create the menubar item
    if not commons.menubarItem then
        commons.menubarItem = hs.menubar.new()
        commons.menubarItem:setTitle('')
        commons.menubarItem:setIcon('~/.hammerspoon/icon/input_u.pdf')
    end

    rebuild_main_menu()

    hs.alert.defaultStyle.strokeColor = { white = 1, alpha = 0 }
    hs.alert.defaultStyle.fillColor = { white = 0.05, alpha = 0.75 }
    hs.alert.defaultStyle.radius = 10
end

function commons:stop()
    commons.logger.info(MODULE_NAME, "Stopping commons module.")
    if commons.menubarItem then
        commons.menubarItem:delete()
        commons.menubarItem = nil
    end
end

return commons
