# OpenDrcom-macOS-x86_64
### 此程序是Drcom的第三方客户端，macOS 64位版本主要使用Swift语言编写，认证模块使用的是此前Python命令行认证模块。如果有能力的话我会使用C语言重写一下。

### 此程序使用的开源组件
1. drcoms/drcom-generic
 - Source Code：[drcoms/drcom-generic on Github](https://github.com/drcoms/drcom-generic)
 - License：[AGPLv3](https://github.com/drcoms/drcom-generic/blob/master/LICENSE)

#### 版本1.0.3更新：错误修复
1. 修复了登录成功之后闪退的bug。

#### 版本1.0.2更新：错误修复
1. 增加重新登录按钮
2. 移除了Debug Mode选择框
3. 优化登录线程，避免卡死。
4. 系统要求变更为OS X 10.10或更高版本。

#### 为什么开发这个客户端？
- 在今年的WWDC 17上苹果发布了macOS High Sierra，苹果宣布将逐步停止32位应用支持。而Mac上现有的第三方Drcom客户端都是32位应用程序。所以在不久的将来（或许就是一年之后），如果不开发64位Drcom，Mac电脑将无法上网。你可以说你不升级macOS High Sierra，但是学弟学妹们新买的Mac电脑是不能降低版本的。出于这个原因我开发了这个64位客户端

#### 此软件有以下特性
1. 支持中国民航大学校园网认证登录，还可以突破原来“使用了路由代理，不支持认证登录”的问题。
2. 支持显示帐号使用时长和使用流量，不用再手动访问网关或者到圈存机查询。
3. 开放源代码：此程序的源代码遵循GPLv3开源协议，您可以免费下载此程序，同时如果您有能力的话可以自由修改此程序的源代码，但前提是修改后的源代码必须也是开源的。
4. 开发者对于此软件的使用不做任何形式的担保（no warranty），这是GPLv3协议所规定的。但是如果您有使用上的困难或者发现了bug，可以在Github上提交issue或者直接联系我。
5. 此软件的二进制版本于此处提供下载（dmg文件），也在中国民航大学计算机科协网站上提供：https://ftp.cstacauc.cn

#### 未来计划添加的功能
1. 自动登录
2. 登录时候的稳定性提升，特别是在非校园网环境误操作。
