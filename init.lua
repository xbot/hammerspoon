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
require('modules/system')
require('modules/windows')
require('modules/launcher')
require('modules/caffeine')
require('modules/karabiner')
require('modules/omnifocus')
require('modules/noizio')

-- require('modules/snippet')
