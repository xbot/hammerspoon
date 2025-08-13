---
-- Switches Karabiner-Elements profiles automatically based on the active application.
---

local commons = require('modules/commons')
local hotkey = require('hs.hotkey')
local dk = require('modules/decoration_keys')
local MODULE_NAME = 'karabiner'
commons.logger.registerModule(MODULE_NAME)

hotkey.bind(dk.hyper, 'K', function()
    local configFile = os.getenv('HOME') .. '/.config/karabiner/karabiner.json'

    if hs.json.read(configFile) == nil then
        hs.alert.show('Failed to read config file!')
        return
    end

    local configs = hs.json.read(configFile)
    local profiles = configs['profiles']
    local selectedIndex = nil

    for i = 1, #profiles do
        if profiles[i]['selected'] == true then
            selectedIndex = i
            break
        end
    end

    local switchToIndex = selectedIndex + 1

    if switchToIndex > #profiles then
        switchToIndex = 1
    end

    profiles[switchToIndex]['selected'] = true
    profiles[selectedIndex]['selected'] = false

    hs.json.write(configs, configFile, true, true)

    hs.alert.show(profiles[switchToIndex]['name'] .. ' activated!')
end)

-- Karabiner-Elements profile switcher
local karabinerCli = '/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_cli'
local karabinerProfileSwitcher = {}
karabinerProfileSwitcher.previousProfile = nil

karabinerProfileSwitcher.appProfiles = {
    ["game.exe"] = "PC Keyboard",
}

local function getCurrentProfile()
    local output, status = hs.execute("'" .. karabinerCli .. "' --show-current-profile-name")
    if status then
        return spoon.EmmyLua.trim(output)
    else
        commons.logger.error(MODULE_NAME, 'Failed to get current Karabiner-Elements profile')
        return nil
    end
end

local function switchProfile(profileName)
    local output, status = hs.execute("'" .. karabinerCli .. "' --select-profile '" .. profileName .. "'")
    if status then
        commons.logger.info(MODULE_NAME, 'Switched Karabiner-Elements profile to "' .. profileName .. '"')
        return true
    else
        commons.logger.error(MODULE_NAME, 'Failed to switch Karabiner-Elements profile to "' .. profileName .. '"')
        return false
    end
end

karabinerProfileSwitcher.appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.activated then
        commons.logger.debug(MODULE_NAME, 'Activated application: "' .. appName .. '"')
        local currentProfile = getCurrentProfile()
        if not currentProfile then return end

        commons.logger.debug(MODULE_NAME, 'Current Karabiner-Elements profile: "' .. currentProfile .. '"')

        local targetProfile = karabinerProfileSwitcher.appProfiles[appName]
        if targetProfile then
            if currentProfile ~= targetProfile then
                karabinerProfileSwitcher.previousProfile = currentProfile
                if switchProfile(targetProfile) then
                    commons.logger.debug(MODULE_NAME, 'Saved previous profile: "' .. currentProfile .. '"')
                end
            end
        elseif karabinerProfileSwitcher.previousProfile and karabinerProfileSwitcher.previousProfile ~= currentProfile then
            if switchProfile(karabinerProfileSwitcher.previousProfile) then
                karabinerProfileSwitcher.previousProfile = nil
                commons.logger.debug(MODULE_NAME, 'Cleared previous profile after switching back')
            end
        end
    end
end)

function karabinerProfileSwitcher:start()
    self.appWatcher:start()
end

function karabinerProfileSwitcher:setAppProfile(appName, profileName)
    self.appProfiles[appName] = profileName
    commons.logger.info(MODULE_NAME, 'Updated profile mapping: "' .. appName .. '" -> "' .. profileName .. '"')
end

return karabinerProfileSwitcher
