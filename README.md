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

格式化剪贴板中的 JSON 。

### 屏幕取色功能

菜单栏点击屏幕取色，出现取色界面后点击颜色拾取器，就可以获取当前屏幕鼠标所在位置的颜色值

### 咖啡因

菜单栏点击 咖啡因打开系统永不休眠功能，再点击一次就能关闭
