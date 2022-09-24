---
--- Create a menubar icon providing utilities and initialize the settings.
---

MenubarItem = nil
Settings = {}

local config_file = '~/.hammerspoon/data/Config.json'
local config_file_template = '~/.hammerspoon/data/initConfig.json'
local jq_cmd = nil
local version = 'v0.1.2'

local function file_exists(path)
    local file = hs.fs.pathToAbsolute(path)
    return file ~= nil
end

local function copy_file(source, destination)
    local sourcefile = io.open(source, 'r')
    local destinationfile = io.open(destination, 'w')
    destinationfile:write(sourcefile:read('*all'))
    sourcefile:close()
    destinationfile:close()
end

local function toggle_caffeine()
    if Settings[1].caffeine == 'on' then
        Settings[1].caffeine = 'off'
    else
        Settings[1].caffeine = 'on'
    end
    hs.json.write(Settings, config_file, true, true)
    hs.reload()
end

local function open_color_picker()
    local color_dialog = hs.dialog.color

    hs.openConsole(true)

    color_dialog.show()
    color_dialog.mode('RGB')
    color_dialog.callback(function(a, b)
        if b then
            hs.closeConsole()
        end
    end)

    hs.closeConsole()
end

local function format_json_in_clipboard()
    local pasteboard = require('hs.pasteboard')
    local pasteboard_content = pasteboard.getContents()

    local decoded_table = hs.json.decode(pasteboard_content)
    if decoded_table == nil then
        hs.alert('No valid JSON string found.')
        return
    end

    if jq_cmd == nil then
        local status = nil
        jq_cmd, status = hs.execute('which jq', true)
        if status == false then
            hs.alert('Failed to find jq.')
            return
        end
        jq_cmd = jq_cmd:gsub("[\n\r]", "")
    end

    local cmd = "echo '" .. pasteboard_content .. "' | " .. jq_cmd .. ' --indent 4'
    local output, status = hs.execute(cmd)
    if status == false then
        hs.alert(output)
        return
    end

    pasteboard.setContents(output)
    hs.alert(output)
end

local function create_menu()
    MenubarItem = hs.menubar.new()
    MenubarItem:setTitle('')
    MenubarItem:setIcon('~/.hammerspoon/icon/input_u.pdf')
    MenubarItem:setMenu({
        {
            title = 'Reload Settings',
            fn = function()
                hs.reload()
            end,
        },
        {
            title = 'Open console',
            fn = function()
                hs.openConsole()
            end,
        },
        {
            title = 'Relaunch',
            fn = function()
                hs.relaunch()
            end,
        },
        { title = '-' },
        {
            title = '屏幕取色',
            fn = function()
                open_color_picker()
            end,
        },
        {
            title = '咖啡因：' .. Settings[1].caffeine,
            fn = function()
                toggle_caffeine()
            end,
        },
        {
            title = '格式化剪贴板 Json',
            fn = function()
                format_json_in_clipboard()
            end,
        },
        { title = '-' },
        {
            title = '关于',
            fn = function()
                if
                    hs.dialog.blockAlert(
                        '当前版本：' .. version,
                        '整理了一些能够提高效率的脚本，打开主页查看详细说明。',
                        '确定',
                        '取消',
                        'informational'
                    ) == '确定'
                then
                    hs.urlevent.openURL('https://github.com/xbot/hammerspoon')
                end
            end,
        },
    })
end

local function run()
    hs.console.clearConsole()

    if file_exists(config_file) == false then
        -- io.open requires absolute file path.
        local source = hs.fs.pathToAbsolute(config_file_template)
        local destination = string.gsub(source, 'initConfig.json$', 'Config.json')
        copy_file(source, destination)
    end

    if hs.json.read(config_file) ~= nil then
        Settings = hs.json.read(config_file)
    end

    create_menu()

    -- Set the global alert style
    hs.alert.defaultStyle.strokeColor = { white = 1, alpha = 0 }
    hs.alert.defaultStyle.fillColor = { white = 0.05, alpha = 0.75 }
    hs.alert.defaultStyle.radius = 10
end

run()
