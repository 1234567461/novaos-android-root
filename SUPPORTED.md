# 支持列表（Support Matrix）

> 这是“能 Root 的判定数据库”，不是“保证成功的名单”。
> 判定规则：**官方解锁通道存在 + 内核支持（GKI 或官方修补）+ 可回滚**。
> 每一行的判断方法都在 `docs/PROCESS.md` 里，现场用 `scripts/check.sh` 复核。

## 1. 架构支持（32 / 64 位）

| 架构 | 名称 | 判定方法 | Root 方案 | 备注 |
|---|---|---|---|---|
| arm64-v8a | 64 位 ARM（绝大多数 2017 后机型） | `uname -m` → aarch64 | Magisk / KernelSU | KernelSU 需 GKI 2.0 内核 |
| armeabi-v7a | 32 位 ARM（老款 / 低端） | `uname -m` → armv7l | Magisk | 仍受支持，Boot 分区修补即可 |
| x86_64 | 64 位 Intel（模拟器 / 少量平板） | `uname -m` → x86_64 | Magisk | 模拟器不适用，真机少见 |
| x86 | 32 位 Intel | `uname -m` → i686 | Magisk | 同上 |

## 2. Android 版本支持

| Android | API | Magisk | KernelSU | 说明 |
|---|---|---|---|---|
| 5.0–5.1 | 21–22 | ✅ | – | 老设备，Magisk 官方仍支持 |
| 6.0–9 | 23–28 | ✅ | – | 最稳妥区间 |
| 10–11 | 29–30 | ✅ | 部分 | 需 GKI 或内核支持 |
| 12–13 | 31–33 | ✅ | ✅（GKI） | KernelSU 推荐区间 |
| 14–15 | 34–35 | ✅ | ✅（GKI 2.0） | 新版注意 selinux / avb 校验 |

## 3. 设备判定规则（逐设备）

满足**全部**条件才建议操作：

- [ ] bootloader 可官方解锁（厂商官网有解锁工具/页面；见 docs/PROCESS.md §2）
- [ ] 能进 fastboot / download 模式（`adb reboot bootloader`）
- [ ] Android 版本 >= 5.0，且 `scripts/check.sh` 无红字拒绝
- [ ] 当前系统没有启用不可逆的锁（部分运营商定制机例外）
- [ ] 已备份全部数据 + 提取原版 boot.img（脚本会自动做）

**不在列表 ≠ 不能 Root**：社区支持变化很快，先跑 `scripts/check.sh`，
再查官方渠道：Magisk 讨论区、KernelSU 文档、XDA Developers 对应机型板块。

## 4. 临时 vs 永久

| 模式 | 命令 | 是否写分区 | 重启后 | 回滚 |
|---|---|---|---|---|
| 临时 | `fastboot boot <img>` | 否 | 还原未 root 状态 | 无需操作 |
| 永久 | `fastboot flash boot <img>` | 是 | 保持 root | 刷回备份 boot.img |

## 5. 反支持列表（明确不做）

| 情况 | 原因 |
|---|---|
| bootloader 永久锁死（部分运营商机） | 无官方通道，硬破=漏洞，不做 |
| 未解锁就试图直接刷 | 会导致变砖 / 校验失败 |
| 云端“一键 root”APK / 未知 exe | 基本是盗号木马，本项目永远不提供 |
| 仅 root 用途的漏洞利用 | 违反本仓库正道原则 |

> 更新建议：每次 Android 大版本升级后重跑 `scripts/check.sh` 核对支持状态。
