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

记录缺失的项目。**如果全局 skill 也不存在**（四个位置全部缺失）——说明当前环境就没有 cyclic-workflow，无法安装。告诉用户先去 reasonix 源码项目编译运行一次 `/cycle` 或手动运行 `scripts/cycle-install.bat`。

**如果全局 skill 存在但项目级缺失**（最常见场景——桌面端用了新 workspace）：不需要停，继续步骤 2，只安装缺少的项目级文件。

## 步骤 2：定位源文件

用 `read_file` 读取以下路径（按优先级），确保读取成功后再继续：
1. `~/.reasonix/skills/cyclic-workflow/SKILL.md`（全局）
2. `.reasonix/skills/cyclic-workflow/SKILL.md`（项目级）
3. 如果前两者都不存在——说明当前环境本身就还没装 cyclic-workflow，无法安装。告诉用户先去 reasonix 源码项目编译并运行一次 `/cycle`，让 skill 生成到全局目录，或者手动运行 `scripts/cycle-install.bat`。

## 步骤 3：写入缺失的目标位置

按步骤 1 记录的目标缺失列表，逐项安装。已存在的跳过。

### 全局 skill（~/.reasonix/skills/cyclic-workflow/SKILL.md）
如果缺失：用步骤 2 读到内容，`write_file` 写入目标。

### 全局命令（~/.reasonix/commands/cycle.md）
如果缺失，用 `write_file` 创建：
```markdown
---
description: 启动三阶段循环工作流（设计→编码→验证），SSE 流式输出
argument-hint: [goal]
---
用户要求启动循环工作流。目标：$ARGUMENTS

请调用 `run_skill({name: "cyclic-workflow", arguments: "Goal: $ARGUMENTS"})` 直接在当前会话中执行三阶段。
所有工具调用通过事件流实时推送到前端。完成后展示产物路径。
```

### 项目 skill（.reasonix/skills/cyclic-workflow/SKILL.md）
如果缺失：用步骤 2 读到内容，`write_file` 写入目标。

### 项目命令（.reasonix/commands/cycle.md）
如果缺失：写入与全局命令相同的内容。

## 步骤 4：检查 reasonix.toml

检查当前项目是否有 `reasonix.toml` 且包含 `[[plugins]]` 段中注册了 `cycle-bridge`。

如果没有，告知用户需要在 `reasonix.toml` 中添加：
```toml
[[plugins]]
name    = "cycle-bridge"
command = "bin/cycle-bridge.exe"
```

注意：`bin/cycle-bridge.exe` 需要先编译（`go build -o bin/cycle-bridge.exe ./cmd/cycle-bridge/`）或从已安装的 reasonix 项目拷贝。

## 完成提示

告知用户实际安装/跳过了哪些位置，以及现在可以在所有 workspace 中使用：
- TUI/桌面端：输入 `/cycle 你的目标`
- 终端：`reasonix cycle "你的目标"`
