# NovaOS Android Root — 完整操作流程（官方正道）

> 全程不使用任何漏洞。每一步都有官方依据。
> 通用步骤之外，**你的机型专属细节以厂商官方解锁说明 + Magisk/KernelSU 官方文档为准**。

## §0 前置条件（全部满足才继续）

- [ ] 手机数据已备份（解锁会清空数据）
- [ ] 电脑装好 platform-tools：https://developer.android.com/tools/releases/platform-tools
- [ ] 手机开“开发者选项” → 打开 **USB 调试**
- [ ] 电池 ≥ 50%，全程保持数据线连接

## §1 现场检测

```sh
# 手机上（Termux）：
sh scripts/check.sh
```

看输出：架构（32/64）、Android 版本、bootloader 状态。任何 `[FAIL]` 先解决再继续。

## §2 解锁 bootloader（官方通道，一次性）

| 品牌 | 官方解锁方式（示例，以官网为准） |
|---|---|
| Google Pixel | 官网解锁页面提交 IMEI → 同意条款 → 命令 `fastboot flashing unlock` |
| 一加 / OPPO / realme | 官网解锁申请 → 深度测试 / `fastboot oem unlock`（按官方指引） |
| 小米 / Redmi | 官网申请解锁 → 绑定账号等待 → 小米解锁工具 |
| 三星（部分） | 无官方解锁 → **本项目判定为不支持，请勿硬来** |
| 华为 / 荣耀（新机） | 无官方解锁 → **不支持** |

```sh
adb reboot bootloader        # 进 fastboot
fastboot flashing unlock     # 按厂商指引（会清空数据）
fastboot reboot              # 重启后重开 USB 调试
```

## §3 提取当前 boot.img（必须用自己手机的这个文件）

```sh
# 手机上 Termux：
sh scripts/patch-boot.sh      # 自动定位 boot 分区并备份到 /sdcard/Download/boot.img
```

把 `boot.img` 复制到电脑（`adb pull /sdcard/Download/boot.img`）。

## §4 修补 boot（Magisk / KernelSU 二选一）

### 方案 A：Magisk（全部设备）

1. 安装 Magisk App：https://github.com/topjohnwu/Magisk/releases （下载 `Magisk-vXX.apk` 安装）
2. 打开 Magisk App → **Install → Select and patch a file**
3. 选择 §3 的 `boot.img` → 开始修补
4. 修补完生成 `magisk_patched-XXXXX.img`，拷回电脑

### 方案 B：KernelSU（仅 GKI 2.0 设备）

1. 查内核是否 GKI：`adb shell getprop ro.build.version.release` ≥ 13 且内核版本含 `android13`/`android14`/`android15`（或主板为通用内核）
2. 按 KernelSU 官方文档修补 boot：https://kernelsu.org/guide/how-to-integrate-for-non-gki.html （非 GKI 需内核源码集成，不在本仓库范围）

## §5 临时 / 永久切换

### 临时 root（推荐先试，重启即还原）

```sh
adb reboot bootloader
fastboot boot magisk_patched-XXXXX.img     # 只进内存，不写入分区
```

重启后 root 生效；**再次重启 = 回到未 root 状态**，零残留、零风险。

### 永久 root（确认临时模式没问题后）

```sh
adb reboot bootloader
fastboot flash boot magisk_patched-XXXXX.img
fastboot reboot
```

永久模式保留 root。**把 §3 的原版 boot.img 永久备份**（例如命名为 `stock-boot-<机型>-<版本>.img` 存两处）。

## §6 回滚 / 卸载

| 场景 | 做法 |
|---|---|
| 临时模式想退出 | 直接重启手机 |
| 永久模式想还原 | `fastboot flash boot <原版boot.img>` |
| Magisk 官方卸载 | Magisk App → Uninstall → Restore images |
| 系统更新（OTA）后 | 重跑 §3-§5（OTA 会覆盖 boot 分区） |
| KernelSU 卸载 | 刷回原版 boot.img |

## §7 常见错误速查

| 现象 | 原因 / 处理 |
|---|---|
| `fastboot: no devices` | 没装驱动 / 数据线非原装；换线、重装驱动 |
| `flashing unlock` 失败 | 厂商要求先在官网申请；看 §2 对应品牌 |
| 刷完卡在开机 logo | 用 §6 刷回原版 boot.img，一般可救 |
| Magisk 显示 not installed | 修补的 boot 与当前系统版本不符，重新走 §3-§4 |
| 银行/游戏提示 root | root 会被检测到，属正常现象；用临时模式可按需进出 |

## 参考（官方文档，以链接内最新内容为准）

- Magisk 文档：https://topjohnwu.github.io/Magisk/
- KernelSU 文档：https://kernelsu.org/
- platform-tools：https://developer.android.com/tools/releases/platform-tools
- 各厂商解锁页面：见 §2 表格（链接随官网调整，搜索“<品牌> bootloader unlock 官方”）
