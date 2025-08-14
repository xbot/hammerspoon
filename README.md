# Hammerspoon 配置

- en [English](README_en.md)
- zh_CN [简体中文](README.md)

## 使用方法

1. 安装 [Hammerspoon](http://www.hammerspoon.org/)
2. `git clone https://github.com/xbot/hammerspoon.git ~/.hammerspoon`

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

### 调试

此配置包含一个集中的日志系统，方便进行问题排查。

* **日志级别控制**: 通过 Hammerspoon 菜单栏图标 -> `Debug Log Levels` 子菜单，可以为每个模块动态切换日志级别（`info` 或 `debug`）。这有助于在需要时查看更详细的调试信息，而不会被不必要的信息淹没。

### 快速启动

通过 `⌥` + `快捷键` 的组合，可以快速启动或切换到指定的应用程序。这个功能的核心逻辑是，如果应用程序未运行或不在前台，则启动或将其置于前台；如果它已在最前台，则隐藏它。

所有的快捷键绑定都在 `modules/launcher.lua` 文件的 `applist` 变量中定义。您可以根据自己的需要轻松地添加、删除或修改这些快捷键。

**例如，根据默认配置：**

*   `⌥` + `A` 启动/切换 `Arc`
*   `⌥` + `C` 启动/切换 `Visual Studio Code`
*   `⌥` + `K` 启动/切换 `kitty`

...等等。请直接修改配置文件以获得最适合您的工作流。

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

### 终端主题自动切换

自动检测系统外观模式变化，为 kitty 终端切换相应的主题配置。

### Noizio 自动控制器

此模块会监控音频设备的变化，实现对 Noizio 应用的自动管理。

- **功能**：当所有预设的耳机（如 AirPods）断开连接时，脚本会自动关闭 Noizio 应用。这可以避免在没有使用耳机时，环境音通过电脑扬声器播放出来。
- **配置**：需要自动关闭 Noizio 的耳机设备名称列表，可以在 `modules/noizio.lua` 文件的 `earphones` 变量中进行修改。

## 致谢
本配置的初始版本参考了以下项目：

- https://github.com/sugood/hammerspoon