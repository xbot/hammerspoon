---
--- Control whether the screen hibernates when it is idle
---

local menubar_item = nil

local function initialize_caffeine()
    if Settings ~= nil and Settings[1].caffeine == 'on' and menubar_item == nil then
        menubar_item = hs.menubar.new()
        menubar_item:setTitle('')
        menubar_item:setIcon('~/.hammerspoon/icon/caffeine-on.pdf')
        hs.caffeinate.set('displayIdle', true)
    else
        hs.caffeinate.set('displayIdle', false)
    end
end

local function reset_menubar_item()
    if Settings ~= nil and Settings[1].caffeine == 'on' and menubar_item:isInMenuBar() == false then
        menubar_item:delete()
        menubar_item = hs.menubar.new()
        menubar_item:setTitle('')
        menubar_item:setIcon('~/.hammerspoon/icon/caffeine-on.pdf')
        --hs.caffeinate.set("displayIdle", true)
    end
end

initialize_caffeine()

-- Check caffeine status, decide whether to reset the menubar item
hs.timer.doEvery(1, reset_menubar_item)
