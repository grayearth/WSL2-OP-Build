1. wsl2 “系统找不到指定的文件”如何解决？
在powerShell上

先看还有哪些子系统
wsl --list --all

注销子系统
wsl --unregister Ubuntu-22.04

然后重新安装就好了

2. 在执行./scripts/feeds update -a 过程中遇到了错误。Build dependency: OpenWrt can only be built on a case-sensitive filesystem.

以管理员权限运行 cmd 输入下面这个命令就可以开启某个目录区分大小写。

fsutil.exe file setCaseSensitiveInfo <path> enable
