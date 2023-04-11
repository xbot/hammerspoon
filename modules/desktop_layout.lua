--
-- Desktop layout
--

local logger = hs.logger.new('Launcher', 'debug')

local previousScreenByWindow = {}

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
-- Set *.layouts.*.frame = nil to ignore resizing windows on that screen.
local desktopLayout = {
    -- Center of the primary screen
    {app = 'Anki', screen = hs.screen.primaryScreen(), center = true, excludeWindows = {'Browse %((%d+) of (%d+) cards selected%)'}},
    {apps = {'Bitwarden'}, screen = hs.screen.primaryScreen(), center = true},
    -- The full size of the primary screen.
    {apps = {'Home Assistant', 'Logseq', 'Notion', 'Vivaldi'}, screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 1, 1)},
    {app = 'Brave Browser', screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 1, 1), excludeWindows = {'Picture in Picture'}},
    -- The full size of the secondary screen, fallback to the left a third of the primary screen.
    {apps = {'Dash'}, screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0, 1, 1), fallback = {screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1)}},
    -- The left a third of the primary screen.
    {
        apps = {'EuDic', 'Hammerspoon', 'Telegram'},
        screen = hs.screen.primaryScreen(),
        frame = hs.geometry.rect(0, 0, 0.33, 1),
        layouts = {
            {screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0, 1, 0.5)}
            -- {screenUUID = 'XXXXXX-XXXXXX-XXXXXX-XXXXXX', frame = hs.geometry.rect(0, 0, 1, 0.5)}
        }
    },
    {app = 'Twitter', screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1), excludeWindows = {'Tweet'}},
    {app = 'WeChat', screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1), excludeWindows = {'Log In'}},
    -- The right two thirds of the primary screen.
    {
        apps = {'OmniFocus', 'kitty'},
        screen = hs.screen.primaryScreen(),
        frame = hs.geometry.rect(0.33, 0, 0.67, 1),
        layouts = {
            {screen = get_secondary_screen(), frame = nil}
        }
    },
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
local function apply_layout(window, layout)
    if not layout then
        return
    end

    -- Check if the window title matches any excludeWindows patterns
    local shouldExclude = false
    for _, pattern in ipairs(layout.excludeWindows or {}) do
        if string.match(window:title(), pattern) ~= nil then
            shouldExclude = true
            break
        end
    end

    if shouldExclude then
        logger.d('Window "' .. window:title() .. '" ignored by the "excludeWindows" patterns.')
        return
    end

    if layout.screen then
        if layout.frame then
            window:move(layout.frame, layout.screen, true)
        else
            window:moveToScreen(layout.screen, true)
        end
    end

    if layout.center == true then
        window:centerOnScreen()
    end

    previousScreenByWindow[window:id()] = window:screen():getUUID()

    logger.d('Placed ' .. window:application():name() .. ' (' .. window:title() .. ') to the ' .. hs.inspect(layout.frame) .. ' of the ' .. layout.screen:name())
end

-- Get config from desktopLayout by app name
local function get_app_config(appName)
    for _, appConfig in ipairs(desktopLayout) do
        if appConfig.app == appName or hs.fnutils.contains(appConfig.apps or {}, appName) then
            return appConfig
        end
    end

    return nil
end

local function generate_layout(appConfig, screen)
    local layout = hs.fnutils.copy(appConfig)

    layout.fallback = nil
    layout.layouts = nil

    -- Return the pre-defined layout for the current screen.
    if appConfig.layouts then
        for _, screenLayout in ipairs(appConfig.layouts) do
            if (screenLayout.screen and screenLayout.screen == screen) or (screenLayout.screenUUID and screenLayout.screenUUID == screen:getUUID()) then
                layout.screen = screen
                layout.frame = screenLayout.frame
                layout.center = screenLayout.center

                return layout
            end
        end
    end

    if not layout.screen and appConfig.fallback then
        if appConfig.fallback.screen then
            layout.screen = appConfig.fallback.screen
        end

        if appConfig.fallback.frame then
            layout.frame = appConfig.fallback.frame
        end

        if appConfig.fallback.center then
            layout.center = appConfig.fallback.center
        end
    end

    return layout
end

-- Window watcher

local wf = hs.window.filter.default

wf:subscribe(hs.window.filter.windowCreated, function(window, appName)
    if not window:isStandard() or window:isMinimized() then
        return
    end

    logger.d('New window "' .. window:title() .. '" created for ' .. appName)

    local config = get_app_config(appName)
    if not config then
        return
    end

    local layout = generate_layout(config, window:screen())
    apply_layout(window, layout)
end)

wf:subscribe(hs.window.filter.windowMoved, function(window)
    local prevScreenUUID = previousScreenByWindow[window:id()]
    local newScreenUUID = window:screen():getUUID()

    if newScreenUUID ~= prevScreenUUID then
        local config = get_app_config(window:application():name())
        if not config then
            return
        end

        logger.d("Window " .. window:title() .. " has been moved to screen: " .. window:screen():name())

        local layout = generate_layout(config, window:screen())
        apply_layout(window, layout)
    end
end)

-- Application watcher

AppWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType ~= hs.application.watcher.activated then
        return
    end

    local config = get_app_config(appName)
    if not config then
        return
    end

    wait_for_window_ready(appObject, function()
        local layout = generate_layout(config, appObject:focusedWindow():screen())
        apply_layout(appObject:focusedWindow(), layout)
    end)
end)

AppWatcher:start()

-- Screen watcher

ScreenWatcher = hs.screen.watcher.new(function()
    -- Reload configuration upon changing screen layout.
    hs.reload()
    hs.notify.new({title="Hammerspoon", informativeText="Config Reloaded"}):send()
end)

ScreenWatcher:start()
