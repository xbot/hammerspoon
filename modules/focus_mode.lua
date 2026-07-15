---
-- Focus mode watcher
-- Synchronizes the system appearance and Night Shift with the specified Focus mode.
---

local focusMode = {}
local commons = require('modules/commons')
local MODULE_NAME = 'focus_mode'
commons.logger.registerModule(MODULE_NAME)

-- --- Configuration ---
local targetFocusModeName = '夜间'
local nightlightExecutablePath = '/opt/homebrew/bin/nightlight'

local focusDatabasePath = os.getenv('HOME') .. '/Library/DoNotDisturb/DB'
local assertionsPath = focusDatabasePath .. '/Assertions.json'
local configurationsPath = focusDatabasePath .. '/ModeConfigurations.json'

local watcher
local debounceTimer
local lastNightModeEnabled

local function getDataStore(document)
    if type(document) ~= 'table' or type(document.data) ~= 'table' then
        return nil
    end

    local firstEntry = document.data[1]
    if type(firstEntry) ~= 'table' then
        return nil
    end

    return firstEntry
end

local function getActiveModeIdentifier(assertions)
    local dataStore = getDataStore(assertions)
    if not dataStore then
        return nil
    end

    local records = dataStore.storeAssertionRecords
    if type(records) ~= 'table' then
        return nil
    end

    local latestRecord
    local latestTimestamp = -math.huge

    for _, record in pairs(records) do
        if type(record) == 'table' then
            local timestamp = tonumber(record.assertionStartDateTimestamp) or 0
            if not latestRecord or timestamp > latestTimestamp then
                latestRecord = record
                latestTimestamp = timestamp
            end
        end
    end

    if not latestRecord or type(latestRecord.assertionDetails) ~= 'table' then
        return nil
    end

    return latestRecord.assertionDetails.assertionDetailsModeIdentifier
end

local function getModeName(configurations, modeIdentifier)
    if not modeIdentifier then
        return nil
    end

    local dataStore = getDataStore(configurations)
    if not dataStore or type(dataStore.modeConfigurations) ~= 'table' then
        return nil
    end

    for key, configuration in pairs(dataStore.modeConfigurations) do
        if type(configuration) == 'table' and type(configuration.mode) == 'table' then
            local configuredIdentifier = configuration.mode.modeIdentifier
            if key == modeIdentifier or configuredIdentifier == modeIdentifier then
                return configuration.mode.name
            end
        end
    end

    return nil
end

local function setSystemAppearance(isDark)
    local script = string.format([[
        tell application "System Events"
            tell appearance preferences
                set dark mode to %s
            end tell
        end tell
    ]], tostring(isDark))

    local ok = hs.applescript(script)
    if ok then
        commons.logger.info(MODULE_NAME, 'Switched system appearance to ' .. (isDark and 'dark' or 'light') .. ' mode.')
    else
        commons.logger.error(MODULE_NAME, 'Failed to switch system appearance.')
    end
end

local function setNightShift(enabled)
    hs.task.new(nightlightExecutablePath, function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            commons.logger.info(MODULE_NAME, 'Turned Night Shift ' .. (enabled and 'on.' or 'off.'))
        else
            commons.logger.error(MODULE_NAME, 'Failed to change Night Shift: ' .. (stdErr or stdOut or 'Unknown error'))
        end
    end, { enabled and 'on' or 'off' }):start()
end

local function synchronizeWithFocusMode()
    local assertions = hs.json.read(assertionsPath)
    local configurations = hs.json.read(configurationsPath)

    if not assertions or not configurations then
        commons.logger.error(MODULE_NAME, 'Failed to read Focus mode data. Make sure Hammerspoon has Full Disk Access.')
        return
    end

    local activeModeIdentifier = getActiveModeIdentifier(assertions)
    local activeModeName = getModeName(configurations, activeModeIdentifier)
    local nightModeEnabled = activeModeName == targetFocusModeName

    commons.logger.debug(MODULE_NAME, 'Active Focus mode: ' .. (activeModeName or 'none'))

    if lastNightModeEnabled == nightModeEnabled then
        return
    end

    lastNightModeEnabled = nightModeEnabled
    commons.logger.info(MODULE_NAME, targetFocusModeName .. (nightModeEnabled and ' enabled.' or ' disabled.'))
    setSystemAppearance(nightModeEnabled)
    setNightShift(nightModeEnabled)
end

local function scheduleSynchronization()
    if debounceTimer then
        debounceTimer:stop()
    end

    debounceTimer = hs.timer.doAfter(0.5, function()
        debounceTimer = nil
        synchronizeWithFocusMode()
    end)
end

function focusMode:start()
    self:stop()

    commons.logger.info(MODULE_NAME, 'Starting Focus mode watcher.')
    watcher = hs.pathwatcher.new(focusDatabasePath, scheduleSynchronization)
    watcher:start()

    -- Perform an initial check on start
    synchronizeWithFocusMode()
end

function focusMode:stop()
    if watcher then
        commons.logger.info(MODULE_NAME, 'Stopping Focus mode watcher.')
        watcher:stop()
        watcher = nil
    end

    if debounceTimer then
        debounceTimer:stop()
        debounceTimer = nil
    end
end

return focusMode
