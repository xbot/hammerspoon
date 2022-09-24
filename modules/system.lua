local audiodevice = require('hs.audiodevice')
local caffeinate = require('hs.caffeinate')
local dk = require('modules/decoration_keys')
local hotkey = require('hs.hotkey')

hotkey.bind(dk.hyper, 'L', function()
    caffeinate.lockScreen()
    -- caffeinate.startScreensaver()
end)

local function mute_on_wake(event)
    if event == caffeinate.watcher.systemDidWake then
        local output = audiodevice.defaultOutputDevice()
        output:setMuted(true)
    end
end

local caffeine_watcher = caffeinate.watcher.new(mute_on_wake)
caffeine_watcher:start()
