--
-- Provides various integrations with OmniFocus.
--

local commons = require('modules/commons')
local MODULE_NAME = 'omnifocus'
commons.logger.registerModule(MODULE_NAME)

local omnifocus = {}

local watcher = nil
local hotkeys = {}

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

local function open_omnifocus_edit_dialog(lines)
    commons.logger.debug(MODULE_NAME, "Opening OmniFocus edit dialog.")
    local module_dir = debug.getinfo(1, "S").source:sub(2):match("(.*/)")
    local template_file = module_dir .. '../templates/add_webpage_to_omnifocus.tpl'
    local text = slurp(template_file)
    local data = {
        title = lines[2],
        url = lines[3],
    }
    local as_script = interp(text, data)
    hs.osascript.applescript(as_script)
end

function omnifocus:start()
    commons.logger.info(MODULE_NAME, "Starting OmniFocus module")
    hs.loadSpoon('SendToOmniFocus')

    spoon.SendToOmniFocus:bindHotkeys({
        send_to_omnifocus = { { 'ctrl', 'alt', 'cmd' }, 'O' },
    })
    commons.logger.debug(MODULE_NAME, "Bound SendToOmniFocus hotkey.")

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
    commons.logger.debug(MODULE_NAME, "Registered applications with SendToOmniFocus spoon.")


    local dk = require('modules/decoration_keys')
    local hotkey = require('hs.hotkey')

    -- Press ctrl+opt+O to format Jira ticket title
    hotkeys.jira_format = hotkey.bind(dk.hyperCtrl, 'O', function()
        local selectedText = hs.uielement.focusedElement():selectedText()
        if not selectedText then
            hs.alert.show('No text selected')
            return
        end

        commons.logger.debug(MODULE_NAME, "Jira format hotkey triggered with text:", selectedText)
        local formattedText
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
    hotkeys.log_chore = hotkey.bind(dk.hyper, '.', function()
        commons.logger.debug(MODULE_NAME, "Log chore hotkey triggered.")
        hs.urlevent.openURL('omnifocus:///add?project=Chore&context=Journal&completed=now')
    end)

    -- Press ctrl+opt+cmd+, to open the quick entry dialog for today's chore.
    hotkeys.today_chore = hotkey.bind(dk.hyper, ',', function()
        commons.logger.debug(MODULE_NAME, "Today chore hotkey triggered.")
        hs.urlevent.openURL('omnifocus:///add?project=Chore&context=Today')
    end)

    -- Press ctrl+opt+cmd+/ to open the quick entry dialog for bucket list.
    hotkeys.bucket_list = hotkey.bind(dk.hyper, '/', function()
        commons.logger.debug(MODULE_NAME, "Bucket list hotkey triggered.")
        hs.urlevent.openURL('omnifocus:///add?project=Bucket%20List&context=Shopping,Today')
    end)

    -- Start pasteboard watcher if enabled
    if commons.getOption('watch_omnifocus_sensible_data', 'off') == 'on' then
        commons.logger.info(MODULE_NAME, "Starting OmniFocus pasteboard watcher.")
        local pasteboard = require('hs.pasteboard')
        watcher = pasteboard.watcher.new(function(pasteboard_content) 
            if type(pasteboard_content) ~= "string" then
                return -- Not a string, do nothing
            end
            local lines = {}
            for line in string.gmatch(pasteboard_content, "[^\r\n]+") do
                table.insert(lines, line)
            end

            if #lines == 3 and lines[1] == '#omnifocus_sensible' then
                commons.logger.debug(MODULE_NAME, "OmniFocus sensible data detected in pasteboard.")
                open_omnifocus_edit_dialog(lines)
            end
        end)
        watcher:start()
    else
        commons.logger.info(MODULE_NAME, "OmniFocus pasteboard watcher is disabled in settings.")
    end
end

function omnifocus:stop()
    commons.logger.info(MODULE_NAME, "Stopping OmniFocus module")
    if watcher then
        watcher:stop()
        watcher = nil
    end
    for _, hk in pairs(hotkeys) do
        hk:disable()
    end
    hotkeys = {}
end

return omnifocus
