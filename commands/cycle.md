---
description: 启动管线（pipeline）或循环模式。推荐用 /pipeline 开始完整项目。
argument-hint: [goal]
---
用户要求启动循环工作流。目标：$ARGUMENTS

请调用 `run_skill({name: "pipeline", arguments: "Goal: $ARGUMENTS"})` 开启多角色管线。

- 管线 `/pipeline`：架构师→开发→测试→评判→挑刺大王。适合完整项目。
- 循环 `/loop target=...`：单 agent 串行迭代。适合打磨已有代码。

直接用 `run_skill({name: "pipeline", arguments: "Goal: $ARGUMENTS"})`。
完成后展示产物路径。
