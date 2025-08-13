---
-- Noizio watcher
-- Kills Noizio if all of the specified earphones are disconnected.
---
local noizio = {}
local commons = require('modules/commons')
local MODULE_NAME = 'noizio'
commons.logger.registerModule(MODULE_NAME)

local noizio_bundle_id = 'com.kryolokovlin.Noizio-setapp'
local earphones = { 'Earmuffs', "xbot's AirPods Pro" }

local function kill_noizio_if_needed()
    for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
        if hs.fnutils.indexOf(earphones, dev:name()) ~= nil then
            commons.logger.info(MODULE_NAME, 'Earphones connected, Noizio can stay.')
            return -- Found earphones, do nothing.
        end
    end

    -- If we get here, no specified earphones were found.
    local noizio_app = hs.application.find(noizio_bundle_id)
    if noizio_app then
        commons.logger.info(MODULE_NAME, 'No earphones connected, killing Noizio.')
        noizio_app:kill()
    end
end

local function audio_device_listener(event)
    if event == 'dev#' then
        commons.logger.info(MODULE_NAME, 'Audio device list changed (dev# event), checking for Noizio.')
        kill_noizio_if_needed()
    end
end

function noizio:start()
    if hs.audiodevice.watcher.isRunning() then
        self:stop()
    end

    commons.logger.info(MODULE_NAME, 'Starting Noizio watcher.')
    hs.audiodevice.watcher.setCallback(audio_device_listener)
    hs.audiodevice.watcher.start()

    -- Perform an initial check on start
    kill_noizio_if_needed()
end

function noizio:stop()
    if hs.audiodevice.watcher.isRunning() then
        commons.logger.info(MODULE_NAME, 'Stopping Noizio watcher.')
        hs.audiodevice.watcher.stop()
        hs.audiodevice.watcher.setCallback(nil)
    end
end

return noizio