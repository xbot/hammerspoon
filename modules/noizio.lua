---
--- Noizio watcher
--- Kills Noizio if all of the specified earphones are disconnected.
--- 
--- Set the following options at the first time:
---   1. noizio_bundle_id
---      Bundle ID of the Noizio APP.
---   2. earphones
---      Device names of your earphones.
---
local noizio_bundle_id = "com.kryolokovlin.Noizio-setapp"
local earphones = {"Earmuffs", "xbot's AirPods Pro"}

local logger = hs.logger.new('Launcher', 'debug')

function audio_device_listener(event)
   if event == "dev#" then
       kill_noizio_for_no_earphones()
   end
end

function kill_noizio_for_no_earphones()
    for i,dev in ipairs(hs.audiodevice.allOutputDevices()) do
        if hs.fnutils.indexOf(earphones, dev:name()) ~= nil then
            return
        end
    end

    local noizio_app = hs.application.find(noizio_bundle_id)

    if noizio_app == nil then
        return
    end

    noizio_app:kill()
end

hs.audiodevice.watcher.setCallback(audio_device_listener)
hs.audiodevice.watcher.start()

kill_noizio_for_no_earphones()
