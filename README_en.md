# Hammerspoon Configuration

- en [English](README_en.md)
- zh_CN [简体中文](README.md)

## Usage

1. Install [Hammerspoon](http://www.hammerspoon.org/)
2. `git clone https://github.com/sugood/hammerspoon.git ~/.hammerspoon`

## Features

### Window Management

#### Split Screen Actions

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>←</kbd> Left half
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>→</kbd> Right half
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>↑</kbd> Top half
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>↓</kbd>	Bottom half

#### Quarter Screen Actions

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>←</kbd> Left top quarter
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>→</kbd> Right bottom quarter
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>↑</kbd> Right top quarter
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>↓</kbd> Left bottom quarter

#### Multiple Monitor

##### Move Cursor

* <kbd>⌃</kbd><kbd>⌥</kbd> + <kbd>←</kbd> Move cursor to next monitor
* <kbd>⌃</kbd><kbd>⌥</kbd> + <kbd>→</kbd> Move cursor to previous monitor

##### Move Windows

* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>←</kbd> Move active window to previous monitor
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>→</kbd> Move active window to next monitor
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>1</kbd> Move active window to monitor 1 and maximize the window
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>2</kbd> Move active window to monitor 2 and maximize the window


#### Other

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>F</kbd> Full Screen
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>M</kbd> Maximize Window
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>C</kbd> Window Center


* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>H</kbd>  Switch active window
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>/</kbd>  Display a keyboard hint for switching focus to each window

### Desktop layout

The app will automatically adjust its size and position based on the layout configuration when activated.

To disable the `desktop_layout` module, comment it out.

### System Tools

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>L</kbd> Lock Screen

### Launch Application

You can quickly launch or switch to a specific application using the `⌥` + `shortcut` combination. The core logic is: if the application is not running or not in the foreground, it will be launched or brought to the front; if it is already the frontmost application, it will be hidden.

All keybindings are defined in the `applist` variable within the `modules/launcher.lua` file. You can easily add, remove, or modify these shortcuts to suit your needs.

**For example, based on the default configuration:**

*   `⌥` + `A` launches/switches to `Arc`
*   `⌥` + `C` launches/switches to `Visual Studio Code`
*   `⌥` + `K` launches/switches to `kitty`

...and so on. Please modify the configuration file directly to best suit your workflow.

### JSON format

Automatically format JSON string in the pasteboard. Toggle it in the menubar item.

### Manually/Automatic clipping web page to OmniFocus

Manual web collection support Google Chrome / Arc Browser / Brave Browser / Vivaldi

<kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + O

Automatic collection of web pages supports any browser and requires copying a specific formatted string to the clipboard. For example, add the following configuration to Surfingkeys:

```javascript
mapkey('yO', 'Copy OmniFocus sensible info.', copyOmniFocusSensibleInfo);

function copyOmniFocusSensibleInfo() {
    var info_arr = [];
    
    info_arr.push("#omnifocus_sensible");
    info_arr.push(document.title);
    info_arr.push(window.location.href);
    
    Clipboard.write(info_arr.join("\n"));
}
```

### Screen color picker

Toggle it in the menubar item.

### Caffeine

Toggle it in the menubar item.

### Switching Karabiner-Elements Profiles

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>K</kbd> Manually switching profiles.
* Automatic switching based on apps:
    ```lua
    karabinerProfileSwitcher.appProfiles = {
        ["game.exe"] = "PC Keyboard",
    }
    ```

### Debugging

This configuration includes a centralized logging system to facilitate troubleshooting.

* **Log Level Control**: Through the Hammerspoon menu bar icon -> `Debug Log Levels` submenu, you can dynamically switch the log level (`info` or `debug`) for each module. This helps in viewing more detailed debug information when needed without being overwhelmed by unnecessary messages.

### Unified Appearance Manager

This configuration includes a unified appearance manager (`modules/appearance_manager.lua`) that listens for macOS system appearance changes (Dark/Light Mode) and automatically switches themes for supported applications.

Currently supported:
- **Hammerspoon Console**: Automatically switches between dark/light themes for the console.
- **kitty Terminal**: Automatically switches between `light.conf` and `dark.conf` themes.
- **Neovim**: Remotely controls Neovim to switch its theme via the `nvr` command.

#### Neovim Integration Requirements
For the Neovim theme switching to work, you need to:
1.  Add the theme-switching Lua function to your Neovim configuration file (e.g., `.vimrc`).
2.  Install `neovim-remote` (nvr) and set up the shell alias.
3.  If the `nvr` executable is not in a standard PATH, you can specify its absolute path in the `nvr_executable_path` variable at the top of the `modules/appearance_manager.lua` file.

This module is extensible, allowing for easy integration with other applications (like VS Code) in the future.

### Focus Mode Appearance Integration

`modules/focus_mode.lua` watches for macOS Focus mode changes. When the “夜间” Focus mode is enabled, it switches the system to Dark Mode and turns on Night Shift through `nightlight`. When that Focus mode is disabled, it switches to Light Mode and turns Night Shift off.

This feature requires `nightlight` and Full Disk Access for Hammerspoon so it can read the current Focus mode. The target Focus mode name and `nightlight` path can be changed at the top of the module.

### Automatic Noizio Control

This module monitors audio device changes to automatically manage the Noizio application.

- **Functionality**: When all specified headphones (e.g., AirPods) are disconnected, the script will automatically quit the Noizio application. This prevents ambient sounds from playing through the computer's speakers when headphones are not in use.
- **Configuration**: The list of headphone device names that trigger this behavior can be modified in the `earphones` variable within the `modules/noizio.lua` file.

## Credits
The initial version of this configuration was referenced from the following project:

- https://github.com/sugood/hammerspoon
