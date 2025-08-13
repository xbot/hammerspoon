---
-- Handles general system-level functions and hotkeys.
---

local commons = require('modules/commons')
local MODULE_NAME = 'system'
commons.logger.registerModule(MODULE_NAME)

local audiodevice = require('hs.audiodevice')
local caffeinate = require('hs.caffeinate')
local dk = require('modules/decoration_keys')
local hotkey = require('hs.hotkey')

-- Bind Hyper+L to lock the screen
hotkey.bind(dk.hyper, 'L', function()
    commons.logger.debug(MODULE_NAME, "Hyper+L pressed, locking screen.")
    caffeinate.lockScreen()
end)

-- Mute system audio when the system wakes from sleep
local function mute_on_wake(event)
    if event == caffeinate.watcher.systemDidWake then
        commons.logger.info(MODULE_NAME, "System woke up, muting audio.")
        local output = audiodevice.defaultOutputDevice()
        output:setMuted(true)
    end
end

-- Create and start the watcher
commons.logger.debug(MODULE_NAME, "Starting caffeine watcher for system events.")
local caffeine_watcher = caffeinate.watcher.new(mute_on_wake)
caffeine_watcher:start()
