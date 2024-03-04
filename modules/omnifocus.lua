hs.loadSpoon('SendToOmniFocus')

spoon.SendToOmniFocus:bindHotkeys({
    send_to_omnifocus = { { 'ctrl', 'alt', 'cmd' }, 'O' },
})

spoon.SendToOmniFocus:registerApplication('Arc', {
    as_scriptfile = os.getenv('HOME') .. '/.hammerspoon/templates/add_arc_webpage_to_omnifocus.applescript',
    itemname = 'tab'
})
spoon.SendToOmniFocus:registerApplication('Brave Browser', {
    apptype = 'chromeapp',
    itemname = 'tab',
})
spoon.SendToOmniFocus:registerApplication('Microsoft Edge', {
    apptype = 'chromeapp',
    itemname = 'tab',
})
spoon.SendToOmniFocus:registerApplication('Vivaldi', {
    apptype = 'chromeapp',
    itemname = 'tab',
})

local dk = require('modules/decoration_keys')
local hotkey = require('hs.hotkey')

-- Press ctrl+opt+O to format Jira ticket title
hotkey.bind(dk.hyperCtrl, 'O', function()
    local selectedText = hs.uielement.focusedElement():selectedText()

    if selectedText == nil then
        hs.alert.show('No text selected')
        return
    end

    local formattedText = nil

    if string.match(selectedText, '^Review:%s%[DEV%-%d+%]%s.*%s%-%sJira$') then
        local ticketNumber = string.match(selectedText, '^Review:%s%[(DEV%-%d+)%]%s.*%s%-%sJira$')
        local ticketTitle = string.match(selectedText, '^Review:%s%[DEV%-%d+%]%s(.*)%s%-%sJira$')

        formattedText = ticketNumber .. ' ' .. ticketTitle
    elseif string.match(selectedText, '^Review:%s.*$') then
        formattedText = string.gsub(selectedText, '^Review:%s', '')
    else
        hs.alert.show('Not an expected string, nothing happened.')
        return
    end

    hs.pasteboard.setContents(formattedText)
    hs.eventtap.keyStroke({ 'cmd' }, 'v')
end)

-- Press ctrl+opt+cmd+. to open the quick entry dialog for logging.
hotkey.bind(dk.hyper, '.', function()
    hs.urlevent.openURL('omnifocus:///add?project=Chore&context=Journal&completed=now')
end)

-- Press ctrl+opt+cmd+, to open the quick entry dialog for today's chore.
hotkey.bind(dk.hyper, ',', function()
    hs.urlevent.openURL('omnifocus:///add?project=Chore&context=Today')
end)

-- Press ctrl+opt+cmd+/ to open the quick entry dialog for bucket list.
hotkey.bind(dk.hyper, '/', function()
    hs.urlevent.openURL('omnifocus:///add?project=Wish&context=Shopping,Today')
end)

---
--- Pasteboard watcher
---

-- OmniFocusPasteboardWatcher = nil

-- Interpolate table values into a string
-- From http://lua-users.org/wiki/StringInterpolation
local function interp(s, tab)
   return (s:gsub('($%b{})', function(w) return tab[w:sub(3, -2)] or w end))
end

-- Read a whole file into a string
local function slurp(path)
   local f = assert(io.open(path))
   local s = f:read("*a")
   f:close()
   return s
end

local pasteboard = require('hs.pasteboard')

local function open_omnifocus_edit_dialog(lines)
    local module_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
    local template_file = module_dir .. '../templates/add_webpage_to_omnifocus.tpl'
    local text=slurp(template_file)
    local data = {
        title = lines[2],
        url = lines[3],
    }
    local as_script = interp(text, data)
    hs.osascript.applescript(as_script)
end

if GetOption('watch_omnifocus_sensible_data', 'off') == 'on' then
    OmniFocusPasteboardWatcher = pasteboard.watcher.new(function(pasteboard_content)
        local lines = {}
        for line in string.gmatch(pasteboard_content, "[^\r\n]+") do
            table.insert(lines, line)
        end

        if #lines == 3 and lines[1] == '#omnifocus_sensible' then
            open_omnifocus_edit_dialog(lines)
        end
    end)

    OmniFocusPasteboardWatcher:start()
end
