---
-- JSON beautifier
---
local commons = require('modules/commons')
local MODULE_NAME = 'json_beautifier'
commons.logger.registerModule(MODULE_NAME)

local beautifier = {}

local watcher = nil
local jq_cmd = nil
local last_formatted_json = nil
local pasteboard = require('hs.pasteboard')

local function format_json_in_clipboard(json_string)
    if jq_cmd == nil then
        local status = nil
        -- Try to find the jq command
        jq_cmd, status = hs.execute('which jq', true)
        if status == false then
            commons.logger.error(MODULE_NAME, 'Failed to find jq command.')
            hs.alert('jq command not found. JSON beautifier will not work.')
            return
        end
        jq_cmd = jq_cmd:gsub("[\n\r]", "")
        commons.logger.debug(MODULE_NAME, "Found jq command at:", jq_cmd)
    end

    local cmd = "echo '" .. json_string .. "' | " .. jq_cmd .. ' --indent 4'
    commons.logger.debug(MODULE_NAME, "Executing format command:", cmd)
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

    if commons.getOption('json_beautifier', 'off') == 'on' then
        commons.logger.info(MODULE_NAME, 'Starting JSON beautifier watcher.')
        watcher = pasteboard.watcher.new(function(pasteboard_content)
            if pasteboard_content ~= last_formatted_json and hs.json.decode(pasteboard_content) ~= nil then
                commons.logger.debug(MODULE_NAME, "New JSON detected in clipboard, formatting.")
                format_json_in_clipboard(pasteboard_content)
            end
        end)
        watcher:start()
    else
        commons.logger.info(MODULE_NAME, 'JSON beautifier is disabled in settings.')
    end
end

function beautifier:stop()
    if watcher then
        commons.logger.info(MODULE_NAME, 'Stopping JSON beautifier watcher.')
        watcher:stop()
        watcher = nil
    end
end

return beautifier
