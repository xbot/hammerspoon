--
-- Desktop layout
--
local commons = require('modules/commons')
local MODULE_NAME = 'desktop_layout'
commons.logger.registerModule(MODULE_NAME)

-- Move type constants for windows
local MOVE_TYPE_MANUALLY      = 'manually'
local MOVE_TYPE_AUTOMATICALLY = 'automatically'
local MOVE_TYPE_IGNORED       = 'ignored'

local desktopLayoutSitter = {}

local previousScreenByWindow = {}
local moveTypeByWindow = {}

-- Initiate previousScreenByWindow and moveTypeByWindow on startup.
-- Windows that already exist at startup are marked as 'ignored' so that
-- the layout rules are not applied to them automatically.
for _, app in ipairs(hs.application.runningApplications()) do
    for _, window in ipairs(app:allWindows()) do
        if window:isStandard() and not window:isMinimized() then
            previousScreenByWindow[window:id()] = window:screen():getUUID()
            moveTypeByWindow[window:id()] = MOVE_TYPE_IGNORED
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
                -- { screen = get_secondary_screen(), frame = hs.geometry.rect(0, 0, 1, 0.5) },
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
        commons.logger.debug(MODULE_NAME, 'Leave window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. window:id() .. ') stay put.')
        return
    end

    local windowId = window:id()
    local moveType = moveTypeByWindow[windowId]

    if moveType == MOVE_TYPE_MANUALLY or moveType == MOVE_TYPE_IGNORED then
        commons.logger.debug(MODULE_NAME, 'Skipping layout for window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. windowId .. ') as it was ' .. (moveType == MOVE_TYPE_IGNORED and 'pre-existing' or 'previously placed manually') .. '.')
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
        commons.logger.debug(MODULE_NAME, 'Window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. window:id() .. ') is ignored by the "excludeWindows" patterns.')
        return
    end

    -- A layout is needed if the window's current state violates any of the defined constraints (screen, center, frame).
    -- Each constraint is checked independently below.
    local needsLayout = false
    local winFrame = window:frame()
    local targetScreen = layout.screen or window:screen()

    -- Check screen constraint
    if layout.screen and window:screen() ~= layout.screen then
        needsLayout = true
    end

    -- Check center constraint
    if layout.center then
        -- For centered layouts, we calculate the ideal centered frame based on the target size
        -- (derived from layout.frame or the window's current size) and compare it to the actual frame.
        local screen = targetScreen:fullFrame()
        local targetSize

        if layout.frame then
            local targetRect = screen * layout.frame
            targetSize = hs.geometry.size(targetRect.w, targetRect.h)
        else
            targetSize = hs.geometry.size(winFrame.w, winFrame.h)
        end

        local targetFrame = hs.geometry.rect(
            screen.x + (screen.w - targetSize.w) / 2,
            screen.y + (screen.h - targetSize.h) / 2,
            targetSize.w,
            targetSize.h
        )

        if not hs.geometry.equals(hs.geometry.floor(winFrame), hs.geometry.floor(targetFrame)) then
            needsLayout = true
        end
    end

    -- Check frame constraint (only if not centered, as center takes precedence for positioning)
    if not layout.center and layout.frame then
        local screenFrame = targetScreen:frame()
        local targetFrame = screenFrame * layout.frame
        -- Use floor to truncate fractional pixels, matching system behavior
        if not hs.geometry.equals(hs.geometry.floor(winFrame), hs.geometry.floor(targetFrame)) then
            needsLayout = true
        end
    end

    if not needsLayout then
        commons.logger.debug(MODULE_NAME, 'Window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. window:id() .. ') is already in the correct layout. Ignoring.')
        return
    end

    commons.logger.debug(MODULE_NAME,
        'Apply layout for window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. window:id() .. ') on screen "' .. targetScreen:getUUID() .. '": `' .. hs.inspect(layout, { newline = '', indent = ' ' }) .. '` .'
    )

    moveTypeByWindow[window:id()] = 'automatically'

    if layout.frame then
        window:move(layout.frame, targetScreen, true)
    else
        window:moveToScreen(targetScreen, true)
    end

    if layout.center == true then
        window:centerOnScreen()
    end

    previousScreenByWindow[window:id()] = window:screen():getUUID()

    commons.logger.debug(MODULE_NAME, 'Placed ' .. window:application():name() .. ' (' .. window:title() .. ') to the '
            .. hs.inspect(layout.frame, { newline = '', indent = ' ' })
            .. ' of the ' .. targetScreen:name()
    )
end

local layoutTimers = {}

local function apply_layout_debounced(window, layout)
    local windowId = window:id()
    if layoutTimers[windowId] then
        layoutTimers[windowId]:stop()
    end

    layoutTimers[windowId] = hs.timer.doAfter(0.2, function()
        apply_layout(window, layout)
        layoutTimers[windowId] = nil
    end)
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

                commons.logger.debug(MODULE_NAME, 'Hit pre-defined layout on screen ' .. screen:name() .. '.')

                return layout
            end
        end
    end

    if event == hs.window.filter.windowMoved or event == hs.application.watcher.activated then
        -- Return nil when the default screen is not nil and is not the current screen.
        if appConfig.screen and appConfig.screen ~= screen then
            commons.logger.debug(MODULE_NAME,
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

            commons.logger.debug(MODULE_NAME, 'Use the fallback configuration.')
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

    commons.logger.debug(MODULE_NAME, 'New window "' .. appName .. ' - ' .. window:title() .. '" (' .. window:id() .. ') created')

    previousScreenByWindow[window:id()] = window:screen():getUUID()

    local config = get_app_config(appName)
    if not config then
        return
    end

    apply_layout_debounced(window, generate_layout(config, window:screen(), event))
end)

wf:subscribe(hs.window.filter.windowMoved, function(window, appName, event)
    if not window:isStandard() or window:isMinimized() then
        return
    end

    local windowId = window:id()
    local currentMoveType = moveTypeByWindow[windowId]

    -- Determine the new move type based on the previous state
    if currentMoveType == MOVE_TYPE_AUTOMATICALLY then
        -- If the window was moved automatically by the script, clear the flag.
        moveTypeByWindow[windowId] = nil
    else
        -- If the window's move type is 'manually', 'ignored', or nil,
        -- it means it was moved by the user. Update the state to 'manually'.
        moveTypeByWindow[windowId] = MOVE_TYPE_MANUALLY
    end

    -- Log the state change
    commons.logger.debug(MODULE_NAME,
        'Window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. windowId .. ') has been moved. Previous state: ' .. (currentMoveType or 'nil') .. ', New state: ' .. (moveTypeByWindow[windowId] or 'nil')
    )

    local prevScreenUUID = previousScreenByWindow[windowId]
    local newScreenUUID = window:screen():getUUID()

    -- Apply the corresponding layout when a window is manually moved to another screen.
    -- This also applies if an 'ignored' window is moved.
    if newScreenUUID ~= prevScreenUUID then
        -- Clear the move type as it's now being actively managed again.
        moveTypeByWindow[windowId] = nil

        local config = get_app_config(window:application():name())
        if not config then
            return
        end

        commons.logger.debug(MODULE_NAME, 'Window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. windowId .. ') has been moved to screen: ' .. window:screen():name())

        apply_layout(window, generate_layout(config, window:screen(), event))

        previousScreenByWindow[windowId] = newScreenUUID
    end
end)

wf:subscribe(hs.window.filter.windowDestroyed, function(window)
    commons.logger.debug(MODULE_NAME, 'Window "' .. window:application():name() .. ' - ' .. window:title() .. '" (' .. window:id() .. ') has been destroyed.')
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

        commons.logger.debug(MODULE_NAME,
            'The activated event is triggered for app "' .. appName .. '" window "' .. window:title() .. '" (' .. window:id() .. ').'
        )

        previousScreenByWindow[window:id()] = window:screen():getUUID()

        apply_layout_debounced(window, generate_layout(config, window:screen(), eventType))
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