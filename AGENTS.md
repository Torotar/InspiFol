# Pinter 项目协作指南

本文件是仓库级编码代理运行手册，适用于本目录及所有子目录。开始修改前先阅读本文件；通用 ArkTS 规则另见 [`HarmonyOS_ArkTS开发规范与最佳实践.md`](HarmonyOS_ArkTS开发规范与最佳实践.md)，不要在本文件中重复整套通用规范。

## 1. 项目概况

- 产品：Pinter 灵感画板原型，当前数据来自本地固定演示内容。
- 平台：HarmonyOS，Stage 模型，单 `entry` HAP 模块。
- SDK：`targetSdkVersion` 与 `compatibleSdkVersion` 均为 `6.1.1(24)`。
- 设备：`phone`、`tablet`。
- 应用标识：`com.Pinter.app`；当前版本 `1.0.0` / `1000000`。
- 入口链路：`EntryAbility.onWindowStageCreate()` 加载 `pages/Index`。
- 当前无业务网络依赖，也没有真实账号、云同步、消息或图片上传服务。

## 2. 目录与职责

```text
AppScope/app.json5                         应用标识、版本、图标和名称
build-profile.json5                        产品、SDK、构建模式和签名配置
entry/src/main/module.json5                entry 模块、设备类型和 Ability 声明
entry/src/main/ets/entryability/           UIAbility 入口
entry/src/main/ets/entrybackupability/     系统备份扩展占位实现
entry/src/main/ets/models/                 业务数据接口
entry/src/main/ets/pages/                  页面和顶层交互
entry/src/main/ets/services/               演示数据与本地存储服务
entry/src/main/resources/                  字符串、颜色、页面清单和媒体资源
entry/src/test/                            本地单元测试
entry/src/ohosTest/                        设备侧测试
```

关键文件的所有权边界：

- `pages/Index.ets`：顶层页面与交互协调器。拥有首页、发现、发布、收件箱、我的五个标签页，以及搜索、灵感详情、画板选择、新建画板和反馈消息状态。
- `services/DemoContentRepository.ets`：固定演示灵感和原型用户资料的来源。不要把这里的数据描述为服务端或用户上传内容。
- `services/BoardStorageService.ets`：通过 Preferences 读取和保存画板、收藏 ID；页面不得复制另一套持久化实现。
- `models/InspirationModels.ets`：`Pin`、`Board`、`Profile`、`LocalBoardState` 的权威数据契约。跨层字段变更从这里开始。
- `entryability/EntryAbility.ets`：Ability 生命周期、颜色模式和 `pages/Index` 加载，不承载页面业务状态。
- `entrybackupability/EntryBackupAbility.ets`：当前只记录系统备份/恢复回调，不等同于完整的数据备份能力。

## 3. 当前能力边界

### 已实现

- 展示六条固定灵感内容及双列瀑布流。
- 按标题、作者、分类和描述进行本地搜索。
- 打开灵感详情。
- 新建本地画板，将灵感收藏到画板。
- 使用 Preferences 在本地持久化画板和收藏 ID。

### 原型占位

- 发布页不选择或上传真实图片，标题和描述也不会提交。
- 收件箱中的活动、消息和设置入口没有真实业务后端。
- 没有登录、关注、评论、联网内容加载、云同步或跨设备业务同步。
- 系统 `EntryBackupAbility` 只有空回调，不能宣称已经备份或恢复业务数据。

修改产品文案、帮助内容或测试名称时，必须遵守上述边界。未接入的能力应明确标为演示、占位或暂不可用，不得写成已完成。

## 4. 数据与持久化

- Preferences 文件名：`inspira_boards`。
- 画板键：`boards`，JSON 内容为 `Board[]`。
- 收藏键：`saved_pin_ids`，JSON 内容为 `string[]`。
- 当前读取失败会回退为空状态；保存失败由 `BoardStorageService.save()` 返回 `false`，页面展示失败反馈。
- UI 状态数组采用重新赋值更新，例如 `this.boards = [...]` 或 `map()`，避免原地修改导致 ArkUI 状态未刷新。
- 新建画板 ID 当前使用 `board-${Date.now()}`；不要在没有迁移方案时改变已有 ID 或存储键含义。
- 修改 `Board`、`LocalBoardState` 或序列化格式时，必须同时检查旧数据解析、默认值、重复收藏处理和相关测试。
- 不在 Preferences、日志或演示仓库中加入密码、令牌、API Key 等敏感信息。未来若增加凭证，应使用系统安全凭据能力并单独设计其生命周期。

## 5. ArkTS 与代码组织

- 保持严格类型；公共数据结构使用明确接口，避免 `any`、无依据的类型断言和结构不一致的匿名对象。
- 页面负责展示与交互协调，数据来源和持久化留在 `services/`，共享数据契约留在 `models/`。
- 优先使用当前 SDK 对应的 `@kit` 模块；已有 `@ohos` 导入只有在缺少等价 Kit API 或兼容性要求明确时保留。
- 异步存储调用必须处理成功与失败，不要先显示成功再忽略真实结果。
- `catch` 中不得静默吞掉会影响用户数据的错误；如需降级，返回可判断的结果并由 UI 给出真实反馈。
- 新增文件按职责放入现有目录。只有出现稳定复用需求时才增加 `components/`、`common/` 等新层级。
- 不为小范围修改引入新框架、状态管理库或网络库。
- 中文源文件和 Markdown 使用 UTF-8；PowerShell 输出乱码时使用 `Get-Content -Encoding utf8` 核对，不能仅凭终端显示判断文件已损坏。

## 6. UI、资源与无障碍

- 保持现有 ArkUI/HDS 导航结构：五个底部标签页由 `HdsTabs` 管理，发布按钮位于中间标签。
- 首页顶部采用操作块组件，不设置标题组件，也不设置右上角头像或个人资料区域；新增或调整首页布局时必须保持这一信息架构。
- UI 改动同时检查手机和平板；避免只依赖单一固定屏宽。固定格式控件应使用稳定尺寸或响应式约束，防止内容切换导致布局跳动。
- 保持当前视觉语言：白色主背景、中性色文本、Pinter 红色强调色和克制的圆角。不要无任务依据重做整体主题。
- 优先复用 `entry/src/main/resources/base/media/` 内现有 Lucide 图标与品牌资源，不手绘重复图标。
- 新增图标按钮、无文字控件和关键可点击区域时补充准确的 `accessibilityText`。
- 文本需要设置合理的宽度、最大行数或溢出策略，确保中文和长名称不遮挡相邻内容。
- 需要深浅色差异的颜色应进入资源文件；修改颜色时同步检查 `base` 与 `dark` 资源。
- 面向用户的稳定文案优先放入资源；局部原型文案若继续内联，必须保持 UTF-8 并与真实功能一致。

## 7. 典型变更决策

- 修改灵感字段：先改 `InspirationModels.ets`，再更新 `DemoContentRepository.ets`、页面消费点和仓库单元测试。
- 修改演示内容：保持 Pin ID 稳定，除非同时处理已有画板中的 `pinIds` 兼容问题。
- 修改收藏/画板行为：沿 `Index.ets -> BoardStorageService -> Preferences` 检查完整读写路径，不在页面另建存储源。
- 修改标签页或详情层：确认 `selectedPin`、`showBoardPicker`、`showNewBoardDialog` 的关闭路径以及遮罩点击行为。
- 增加真实上传、消息、账号或联网能力：先定义服务接口、权限、错误状态、隐私边界和测试，不直接把占位按钮改成虚假成功。
- 修改版本：同步更新 `AppScope/app.json5` 中的 `versionName`、`versionCode`，并确认对外显示位置。
- 修改设备范围或 SDK：同时检查根 `build-profile.json5`、`module.json5` 和所用 API 的兼容性。

## 8. 测试与构建

### 测试位置

- 本地单元测试入口：`entry/src/test/List.test.ets`。
- 业务单元测试：`entry/src/test/InspirationRepository.test.ets`。
- 设备测试入口：`entry/src/ohosTest/ets/test/List.test.ets`。
- 当前模板测试仍较少。修改仓库数据、搜索、画板状态或序列化逻辑时，应补充针对实际行为的测试，不只依赖模板断言。

### 当前可用路径

- 使用 DevEco Studio 的 Build、Run、Test 流程进行编译、安装与测试。
- 本仓库当前没有 `hvigorw`/`hvigorw.bat`，并且 `hvigor`、`ohpm`、`hdc` 不在当前 PowerShell `PATH`。不要在交付记录中声称执行了不存在的命令。
- 若后续恢复项目 wrapper 或明确配置 DevEco Studio 的 CLI 路径，再将经过实际验证的命令补充到本文件。
- 根 `build-profile.json5` 中 `signingConfigs` 当前为空，同时产品引用 `default` 签名配置。编译通过不代表签名、安装或设备运行通过；报告时分开说明源码编译、打包签名、安装启动和设备验证结果。

纯 Markdown 修改通常不需要运行 HAP 构建，但必须验证文档内容、路径和编码。ArkTS、资源或构建配置变化应按风险运行相应单元测试和 HAP 构建。

## 9. 生成文件与修改范围

- 不编辑或提交 `.idea/`、`.hvigor/`、`oh_modules/`、`build/`、`.preview/` 等工具、依赖或构建产物作为业务实现。
- `local.properties` 是 DevEco Studio 自动生成的本机配置，不手工维护，也不写入仓库说明中的绝对 SDK 路径。
- 不顺手重构与任务无关的页面、资源或模板测试。
- 工作区可能已有用户改动；修改前检查目标文件，保留并兼容不属于当前任务的内容。
- 不使用破坏性 Git 命令，不重置或覆盖用户改动。

## 10. 交付要求

完成任务时应说明：

1. 修改了哪些行为或文档，以及对应文件。
2. 实际运行了哪些检查、测试或构建，结果是什么。
3. 哪些验证未执行，以及原因。
4. 如存在签名、设备、环境或工具链阻塞，将其与源码问题分开报告。

交付前至少进行一次范围检查，确保没有把占位能力描述为真实能力，没有改动生成目录，也没有泄露本机路径、凭据或敏感数据。
