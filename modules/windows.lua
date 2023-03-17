--
-- Window management
--

local alert = require('hs.alert')
local dk = require('modules/decoration_keys')
local fnutils = require('hs.fnutils')
local geometry = require('hs.geometry')
local hints = require('hs.hints')
local hotkey = require('hs.hotkey')
local layout = require('hs.layout')
local mouse = require('hs.mouse')
local window = require('hs.window')
-- local application = require('hs.application')
-- local grid = require('hs.grid')
-- local screen = require('hs.screen')

-- default 0.2
window.animationDuration = 0

-- Predicate that checks if a window belongs to a screen
local function is_in_screen(screen, win)
    return win:screen() == screen
end

local function focus_screen(screen)
    -- Get windows within screen, ordered from front to back.
    -- If no windows exist, bring focus to desktop. Otherwise, set focus on
    -- front-most application window.
    local windows = fnutils.filter(window.orderedWindows(), fnutils.partial(is_in_screen, screen))
    local windowToFocus = #windows > 0 and windows[1] or window.desktop()
    windowToFocus:focus()

    -- move cursor to center of screen
    local pt = geometry.rectMidPoint(screen:fullFrame())
    mouse.absolutePosition(pt)
end

local function is_screen_vertical()
    local screen = window.focusedWindow():screen()

    return hs.fnutils.contains({ 90, 270 }, screen:rotate())
end

-- defines for window maximize toggler
local frameCache = {}
-- toggle a window between its normal size, and being maximized
local function toggle_maximize()
    local win = window.focusedWindow()
    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
    end
end

-- left half
hotkey.bind(dk.hyperCtrl, ',', function()
    if window.focusedWindow() then
        window.focusedWindow():moveToUnit(layout.left50)
    else
        alert.show('No active window')
    end
end)

-- right half
hotkey.bind(dk.hyperCtrl, '.', function()
    window.focusedWindow():moveToUnit(layout.right50)
end)

-- top half
hotkey.bind(dk.hyperCtrl, "J", function()
window.focusedWindow():moveToUnit'[0,0,100,50]'
end)

-- bottom half
hotkey.bind(dk.hyperCtrl, "K", function()
window.focusedWindow():moveToUnit'[0,50,100,100]'
end)

-- right three quarters
hotkey.bind(dk.hyperCtrl, 'L', function()
    if window.focusedWindow() then
        local unit = layout.right75

        if is_screen_vertical() then
            unit = geometry.rect(0, 0, 1, 0.75)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show('No active window')
    end
end)

-- left a quarter
hotkey.bind(dk.hyperCtrl, 'R', function()
    if window.focusedWindow() then
        local unit = layout.left25

        if is_screen_vertical() then
            unit = geometry.rect(0, 0.75, 1, 0.25)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show('No active window')
    end
end)

-- right two thirds
hotkey.bind(dk.hyperCtrl, 'E', function()
    if window.focusedWindow() then
        local unit = geometry.rect(0.34, 0, 0.66, 1)

        if is_screen_vertical() then
            unit = geometry.rect(0, 0, 1, 0.66)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show('No active window')
    end
end)

-- left a third
hotkey.bind(dk.hyperCtrl, 'G', function()
    if window.focusedWindow() then
        local unit = geometry.rect(0, 0, 0.34, 1)

        if is_screen_vertical() then
            unit = geometry.rect(0, 0.66, 1, 0.34)
        end

        window.focusedWindow():moveToUnit(unit)
    else
        alert.show('No active window')
    end
end)

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
-- hotkey.bind(dk.hyper, 'F', function()
-- window.focusedWindow():toggleFullScreen()
-- end)

-- center window
hotkey.bind(dk.hyperCtrl, 'C', function()
    window.focusedWindow():centerOnScreen()
end)

-- maximize window
hotkey.bind(dk.hyperCtrl, 'Return', function()
    toggle_maximize()
end)

-- display a keyboard hint for switching focus to each window
hotkey.bind(dk.hyperShift, '/', function()
    hints.windowHints()
    -- Display current application window
    -- hints.windowHints(hs.window.focusedWindow():application():allWindows())
end)

-- -- switch active window
-- hotkey.bind(dk.hyperShift, "H", function() window.switcher.nextWindow() end)

-- move active window to previous monitor
hotkey.bind(dk.hyper, 'Left', function()
    window.focusedWindow():moveOneScreenWest()
end)

-- move active window to next monitor
hotkey.bind(dk.hyper, 'Right', function()
    window.focusedWindow():moveOneScreenEast()
end)

-- move cursor to previous monitor
hotkey.bind(dk.hyperCtrl, 'Right', function()
    focus_screen(window.focusedWindow():screen():previous())
end)

-- move cursor to next monitor
hotkey.bind(dk.hyperCtrl, 'Left', function()
    focus_screen(window.focusedWindow():screen():next())
end)

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
-- hotkey.bind(dk.hyperShift, "1", function()
-- local win = window.focusedWindow()
-- moveto(win, 1)
-- end)

-- hotkey.bind(dk.hyperShift, "2", function()
-- local win = window.focusedWindow()
-- moveto(win, 2)
-- end)

-- hotkey.bind(dk.hyperShift, "3", function()
-- local win = window.focusedWindow()
-- moveto(win, 3)
-- end)

hotkey.bind(dk.hyperCtrl, 'X', function()
    if window.focusedWindow() then
        local size = geometry.size(1280, 720)

        window.focusedWindow():setSize(size)
    else
        alert.show('No active window')
    end
end)
