-- window management
local alert = require "hs.alert"
local application = require "hs.application"
local fnutils = require "hs.fnutils"
local geometry = require "hs.geometry"
local grid = require "hs.grid"
local hints = require "hs.hints"
local hotkey = require "hs.hotkey"
local layout = require "hs.layout"
local mouse = require "hs.mouse"
local screen = require "hs.screen"
local window = require "hs.window"

-- default 0.2
window.animationDuration = 0

-- left half
hotkey.bind(hyperCtrl, ",", function()
    if window.focusedWindow() then
        window.focusedWindow():moveToUnit(layout.left50)
    else
        alert.show("No active window")
    end
end)

-- right half
hotkey.bind(hyperCtrl, ".", function()
    window.focusedWindow():moveToUnit(layout.right50)
end)

function is_screen_vertical()
    local screen = window.focusedWindow():screen()

    return hs.fnutils.contains({90, 270}, screen:rotate())
end

-- right three quarters
hotkey.bind(hyperCtrl, "L", function()
    if window.focusedWindow() then
        local unit = layout.right75

        if is_screen_vertical() then
            unit = geometry.rect(0, 0, 1, 0.75)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show("No active window")
    end
end)

-- left a quarter
hotkey.bind(hyperCtrl, "R", function()
    if window.focusedWindow() then
        local unit = layout.left25

        if is_screen_vertical() then
            unit = geometry.rect(0, 0.75, 1, 0.25)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show("No active window")
    end
end)

-- right two thirds
hotkey.bind(hyperCtrl, "E", function()
    if window.focusedWindow() then
        local unit = geometry.rect(0.34, 0, 0.66, 1)

        if is_screen_vertical() then
            unit = geometry.rect(0, 0, 1, 0.66)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show("No active window")
    end
end)

-- left a third
hotkey.bind(hyperCtrl, "G", function()
    if window.focusedWindow() then
        local unit = geometry.rect(0, 0, 0.34, 1)

        if is_screen_vertical() then
            unit = geometry.rect(0, 0.66, 1, 0.34)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show("No active window")
    end
end)

-- -- top half
-- hotkey.bind(hyper, "Up", function()
-- window.focusedWindow():moveToUnit'[0,0,100,50]'
-- end)

-- -- bottom half
-- hotkey.bind(hyper, "Down", function()
-- window.focusedWindow():moveToUnit'[0,50,100,100]'
-- end)

-- -- left top quarter
-- hotkey.bind(hyperAlt, "Left", function()
-- window.focusedWindow():moveToUnit'[0,0,50,50]'
-- end)

-- -- right bottom quarter
-- hotkey.bind(hyperAlt, "Right", function()
-- window.focusedWindow():moveToUnit'[50,50,100,100]'
-- end)

-- -- right top quarter
-- hotkey.bind(hyperAlt, "Up", function()
-- window.focusedWindow():moveToUnit'[50,0,100,50]'
-- end)

-- -- left bottom quarter
-- hotkey.bind(hyperAlt, "Down", function()
-- window.focusedWindow():moveToUnit'[0,50,50,100]'
-- end)

-- -- full screen
-- hotkey.bind(hyper, 'F', function() 
-- window.focusedWindow():toggleFullScreen()
-- end)

-- center window
hotkey.bind(hyperCtrl, 'C', function() 
    window.focusedWindow():centerOnScreen()
end)

-- maximize window
hotkey.bind(hyperCtrl, 'Return', function() toggle_maximize() end)

-- defines for window maximize toggler
local frameCache = {}
-- toggle a window between its normal size, and being maximized
function toggle_maximize()
    local win = window.focusedWindow()
    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- display a keyboard hint for switching focus to each window
hotkey.bind(hyperShift, '/', function()
    hints.windowHints()
    -- Display current application window
    -- hints.windowHints(hs.window.focusedWindow():application():allWindows())
end)

-- -- switch active window
-- hotkey.bind(hyperShift, "H", function() window.switcher.nextWindow() end)

-- move active window to previous monitor
hotkey.bind(hyper, "Left", function()
    window.focusedWindow():moveOneScreenWest()
end)

-- move active window to next monitor
hotkey.bind(hyper, "Right", function()
    window.focusedWindow():moveOneScreenEast()
end)

-- move cursor to previous monitor
hotkey.bind(hyperCtrl, "Right", function()
    focusScreen(window.focusedWindow():screen():previous())
end)

-- move cursor to next monitor
hotkey.bind(hyperCtrl, "Left", function()
    focusScreen(window.focusedWindow():screen():next())
end)

-- Predicate that checks if a window belongs to a screen
function isInScreen(screen, win) return win:screen() == screen end

function focusScreen(screen)
    -- Get windows within screen, ordered from front to back.
    -- If no windows exist, bring focus to desktop. Otherwise, set focus on
    -- front-most application window.
    local windows = fnutils.filter(window.orderedWindows(),
                                   fnutils.partial(isInScreen, screen))
    local windowToFocus = #windows > 0 and windows[1] or window.desktop()
    windowToFocus:focus()

    -- move cursor to center of screen
    local pt = geometry.rectMidPoint(screen:fullFrame())
    mouse.absolutePosition(pt)
end

-- -- maximized active window and move to selected monitor
-- moveto = function(win, n)
    -- local screens = screen.allScreens()
    -- if n > #screens then
        -- alert.show("Only " .. #screens .. " monitors ")
    -- else
        -- local toWin = screen.allScreens()[n]:name()
        -- alert.show("Move " .. win:application():name() .. " to " .. toWin)

        -- layout.apply({{nil, win:title(), toWin, layout.maximized, nil, nil}})

    -- end
-- end

-- -- move cursor to monitor 1 and maximize the window
-- hotkey.bind(hyperShift, "1", function()
    -- local win = window.focusedWindow()
    -- moveto(win, 1)
-- end)

-- hotkey.bind(hyperShift, "2", function()
    -- local win = window.focusedWindow()
    -- moveto(win, 2)
-- end)

-- hotkey.bind(hyperShift, "3", function()
    -- local win = window.focusedWindow()
    -- moveto(win, 3)
-- end)
