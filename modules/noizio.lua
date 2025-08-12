---
-- Noizio watcher
-- Kills Noizio if all of the specified earphones are disconnected.
---
local noizio = {}
local logger = hs.logger.new('noizio_watcher', 'debug')

local noizio_bundle_id = 'com.kryolokovlin.Noizio-setapp'
local earphones = { 'Earmuffs', "xbot's AirPods Pro" }

local function kill_noizio_if_needed()
    for _, dev in ipairs(hs.audiodevice.allOutputDevices()) do
        if hs.fnutils.indexOf(earphones, dev:name()) ~= nil then
            logger.i('Earphones connected, Noizio can stay.')
            return -- Found earphones, do nothing.
        end
    end

    -- If we get here, no specified earphones were found.
    local noizio_app = hs.application.find(noizio_bundle_id)
    if noizio_app then
        logger.i('No earphones connected, killing Noizio.')
        noizio_app:kill()
    end
end

local function audio_device_listener(event)
    if event == 'dev#' then
        logger.i('Audio device list changed (dev# event), checking for Noizio.')
        kill_noizio_if_needed()
    end
end

function noizio:start()
    if hs.audiodevice.watcher.isRunning() then
        self:stop()
    end

    logger.i('Starting Noizio watcher.')
    hs.audiodevice.watcher.setCallback(audio_device_listener)
    hs.audiodevice.watcher.start()

    -- Perform an initial check on start
    kill_noizio_if_needed()
end

function noizio:stop()
    if hs.audiodevice.watcher.isRunning() then
        logger.i('Stopping Noizio watcher.')
        hs.audiodevice.watcher.stop()
        hs.audiodevice.watcher.setCallback(nil)
    end
end

return noizio
