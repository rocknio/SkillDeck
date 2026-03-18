# Skill Content Inline zh-CN Translation (方案A) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**目标：**在右侧 Skill 内容展示页中，对英文 Markdown 内容的“段落（Paragraph）”提供中文翻译，并在英文段落下方紧接展示中文译文。

**架构：**使用 swift-markdown 将 Markdown 解析为 AST；渲染仍由现有 `MarkdownContentView` 负责，但在遇到 `Paragraph` 节点时，先渲染英文段落，再异步调用免费在线翻译服务（MyMemory API）获取中文译文，并将译文以次要样式（secondary、稍小字号）插入到该段落下方。翻译请求通过新的 `TranslationService`（Swift `actor`）进行网络访问与缓存，UI 侧通过 `@Environment(SkillManager.self)` 获取服务入口，避免在 View 内直接持有 URLSession。

**技术栈：**SwiftUI (macOS 14+)、swift-markdown、URLSession、XCTest。

---

## 验收标准（Pass/Fail）

1. 打开任意 Skill 详情页（本地 Skill、skills.sh Registry、ClawHub），在“Skill Content/Documentation”区域内：每个英文段落下方会出现一段中文译文。
2. 译文与英文段落的对应关系稳定：翻译结果不会串段，不会因为滚动/刷新错位。
3. 翻译失败时不会崩溃；该段落下方显示“翻译失败/翻译中”中的一种占位文本。
4. `swift test` 全绿；`swift build` 成功；`swift run SkillDeck` 能启动（手动确认在详情页可见译文）。

---

## Task 0：基线测试

**Step 1：运行全量测试（基线必须先绿）**

Run:

```bash
swift test
```

Expected:

- `Executed ... tests, with 0 failures`

---

## Task 1：RED — 新增单元测试（纯文本提取 + MyMemory 响应解析）

**Files:**

- Create (tests): `Tests/SkillDeckTests/MarkdownPlainTextExtractorTests.swift`
- Create (tests): `Tests/SkillDeckTests/TranslationServiceTests.swift`

**Step 1：写失败测试（允许先不编译通过 = RED）**

1) `MarkdownPlainTextExtractorTests`：验证从 `Paragraph` AST 节点提取纯文本（含加粗/斜体/inline code/link）。

2) `TranslationServiceTests`：验证 MyMemory 的 JSON 响应解析逻辑（`responseStatus` 既可能是 Int 也可能是 String）。

**Step 2：运行测试验证 RED**

Run:

```bash
swift test --filter MarkdownPlainTextExtractorTests
swift test --filter TranslationServiceTests
```

Expected:

- 失败原因应为“类型/方法不存在”或断言失败（功能尚未实现）。

---

## Task 2：GREEN — 实现最小生产代码（提取器 + 翻译服务 + 缓存）

**Files:**

- Create (prod): `Sources/SkillDeck/Utilities/MarkdownPlainTextExtractor.swift`
- Create (prod): `Sources/SkillDeck/Services/TranslationService.swift`
- Modify (prod): `Sources/SkillDeck/Services/SkillManager.swift`

**Step 1：实现 `MarkdownPlainTextExtractor`**

- API：`enum MarkdownPlainTextExtractor { static func extract(from markup: any Markup) -> String }`
- 行为：递归遍历子节点，只拼接可见文本（`Markdown.Text`、`InlineCode` 等），把软换行当空格。

**Step 2：实现 `TranslationService`（MyMemory）**

- actor + 内存缓存 `[String: String]`
- MyMemory endpoint：`https://api.mymemory.translated.net/get?q=...&langpair=en|zh-CN`
- 解析字段：`responseData.translatedText`、`responseStatus`、`responseDetails`、`quotaFinished`
- 对 `responseStatus` 做“Int/String 兼容解析”。

**Step 3：在 `SkillManager` 暴露翻译入口**

- 新增私有依赖 `TranslationService`
- 新增方法：`func translateEnglishParagraphToChinese(_ text: String) async throws -> String`

**Step 4：运行测试验证 GREEN**

Run:

```bash
swift test --filter MarkdownPlainTextExtractorTests
swift test --filter TranslationServiceTests
```

Expected:

- All pass.

---

## Task 3：接入 UI — 在段落下方插入译文

**Files:**

- Modify (prod): `Sources/SkillDeck/Views/Components/MarkdownContentView.swift`
- Modify (prod): `Sources/SkillDeck/Views/Detail/SkillDetailView.swift`

**Step 1：扩展 `MarkdownContentView` 支持“逐段翻译显示”**

- 仅对 `Paragraph` 节点启用。
- 对每个段落：渲染英文段落 → 异步翻译 → 在其下方渲染中文 `Text`。
- 翻译调用路径：View → `SkillManager`（Environment 注入）→ `TranslationService`。

**Step 2：本地 Skill 详情页启用新渲染器**

- `SkillDetailView` 的 markdown 区域改为使用 `MarkdownContentView`，并开启“显示中文译文”。

---

## Task 4：验证（必须）

**Step 1：全量测试**

```bash
swift test
```

**Step 2：构建**

```bash
swift build
```

**Step 3：手动验证（真实运行）**

```bash
swift run SkillDeck
```

Expected:

- App 能启动；打开任意 Skill 详情页可看到每个英文段落下方出现中文译文。
