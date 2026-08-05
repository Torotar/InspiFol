# PinCase

PinCase 是一个 HarmonyOS 灵感画板原型。项目提供浏览灵感、管理画板和
保存本地状态所需的产品界面，账号和内容服务将在未来后端接入。

## 当前能力

- 首页、发现、通知和我的页面骨架。
- 面向未来内容服务的空内容状态。
- 通过 Preferences 在本机创建画板并保存收藏状态。
- 使用 Stage 模型和 ArkUI/HDS 组件适配手机和平板。

仓库不内置灵感内容，也不提供演示账号。

## 当前限制

以下服务尚未接入：

- 联网内容加载或 Pinterest API。
- 真实账号登录、关注、评论和通知后端。
- 图片选择、上传和内容发布。
- 云同步、跨设备同步和完整业务数据备份。

系统备份扩展目前只是生命周期占位实现。本地画板和收藏 ID 通过
Preferences 保存在设备上，不代表云备份或账号服务。

## 平台信息

- HarmonyOS Stage 模型
- 目标 SDK 与兼容 SDK：`6.1.1(24)`
- 支持设备：`phone`、`tablet`
- Bundle 名称：`com.PinCase.app`
- 版本：`1.0.0`（`1000000`）

## 构建

使用 DevEco Studio 打开项目并执行项目 Build 流程。需要签名 HAP 时，
请在本机配置签名材料。签名凭据和设备相关路径必须保留在公共仓库之外。

## Release

[v1.0.0 Release](https://github.com/Torotar/PinCase/releases/tag/v1.0.0)
提供未签名的开发测试包：

- [下载 `entry-default-unsigned.hap`](https://github.com/Torotar/PinCase/releases/download/v1.0.0/entry-default-unsigned.hap)

该 HAP 仅用于开发和测试，未签名，不得作为生产分发包使用。

## 项目结构

- `AppScope/`：应用标识、版本和资源。
- `entry/src/main/ets/pages/`：页面 UI 和交互协调。
- `entry/src/main/ets/models/`：共享数据契约。
- `entry/src/main/ets/services/`：本地持久化和系统服务。
- `entry/src/main/resources/`：字符串、颜色、媒体和页面配置。
- `entry/src/test/`：本地单元测试入口。
