--
-- Desktop layout
--

local logger = hs.logger.new('Launcher', 'debug')

-- Take the right most screen as the secondary screen.
local function get_secondary_screen()
    local primary = hs.screen.primaryScreen()
    local screens = hs.screen.allScreens()
    local rightmost = primary

    if not screens then
        return nil
    end

    for _, screen in ipairs(screens) do
        if screen ~= primary and screen:frame().x > rightmost:frame().x then
            rightmost = screen
        end
    end

    if rightmost == primary then
        return nil
    end

    return rightmost
end

-- Application list and corresponding layouts
local desktopLayout = {
    -- Center of the primary screen
    {apps = {'Anki', 'Bitwarden'}, screen = hs.screen.primaryScreen(), center = true},
    -- The full size of the primary screen.
    {apps = {'Home Assistant', 'Logseq', 'Notion', 'Vivaldi'}, screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 1, 1)},
    -- The full size of the secondary screen, fallback to the left a third of the primary screen.
    {apps = {'Dash'}, screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0, 1, 1), fallback = {screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1)}},
    -- The left a third of the primary screen.
    {apps = {'EuDic', 'Hammerspoon', 'Telegram'}, screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1)},
    {app = 'Twitter', screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1), exclude = {'Tweet'}},
    {app = 'WeChat', screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1), exclude = {'Log In'}},
    -- The right two thirds of the primary screen.
    {apps = {'OmniFocus', 'kitty'}, screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0.33, 0, 0.67, 1)},
    -- The top half of the secondary screen, fallback to the left a third of the primary screen.
    {apps = {'Slack'}, screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0, 1, 0.5), fallback = {screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1)}},
    -- The bottom half of the secondary screen, fallback to the right two thirds of the primary screen.
    {apps = {'Safari'}, screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0.5, 1, 0.5), fallback = {screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0.33, 0, 0.67, 1)}}
}

-- Wait for window to be ready
local function wait_for_window_ready(appObject, callback)
    hs.timer.waitUntil(function()
        local focusedWindow = appObject:focusedWindow()
        return focusedWindow ~= nil and focusedWindow:isStandard() and not focusedWindow:isMinimized()
    end, function()
        callback()
    end)
end

-- Move window to designated position
local function move_window(window, config)
    if not config then
        return
    end

    -- Check if the window title matches any exclude patterns
    local shouldExclude = false
    for _, pattern in ipairs(config.exclude or {}) do
        if string.find(window:title(), pattern) ~= nil then
            shouldExclude = true
            break
        end
    end

    if shouldExclude then
        logger.d('Window "' .. window:title() .. '" ignored by the "exclude" patterns.')
        return
    end

    if config.screen then
        if config.frame then
            window:move(config.frame, config.screen, true)
        else
            window:moveToScreen(config.screen, true)
        end
    end

    if config.center == true then
        window:centerOnScreen()
    end

    logger.d('Placed ' .. window:application():name() .. ' to the ' .. hs.inspect(config.frame) .. ' of the ' .. config.screen:name())
end

-- Get config from desktopLayout by app name
local function get_config_by_app_name(appName)
    for _, appConfig in ipairs(desktopLayout) do
        if appConfig.app == appName or hs.fnutils.contains(appConfig.apps or {}, appName) then
            local config = appConfig

            if (not config.screen or not config.frame) and config.fallback then
                config = hs.fnutils.copy(config)

                if not config then
                    return
                end

                if config.fallback.screen then
                    config.screen = config.fallback.screen
                end

                if config.fallback.frame then
                    config.frame = config.fallback.frame
                end
            end

            return config
        end
    end

    return nil
end

-- Watch new window

local wf = hs.window.filter.new(nil)

local function on_window_created(window, appName, event)
    if not window:isStandard() or window:isMinimized() then
        return
    end

    logger.d('New window "' .. window:title() .. '" created for ' .. appName)

    local config = get_config_by_app_name(appName)
    if not config then
        return
    end

    move_window(window, config)
end

wf:subscribe(hs.window.filter.windowCreated, on_window_created)

-- Application watcher function
local function application_watcher(appName, eventType, appObject)
    if eventType ~= hs.application.watcher.activated then
        return
    end

    local config = get_config_by_app_name(appName)
    if not config then
        return
    end

    wait_for_window_ready(appObject, function()
        move_window(appObject:focusedWindow(), config)
    end)
end

-- Start the application watcher
AppWatcher = hs.application.watcher.new(application_watcher)
AppWatcher:start()
