---
name: cycle-install
description: 将 cyclic-workflow 插件安装到当前项目的 .reasonix/ 和全局 ~/.reasonix/ 中。
runAs: inline
---

# cycle-install — 安装循环工作流插件

你被要求将 cyclic-workflow 插件安装到当前项目中。

## 步骤 1：检查哪些目标缺失

检查以下目标位置：
- 全局 skill：`~/.reasonix/skills/cyclic-workflow/SKILL.md`
- 全局命令：`~/.reasonix/commands/cycle.md`
- 项目 skill：`.reasonix/skills/cyclic-workflow/SKILL.md`
- 项目命令：`.reasonix/commands/cycle.md`

记录缺失的项目。

**四种情况处理：**

| 全局 skill | 全局命令 | 项目 skill | 项目命令 | 处理 |
|-----------|---------|-----------|---------|------|
| ❌ 缺 | ❌ 缺 | ❌ 缺 | ❌ 缺 | **无法安装**——告诉用户去 GitHub 下载并运行 `install.bat` |
| ✅ 有 | ✅ 有 | ❌ 缺 | ❌ 缺 | 最常见——换项目了，步骤 1 记录缺项目级文件，继续步骤 2 |
| ✅ 有 | ❌ 缺 | ✅ 有 | ❌ 缺 | 继续步骤 2，装缺的 |
| ✅ 有 | ✅ 有 | ✅ 有 | ✅ 有 | 全部已装，告诉用户"已安装"结束 |

全局 skill 和全局命令应该同时存在或同时缺失（因为 `install.bat` 一起装），但上面的组合覆盖了所有可能。

## 步骤 2：定位源文件

从已有位置读取 `cyclic-workflow` SKILL.md 内容作为源：

1. 如果全局 skill 存在：`read_file ~/.reasonix/skills/cyclic-workflow/SKILL.md`
2. 否则如果项目 skill 存在：`read_file .reasonix/skills/cyclic-workflow/SKILL.md`
3. 如果两者都不存在——与步骤 1 矛盾（应该已返回"无法安装"），作为安全兜底，报错结束。

`cycle.md` 命令的内容不需要读源文件——用下方内联模板写入即可。

## 步骤 3：写入缺失的目标位置

按步骤 1 记录的缺失列表，逐项安装。已存在的跳过。

### 全局命令 `~/.reasonix/commands/cycle.md`（如果缺失）
```markdown
---
description: 启动三阶段循环工作流（设计→编码→验证），SSE 流式输出
argument-hint: [goal]
---
用户要求启动循环工作流。目标：$ARGUMENTS

请调用 `run_skill({name: "cyclic-workflow", arguments: "Goal: $ARGUMENTS"})` 直接在当前会话中执行三阶段。
所有工具调用通过事件流实时推送到前端。完成后展示产物路径。
```

### 全局 skill `~/.reasonix/skills/cyclic-workflow/SKILL.md`（如果缺失）
用步骤 2 读到内容，`write_file` 写入目标。

### 项目 skill `.reasonix/skills/cyclic-workflow/SKILL.md`（如果缺失）
用步骤 2 读到内容，`write_file` 写入目标。

### 项目命令 `.reasonix/commands/cycle.md`（如果缺失）
写入与全局命令相同的内联内容。

## 步骤 4：检查 reasonix.toml

检查当前项目是否有 `reasonix.toml` 且包含 `[[plugins]]` 段中注册了 `cycle-bridge`。

如果没有，告知用户需要在 `reasonix.toml` 中添加：
```toml
[[plugins]]
name    = "cycle-bridge"
command = "bin/cycle-bridge.exe"
```

`bin/cycle-bridge.exe` 可以从 bobanana4.0 的 `bin/` 目录复制。

## 完成提示

告知用户实际安装/跳过了哪些位置，以及现在可以在所有 workspace 中使用：
- TUI/桌面端：输入 `/cycle 你的目标`
- 终端：`reasonix cycle "你的目标"`
