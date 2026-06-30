---
description: 启动三阶段循环工作流（设计→编码→验证），SSE 流式输出
argument-hint: [goal]
---
用户要求启动循环工作流。目标：$ARGUMENTS

请调用 `run_skill({name: "cyclic-workflow", arguments: "Goal: $ARGUMENTS"})` 直接在当前会话中执行三阶段。

### 执行方式

1. **首选**：`run_skill({name: "cyclic-workflow", arguments: "Goal: $ARGUMENTS"})`
   - 该 skill 是 inline 模式，body 折入当前 turn
   - 所有工具调用（write_file、task、bash verify.sh）通过 SSE/事件流实时推送到前端
   - 三阶段在**同一会话**内自动衔接
   - **不要**用 bash 执行 `reasonix cycle`——那样会创建子进程，输出不会实时流式推送

2. **备用**：如果 `run_skill` 不可用，提示用户在终端中执行 `reasonix cycle "$ARGUMENTS"`
   - 编译：`go build -o bin/reasonix.exe ./cmd/reasonix/`
   - 运行：`reasonix cycle "$ARGUMENTS"`

### 完成后

展示产物路径给用户：
- 设计文档：`docs/design/<项目>-design.html`
- 验证脚本：`docs/design/<项目>-verify.sh`
- 验证结果：通过/失败统计
