--
-- Desktop layout
--

local logger = hs.logger.new('Launcher', 'debug')

local desktopLayoutSitter = {}

local previousScreenByWindow = {}
local moveTypeByWindow = {}

-- Initiate previousScreenByWindow on startup
for _, app in ipairs(hs.application.runningApplications()) do
    for _, window in ipairs(app:allWindows()) do
        if window:isStandard() and not window:isMinimized() then
            previousScreenByWindow[window:id()] = window:screen():getUUID()
        end
    end
end

-- Take the first non-primary screen as the secondary screen.
local function get_secondary_screen()
    local secondaryScreen
    local primary = hs.screen.primaryScreen()
    local screens = hs.screen.allScreens()

    for _, screen in ipairs(screens) do
        if screen ~= primary then
            secondaryScreen = screen
            break
        end
    end

    return secondaryScreen
end

-- Application layouts
-- Set *.layouts.*.frame = nil to ignore resizing windows on that screen.
local function init_desktop_layout()
    return {
        -- Center of the primary screen
        {
            app = 'Anki',
            screen = hs.screen.primaryScreen(),
            center = true,
            excludeWindows = { 'Browse %((%d+) of (%d+) cards selected%)' },
        },
        { apps = { 'Bitwarden' }, screen = hs.screen.primaryScreen(), center = true },
        -- The full size of the primary screen.
        {
            apps = { 'Home Assistant', 'Logseq', 'Notion', 'Vivaldi' },
            screen = hs.screen.primaryScreen(),
            frame = hs.geometry.rect(0, 0, 1, 1),
        },
        {
            app = 'Brave Browser',
            screen = hs.screen.primaryScreen(),
            frame = hs.geometry.rect(0, 0, 1, 1),
            excludeWindows = { 'Picture in Picture' },
        },
        -- The full size of the secondary screen, fallback to the left a third of the primary screen.
        {
            apps = { 'Dash' },
            screen = get_secondary_screen(),
            frame = hs.geometry.rect(0, 0, 1, 1),
            fallback = { screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1) },
        },
        -- The left a third of the primary screen.
        {
            apps = { 'EuDic', 'Hammerspoon', 'Telegram' },
            screen = hs.screen.primaryScreen(),
            frame = hs.geometry.rect(0, 0, 0.33, 1),
            layouts = {
                { screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0, 1, 0.5) },
                -- {screenUUID = 'XXXXXX-XXXXXX-XXXXXX-XXXXXX', frame = hs.geometry.rect(0, 0, 1, 0.5)}
            },
        },
        {
            app = 'Twitter',
            screen = hs.screen.primaryScreen(),
            frame = hs.geometry.rect(0, 0, 0.33, 1),
            excludeWindows = { 'Tweet' },
        },
        {
            app = 'WeChat',
            screen = hs.screen.primaryScreen(),
            frame = hs.geometry.rect(0, 0, 0.33, 1),
            excludeWindows = { 'Log In' },
            layouts = {
                { screenUUID = '37D8832A-2D66-02CA-B9F7-8F30A301B230', frame = hs.geometry.rect(0, 0, 0.5, 1) },
                { screenUUID = '5305866C-4D51-2169-0857-D6964E3302DB', frame = hs.geometry.rect(0, 0, 0.33, 1) },
            },
        },
        -- The right two thirds of the primary screen.
        {
            apps = { 'OmniFocus', 'kitty' },
            screen = hs.screen.primaryScreen(),
            frame = hs.geometry.rect(0.33, 0, 0.67, 1),
            layouts = {
                { screenUUID = '37D8832A-2D66-02CA-B9F7-8F30A301B230', frame = nil },
                { screenUUID = '5305866C-4D51-2169-0857-D6964E3302DB', frame = hs.geometry.rect(0.33, 0, 0.67, 1) },
            },
            excludeWindows = { '.* Preferences' },
        },
        -- The top half of the secondary screen, fallback to the left a third of the primary screen.
        {
            apps = { 'Slack' },
            screen = get_secondary_screen(),
            frame = hs.geometry.rect(0, 0, 1, 0.5),
            fallback = { screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0, 0, 0.33, 1) },
        },
        -- The bottom half of the secondary screen, fallback to the right two thirds of the primary screen.
        {
            apps = { 'Safari' },
            screen = get_secondary_screen(),
            frame = hs.geometry.rect(0, 0.5, 1, 0.5),
            fallback = { screen = hs.screen.primaryScreen(), frame = hs.geometry.rect(0.33, 0, 0.67, 1) },
        },
    }
end

local desktopLayout = init_desktop_layout()

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
        logger.d('Leave window "' .. window:title() .. '" (' .. window:id() .. ') stay put.')
        return
    end

    local targetScreen = window:screen()
    if layout.screen then
        targetScreen = layout.screen
    end

    logger.d(
        'Apply layout `'
            .. hs.inspect(layout, { newline = '', indent = ' ' })
            .. '` for window "'
            .. window:title()
            .. '" ('
            .. window:id()
            .. ') on screen "'
            .. targetScreen:getUUID()
            .. '".'
    )

    if moveTypeByWindow[window:id()] == 'manually' then
        logger.d('Window "' .. window:title() .. '" is ignored for being manually resized.')
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
        logger.d('Window "' .. window:title() .. '" is ignored by the "excludeWindows" patterns.')
        return
    end

    if layout.frame then
        window:move(layout.frame, targetScreen, true)
    else
        window:moveToScreen(targetScreen, true)
    end

    if layout.center == true then
        window:centerOnScreen()
    end

    previousScreenByWindow[window:id()] = window:screen():getUUID()

    moveTypeByWindow[window:id()] = 'automatically'

    logger.d('Placed ' .. window:application():name() .. ' (' .. window:title() .. ') to the '
            .. hs.inspect(layout.frame, { newline = '', indent = ' ' })
            .. ' of the ' .. targetScreen:name()
    )
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

local function generate_layout(appConfig, screen, event)
    local layout = hs.fnutils.copy(appConfig)

    layout.fallback = nil
    layout.layouts = nil

    -- Return the pre-defined layout for the current screen.
    if appConfig.layouts then
        for _, screenLayout in ipairs(appConfig.layouts) do
            if
                (screenLayout.screen and screenLayout.screen == screen)
                or (screenLayout.screenUUID and screenLayout.screenUUID == screen:getUUID())
            then
                layout.screen = screen
                layout.frame = screenLayout.frame
                layout.center = screenLayout.center

                logger.d('Hit pre-defined layout on screen ' .. screen:name() .. '.')

                return layout
            end
        end
    end

    if event == hs.window.filter.windowMoved or event == hs.application.watcher.activated then
        -- Return nil when the default screen is not nil and is not the current screen.
        if appConfig.screen and appConfig.screen ~= screen then
            logger.d(
                'The window is activated or moved or resized on the non-default screen '
                    .. screen:name()
                    .. ', return nil for the layout.'
            )
            return nil
        end
    else
        -- Use the fallback configuration when the default screen is nil.
        if not appConfig.screen and appConfig.fallback then
            if appConfig.fallback.screen then
                layout.screen = appConfig.fallback.screen
            end

            if appConfig.fallback.frame then
                layout.frame = appConfig.fallback.frame
            end

            if appConfig.fallback.center then
                layout.center = appConfig.fallback.center
            end

            logger.d('Use the fallback configuration.')
        end
    end

    return layout
end

-- Window watcher

local wf = hs.window.filter.default

wf:subscribe(hs.window.filter.windowCreated, function(window, appName, event)
    if not window:isStandard() or window:isMinimized() then
        return
    end

    logger.d('New window "' .. window:title() .. '" (' .. window:id() .. ') created for ' .. appName)

    previousScreenByWindow[window:id()] = window:screen():getUUID()

    local config = get_app_config(appName)
    if not config then
        return
    end

    apply_layout(window, generate_layout(config, window:screen(), event))

    -- The windowMoved event won't be triggered here.
    moveTypeByWindow[window:id()] = nil
end)

wf:subscribe(hs.window.filter.windowMoved, function(window, appName, event)
    if not window:isStandard() or window:isMinimized() then
        return
    end

    if not moveTypeByWindow[window:id()] then
        moveTypeByWindow[window:id()] = 'manually'
    end

    logger.d(
        'Window '
            .. window:title()
            .. ' ('
            .. window:id()
            .. ') has been moved '
            .. moveTypeByWindow[window:id()]
            .. '.'
    )

    if moveTypeByWindow[window:id()] == 'automatically' then
        moveTypeByWindow[window:id()] = nil
    end

    local prevScreenUUID = previousScreenByWindow[window:id()]
    local newScreenUUID = window:screen():getUUID()

    if newScreenUUID ~= prevScreenUUID then
        -- Apply the corresponding layout when a window is manually moved to another screen.
        moveTypeByWindow[window:id()] = nil

        local config = get_app_config(window:application():name())
        if not config then
            return
        end

        logger.d('Window ' .. window:title() .. ' has been moved to screen: ' .. window:screen():name())

        apply_layout(window, generate_layout(config, window:screen(), event))

        previousScreenByWindow[window:id()] = newScreenUUID
    end
end)

wf:subscribe(hs.window.filter.windowDestroyed, function(window)
    moveTypeByWindow[window:id()] = nil
    previousScreenByWindow[window:id()] = nil
end)

-- Application watcher

desktopLayoutSitter.appWatcher = hs.application.watcher.new(function(appName, eventType, appObject)
    if eventType ~= hs.application.watcher.activated then
        return
    end

    local config = get_app_config(appName)
    if not config then
        return
    end

    wait_for_window_ready(appObject, function()
        local window = appObject:focusedWindow()

        if not window:isStandard() or window:isMinimized() then
            return
        end

        logger.d(
            'The activated event is triggered for app "'
                .. appName
                .. '" window "'
                .. window:title()
                .. '" ('
                .. window:id()
                .. ').'
        )

        previousScreenByWindow[window:id()] = window:screen():getUUID()

        apply_layout(window, generate_layout(config, window:screen(), eventType))
    end)
end)

-- Screen watcher

desktopLayoutSitter.screenWatcher = hs.screen.watcher.new(function()
    desktopLayout = init_desktop_layout()
end)

function desktopLayoutSitter:start()
    self.appWatcher:start()
    self.screenWatcher:start()
end

return desktopLayoutSitter
