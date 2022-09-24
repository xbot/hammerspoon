---
--- JSON beautifier
---

PBWatcher = nil

local jq_cmd = nil
local last_formatted_json = nil
local pasteboard = require('hs.pasteboard')

local function format_json_in_clipboard(json_string)
    if jq_cmd == nil then
        local status = nil
        jq_cmd, status = hs.execute('which jq', true)
        if status == false then
            hs.alert('Failed to find jq.')
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

if GetOption('json_beautifier', 'off') == 'on' then
    PBWatcher = pasteboard.watcher.new(function(pasteboard_content)
        if pasteboard_content ~= last_formatted_json and hs.json.decode(pasteboard_content) ~= nil then
            format_json_in_clipboard(pasteboard_content)
        end
    end)

    PBWatcher:start()
end
