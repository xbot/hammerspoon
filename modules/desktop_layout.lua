--
-- Desktop layout
--

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
    {apps = {'EuDic', 'Hammerspoon', 'Telegram', 'Twitter', 'WeChat'}, screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1)},
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
        local mainWindow = appObject:mainWindow()
        return mainWindow ~= nil and mainWindow:isStandard() and not mainWindow:isMinimized()
    end, function()
        callback()
    end)
end

-- Application watcher function
local function application_watcher(appName, eventType, appObject)
    if eventType ~= hs.application.watcher.activated then
        return
    end

    for _, appConfig in ipairs(desktopLayout) do
        if hs.fnutils.contains(appConfig.apps, appName) then
            local config = appConfig

            if (not config.screen or not config.frame) and config.fallback then
                config = hs.fnutils.copy(config)

                if not config then
                    break
                end

                if config.fallback.screen then
                    config.screen = config.fallback.screen
                end

                if config.fallback.frame then
                    config.frame = config.fallback.frame
                end
            end

            wait_for_window_ready(appObject, function()
                if config.screen then
                    if config.frame then
                        appObject:mainWindow():move(config.frame, config.screen, true)
                    else
                        appObject:mainWindow():moveToScreen(config.screen, true)
                    end
                end

                if config.center == true then
                    appObject:mainWindow():centerOnScreen()
                end

                print('Placed ' .. appName .. ' to the ' .. hs.inspect(config.frame) .. ' of the ' .. config.screen:name())
            end)

            break
        end
    end
end

-- Start the application watcher
AppWatcher = hs.application.watcher.new(application_watcher)
AppWatcher:start()
