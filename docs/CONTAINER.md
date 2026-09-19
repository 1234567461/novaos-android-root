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

## 内网直连是怎么工作的

```
路由器（192.168.1.1，DHCP 分配地址）
 ├── 手机（无线调试监听 192.168.1.5:37000）  ← 内网设备
 └── 电脑（同一内网，例如 192.168.1.10）
        └─ adb connect 192.168.1.5:37000  ← 电脑直连手机的内网 IP
```

- 手机连上路由器的那一刻，路由器 DHCP 就给它分了一个内网 IP，
  它就是一个**标准内网设备**——和电脑、打印机、NAS 一样
- 电脑和手机**在同一路由器下**（手机 Wi-Fi / 电脑有线或 Wi-Fi 都行），
  电脑就能通过这个内网 IP 直连，不需要公网 IP、不需要端口转发
- 手机 IP 是路由器分配的，**换网络 / 路由器重启后可能变**；
  想让连接稳定，可以在路由器后台给手机绑定静态 IP（DHCP 保留地址）
- 无线调试端口（冒号后面的数字）每次重新开启无线调试也可能变，
  连接前重新看一眼手机上的显示即可

> 首次 root 的那次 fastboot 写入，也可以在这个电脑端容器里做
> （`--device /dev/bus/usb` 已直通 USB，手机进 fastboot 后
> `docker exec -it novaos-root fastboot flash boot ...`）。
> 完成之后，这台手机就永久走手机端全自动路线。

## 电脑不在同一个网（异地 / 不同 Wi-Fi）怎么办

原则不变：**让手机在电脑眼里仍是“内网设备”**——只是这个内网变成虚拟的。

### 方案 A：Tailscale 异地组网（推荐，免费）

1. 手机装 **Tailscale**（Play 商店或官网 tailscale.com，**无需 root**），登录账号
2. 电脑装 Tailscale，登录**同一个账号**
3. 打开后两台设备自动组进同一个虚拟内网，手机 App 里显示虚拟 IP
   （通常是 `100.x.y.z`）
4. 电脑照旧一键连：

```sh
sh container/pc.sh connect 100.101.102.103:<无线调试端口>
#                          ^^^^^^^^^^^^^^^^
#                          换成手机 Tailscale 里显示的虚拟 IP
```

原理：Tailscale 用 WireGuard 加密隧道把设备组进**虚拟局域网**，
手机在公网/蜂窝网络下也像在同一路由器下——还是那个“内网设备”模型，
只是路由器换成了虚拟的。手机和电脑之间全程加密，不经过第三方中转明文。

### 方案 B：手机开热点（临时应急）

- 手机开“个人热点”，电脑连这个热点 → 物理上变成同一网
- 无线调试里 IP 会变成 `192.168.43.x` 之类，照旧 connect 即可
- 注意：这样电脑的外网走手机流量；手机支持“数据共享”时电脑才有网

### 方案 C：自建隧道（有公网服务器时，进阶）

- WireGuard / OpenVPN / frp：需要一台有公网 IP 的服务器做出口，
  长期固定使用、想完全自控时选这个
- 配置好后同样是“虚拟内网 IP + adb connect”的用法

## 异地连接安全提醒

- 只在自己信任的 Tailscale 账号 / 设备里操作，用完**关闭无线调试**
- 不要用任何来路不明的第三方“远程一键 root”服务——那通常是钓鱼/木马
- 首次 root 的 fastboot 那一步仍然只建议在物理局域网或 USB 下做，
  更稳也更安全
