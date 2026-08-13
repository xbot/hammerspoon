hs.configdir = os.getenv('HOME') .. '/.hammerspoon'
package.path = hs.configdir
    .. '/?.lua;'
    .. hs.configdir
    .. '/?/init.lua;'
    .. hs.configdir
    .. '/Spoons/?.spoon/init.lua;'
    .. package.path

hs.console.consoleFont({ name = 'Menlo', size = 14 })

-- Generate annotations for lua-language-server
hs.loadSpoon('EmmyLua')

-- -- Watch for changes and do automatic reloadings.
-- hs.loadSpoon('ReloadConfiguration')
-- spoon.ReloadConfiguration:start()

-- Install CLI commands
hs.ipc.cliInstall()

-- Load and start the commons module first as others depend on it
local commons = require('modules/commons')
commons:start()

require('modules/caffeine')
require('modules/launcher')
require('modules/system')
require('modules/windows')

-- Load API-based modules and start them
local jsonBeautifier = require('modules/json_beautifier')
jsonBeautifier:start()

local omnifocus = require('modules/omnifocus')
omnifocus:start()

local noizioWatcher = require('modules/noizio')
noizioWatcher:start()

local appearanceManager = require('modules/appearance_manager')
appearanceManager:start()

local focusModeWatcher = require('modules/focus_mode')
focusModeWatcher:start()

local desktopLayoutSitter = require('modules/desktop_layout')
desktopLayoutSitter:start()

local karabinerProfileSwitcher = require('modules/karabiner')
karabinerProfileSwitcher:start()

hs.notify.show('Hammerspoon', 'Hammerspoon loaded!', '')
