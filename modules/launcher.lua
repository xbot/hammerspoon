local hotkey = require "hs.hotkey"
local grid = require "hs.grid"
local window = require "hs.window"
local application = require "hs.application"
local appfinder = require "hs.appfinder"
local fnutils = require "hs.fnutils"

grid.setMargins({0, 0})

applist = {
    {shortcut = '1',appname = 'OmniFocus'},
    {shortcut = '2',appname = 'flomo'},
    {shortcut = 'A',appname = 'Sequel Ace'},
    {shortcut = 'B',appname = 'Brave Browser'},
    {shortcut = 'C',appname = 'Visual Studio Code'},
    {shortcut = 'D',appname = 'Dash'},
    {shortcut = 'E',appname = 'EuDic'},
    {shortcut = 'F',appname = 'Firefox'},
    {shortcut = 'G',appname = 'Google Chrome'},
    {shortcut = 'L',appname = 'Telegram'},
    {shortcut = 'M',appname = 'Mail'},
    {shortcut = 'N',appname = 'Notion'},
    {shortcut = 'O',appname = 'Microsoft Outlook'},
    {shortcut = 'P',appname = 'PhpStorm'},
    {shortcut = 'Q',appname = 'Activity Monitor'},
    {shortcut = 'S',appname = 'Slack'},
    {shortcut = 'T',appname = 'Tweetbot'},
    {shortcut = 'V',appname = 'MacVim'},
    {shortcut = 'W',appname = 'Workflowy'},
}

fnutils.each(applist, function(entry)
    -- hotkey.bind({'ctrl', 'shift'}, entry.shortcut, entry.appname, function()
    hotkey.bind({'alt'}, entry.shortcut, entry.appname, function()
        application.launchOrFocus(entry.appname)
        -- toggle_application(applist[i].appname)
    end)
end)

-- Toggle an application between being the frontmost app, and being hidden
function toggle_application(_app)
    local app = appfinder.appFromName(_app)
    if not app then
        application.launchOrFocus(_app)
        return
    end
    local mainwin = app:mainWindow()
    if mainwin then
        if mainwin == window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end
