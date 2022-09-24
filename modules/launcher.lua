local appfinder = require('hs.appfinder')
local application = require('hs.application')
local fnutils = require('hs.fnutils')
local grid = require('hs.grid')
local hotkey = require('hs.hotkey')
local window = require('hs.window')

hs.application.enableSpotlightForNameSearches(true)

local logger = hs.logger.new('Launcher', 'debug')

grid.setMargins({ 0, 0 })

-- Toggle an application between being the frontmost app, and being hidden
local function toggle_application(app_names)
    local app = nil
    local app_name = nil

    if type(app_names) == 'table' then
        for i = 1, #app_names do
            app = appfinder.appFromName(app_names[i])
            if app ~= nil then
                app_name = app_names[i]
                break
            end
        end

        if not app_name then
            app_name = app_names[1]
        end
    elseif type(app_names) == 'string' then
        app = appfinder.appFromName(app_names)
        app_name = app_names
    else
        hs.alert.show('Only string or list is accepted for App names.')
        return
    end

    if not app or not app:mainWindow() then
        application.launchOrFocus(app_name)
        return
    else
        local mainwin = app:mainWindow()

        if mainwin == window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end

local applist = {
    { shortcut = '1', appname = 'OmniFocus' },
    { shortcut = '2', appname = 'Google Keep' },
    { shortcut = '3', appname = 'Sequel Ace' },
    { shortcut = 'A', appname = 'Arc' },
    { shortcut = 'C', appname = 'Visual Studio Code' },
    { shortcut = 'D', appname = 'Dash' },
    { shortcut = 'E', appname = 'EuDic' },
    { shortcut = 'F', appname = 'Firefox' },
    { shortcut = 'G', appname = 'Telegram' },
    { shortcut = 'I', appname = 'Anki' },
    { shortcut = 'J', appname = 'Safari' },
    { shortcut = 'K', appname = 'kitty' },
    { shortcut = 'L', appname = 'Logseq' },
    { shortcut = 'M', appname = { 'Mail', 'Spark' } },
    { shortcut = 'N', appname = 'Notion' },
    { shortcut = 'O', appname = 'Microsoft Outlook' },
    { shortcut = 'P', appname = 'PhpStorm' },
    { shortcut = 'Q', appname = 'Activity Monitor' },
    { shortcut = 'S', appname = 'Slack' },
    { shortcut = 'V', appname = 'Vivaldi' },
    { shortcut = 'W', appname = 'Workflowy' },
    { shortcut = 'Z', appname = 'MacVim' },
}

local machine_name = hs.host.localizedName()

--[[
   [ Map key B to the default browser.
   ]]
local defaultBrowser = nil

if machine_name == 'MacBook Air' then
    defaultBrowser = 'Brave Browser'
else
    defaultBrowser = 'Google Chrome'
end

if defaultBrowser ~= nil then
    table.insert(applist, { shortcut = 'B', appname = defaultBrowser })
end

--[[
   [ Map key T to the default twitter client.
   ]]
local defaultTwitterClient = nil

if machine_name == 'MacBook Air' then
    defaultTwitterClient = 'Tweetbot'
else
    defaultTwitterClient = 'Tweetbot'
end

if defaultTwitterClient ~= nil then
    table.insert(applist, { shortcut = 'T', appname = defaultTwitterClient })
end

-- Do mappings.
fnutils.each(applist, function(entry)
    hotkey.bind({ 'alt' }, entry.shortcut, entry.appname, function()
        -- application.launchOrFocus(entry.appname)
        toggle_application(entry.appname)
    end)
end)
