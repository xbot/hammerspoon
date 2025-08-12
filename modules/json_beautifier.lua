---
-- JSON beautifier
---
local beautifier = {}
local logger = hs.logger.new('json_beautifier', 'debug')

local watcher = nil
local jq_cmd = nil
local last_formatted_json = nil
local pasteboard = require('hs.pasteboard')

local function format_json_in_clipboard(json_string)
    if jq_cmd == nil then
        local status = nil
        jq_cmd, status = hs.execute('which jq', true)
        if status == false then
            logger.e('Failed to find jq.')
            hs.alert('jq command not found. JSON beautifier will not work.')
            return
        end
        jq_cmd = jq_cmd:gsub("[\n\r]", "")
    end

    local cmd = "echo '" .. json_string .. "' | " .. jq_cmd .. ' --indent 4'
    local output, status = hs.execute(cmd)
    if status == false then
        hs.alert(output)
        return
    end

    pasteboard.setContents(output)
    hs.alert(output)
    last_formatted_json = output
end

function beautifier:start()
    if watcher then
        self:stop()
    end

    if GetOption('json_beautifier', 'off') == 'on' then
        logger.i('Starting JSON beautifier watcher.')
        watcher = pasteboard.watcher.new(function(pasteboard_content)
            if pasteboard_content ~= last_formatted_json and hs.json.decode(pasteboard_content) ~= nil then
                format_json_in_clipboard(pasteboard_content)
            end
        end)
        watcher:start()
    else
        logger.i('JSON beautifier is disabled in settings.')
    end
end

function beautifier:stop()
    if watcher then
        logger.i('Stopping JSON beautifier watcher.')
        watcher:stop()
        watcher = nil
    end
end

return beautifier
