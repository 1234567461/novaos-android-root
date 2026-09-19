# NovaOS Android Root — 合规一键 Root 助手

给 Android 手机（32 位 / 64 位）提供**一条命令检测 → 官方正道 Root → 临时/永久切换**的辅助工具集。
配套 **nova-kernel**（自研内核）与 **novaos-linux**（发行版）生态，面向想安全获得 root 权限的普通用户。

## 重要：本工具的正道原则

- ✅ **只走官方支持机制**：解锁 bootloader（厂商官方通道）→ 用 Magisk / KernelSU 修补启动镜像 → 刷入
- ✅ **不用任何漏洞**：不依赖、不包含、不传播任何内核/系统漏洞利用代码
- ✅ **临时 root 是真临时**：`fastboot boot`（不写入分区），重启即还原，官方支持
- ✅ **永久 root 可回滚**：备份原 boot.img，随时刷回
- ⚠️ **不支持的设备不硬来**：bootloader 锁死 / 无官方解锁通道的机型，脚本会明确拒绝并说明原因

> 为什么没有“漏洞一键 root”？漏洞提权会被恶意软件滥用，且设备厂商会打补丁、
> 系统更新会修掉——靠漏洞的 root 既不可持续也不安全。正规工具（Magisk、KernelSU）
> 本身就是官方正道，本仓库把“用什么、怎么查、怎么刷、怎么还原”全部标准化成一键脚本。

## 如何克隆这个仓库（小白版）

git 就是把整个仓库复制到你电脑上的工具。三分钟搞定：

**第 1 步：安装 git**
- Windows：去 https://git-scm.com/download/win 下载安装（一路下一步）
- macOS：打开“终端”，输入 `xcode-select --install`
- Linux（Ubuntu/Debian）：终端输入 `sudo apt install -y git`

**第 2 步：复制仓库地址**
本仓库地址：`https://github.com/1234567461/novaos-android-root.git`

**第 3 步：克隆**
```sh
git clone https://github.com/1234567461/novaos-android-root.git
cd novaos-android-root
```

以后更新：进文件夹输入 `git pull`。
**只看不下载**：浏览器打开 https://github.com/1234567461/novaos-android-root ，点 `<> Code` → Download ZIP。

## 快速开始

在手机安装 **Termux**（F-Droid 或 GitHub Releases），然后：

```sh
# 1. 检测：设备架构 / Android 版本 / bootloader 状态 / 是否已 root
sh scripts/check.sh

# 2. 看你的设备是否在支持列表
cat SUPPORTED.md

# 3. 按 docs/PROCESS.md 的官方流程操作（提取 boot → Magisk 修补 → 临时/永久）
sh scripts/patch-boot.sh          # 辅助：自动提取当前 boot.img 到 /sdcard/Download

# 4. 已 root 后查状态
sh scripts/status.sh
```

## 支持范围（详见 SUPPORTED.md）

| 维度 | 覆盖 |
|---|---|
| 架构 | arm64-v8a（64 位）、armeabi-v7a（32 位）、x86_64 |
| Android 版本 | 5.0（API 21）起，到最新（API 35+） |
| Root 方案 | Magisk（全部）、KernelSU（GKI 2.0 设备） |
| 模式 | 临时（fastboot boot，重启还原）/ 永久（fastboot flash，可回滚） |
| 判定 | 逐设备支持列表 + 现场检测脚本，双保险 |

## 目录

```
scripts/   手机端脚本（check / status / patch-boot，POSIX sh）
docs/      完整流程（PROCESS）、常见问题（FAQ）
SUPPORTED.md  支持列表数据库（架构/版本/设备/方案判定）
README.md     本文件
```

> 生态配套：`nova-kernel`（自研内核）· `novaos-linux`（完整电脑+手机发行版工程）
