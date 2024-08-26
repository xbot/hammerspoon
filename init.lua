hs.configdir = os.getenv('HOME') .. '/.hammerspoon'
package.path = hs.configdir
    .. '/?.lua;'
    .. hs.configdir
    .. '/?/init.lua;'
    .. hs.configdir
    .. '/Spoons/?.spoon/init.lua;'
    .. package.path

-- Generate annotations for lua-language-server
hs.loadSpoon('EmmyLua')

-- Watch for changes and do automatic reloadings.
hs.loadSpoon('ReloadConfiguration')
spoon.ReloadConfiguration:start()

-- Install CLI commands
hs.ipc.cliInstall()

require('modules/commons')
require('modules/caffeine')
require('modules/json_beautifier')
require('modules/launcher')
require('modules/noizio')
require('modules/omnifocus')
require('modules/system')
require('modules/windows')

local desktopLayoutSitter = require('modules/desktop_layout')
desktopLayoutSitter:start()

local karabinerProfileSwitcher = require('modules/karabiner')
karabinerProfileSwitcher:start()

hs.notify.show("Hammerspoon", "Hammerspoon loaded!", "")
