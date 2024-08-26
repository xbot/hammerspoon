# Hammerspoon 配置

## 使用方法

1. 安装 [Hammerspoon](http://www.hammerspoon.org/)
2. `git clone https://github.com/xbot/hammerspoon.git ~/.hammerspoon`

## 快捷键图标
|              | 键位           |
| ---------    | -------------- |
| <kbd>⇧</kbd> | Shift          |
| <kbd>⌃</kbd> | Control        |
| <kbd>⌥</kbd> | Option         |
| <kbd>⌘</kbd> | Command        |

## 代码参考
https://github.com/sugood/hammerspoon

## 语言切换

- en [English](README_en.md)
- zh_CN [简体中文](README.md)

## 功能

### 窗口管理

#### 1/2 屏幕

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>←</kbd> 将当前窗口移动到左半屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>→</kbd> 将当前窗口移动到右半屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>↑</kbd> 将当前窗口移动到上半屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>↓</kbd>	将当前窗口移动到下半屏

#### 1/4 屏幕

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>←</kbd> 将当前窗口移动到左上 1/4 屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>→</kbd> 将当前窗口移动到右下 1/4 屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>↑</kbd> 将当前窗口移动到右上 1/4 屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⇧</kbd> + <kbd>↓</kbd> 将当前窗口移动到左下 1/4 屏

#### 多个显示器

##### 移动光标

* <kbd>⌃</kbd><kbd>⌥</kbd> + <kbd>←</kbd> 把光标移动到下一个显示器
* <kbd>⌃</kbd><kbd>⌥</kbd> + <kbd>→</kbd> 把光标移动到上一个显示器

##### 移动窗口

* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>←</kbd> 将当前活动窗口移动到上一个显示器
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>→</kbd> 将当前活动窗口移动到下一个显示器
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>1</kbd> 将当前活动窗口移动到第一个显示器并窗口最大化
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>2</kbd> 将当前活动窗口移动到第二个显示器并窗口最大化


#### 其它

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>F</kbd> 全屏
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>M</kbd> 最大化窗口
* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>C</kbd> 将窗口放到中间
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>H</kbd>  切换活动窗口
* <kbd>⇧</kbd><kbd>⌥</kbd> + <kbd>/</kbd>  显示窗口切换的快捷键

### 桌面布局

根据布局配置，在应用程序被激活时自动调整大小和重新定位。

如果您不需要`desktop_layout`模块，请将其注释掉。

### 系统工具

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>L</kbd> 锁屏

### 快速启动

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

### JSON格式化

自动格式化剪贴板中的 JSON 。通过托盘图标中的菜单项开关。

### 手动/自动收集网页到 OmniFocus

手动收集网页支持 Google Chrome / Arc Browser / Brave Browser / Vivaldi

<kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + O

自动收集网页支持任意浏览器，需将特定格式字符串复制到剪贴板。例如在 Surfingkeys 中添加如下配置：

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

### 屏幕取色功能

菜单栏点击屏幕取色。通过托盘图标中的菜单项开关。

### 咖啡因

控制是否允许系统自动休眠。通过托盘图标中的菜单项开关。

### 切换 Karabiner-Elements 配置方案

* <kbd>⌃</kbd><kbd>⌥</kbd><kbd>⌘</kbd> + <kbd>K</kbd> 手动切换配置方案
* 根据 App 自动切换:
    ```lua
    karabinerProfileSwitcher.appProfiles = {
        ["game.exe"] = "PC Keyboard",
    }
    ```
