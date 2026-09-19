# 常见问题（FAQ）

## 为什么没有“漏洞一键 root”？
漏洞提权代码会被恶意软件滥用；且一旦设备厂商推送补丁，漏洞 root 立即失效，
还会破坏系统完整性。正规工具（Magisk / KernelSU）本身就是官方正道，
本仓库把所有正规步骤做成了一键脚本。**要永久且安全的 root，没有捷径可走。**

## 32 位手机能用吗？
能。armeabi-v7a（32 位 ARM）用 Magisk 修补 boot 即可，与 64 位流程完全一致。
`scripts/check.sh` 会自动识别架构并提示对应方案。

## 临时 root 和永久 root 有什么区别？
- 临时：`fastboot boot` 只把修补后的内核载入内存，**不写入分区**，重启即还原。
- 永久：`fastboot flash boot` 写入 boot 分区，重启后依然生效；可随时刷回备份还原。

## 我的机型不在支持列表里怎么办？
列表是“判定规则”不是“穷举名单”。先跑 `scripts/check.sh`，如果三项都 PASS
（架构支持、Android ≥ 5.0、可官方解锁），就可以按 `docs/PROCESS.md` 操作。
任何一项 FAIL 都不要硬来。

## 解锁 bootloader 会怎样？
- 会清空手机数据（先备份）
- 会失去厂商保修（各厂商政策不同，官方解锁页面会写明）
- 银行 / 支付 / 部分游戏可能拒绝在 root 环境运行
- 好处：获得完整控制权，也是 NovaOS 手机系统的前提

## 会不会变砖？
按本仓库流程（临时模式先行 + 原版 boot.img 备份）风险极低。
最常见的变砖原因都是：用网上随便下载的 boot.img、刷错分区、中途拔线。
本仓库脚本只使用**你自己手机提取的 boot.img**，从源头规避。

## Magisk 和 KernelSU 选哪个？
- 想省事、设备较老：Magisk（通吃，社区资料最多）
- 新机（Android 13+ GKI）、想要内核级模块：KernelSU
- 不确定：先 Magisk，效果一样

## root 之后能做什么？
系统级备份、AdBlock（hosts）、绿守/冰箱类工具、Magisk 模块（字体、音效、
LSPosed 框架生态）、**以及刷 NovaOS mobile 前的完全备份**。

## 相关链接
- Magisk：https://github.com/topjohnwu/Magisk
- KernelSU：https://kernelsu.org/
- 本项目配套：nova-kernel（自研内核）· novaos-linux（电脑+手机发行版）
