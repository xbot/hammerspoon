---
-- Binds hotkeys to launch or focus applications.
---

local commons = require('modules/commons')
local MODULE_NAME = 'launcher'
commons.logger.registerModule(MODULE_NAME)

local appfinder = require('hs.appfinder')
local application = require('hs.application')
local fnutils = require('hs.fnutils')
local grid = require('hs.grid')
local hotkey = require('hs.hotkey')
local window = require('hs.window')
local dk = require('modules/decoration_keys')

hs.application.enableSpotlightForNameSearches(true)

grid.setMargins({ 0, 0 })

-- Toggle an application between being the frontmost app, and being hidden
local function toggle_application(app_names)
    local app = nil
    local app_name = nil

    commons.logger.debug(MODULE_NAME, 'Toggling application:', app_names)

    if type(app_names) == 'table' then
        for i = 1, #app_names do
            app = appfinder.appFromName(app_names[i])
            if app ~= nil then
                app_name = app_names[i]
                commons.logger.debug(MODULE_NAME, 'Found installed app in list:', app_name)
                break
            end
        end

        if not app_name then
            app_name = app_names[1]
            commons.logger.debug(MODULE_NAME, 'No installed app found in list, defaulting to first entry:', app_name)
        end
    elseif type(app_names) == 'string' then
        app = appfinder.appFromName(app_names)
        app_name = app_names
    else
        hs.alert.show('Only string or list is accepted for App names.')
        return
    end

    if not app or not app:mainWindow() then
        commons.logger.debug(MODULE_NAME, 'Launching or focusing', app_name)
        application.launchOrFocus(app_name)
        return
    else
        local mainwin = app:mainWindow()

        if mainwin == window.focusedWindow() then
            commons.logger.debug(MODULE_NAME, 'Hiding', app_name)
            mainwin:application():hide()
        else
            commons.logger.debug(MODULE_NAME, 'Activating', app_name)
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end

local applist = {
    -- { shortcut = '2', appname = 'Google Keep' },
    -- { shortcut = '3', appname = 'TablePlus' },
    -- { shortcut = 'F', appname = 'Firefox' },
    -- { shortcut = 'P', appname = 'PhpStorm' },
    -- { shortcut = 'S', appname = 'Slack' },
    -- { shortcut = 'V', appname = 'Vivaldi' },
    -- { shortcut = 'Z', appname = 'MacVim' },
    { shortcut = '1', appname = 'OmniFocus' },
    { shortcut = '2', appname = 'ChatGPT' },
    { shortcut = '3', appname = 'DeepSeek' },
    { shortcut = '4', appname = 'Grok' },
    { shortcut = '5', appname = 'Gemini' },
    { shortcut = '6', appname = 'Kimi' },
    { shortcut = 'A', appname = 'Arc' },
    { shortcut = 'C', appname = 'Comet' },
    { shortcut = 'D', appname = 'Discord' },
    { shortcut = 'E', appname = 'EuDic' },
    { shortcut = 'G', appname = 'Telegram' },
    { shortcut = 'I', appname = 'Anki' },
    { shortcut = 'J', appname = 'Safari' },
    { shortcut = 'K', appname = 'kitty' },
    { shortcut = 'L', appname = 'Logseq' },
    { shortcut = 'M', appname = { 'Mail', 'Spark' } },
    { shortcut = 'N', appname = 'Notion' },
    { shortcut = 'O', appname = 'Obsidian' },
    { shortcut = 'Q', appname = 'Activity Monitor' },
    { shortcut = 'V', appname = 'Neovide' },
    { shortcut = 'X', appname = 'XiaoHongShu' },
}

local machine_name = hs.host.localizedName()

--[[
   [ Map key B to the default browser.
   ]]
local defaultBrowser = nil

if string.find(machine_name, 'MacBook Air') or string.find(machine_name, 'iMac') then
    defaultBrowser = 'Brave Browser'
else
    defaultBrowser = 'Google Chrome'
end

if defaultBrowser ~= nil then
    table.insert(applist, { shortcut = 'B', appname = defaultBrowser })
end

-- Do mappings.
fnutils.each(applist, function(entry)
    hotkey.bind({ 'alt' }, entry.shortcut, entry.appname, function()
        toggle_application(entry.appname)
    end)
end)
