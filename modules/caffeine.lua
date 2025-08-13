---
--- Control whether the screen hibernates when it is idle
---

local commons = require('modules/commons')
local MODULE_NAME = 'caffeine'
commons.logger.registerModule(MODULE_NAME)

local menubar_item = nil

local function initialize_caffeine()
    commons.logger.info(MODULE_NAME, "Initializing with status:", commons.getOption('caffeine', 'off'))
    if commons.getOption('caffeine', 'off') == 'on' and menubar_item == nil then
        menubar_item = hs.menubar.new()
        menubar_item:setTitle('')
        menubar_item:setIcon('~/.hammerspoon/icon/caffeine-on.pdf')
        hs.caffeinate.set('displayIdle', true)
        commons.logger.debug(MODULE_NAME, "Caffeine lock enabled, menubar item created.")
    else
        hs.caffeinate.set('displayIdle', false)
        commons.logger.debug(MODULE_NAME, "Caffeine lock disabled.")
    end
end

local function reset_menubar_item()
    if commons.getOption('caffeine', 'off') == 'on' and menubar_item:isInMenuBar() == false then
        commons.logger.debug(MODULE_NAME, "Menubar item was missing, recreating it.")
        menubar_item:delete()
        menubar_item = hs.menubar.new()
        menubar_item:setTitle('')
        menubar_item:setIcon('~/.hammerspoon/icon/caffeine-on.pdf')
    end
end

initialize_caffeine()

hs.timer.doEvery(1, reset_menubar_item)
