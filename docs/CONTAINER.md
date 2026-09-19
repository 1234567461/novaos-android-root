# 手机端容器方案（Container on the phone）

“跑个容器，ADB 控制” —— 容器直接部署在**手机上**（Termux 里的 Debian
容器），不用电脑。手机自己给自己跑 adb，全程手机操作。

## 原理

| 组件 | 作用 | 是否官方 |
|---|---|---|
| Termux | 手机上的 Linux 终端环境 | 开源（F-Droid/GitHub） |
| proot-distro | 在 Termux 里安装 Debian 容器（用户态，无需 root） | 开源 |
| android-tools（Termux 包） | adb / fastboot（arm 版） | 官方 platform-tools 构建 |
| Magisk 官方 APK | 从中提取 magiskboot 等工具链 | 官方发布 |

> 为什么是 proot 容器而不是 Docker on Android：Android 没有系统级 Docker，
> proot-distro 是手机端跑 Linux 容器的事实标准（用户态模拟，不需要 root）。

## 一键部署（手机 Termux 里执行）

```sh
# 克隆仓库（小白版见 README）或直接下载 zip 解压
sh container/setup-container.sh
```

脚本自动完成：装 proot-distro → 装 Debian 容器 → 容器内装 curl/unzip →
把本仓库脚本拷进容器 → 从官方 Magisk release 提取工具链。

## 进入容器

```sh
sh container/run.sh            # 进入 Debian 容器
./auto-root.sh                 # 自动化：检测 -> 提取 boot -> 修补 -> 引导安装
```

## 连接手机（容器内 adb）

手机开启 **开发者选项 → 无线调试**（手机和自己永远是“同一网络”=localhost）：

```sh
# 配对（“使用配对码配对设备”界面显示 IP:配对端口 + 6 位码）
./adb-connect.sh pair 127.0.0.1:<配对端口> <6位码>
# 连接（“IP 地址和端口”界面显示的端口）
./adb-connect.sh connect 127.0.0.1:<连接端口>
adb devices            # 看到设备即连接成功
```

## 容器里能自动做什么

- ✅ 检测：架构（32/64）、Android 版本、root 状态
- ✅ 已 root 手机：Magisk Direct Install / Restore images 全程引导（全手机）
- ✅ 提取当前 boot.img（root 权限下）+ 用官方 magiskboot 修补
- ⚠️ 未 root 首次：boot 分区只读是 Android 官方机制（无可绕过的正道），
  首次写入仍需一次外部 fastboot —— 这是全项目唯一的电脑接触点，
  之后这台手机就永久全手机操作（见 docs/PROCESS.md §5）

## 常见问题

- **配对端口和连接端口不一样？** 正常。配对端口只用于配对，连接端口用于
  日常 adb，都在“无线调试”界面显示。
- **容器里没有 magiskboot？** 重跑一次 fetch-magisk.sh（网络问题时）。
- **想删容器？** `proot-distro remove debian`（Termux 里执行）。

---

# 电脑端一键路线（可选）

同一套自动化也可以在电脑上跑 Docker 容器，手机和电脑连**同一个路由器**
（Wi-Fi），电脑端通过**手机在路由器下分配到的 IP** 无线连接手机——
把示例 IP 换成你自己的即可。

## 手机端准备（一次）

1. 手机连 Wi-Fi（和电脑同一个路由器）
2. 开发者选项 → **无线调试** → 打开
3. 记下 “IP 地址和端口” 那一行，例如 `192.168.1.5:37000`
   —— **这个 IP 是你路由器给手机分配的，每台手机不一样**，
   下面命令里把它换成你自己的

## 电脑端一键

```sh
# 需要先装 Docker（docker.com 下载 Desktop，Windows/Mac 均可）
sh container/pc.sh connect 192.168.1.5:37000
#                          ^^^^^^^^^^^^^^^^
#                          换成你手机在无线调试里显示的 IP:端口
```

容器自动：连接手机 → 检测 → 提取 boot → 官方 magiskboot 修补 → 引导安装。
手机插 USB 直连电脑也可以（需要把 USB 直通容器，脚本已带）：

```sh
sh container/pc.sh usb
```

> 首次 root 的那次 fastboot 写入，也可以在这个电脑端容器里做
> （`--device /dev/bus/usb` 已直通 USB，手机进 fastboot 后
> `docker exec -it novaos-root fastboot flash boot ...`）。
> 完成之后，这台手机就永久走手机端全自动路线。
