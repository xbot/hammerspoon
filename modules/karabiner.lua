local dk = require('modules/decoration_keys')
local hotkey = require('hs.hotkey')
local logger = hs.logger.new('Launcher', 'debug')

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
        logger.e('Failed to get current Karabiner-Elements profile')
        return nil
    end
end

local function switchProfile(profileName)
    local output, status = hs.execute("'" .. karabinerCli .. "' --select-profile '" .. profileName .. "'")
    if status then
        logger.i('Switched Karabiner-Elements profile to "' .. profileName .. '"')
        return true
    else
        logger.e('Failed to switch Karabiner-Elements profile to "' .. profileName .. '"')
        return false
    end
end

karabinerProfileSwitcher.appWatcher = hs.application.watcher.new(function(appName, eventType, app)
    if eventType == hs.application.watcher.activated then
        logger.d('Activated application: "' .. appName .. '"')
        local currentProfile = getCurrentProfile()
        if not currentProfile then return end

        logger.d('Current Karabiner-Elements profile: "' .. currentProfile .. '"')

        local targetProfile = karabinerProfileSwitcher.appProfiles[appName]
        if targetProfile then
            if currentProfile ~= targetProfile then
                karabinerProfileSwitcher.previousProfile = currentProfile
                if switchProfile(targetProfile) then
                    logger.d('Saved previous profile: "' .. currentProfile .. '"')
                end
            end
        elseif karabinerProfileSwitcher.previousProfile and karabinerProfileSwitcher.previousProfile ~= currentProfile then
            if switchProfile(karabinerProfileSwitcher.previousProfile) then
                karabinerProfileSwitcher.previousProfile = nil
                logger.d('Cleared previous profile after switching back')
            end
        end
    end
end)

function karabinerProfileSwitcher:start()
    self.appWatcher:start()
end

function karabinerProfileSwitcher:setAppProfile(appName, profileName)
    self.appProfiles[appName] = profileName
    logger.i('Updated profile mapping: "' .. appName .. '" -> "' .. profileName .. '"')
end

return karabinerProfileSwitcher
