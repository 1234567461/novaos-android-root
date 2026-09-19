# NovaOS Android Root — 合规一键 Root 助手

给 Android 手机（32 位 / 64 位）提供**一条命令检测 → 官方正道 Root → 临时/永久切换**的辅助工具集。
配套 **nova-kernel**（自研内核）与 **novaos-linux**（发行版）生态，面向想安全获得 root 权限的普通用户。

## 重要：本工具的正道原则

- ✅ **全程手机自己操作**：检测、提取、修补、安装、临时/永久切换、卸载还原，
  全部在手机上完成（Termux + Magisk App），不需要电脑
- ✅ **只走官方支持机制**：解锁 bootloader（厂商官方通道）→ 用 Magisk / KernelSU 修补启动镜像 → 安装
- ✅ **不用任何漏洞**：不依赖、不包含、不传播任何内核/系统漏洞利用代码
- ✅ **临时 root 是真临时**：Magisk 一键“Restore images”，重启即还原，官方支持
- ✅ **永久 root 可回滚**：备份原 boot.img，随时还原
- ⚠️ **不支持的设备不硬来**：bootloader 锁死 / 无官方解锁通道的机型，脚本会明确拒绝并说明原因

> 为什么没有“漏洞一键 root”？漏洞提权会被恶意软件滥用，且设备厂商会打补丁、
> 系统更新会修掉——靠漏洞的 root 既不可持续也不安全。正规工具（Magisk、KernelSU）
> 本身就是官方正道，本仓库把“用什么、怎么查、怎么装、怎么还原”全部标准化成
> **在手机上执行的脚本**。

> 唯一例外：**从未 root 过的手机，首次写入 boot 需要一次外部 fastboot 命令**
> （Android 官方机制下未 root 时 boot 分区只读，没有漏洞可绕、也不该绕）。
> 借电脑 5 分钟做一次之后，这台手机就永久全手机操作。

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

## 快速开始（全手机操作）

在手机安装 **Termux** 和 **Magisk App**（见 docs/PROCESS.md §0），然后：

```sh
# 1. 检测：设备架构 / Android 版本 / bootloader 状态 / 是否已 root
sh scripts/check.sh

# 2. 看你的设备是否在支持列表
cat SUPPORTED.md

# 3. 一键安装 / 切换（自动引导，全程手机）
sh scripts/install.sh

# 4. 辅助脚本（手机）：提取当前 boot.img 供 Magisk 修补
sh scripts/patch-boot.sh
```

### 路线二：容器自动化（手机端默认 / 电脑端可选）

在手机 Termux 里部署 Debian 容器，容器内自己跑 adb 控制自己：

```sh
sh container/setup-container.sh     # 一键部署容器（手机端）
sh container/run.sh                 # 进入容器
./adb-connect.sh pair 127.0.0.1:<配对端口> <配对码>   # 无线调试配对
./auto-root.sh                      # 自动化检测/提取/修补
```

也可以让**电脑**跑同一个容器，通过路由器网络连手机
（手机和电脑连同一 Wi-Fi，把 IP 换成手机在路由器下的 IP）：

```sh
sh container/pc.sh connect <手机IP>:<端口>   # 电脑端一键，IP 见手机无线调试
```

详见 `docs/CONTAINER.md`。

## 支持范围（详见 SUPPORTED.md）

| 维度 | 覆盖 |
|---|---|
| 架构 | arm64-v8a（64 位）、armeabi-v7a（32 位）、x86_64 |
| Android 版本 | 5.0（API 21）起，到最新（API 35+） |
| Root 方案 | Magisk（全部）、KernelSU（GKI 2.0 设备） |
| 模式 | 临时 / 永久（**全手机随时切换**：Direct Install 开启，Restore images 关闭） |
| 判定 | 逐设备支持列表 + 现场检测脚本，双保险 |

## 目录

```
scripts/   手机端脚本（check / status / patch-boot / install，POSIX sh）
container/ 容器方案（手机端 proot 默认 + 电脑端 Docker 可选）
docs/      完整流程（PROCESS）、容器（CONTAINER）、常见问题（FAQ）
SUPPORTED.md  支持列表数据库（架构/版本/设备/方案判定）
README.md     本文件
```

> 生态配套：`nova-kernel`（自研内核）· `novaos-linux`（完整电脑+手机发行版工程）
