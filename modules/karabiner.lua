local hotkey = require "hs.hotkey"

hotkey.bind(hyper, "K", function()
    local configFile = os.getenv('HOME') .. '/.config/karabiner/karabiner.json'

    if hs.json.read(configFile) == nil then
        hs.alert.show('配置读取失败！')
        return
    end

    local configs = hs.json.read(configFile)
    local profiles = configs['profiles']
    local selectedIndex = nil

    for i = 1, #profiles do
        if profiles[i]['selected'] == true then
            selectedIndex = i
            break
        end
    end

    local switchToIndex = selectedIndex + 1

    if switchToIndex > #profiles then switchToIndex = 1 end

    profiles[switchToIndex]['selected'] = true
    profiles[selectedIndex]['selected'] = false

    hs.json.write(configs, configFile, true, true)

    hs.alert.show(profiles[switchToIndex]['name'] .. ' activated!')
end)
