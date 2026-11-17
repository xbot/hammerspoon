# PROJECT KNOWLEDGE BASE

**Generated:** 2026-11-17
**Base commit:** 064e27f
**Branch:** docs/init-deep

## OVERVIEW
Personal Hammerspoon (macOS automation) config in plain Lua. `init.lua` sets `package.path`, loads Spoons, then requires and starts 13 modules in dependency order. Every module builds on `modules/commons.lua` for settings, logging, and the menubar.

## STRUCTURE
```
.hammerspoon/
├── init.lua        # package.path -> load EmmyLua -> require/start modules (order matters)
├── modules/        # 13 user modules - see MODULES
├── Spoons/         # 4 third-party Spoons; vendored, NOT tracked by git (.gitignore: /Spoons/*)
├── data/           # initConfig.json template; runtime Config.json is generated + ignored
├── icon/           # PDF icons for menubar items
├── templates/      # AppleScript templates for OmniFocus
└── .stylua.toml    # 120 cols, 4-space indent, single quotes, call_parentheses = "Always"
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add a feature module | modules/ | copy the `json_beautifier.lua` lifecycle template |
| Change hotkeys | launcher / windows / system / karabiner | always bind through `dk.hyper*` |
| Change window layout rules | modules/desktop_layout.lua | rule DSL matched by `screenUUID` |
| Add OmniFocus automation | modules/omnifocus.lua + templates/ | relies on SendToOmniFocus.spoon |
| React to dark/light mode | modules/appearance_manager.lua | `manager.register_handler()` |
| Change settings | data/initConfig.json | copied to Config.json on first run |
| Change log verbosity | modules/commons.lua | `commons.getOption` + `LOG_LEVELS` |

## MODULES
| Module | Lines | Kind | Role |
|--------|-------|------|------|
| commons | 291 | lifecycle | settings, central logger, menubar menu; dependency of every other module |
| decoration_keys | 11 | data table | `hyper` / `hyperShift` / `hyperCtrl` modifier groups |
| caffeine | 38 | side-effect | prevent display sleep, menubar toggle |
| launcher | 123 | side-effect | Alt+letter launch/focus applications |
| system | 33 | side-effect | Hyper+L lock screen, mute on wake |
| windows | 293 | side-effect | window move/resize/hints/focus hotkeys |
| json_beautifier | 70 | lifecycle | pretty-print clipboard JSON via `jq` |
| omnifocus | 157 | lifecycle | OmniFocus integration, loads SendToOmniFocus.spoon |
| noizio | 57 | lifecycle | kill Noizio when known earphones are gone |
| appearance_manager | 279 | lifecycle | dark/light watcher, handler registry, Neovim theme sync |
| focus_mode | 177 | lifecycle | follow macOS Focus mode, toggle appearance + Night Shift |
| desktop_layout | 747 | lifecycle (no :stop) | window layout rule engine |
| karabiner | 109 | lifecycle (no :stop) | switch Karabiner profile by frontmost app |

## SPOONS
| Spoon | Status | Purpose |
|-------|--------|---------|
| EmmyLua | active (init.lua) | generates lua-language-server annotation stubs |
| SendToOmniFocus | active (omnifocus.lua) | send pages/mail to OmniFocus |
| ReloadConfiguration | inactive | only referenced in a commented block |
| DeepLTranslate | inactive | never loaded, dead weight |

Add one: drop `Spoons/Name.spoon/init.lua`, then `hs.loadSpoon('Name')` and use `spoon.Name`.

## CONVENTIONS
- **Language: all conversation and replies must be Simplified Chinese (proper nouns excepted)**
- File names snake_case; each module declares `MODULE_NAME = 'name'` and calls `commons.logger.registerModule(MODULE_NAME)`
- Public API lowerCamelCase methods: `:start()` / `:stop()` / `:setAppProfile()`
- Local helpers snake_case (`toggle_application`, `apply_layout`); constants UPPER_SNAKE_CASE (`LOG_LEVELS`, `MOVE_TYPE_MANUALLY`)
- Settings keys are snake_case strings read via `commons.getOption('key', 'default')`
- Hotkeys: `local dk = require('modules/decoration_keys')` then `hotkey.bind(dk.hyperCtrl, 'X', ...)`
- Logging: `commons.logger.info/debug/error(MODULE_NAME, ...)`; levels error < warn < info < debug < verbose
- Toggle-style settings are written back to Config.json and applied with `hs.reload()`

## ANTI-PATTERNS (THIS PROJECT)
- Side-effect modules (caffeine, launcher, system, windows) run at `require` time with no `:start()`/`:stop()`, so they cannot be unloaded cleanly
- desktop_layout and karabiner have no `:stop()`, leaving watchers/timers dangling
- Spoons are vendored but untracked (`/Spoons/*` in .gitignore): reinstalling or cleaning them loses local edits and they never appear in a commit
- DeepLTranslate.spoon is never loaded; ReloadConfiguration is only referenced in comments
- `.ruff_cache/` (Python cache) and the empty `coc-stylua/` are unrelated leftovers
- desktop_layout uses Lua patterns, not PCRE; `frame = false` is the "move without resize" sentinel because Lua drops `nil` table fields
- `rebuild_main_menu` in commons must use the commons logger directly to avoid recursion

## UNIQUE STYLES
- Every module repeats the `MODULE_NAME` + `registerModule` boilerplate
- `decoration_keys` is lazily required per module instead of being preloaded in init.lua
- Neovim theme sync: list sockets with `nvr --serverlist`, dedupe, then `nvr --remote-send`
- Karabiner switching rewrites the `selected` flag in `~/.config/karabiner/karabiner.json`
- focus_mode / noizio / appearance_manager depend on hardcoded paths and device names (`/opt/homebrew/bin/nightlight`, `夜间`, earphone names)

## COMMANDS
```bash
stylua --check .      # format check
stylua .              # format
hs.reload()           # from the Hammerspoon console
hs.ipc.cliInstall()   # install the ipc CLI once
```

## NOTES
- Run `hs.reload()` after changing Config.json toggles
- `data/Config.json` is generated from `data/initConfig.json` on first run and is gitignored
- `commons:start()` must run before the other modules; keep the order in init.lua
- External binaries in play: `jq` (JSON), `nvr` (Neovim themes), `nightlight` (Night Shift)
