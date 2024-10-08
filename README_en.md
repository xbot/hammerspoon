# Hammerspoon Configuration

## Usage

1. Install [Hammerspoon](http://www.hammerspoon.org/)
2. `git clone https://github.com/sugood/hammerspoon.git ~/.hammerspoon`

## Modifier keys
|           |  Key           |
| --------- | -------------- |
| <kbd>⇧</kbd> | Shift       |
| <kbd>⌃</kbd> | Control   	 |
| <kbd>⌥</kbd> | Option 	 |
| <kbd>⌘</kbd> | Command   	 |

## Reference code
https://github.com/sugood/hammerspoon

## Language

- en [English](README_en.md)
- zh_CN [简体中文](README.md)

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

* <kbd>⌥</kbd> + <kbd>1</kbd> `OmniFocus`
* <kbd>⌥</kbd> + <kbd>2</kbd> `Google Keep`
* <kbd>⌥</kbd> + <kbd>3</kbd> `Sequel Ace`
* <kbd>⌥</kbd> + <kbd>A</kbd> `Arc`
* <kbd>⌥</kbd> + <kbd>C</kbd> `Visual Studio Code`
* <kbd>⌥</kbd> + <kbd>D</kbd> `Dash`
* <kbd>⌥</kbd> + <kbd>C</kbd> `EuDic`
* <kbd>⌥</kbd> + <kbd>F</kbd> `Firefox`
* <kbd>⌥</kbd> + <kbd>G</kbd> `Telegram`
* <kbd>⌥</kbd> + <kbd>I</kbd> `Anki`
* <kbd>⌥</kbd> + <kbd>J</kbd> `Safari`
* <kbd>⌥</kbd> + <kbd>K</kbd> `kitty`
* <kbd>⌥</kbd> + <kbd>L</kbd> `Logseq`
* <kbd>⌥</kbd> + <kbd>M</kbd> `Mail or Spark`
* <kbd>⌥</kbd> + <kbd>N</kbd> `Notion`
* <kbd>⌥</kbd> + <kbd>O</kbd> `Microsoft Outlook`
* <kbd>⌥</kbd> + <kbd>P</kbd> `PhpStorm`
* <kbd>⌥</kbd> + <kbd>Q</kbd> `Activity Monitor`
* <kbd>⌥</kbd> + <kbd>S</kbd> `Slack`
* <kbd>⌥</kbd> + <kbd>V</kbd> `Vivaldi`
* <kbd>⌥</kbd> + <kbd>Z</kbd> `MacVim`

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
