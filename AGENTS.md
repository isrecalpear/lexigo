# AGENTS.md — LexiGo 项目上下文

> 给后续 AI 编码代理（及人类）的项目速查手册。**先读本文件，再读要改的文件。**
> 本文件基于 2026-10 当前 master 分支代码整理；如果代码与本文件冲突，以代码为准，并顺手更新本文件。

## 0. 环境提示

- 平台：Windows 开发机；Flutter SDK 位于 `D:\SourceCode\flutter`（Flutter 3.44.4 / Dart 3.12.2，stable）。
- 本机运行在 DSH 沙箱下时，`dart analyze` / `flutter build` 需要进程间管道，**可能被沙箱拒绝（CreateFile failed 5）**；这类命令需要「完全权限」再跑。`dart format` 不受影响。
- 沙箱内 **`lib/` 等子目录下已有文件的写入可能仍被拒绝**（即使目录 ACL 已修复，`Add-Content`/`dart format` 都会报拒绝访问）。遇到时用「完全权限」执行写操作；编辑文件本身通过 agent 的编辑工具不受影响。
- 当前基线：`dart analyze lib` → **No issues found**；`dart format` 干净；仓库**没有任何测试**。
- 构建产物已在 `.gitignore` 中屏蔽：`build/`、`.dart_tool/`、各平台 `ephemeral/`/`Pods/`/`app/build/`，以及自动生成的 `generated_plugin_registrant.*`、`generated_plugins.cmake`、`GeneratedPluginRegistrant.*`。这些文件不再被跟踪，由 `flutter pub get` / 构建自动重建，不要手动加入版本库。

## 1. 项目是什么

**LexiGo（背了么）**：一个本地离线、单机使用的背单词应用。用户导入词表 → 用 FSRS v5 间隔重复算法逐词评分（忘记/困难/还行/简单）→ 下次按到期时间复习。

- UI 语言：中文 / English（跟随系统可选）。
- 学习语言（词表语言）：`ko`（韩语）、`ru`（俄语）、`en`（英语），见 `lib/backend/word.dart` 的 `LanguageCode`。
- 每条单词是**双语卡片**：原文 / 译文 / 原文例句 / 例句翻译，外加 `unitID`、`bookID` 两个分组维度。
- 目标平台：Android / iOS / Windows / macOS / Linux（无 web 目录，`.metadata` 里的 web 条目是模板残留）。
- **macOS 最低系统版本 = 12.0**（Monterey）。`macos/Runner.xcodeproj/project.pbxproj` 中三个 project 级 build configuration（Debug / Release / Profile）的 `MACOSX_DEPLOYMENT_TARGET` 都是 `12.0`。Xcode 27（macOS SDK 27）支持的最低部署目标是 12.0，模板残留的 `10.15` 会直接报 `The macOS deployment target 'MACOSX_DEPLOYMENT_TARGET' is set to 10.15, but the range of supported deployment target versions is 12.0 to 27.0.x` 并让 Runner / Flutter Assemble 两个 target 同时失败。升级 Flutter / Xcode 后如果 `flutter create` 生成的模板又把它写回 `10.15`，按错误提示的下限改回 `12.0` 即可。
- macOS 原生依赖走 **Swift Package Manager**（`macos/Flutter/ephemeral/Packages/FlutterGeneratedPluginSwiftPackage`），仓库里**没有 `macos/Podfile`**（`Podfile.lock` 是旧遗留文件）。切换依赖管理方式时注意 `macos/Runner.xcodeproj` 里的 `XCLocalSwiftPackageReference` / `XCSwiftPackageProductDependency` 与 `Flutter-Generated.xcconfig` 是同一次生成的，别只改一半。
- 在 macOS 上构建时，SwiftPM 会把缓存写到 `~/Library/Caches/org.swift.swiftpm`；本机在 DSH 沙箱下该目录不可写，`xcodebuild -showBuildSettings` 会报 `cannot open file '...org.swift.swiftpm/...' (Operation not permitted)`，`flutter build macos` / `flutter run -d macos` 也因为 Flutter SDK 在沙箱外（`/Users/isrecal/source_code/sdk/flutter`）而无法执行 —— 这些命令要用「完全权限」跑。

## 2. 常用命令

```powershell
flutter pub get
flutter gen-l10n                                            # 改了 lib/l10n/*.arb 之后生成 app_localizations_generated*.dart
dart run build_runner build --delete-conflicting-outputs   # 改了 lib/backend/database/tables.dart 或 interface.dart 之后必须
dart analyze lib                                            # 基线必须 0 issue
dart format lib
dart run import_sorter:main                                 # 可选：按分组重排 import
flutter run -d windows                                      # 桌面调试
flutter run -d <android-device>
flutter build apk --release
```

文案由 Flutter gen-l10n 从 `lib/l10n/app_en.arb` / `app_zh.arb` 生成（见第 6 节）。没有 CI、没有 `test/`。

## 3. 代码地图

```
lib/
├─ main.dart                      入口 + 根 MyApp（主题/动态取色/语言/设置）+ MyHomePage（三 Tab、侧边 Rail、搜索）
├─ app_router.dart                ★路由表：AppRoute 名称 + AppRoutes 类型化构建器（全项目唯一 MaterialPageRoute 来源）
├─ theme/
│  └─ app_theme.dart              ★Material 3 设计系统：AppSpacing/AppRadius/AppMotion + 全部组件主题（只用 ColorScheme 角色，无渐变）
├─ backend/
│  ├─ word.dart                   Word 模型、LanguageCode 枚举
│  ├─ database/
│  │  ├─ tables.dart              drift 表定义（WordTable、WordLearningHistoryTable）
│  │  ├─ interface.dart           Database 类（schemaVersion = 1，无迁移策略）
│  │  └─ interface.g.dart         生成代码，勿手改
│  └─ word/
│     ├─ manager.dart             数据访问层 + FSRS Scheduler（所有 CRUD / 复习）
│     ├─ global_provider.dart     WordProvider（ChangeNotifier，跨页面共享“当前单词”）
│     ├─ import_service.dart      ★导入流水线：检测/校验/去重（prepare）→ 分块事务写入（commit）
│     └─ fallback.dart            每个语言一个兜底词（DB 为空时展示用，不落库）
├─ backend/records/records_service.dart  ★记录页只读查询：周统计/日回顾/未来预测/整体统计/单卡详情 + retrievability
├─ pages/
│  ├─ start_page.dart             学习 Tab：随机词卡片 + 「下一个」+「开始学习」
│  ├─ learning/
│  │  ├─ learn.dart               评分页（4 个 FSRS 按钮、进度条、会话 10 词）
│  │  └─ learning_summarize.dart  会话总结页
│  ├─ records/
│  │  ├─ records_page.dart        记录 Tab：周条 + 当天回顾/未来预测 + 学习概览
│  │  ├─ word_detail_sheet.dart   单词详情弹层（FSRS 状态、遗忘曲线、复习历史）
│  │  ├─ forgetting_curve.dart    遗忘曲线 CustomPainter（FSRS retrievability）
│  │  └─ records_format.dart      rating/state 文案、颜色、时间格式化、RatingBadge
│  ├─ my_page.dart                我的 Tab：菜单（单词管理/编辑设置/日志/关于）
│  ├─ my_page/
│  │  ├─ settings_editing.dart    UI 语言、主题模式、主题色（HSV + Hex 选择器）
│  │  ├─ word_management/
│  │  │  ├─ word_management.dart  ★导入入口（预览确认 + 进度弹窗）+ 导出（分语言导出 sqlite + 分享/保存）
│  │  │  ├─ word_view.dart        当前语言单词列表（编辑/删除）
│  │  │  ├─ word_add.dart         手动添加单词表单
│  │  │  └─ word_edit.dart        编辑单词表单
│  │  └─ log_management/          日志查看/清除/分享
│  └─ widgets/
│     ├─ app_ui.dart              ★共享 M3 组件（AppSurface/AppSettingsGroup/AppStatTile/AppPageHeader/AppEmptyState/...）
│     └─ word_card.dart           单词卡片组件（含“纠错/标记熟知”菜单、遮罩/显示答案）
├─ l10n/
│  ├─ app_en.arb / app_zh.arb          ★文案源（ARB，模板 app_en.arb，占位符元数据写在模板里）
│  ├─ l10n.dart                        手写出口：export 生成类 + BuildContext.l10n 扩展
│  └─ app_localizations_generated*.dart gen-l10n 生成，勿手改（app_localizations_generated.dart/_en/_zh）
└─ utils/
   ├─ settings.dart               Settings + SettingsStore（单例，YAML 持久化）
   ├─ app_font.dart               AppFont 枚举（system/MiSans/HarmonyOS 及官方下载地址）
   ├─ font_manager.dart           ★字体下载/解压/运行时 FontLoader 注册
   ├─ app_logger.dart             文件日志（单例、按天文件、7 天/5MB 清理）
   ├─ device_info.dart            DeviceInfoManager（平台/平板/能力判断，单例）
   └─ permission_manager.dart     Android 存储权限包装
```

## 4. 数据库

### 表结构（`lib/backend/database/tables.dart`）

`WordTable`（表名 `word_table`，列名 snake_case）：

| 列 | 类型 | 说明 |
|---|---|---|
| `id` | int autoincrement PK | 自增主键 |
| `language_code` | text | `LanguageCode.name`（`ko`/`ru`/`en`） |
| `original_word` / `original_translation` | text | 单词 / 译文 |
| `example_sentence` / `example_translation` | text | 例句 / 例句翻译 |
| `unit_id` / `book_id` | text | 默认 `DefaultUnit` / `DefaultBook`（clientDefault） |
| `card_id` | int | FSRS 卡片 id = `Card.create()` 时的 epoch 毫秒 |
| `card_state` / `card_step` | int | FSRS 状态、学习步 |
| `card_stability` / `card_difficulty` | real? | FSRS 记忆参数 |
| `card_due_time` | datetime | 到期时间（有索引 `idx_word_due`） |
| `card_last_review_time` | datetime? | 上次复习 |
| `created_at_time` / `updated_at_time` | datetime | 审计字段（**没人读**） |

唯一键：`UNIQUE(original_word, unit_id, book_id, card_id)`（因为 cardId 每张卡不同，实际上几乎不会触发去重）。

`WordLearningHistoryTable`（`word_learning_history_table`）：`id`、`card_id`、`rating`（`intEnum<Rating>` 存枚举 **index**：0=again、1=hard、2=good、3=easy）、`review_date_time`（UTC 存储）、`review_duration`（毫秒，可空）。

### 关键事实

- `schemaVersion = 1`，**没有 `MigrationStrategy`**。改表必须同时 bump 版本并写迁移，否则老用户升级会直接炸（drift 默认 `onUpgrade` 抛异常/或 schema 校验失败）。
- 数据库文件：`driftDatabase(name: "database")`，目录 Android 用 documents，其它平台用 support。
- **`Database` 是单例**：`WordManager()` 仍然各自创建，但内部的 `Database()` 工厂返回同一实例，所有读写共用一条 sqlite 连接；只有在显式传入 `QueryExecutor` 时才开新连接（测试/工具用）。
- `Word.card` 是 `Card`（不是 `Future<Card>`）：从行数据还原时用 `Card.fromMap`，内存中的卡片可直接读写；兜底词用 `Card(cardId: -1)`。
- 写操作现在都会 `await`（`updateWord` 返回受影响行数），`updateWords` 在事务里执行；`reviewWord` 用受影响行数判断单词是否已落库，未落库的兜底词不会写孤儿 history 记录。

### FSRS 调度

`WordManager.scheduler` 是 `static final`，参数**硬编码**在 `manager.dart` 顶部：21 个 v5 权重、目标保留率 0.9、学习步 1 分钟 / 10 分钟、重学步 10 分钟、最大间隔 36500 天、开启 fuzzing。

> ⚠️ `Settings` 里有 `fsrsDesiredRetention/fsrsLearningSteps/fsrsRelearningSteps/fsrsMaximumInterval/fsrsEnableFuzzing`，会写进 YAML，但**没有任何 UI，也完全没被 Scheduler 使用**（死配置）。默认最大间隔 365 天也和 36500 天对不上。

复习链路：`LearningPage._handleChoice` → `WordProvider.reviewWord` → `WordManager.reviewWord`：`scheduler.reviewCard(card, rating, reviewDateTime: utcNow, reviewDuration: ms)` → 写回 WordTable → 追加 history。之后 `nextReviewWord()` 取 `card_due_time < now` 的最早一条。

## 5. 核心流程

### 启动
`main()` → `AppLogger.initialize()` → `runZonedGuarded(runApp)` → `MyApp._loadSettings()`（`SettingsStore.loadSettings`，YAML）→ `WordProvider.loadRandomWord()`。
`MyApp.build` 按 `DeviceInfoManager().supportsDynamicColor` 决定主题来源，两条分支只差 ColorScheme，`MaterialApp` 的公共配置集中在 `_buildMaterialApp`（iOS 不支持动态取色，用 seed/默认色）。

### 导航
路由集中在 `lib/app_router.dart`：`AppRoute` 是稳定的路径名，`AppRoutes.xxx(...)` 返回带 `RouteSettings(name:)` 的类型化 `MaterialPageRoute`，页面参数保持强类型，没有 `Object? arguments`。**不要在页面里直接 new `MaterialPageRoute`**；新增页面时在 `AppRoutes` 里加构建器。路由名会出现在 `AppRouteObserver` 的日志里。没有引入 `go_router`：应用没有深链 / 多 Shell / 浏览器 URL 需求，集中式路由表已经覆盖可维护性目标。
底部三 Tab 用 `PageView`（禁止滑动）+ `NavigationBar`；横屏宽高比 ≥ 1.2 时换成 `NavigationRail`。

### 学习
`StartPage`（随机词 + 开始）→ `LearningPage`（当前词、遮译文、4 个评分按钮）→ 评一次更新一次 FSRS → `nextReviewWord()` 立刻取下一条到期词 → 满 10 条或没词了 → `LearningSummarizePage`。「下一组」用 `pushReplacement` 回到 `LearningPage`。
- 会话长度 `_totalCount = 10` 是常量（有 TODO 要配置化）。
- 总结页的 `wordsReviewed` / `wordsToReview` 恒为 0；`wordsLearned` 在“没词可用”提前结束时少算最后一条。
- `WordProvider` 构造时就装上当前语言的**不在库里**的兜底词；加载随机词失败（该语言没有词）时保留兜底词而不是把 `currentWord` 置 `null`，所以「下一个 / 左右滑动 / 开始学习」在空词库下不会出现空白帧或闪烁；`currentWord` 为空只出现在学习页 `nextReviewWord()` 取不到下一条到期词时。对它评分不会落库，也不会再写孤儿 history 记录（`reviewWord` 以更新行数为 0 判断并跳过）。

### 记录页（记录 Tab）★
页面在 `lib/pages/records/records_page.dart`，只读查询集中在 `lib/backend/records/records_service.dart`：

- **周条**：以周一为起点展示 7 天；过去/今天显示当天复习次数（有“忘记”时数字标红），未来显示当天到期复习数。左右箭头切换上一周/下一周（Tooltip 同样是“上一周/下一周”），切换时保持当前星期几不变；在周条上左右滑动也切换周。点击中间日期范围会弹出日期选择器并跳到所选日期所在的周；点日期格子选中。选中日期不是今天时，头部右侧额外显示「回到今天」按钮（`Icons.today`，仅此时出现）。
- **手势**：除周条以外的整个页面区域左右滑动都切换前一天/后一天（跨周时周条随之切换）；周条内部滑动仍切换周。左滑=下一天/下一周，右滑=上一天/上一周。实现上整个 `ListView` 包一层日切换 `GestureDetector`，周条自己再包一层周切换 `GestureDetector`（内层在手势竞技场中优先）。
- **当天（≤ 今天）**：`word_learning_history_table` join `word_table` 得到复习事件，展示单词、评分（忘记/困难/还行/简单）、记忆难度/强度、用时；点条目打开单词详情；顶部汇总复习次数、涉及词数、未记住数、平均用时。
- **未来日期**：`card_due_time` 落在本地当天且 `card_last_review_time != null` 计为“到期复习”；`due < 当天` 为“积压”；`card_last_review_time == null` 为“待学新词”（词库库存，不是按天排程）。列出当天到期单词（最多 100 条）。
- **学习概览**：连续学习天数（近 90 天内有记录的连续日期）、近 7 天复习柱状图、近 7 天记忆保持率（非 Again 占比）、已掌握（`card_state = review`）、词库规模、累计复习数。
- **单词详情弹层**：FSRS 状态/难度/强度、下次与上次复习时间、遗忘曲线、该词复习历史。遗忘曲线用 FSRS-5 retrievability `R(t,S) = (1 + 19/81·t/S)^(-0.5)`，`S` 是 stability（天），90% 保留率恰好出现在 `t = S`。
- 记录页只读，不修改任何数据；未来日期的数字是“当前排程快照”，不会模拟未来的评分结果。

### 词表导入（当前唯一导入通道）★
入口：我的 → 单词管理 → 导入单词清单。UI 在 `lib/pages/my_page/word_management/word_management.dart`，流水线在 `lib/backend/word/import_service.dart`，分三步：

1. `detectLanguages(path)`：只读 `sqlite_master`，返回文件里存在的 `ko` / `ru` / `en` 表；只有一个时自动识别，多个时弹窗选择。
2. `prepare(path, language)`：校验必需列，逐行 `trim`，跳过空词/空译，按 `originalWord||bookId||unitId` 与**整表**去重，返回 `ImportPlan`（总行数 / 可导入数 / 跳过数：空行 + 重复）。**此阶段不写库。**
3. UI 用确认框展示 `ImportPlan` 统计（语言、总数、可导入、跳过）→ `commit(plan)`：批量构造 `Word`（`Card(cardId: 起始毫秒 + i)`，不再每词 `await 1ms`），`WordManager.insertWords` 在**单个事务**里按 200 条分块写入并回调进度，UI 用不可取消的进度弹窗显示百分比。
4. 完成后 SnackBar 报 `importSuccess(导入数, 跳过数)`；失败报 `importFailed`。

细节/注意：
- 只接受扩展名 `sqlite` / `db`（**不支持 CSV/JSON/TXT**）；必需列 `original_word, translation, original_example, example_translation, unit_id, book_id`。
- 去重靠应用层：DB 唯一键包含 `card_id`，库层并不保证“同词同书同单元”唯一。
- Android 上 `XFile.path` 可能是缓存路径，部分厂商 ROM 上直接 `sqlite3.open(path)` 不可靠。
- 解析仍使用同步 `sqlite3`，几千行约在百毫秒级；写入已分块并包在事务里，失败会整体回滚。

导出（`_exportWords`）：选择语言（默认当前学习语言）→ 用 `WordManager.getWords` 取该语言全部单词、`getReviewLogs` 取复习记录并按 cardId 过滤 → 通过 `Database.external(driftDatabase(...))` 写入临时 sqlite（表结构与应用库一致，可直接被导入回来）→ iOS/macOS 走系统分享（`share_plus`），Android 复制到 `Documents/LexiGo`，桌面复制到下载目录 → SnackBar 报导出路径。临时文件写在 `getTemporaryDirectory()`。

### 设置持久化
`SettingsStore` 单例持有内存 `Settings`，`saveSettings()` 写 `<support>/settings.yaml`（手写 YAML 序列化，不是 `yaml` 库的输出格式），`loadSettings()` 用 `yaml.loadYaml` 读并用 `_parse*` 兜底。`copyWith` 的 `null` 语义靠 `localeSet` / `colorSeedSet` 两个显式开关表达（`null` 表示跟随系统语言 / 自动主题色）；忘记传开关时 `null` 会被忽略。`font` 存 `AppFont.storageId`（`system`/`misans`/`harmonyos`），缺省/未知值回退 `system`。

### UI 字体（动态下载，不随包分发）★
- 设置项：`AppFont`（`lib/utils/app_font.dart`），默认 `system`；枚举同时携带官方页面、官方 zip 直链和注册用 family 名。
  - MiSans：<https://hyperos.mi.com/font/en/details/sc/>，直链 `https://hyperos.mi.com/font-download/MiSans.zip`。
  - HarmonyOS Sans：<https://developer.huawei.com/consumer/cn/design/resource-V1/>，直链 `https://developer.huawei.com/images/download/general/HarmonyOS-Sans.zip`（注意是站点根路径，不是页面里的 `/consumer/cn/...`）。
- `FontManager`（`lib/utils/font_manager.dart`）负责：`HttpClient` 单线程下载（带 UA/Referer、进度回调）→ 校验 zip 魔数 → `archive` 流式解压 → 只保留 400/500/600/700 四个字重（优先 SC 变体，排除 TC/其它语种与斜体）→ 写入 `<support>/fonts/<storageId>/` 并落 `.lexigo-font.json` 标记 → `FontLoader(family)` 运行时注册。
- 下载缓存目录与设置分离；下载失败/缓存被删时 `MyApp._loadSettings` 回退系统字体并把设置改回 `system`（不会让界面无字体可用）。
- 平台权限：Android 需要 `INTERNET`（已加在 `android/app/src/main/AndroidManifest.xml`）；macOS 沙箱需要 `com.apple.security.network.client`（Debug/Release entitlements 已加）。新增字体时记得同步检查这两处。
- 字体包不进入仓库、不进 `assets`；不要提交下载缓存。UI 入口在「编辑设置 → 字体」，非系统字体首次选择会弹确认框+进度弹窗。

### 日志
`AppLogger` 静态方法（`debug/info/warning/error/fatal`），`logger` 包 + 自定义 printer / `_DailyFileOutput`，同步追加到 `<documents|support>/logs/yyyy-MM-dd.log`；跨天自动切到新日期文件；启动时清理到 7 个文件、单文件 >5MB 删除。日志量小，保留同步写入以保证日志查看页立即可见。禁止 `print`。

## 6. 编码约定

1. **import 分组**：项目用 `import_sorter`，分组注释固定为
   ```dart
   // Dart imports:
   // Flutter imports:
   // Package imports:
   // Project imports:
   ```
   组内字母序。新增 import 请遵守，跑 `dart run import_sorter:main` 自动修。
2. **文件头**：`library;` + `///` 英文文档注释（现有代码风格是英文注释、中文仅出现在文案/少量说明）。公开类/方法写 `///`。
3. **文案**：一律 `context.l10n.xxx`（`BuildContext` 扩展在 `lib/l10n/l10n.dart`）。文案表由 **Flutter gen-l10n** 生成：新增一条要改 `lib/l10n/app_en.arb`（模板，带 `@key.placeholders` 元数据）和 `app_zh.arb`，然后跑 `flutter gen-l10n` 重新生成 `app_localizations_generated*.dart`（**勿手改生成文件**）。带参数的 key 在调用侧按模板里 placeholders 的声明顺序传参（例如 `importPreviewSummary(total, count, skipped)`）；文案里用 `{name}` 占位。
4. **状态管理**：没有 provider/riverpod/bloc。页面自己 `StatefulWidget + setState`；跨页面共享只有两个东西：`WordProvider`（构造参数逐层传）和 `SettingsStore.instance`。新增全局状态先考虑这两条路。
5. **平台差异**：一律走 `DeviceInfoManager`（`isAndroid/isApple/isDesktop/supportsDynamicColor/supportsFileSharing`），不要在业务代码里裸写 `Platform.isX`。
6. **日志**：`AppLogger`，带 `error:` / `stackTrace:`。
7. **异常提示**：`try/catch` → `AppLogger.error` → `ScaffoldMessenger.showSnackBar(l10n.xxxFailed('$e'))`。
8. **生成代码**：`interface.g.dart` 只由 build_runner 生成，改表后必须重跑；不要手改。
9. **格式化**：`dart format`（默认 80 列、末尾逗号风格），提交前 `dart analyze` 必须 0 issue。

## 6.1 UI 设计系统（Material 3）★

这是 2026-10 这一轮 UI 重做后的约定，新增/修改界面前必读。

- **主题**：全局主题在 `lib/theme/app_theme.dart`，由 `AppTheme.build(brightness, dynamicScheme: ..., seedColor: ..., fontFamily: ...)` 统一生成 light/dark `ThemeData`。不要在页面里手写 `ThemeData`，也不要改 `buildTheme` 之类的旧入口。
- **设计令牌**：`AppSpacing`（4dp 网格）、`AppRadius`（xs..huge/full/card/group/sheet）、`AppMotion`（fast/medium/slow + easeOutCubic）。颜色/圆角/间距优先取这些常量。
- **共享组件**（`lib/pages/widgets/app_ui.dart`）：
  - `AppContent`（内容最大宽度 920 并居中）+ `AppInsets`（`page` / `formPage` / `surface` / `group` 标准内边距）；
  - `AppSurface`（圆角 tonal 卡片，可传纯色 `color`/`onTap`，**不支持渐变**）、`AppSectionHeader`、`AppPageHeader`、`AppEyebrow`；
  - `AppSettingsGroup` + `AppSettingsTile`（分组设置列表）、`AppChoiceTile<T>`（选择器行，圆形勾选）；
  - `AppIconBadge`、`AppPill`、`AppStatTile`、`AppEmptyState`、`AppLoading`、`AppErrorView`。
- **页面骨架**：
  - Tab 页（学习/记录/我的）**不要 AppBar**——外壳 `MyHomePage` 已有品牌头、语言选择和搜索；body 用 `SafeArea(top: false) → AppContent → ListView(padding: AppInsets.page)`，需要页面标题时用 `AppPageHeader`。
  - 压栈页面用 `Scaffold + AppBar`，body 用 `SafeArea → AppContent → ListView(padding: AppInsets.formPage)`。
  - `MyHomePage` 宽屏判断沿用宽高比 ≥ 1.2：竖屏 `NavigationBar`，宽屏 `NavigationRail`；`start_page.dart` 在宽度 ≥ 900 时切左右双栏。
- **颜色（Material 规范）**：
  - 只允许 `Theme.of(context).colorScheme` 的语义角色；禁止自定义色相、`Color(0x...)`、`Colors.red` 之类字面色值（`Colors.transparent` 仅用于“无边框/无底色”占位）。不要把多个角色 `Color.alphaBlend` 混成一个新颜色。
  - **禁止渐变**：不要使用 `LinearGradient` / `RadialGradient` / `SweepGradient` / `BoxDecoration(gradient:)` / `Shader` 画渐变；高亮块、品牌块、图表柱体、弹层预览一律用纯色容器角色。
  - 常用映射：页面/卡片底 `surface`、`surfaceContainerLow`、`surfaceContainerHigh`；品牌/主操作 `primary` + `onPrimary` 或 `primaryContainer` + `onPrimaryContainer`；次级 `secondaryContainer` + `onSecondaryContainer`；第三色 `tertiaryContainer` + `onTertiaryContainer`；错误/忘记 `errorContainer` + `onErrorContainer`；分割线/边框 `outlineVariant`；次要文字 `onSurfaceVariant`；遮罩 `scrim`；阴影 `shadow`。
  - 评级/状态色统一走 `lib/pages/records/records_format.dart` 的 `ratingContainerColor` / `ratingOnColor`、`stateContainerColor` / `stateOnColor`（again=errorContainer、hard=tertiaryContainer、good=primaryContainer、easy=secondaryContainer），页面里不要另写映射。
  - 状态层、边框、阴影、图表网格允许对 ColorScheme 角色使用标准透明度（8%–24%，例如 12% hover/选中态、`scrim` 45% 遮罩），但不得因此混出新的色相；图表柱体用 `primary`（今天）/ `primaryContainer`（其余）/ `outlineVariant`（零值），遗忘曲线用 `primary` 线 + `primaryContainer` 端点，不要填充渐变。
  - 主题色选择器本身需要展示用户选择的任意颜色（HSV/Hex 预览），这是唯一允许出现自定义颜色的场景；其余 UI 不得跟随它。
  - 所有页面必须同时适配浅色与深色主题；深浅模式下都不得出现渐变或不可读的低对比文字。
- **文字/图标**：字号走 `textTheme`；图标统一 Material Icons，优先 `*_rounded` 变体；圆角用 `AppRadius`，间距用 `AppSpacing`。
- **组件主题已覆盖**：AppBar / Card / ListTile / FilledButton / OutlinedButton / InputDecoration / Dialog / BottomSheet / SnackBar / NavigationBar / NavigationRail / Chip / PopupMenu / Tooltip / SearchBar / Slider / Switch / SegmentedButton 等，优先复用主题，避免局部 `styleFrom` 重复造轮子。
- **动效**：时间/曲线用 `AppMotion`；选中态用 `AnimatedContainer`，内容切换用 `AnimatedSwitcher`，不要堆叠过多动画。
- **字体/主题色**：用户选的字体只通过 `fontFamily` 注入主题；主题色/动态取色仍然只由 `main.dart` 的 `AppTheme.build(seedColor/dynamicScheme)` 处理，页面不要自己 `ColorScheme.fromSeed`。
- **自测尺寸**：360×800、430×932、≥1024 宽桌面三种尺寸 + 明暗两套主题 + 中英文案，均不能溢出或出现不可读文字。

## 7. 已知问题清单

### 已修复（2026-10 这一轮）

| 问题 | 处理方式 | 位置 |
|---|---|---|
| 搜索忽略语言、无通配、未转义 | 查询加 `languageCode` 过滤，输入包 `%`，转义 `%`/`_`/`\` | `manager.dart` `searchWords` |
| `getWords()` 默认 64 条截断 | 去掉默认上限；新增 `getWordIdentityKeys` 供导入去重全表比对 | `manager.dart`、`word_management.dart` |
| `copyWith(colorSeed: null)` 无法清空 | 增加 `colorSeedSet` 显式开关，`_setColorSeed` 传 `true` | `settings.dart`、`main.dart` |
| 每个 `WordManager()` 新建 DB 连接 | `Database` 改为单例工厂，显式 `QueryExecutor` 时才开新连接 | `interface.dart` |
| drift 写操作未 await、批量更新非事务 | 全部 `await`；`updateWords` 包进 `transaction` | `manager.dart` |
| 兜底词评分产生孤儿 history | `reviewWord` 检查更新行数，为 0 时只记日志不写 history | `manager.dart` |
| 空词库时点击开始学习/滑动切换词会闪一帧空白页 | 兜底词下沉到 `WordProvider`（构造时初始化，加载不到词时保留而不是发布 `null`），`loadRandomWord()` 返回加载结果供调用方判断；`StartPage` 删除帧后安装兜底词的逻辑，空词库时开始学习直接返回 | `global_provider.dart`、`start_page.dart` |
| 总结页手写 `replaceAll` 拼文案 | `learningSummary(learned, reviewed, toReview)` 走 l10n 参数机制 | `app_localizations.dart`、`learning_summarize.dart` |
| `MyApp.build` 两份 `MaterialApp` | 抽取 `_buildMaterialApp`，两分支只传 ColorScheme | `main.dart` |
| 无路由表、跳转散落 | 新增 `app_router.dart`：`AppRoutes` 类型化构建器 + `AppRoute` 名称，全部 `MaterialPageRoute` 收敛于此 | `app_router.dart` |
| 导入无事务/进度/预览、每词 1ms | 抽出 `WordImportService`（检测→预览→提交）：单事务分块写入 + 进度回调 + 确认弹窗；批量构造 Card 去掉 1ms/词 | `import_service.dart`、`word_management.dart`、`manager.dart` |
| 单词列表编辑结果类型不一致（`push<bool>` vs `pop<Word>`） | 统一为 `Route<Word>`，保存后按返回值刷新列表 | `word_view.dart`、`app_router.dart` |
| `Word.card` 是 `Future<Card>` | 模型改为直接持有 `Card`，去掉各处 `await word.card` | `word.dart`、`manager.dart`、各页面 |
| 日志跨天仍写旧文件 | `_DailyFileOutput` 按日期切换文件并同步日志查看路径；`getLogSize` 改为异步遍历 | `app_logger.dart` |

### 仍待处理

| # | 问题 | 位置 |
|---|---|---|
| 1 | FSRS 设置项是死代码（序列化了但 Scheduler 不用），且无设置 UI | `manager.dart` 顶部 vs `settings.dart` |
| 2 | `WordCard` “标记为熟知”只有 TODO；"纠错"实际是打开编辑页 | `word_card.dart` |
| 3 | 导出目标位置是硬编码的（Android 固定 `Documents/LexiGo`，未走 SAF 选目录；桌面固定下载目录），临时文件也未清理 | `word_management.dart` `_exportWords` |
| 4 | 学习会话固定 10 词；总结页 `wordsReviewed`/`wordsToReview` 恒为 0，提前结束时 `wordsLearned` 少算一条 | `learn.dart`、`learning_summarize.dart` |
| 5 | Android 权限模型过时（`READ_MEDIA_*` + `Permission.storage`）与 SAF 不匹配 | `AndroidManifest.xml`、`permission_manager.dart` |
| 6 | `getNextReviewWord` 只按 `due < now`，没有新卡/旧卡优先级、没有每日上限 | `manager.dart` |
| 7 | 没有任何自动化测试 | `test/`（不存在） |

## 8. 典型改动指南

**新增一条 UI 文案**：在 `lib/l10n/app_en.arb`（模板）和 `app_zh.arb` 各加一条；带参数的要在模板里加 `@key.placeholders`（顺序决定生成方法的参数顺序）→ `flutter gen-l10n` → 用 `context.l10n.xxx`。
**新增页面**：`lib/pages/...` 单文件一页（`XxxPage` + `_XxxPageState`）；在 `lib/app_router.dart` 的 `AppRoutes` 里加构建器和 `AppRoute` 名称，页面内用 `Navigator.push(context, AppRoutes.xxx(...))`，不要直接构造 `MaterialPageRoute`；文案走 l10n；进出页面打 `AppLogger.info`。
**新增数据表/字段**：改 `tables.dart` → bump `interface.dart` 的 `schemaVersion` 并实现 `MigrationStrategy`（drift 文档的 `onUpgrade` + `m.addColumn(...)`）→ `dart run build_runner build --delete-conflicting-outputs` → 修 `_wordToCompanion` / `_tableDataToWord` / 各表单页 / 导入列校验。
**新增学习语言**：`LanguageCode` 加值 → `fallback.dart` 加兜底词 → 外部导入表名映射自动生效 → 检查 `settings_editing` 语言名展示（目前直接显示 enum name）。
**支持 CSV/JSON 词表（推荐下一步）**：在现有 `lib/backend/word/import_service.dart` 上扩展解析器（`sqlite` 走 `prepare`，CSV/JSON 走新方法），复用 `ImportPlan` / `commit` 的事务 + 分块 + 进度；`word_management.dart` 只负责选文件和展示预览。批量构造 Card 用 `Card(cardId: base + i)`，不要逐词 `Card.create()`（每个 sleep 1ms）。
**改导出格式/目标位置**：`_exportWords` 目前用 `Database.external(driftDatabase(...))` 复用应用 schema 写临时 sqlite，再按平台分享/复制；若要改格式（CSV/JSON）或让用户选目录，改这一处即可，表结构写死在临时库的 drift schema 里。

## 9. 完成定义（Definition of Done）

- `dart analyze lib` 无 issue；`dart format` 无 diff。
- UI 改动使用 `AppTheme`/`app_ui.dart` 里的令牌与组件，没有新增硬编码颜色/圆角；已检查浅色/深色、小屏/桌面和中英文案不溢出。
- 新增/修改页面跳转 → 已在 `AppRoutes` 中声明，页面内没有裸 `MaterialPageRoute`。
- 改过 `tables.dart` → 已跑 build_runner，`interface.g.dart` 已更新。
- 新增用户可见文案 → 中英双语齐全。
- 手动验证：启动 → 学习（至少一次评分）→ 刷新后数据在 → 导入一份词表（含预览与进度）→ 记录页周条、日回顾、未来预测与单词详情；Android/桌面至少各跑一次（涉及文件/权限时）。
- 不提交构建产物（`build/`、`generated_plugin_*`、`.dart_tool/`）。
