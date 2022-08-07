local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

hs.application.enableSpotlightForNameSearches(true)

local logger = hs.logger.new('Launcher', 'debug')

grid.setMargins({0, 0})

applist = {
    {shortcut = '1', appname = 'OmniFocus'},
    {shortcut = '2', appname = 'flomo'},
    {shortcut = 'A', appname = 'Sequel Ace'},
    {shortcut = 'C', appname = 'Visual Studio Code'},
    {shortcut = 'D', appname = 'Dash'},
    {shortcut = 'E', appname = 'EuDic'},
    {shortcut = 'F', appname = 'Firefox'},
    {shortcut = 'G', appname = 'Telegram'},
    {shortcut = 'I', appname = 'Anki'},
    {shortcut = 'J', appname = 'Safari'},
    {shortcut = 'K', appname = 'kitty'},
    {shortcut = 'L', appname = 'Logseq'},
    {shortcut = 'M', appname = 'Spark'},
    {shortcut = 'N', appname = 'Notion'},
    {shortcut = 'O', appname = 'Microsoft Outlook'},
    {shortcut = 'P', appname = 'PhpStorm'},
    {shortcut = 'Q', appname = 'Activity Monitor'},
    {shortcut = 'S', appname = 'Slack'},
    {shortcut = 'V', appname = 'Vivaldi'},
    {shortcut = 'W', appname = 'Workflowy'},
    {shortcut = 'Z', appname = 'MacVim'}
}

local hostnames = hs.host.names()

--[[
   [ Map key B to the default browser.
   ]]
local defaultBrowser = nil

for i = 1, #hostnames do
    if string.find(string.lower(hostnames[i]), 'imac') ~= nil then
        defaultBrowser = 'Google Chrome'
        break
    elseif string.find(string.lower(hostnames[i]), 'mbp') ~= nil then
        defaultBrowser = 'Brave Browser'
        break
    elseif string.find(string.lower(hostnames[i]), 'air') ~= nil then
        defaultBrowser = 'Brave Browser'
        break
    end
end

if defaultBrowser ~= nil then
    table.insert(applist, {shortcut = 'B', appname = defaultBrowser})
end

--[[
   [ Map key T to the default twitter client.
   ]]
local defaultTwitterClient = nil

for i = 1, #hostnames do
    if string.find(string.lower(hostnames[i]), 'imac') ~= nil then
        defaultTwitterClient = 'Twitter'
        break
    elseif string.find(string.lower(hostnames[i]), 'mbp') ~= nil then
        defaultTwitterClient = 'Tweetbot'
        break
    elseif string.find(string.lower(hostnames[i]), 'air') ~= nil then
        defaultTwitterClient = 'Twitter'
        break
    end
end

if defaultTwitterClient ~= nil then
    table.insert(applist, {shortcut = 'T', appname = defaultTwitterClient})
end

-- Do mappings.
fnutils.each(applist, function(entry)
    hotkey.bind({'alt'}, entry.shortcut, entry.appname, function()
        -- application.launchOrFocus(entry.appname)
        toggle_application(entry.appname)
    end)
end)

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(app_name)
    local app = appfinder.appFromName(app_name)

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
