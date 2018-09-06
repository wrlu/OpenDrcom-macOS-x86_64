# OpenDrcom-macOS-x86_64（哆点工具箱 macOS 64位版）
### 简介：此程序是Drcom的第三方客户端，支持自动登录和断线重连，未来计划支持断网原因检测以及自动修复。
  
### 一、使用说明
- 本软件从2.4版本起仅支持 macOS Sierra (10.12.x)或更高版本，若您正在使用 OS X El Capitan (10.11.x)或者 OS X Yosemite (10.10.x)，请下载2.3.1版本；
- macOS Sierra (10.12.x)或更高版本开启“任何来源”后才可以运行本程序（因为我没注册苹果付费帐号，一年688大洋，穷）；
- 在“终端”中执行以下指令，执行后输入管理员密码即可：

~~~sh
sudo spctl --master-disable
~~~

### 二、最新版本更新日志

#### 版本2.7更新：修复崩溃问题和公网IP接口
1. 更新校园网认证协议的方法，兼容最新网页登录；
2. 修复认证登录成功后崩溃的问题；
3. 修复公网IP显示；
4. 优化登录流程，提高登录速度；
5. 撤回macOS Mojave（10.14）中暗黑模式自动切换的功能，此功能将等待系统正式推送后上线。

### 三、软件许可证
- 本软件是自由软件，遵循GPLv3许可协议分发：
- Copyright (c) 2017-2018, 小路.
- This program is free software; you can redistribute it and/or modify it under the terms and conditions of the GNU General Public License, version 3, as published by the Free Software Foundation.
- This program is distributed in the hope it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

### 四、历史版本更新日志

#### 版本2.6更新：更新校园网认证协议
1. 更新校园网认证协议的方法，兼容最新网页登录；
2. 为带有 Touch Bar 的机型提供了 Touch Bar 快捷操作支持。

#### 版本2.5更新：显示公网IP、Mojave暗黑模式
1. 新增登录成功后显示公网IP功能；
2. 在macOS Mojave（10.14）中支持暗黑模式自动切换；
3. 使用Xcode 10 Beta构建，增加对macOS Mojave（10.14）的支持。

#### 版本2.4更新：更改macOS版本要求
1. macOS版本要求为 macOS Sierra (版本 10.12.x) 或更高版本；
2. 增加对macOS High Sierra 版本10.13.4 的支持；
3. 程序完全适配Swift 4；
4. 更改编译Target。

#### 版本2.3.1更新
1. 撤回校园网环境检测功能

#### 版本2.3更新：完善登录错误处理
1. 新增账号超支时登录的错误提示；
2. 新增校园网环境检测，若未连接校园网登录有错误提示；
3. 修复了在用户名和密码正确的情况下，登录提示用户名或密码错误。

#### 版本2.2更新：修复了与OS X El Capitan的兼容性
1. 修复了在 OS X El Capitan (10.11.x) 上无法登录的问题

#### 版本2.1.4更新：代码和程序流程优化
1. 优化重试登录流程
2. 代码风格统一遵循Google 规范

#### 版本2.1.3更新：新增断网后重试
1. 断网后增加选项自动重新登录

#### 版本2.1.1更新：新增注销功能
1. 新增注销功能
2. 自动登录流程优化
3. 优化程序结构，修正了一些错误

#### 版本2.1更新：新增自动登录和自动重拨
1. 新增自动登录功能
2. 新增登录成功后的自动重拨功能
3. 优化程序代码

#### 版本2.0.1更新：登录方式更新
1. 支持模拟新Web方式登录
2. 新增余额显示
3. 新增帐号显示
4. 更新IP获取算法。

#### 版本1.0.4更新：关于信息和开源许可
1. 新增关于页面；
2. 新增开源许可；
3. 预留检查更新通道。
