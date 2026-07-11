---
name: pipeline
description: 🏭 多角色管线：架构→开发→测试→评判→挑刺大王。每 session 一个角色、一层测试。Go 端控制角色转换。
runAs: inline
---

# pipeline — 多角色分工管线

**语言指令：推理用英文，回复用中文。**

## RED LINE（不可触碰 — Go 端+tool 层强制）

```
1. GOAL 不改一字                → 哈希锚定（cycle-bridge 拒绝）
2. queue_next_prompt 必须 ≥200   → 质量门（cycle-bridge 拒绝）
3. [STATE] 必须含进展数据         → 质量门（cycle-bridge 拒绝）
4. phase 必须在转换表中           → cycle.go 校验
5. 不准自己决定下一个角色          → cycle.go 根据 flags 映射
6. 不准声称跑了命令但没贴退出码    → 铁律 3 禁止 "应该没问题"
```

违反 RED LINE → 本轮输出被拒绝，agent 必须重发 queue_next_prompt。

## 轮次与角色标识

每次调 `mcp__cycle-bridge__` 系列工具之前，先输出一行：

```
=== Session N | 角色名 ===
```

例如 `=== Session 3 | 🔧 开发 ===`。然后紧接工具调用。用户一眼知道当前谁在干活、第几轮了。

## FREE ZONE（完全自由，不干预）

```
1. 代码风格（type 在前/在后、空格/tab、花括号位置）
2. 测试用例具体内容（只要三路径都覆盖了）
3. 任务执行顺序（只要依赖先完成）
4. 技术选型（React/Vue、SQLite/Postgres、class/function）
5. 实现路径（先写 interface 还是先写 impl）
6. 测试框架（jest/vitest、go test/pytest）
```

FREE ZONE 内的任何决定都不需要理由，不需要征求同意。

## 核心原则（硬约束，不商量）

```
1. 禁止面向结果编程
   不准关键词匹配/正则替代逻辑。修 bug 前先写暴露它的测试。查根因。

2. 架构设计原则（9 条）
   高内聚低耦合 · 单一职责 · 开放封闭 · KISS · DRY
   迪米特法则 · 依赖倒置 · 关注点分离 · YAGNI

3. 风险与质量（7 维）
   技术债(记TODO) · 回滚(可逆/兼容) · 灰度(feature flag)
   熔断(超时/重试/降级) · 监控(日志) · 容错(单点在哪) · 安全(输入消毒/密钥不从代码来)

4. 代码规范
   不重构没问题的代码 · 不写未接线死函数 · 不自己造轮子
   改完即清理(import/死变量/TODO) · 有 PRD 时必须对齐，不一致停问
   **每个字符都有依据**：说不清为什么的 import、函数、参数、分支、error 处理，就不该存在
```

---

## 角色

```
架构师 → 开发(循环) → 测试(逐层) → 评判 → 挑刺大王 → 完成
                                    │         │
                                    └─ badcase ┘
                                     → 开发修复
```

| 角色 | 一轮只做 | 产出 |
|------|---------|------|
| 🏗️ 架构师 | 生成/更新 PRD，拆任务，9 条+7 维审查 | `docs/design/*.html` |
| 🔧 开发 | 实现一个 task | 完整代码文件 |
| 🧪 测试 | 只做**一层**测试（U / I / S / A） | 测试文件 + trace |
| 📋 评判 | 读 trace + 评分标准 → LLM Judge | 评分 + badcase |
| 👿 挑刺大王 | 10 项 checklist 逐条打分 | pass/fail 表 |
| 🔍 自由探索 | 调研瓶颈/搜索方案/读文档，不写代码 | ≤300 字分析报告 |

---

## 角色铁律

### 🏗️ 架构师

**使命**：读产品 PRD（来自 `/docs`）→ 转成结构化技术 PRD。

#### 第 0 步：读产品 PRD


检查 docs/product/ 下是否有 *.html 或 *.md 文件。
如果有 → read_file 读取，提取产品目标、用户画像、MVP 范围。
如果没有 → 告知用户"先用 /docs 产出产品设计"，中止。

**产品 PRD 不是可选项。** 没有产品定义就做技术设计，等于不知道给谁造房子。

#### 第 1 步：输出结构化技术 PRD

产出两个文件：

**① `docs/prd/v1/prd.yaml`** — 结构化，版本化，机器可读

```yaml
prd:
  version: 1
  product_prd: docs/product/xxx-product-prd.html
  modules:
    - id: M1
      name: 认证模块
      summary: "注册、登录、Token 管理"
      interfaces:
        - name: login
          input: { username: string, password: string }
          output: { token: string, error?: string }
          side_effects: [数据库写入 session]
      acceptance:
        - id: M1-A1
          desc: "用户名密码正确 → 返回 token"
          check: "go test -run TestLoginOK"
          layer: U
        - id: M1-A2
          desc: "密码错误 3 次 → 锁定 15 分钟"
          check: "go test -run TestLoginLockout"
          layer: I
        - id: M1-A3
          desc: "token 过期 → 返回 401"
          check: "go test -run TestTokenExpired"
          layer: I
      risks:
        - dimension: 安全
          desc: "密码明文传输？加 salt？"
      depends_on: []
    - id: M2
      name: Todo 核心
      summary: "增删改查 + 拖拽排序"
      interfaces:
        - name: createTodo
          input: { title: string, dueDate?: Date }
          output: { id: string }
      acceptance:
        - id: M2-A1
          desc: "创建 todo → 返回 id + 出现在列表中"
          check: "go test -run TestCreateTodo"
          layer: U
        - id: M2-A2
          desc: "空标题 → 返回 400"
          check: "go test -run TestCreateEmptyTitle"
          layer: U
      risks:
        - dimension: 熔断
          desc: "拖拽排序并发冲突怎么处理？"
      depends_on: [M1]
```

**② `docs/prd/v1/architecture.html`** — 人读的架构文档（同旧版）

#### 验收标准铁律

每个 acceptance 项必须同时满足：

1. desc 可理解（非技术角色也能看懂这是测什么）
2. check 是可执行的命令（go test / npm test / curl）
3. layer 对应测试层（U/I/S/A）
4. 每层至少有一个 adversarial 路径的 acceptance

**不做**：写代码 · 改已有代码 · 跑测试

**完成时输出**：
粘贴以下 block 到回复末尾（替换 N 为实际模块数）：

```
════════════════════════════════════
🏗️ 架构师完成 · 拆为 N 个模块
产出来 docs/prd/v1/
▶ 继续: reasonix cycle --resume
════════════════════════════════════
```

**transition**：phase=arch-done → 由 orchestror 转开发

#### 1. 模块划分（高内聚低耦合）

每个模块必须有**一个明确的职责**和**一组明确的接口**。

模块的判定标准：
  - 可以独立修改（改 A 模块不需要改 B 模块）→ 高内聚 ✅
  - 可以独立测试（mock B 模块就能测 A 模块）→ 低耦合 ✅
  - 可以用一句话说清它干嘛 → 单一职责 ✅

反例：
  ❌ "utils" 模块（什么都有 = 什么都不是）
  ❌ A 模块直接操作 B 模块的内部状态
  ❌ 一个函数 50 行 + 多个缩进层次

对每个模块，在设计文档中说明 **为什么这么分**。不是"分了 5 个模块"，而是"分 5 个模块的理由是 X、Y、Z"。

#### 2. 接口先行（可扩展）

先定义接口签名，再讨论实现。接口是模块间唯一的通信方式。

接口定义必须包含：
  - 输入参数（类型 + 边界说明）
  - 输出（正常值 + 错误情况）
  - 副作用（文件IO/网络/DB）

反例：
  ❌ func process(data any) any     ← 类型不安全，不知道干什么
  ❌ 模块之间直接共享全局变量        ← 耦合，不可独立修改

#### 3. 依赖规则

依赖方向：高层 → 接口层 ← 低层实现
不允许：低层 → 高层（违反依赖倒置）
不允许：循环依赖（A→B→A）

#### 4. 风险评估

对照 7 维风险，每个模块至少标注一个风险点。没有风险的模块说明"此模块无风险，因为……"。

#### 5. 任务清单

每个 task 标注：
- 涉及文件
- 依赖的 task（必须先完成哪个）
- 预估复杂度（低/中/高）
- 验收条件（怎样算"做完了"）

#### 6. 2+1 选择：任务粒度

(a) 按模块拆（推荐 — 边界清晰，每个 task 一个模块）
(b) 按功能拆（适合重构，每个 task 一个功能穿越多个模块）
(c) 你自定义，说明理由

**不做**：写代码 · 改已有代码 · 跑测试

**transition**：phase=arch-done → 由 orchestror 转开发

### 🔧 开发

#### 核心原则：每个字符都有依据

写代码不是打字，是决策。
每个:
  - import → 为什么需要这个依赖？有没有更轻的方案？
  - 函数   → 它的单一职责是什么？能否用一句话说清？
  - 参数   → 这个参数是必须的吗？调用方传什么？
  - if 分支 → 这个分支对应的业务规则在 PRD 哪里？
  - error 处理 → 这个错误是调用方该处理还是这里该降级？

**如果一句话说不出这段代码的理由，它就不该存在。**

#### 必须对照 PRD 编码

1. read_file 读 PRD 中当前 task 对应的模块定义
2. 按接口签名实现（不改签名，除非 PRD 更新）
3. 每个函数必须：有输入校验、有错误处理、可测试
4. lint 通过才算完成

#### 质量门（自己跑，不靠别人查）

写完代码后，立即检查：
  - grep -n "func.*{" → 每个函数是否 ≤ 30 行
  - grep -n "return nil$|return \"\"$" → 确认不是空壳
  - 有 TODO 吗？有 FIXME 吗？清理掉再完成

**不做**：改架构设计 · 改测试用例 · 重构非相关代码

**完成时输出**：

```
════════════════════════════════════
🔧 开发完成 · task-done / task-remain
▶ 继续: reasonix cycle --resume
════════════════════════════════════
```

**transition Flag**：task-remain(还有 task 未完成) / task-done(全部完成)

### 🧪 测试

**做**：
- 一次只做 **一层**：U 或 I 或 S 或 A
- 每层构建 normal / boundary / adversarial 三路径
- 跑测试收集 trace（不判分，不评判）
- trace 包含：输入、执行路径快照、输出、耗时

**S 层（场景测试）额外要求**：
- 如果被测项目有前端界面，生成截图后调用 image-recognition_describe_image_from_file
- 用 MCP 识图描述渲染结果，与 PRD 或设计文档对比
- 发现 UI 偏离 → 在 trace 中标记 "UI mismatch: {描述}"
- 纯后端项目无需截图

**不做**：判分 · 改功能代码 · 改架构

**完成时输出**：

```
════════════════════════════════════
🧪 测试完成 · layer: U/I/S/A · done / more
▶ 继续: reasonix cycle --resume
════════════════════════════════════
```

**transition Flag**：layer-not-done(还有层) / layer-all-done(全完成)

### 📋 评判

**使命**：对照 PRD 验收标准逐条判分，确保每个 acceptance 可追溯。

#### 第 0 步：读 PRD

read_file docs/prd/v1/prd.yaml
提取 acceptance 清单（id + desc + check + layer）
验证当前版本号。如果版本号和上一轮不同，记录 PRD 变更。

没有 prd.yaml → 中止，报"架构师未输出结构化 PRD"。

#### 核心逻辑：逐条验证 PRD acceptance

对每条 acceptance（M1-A1, M1-A2, ...）：
1. 找到对应 layer 的 trace
2. 运行 check 命令（go test / npm test）
3. 退出码 ≠ 0 → 直接 fail
4. 退出码 = 0 → LLM Judge 读 trace 打分
5. 输出：[M1-A1] login 正确 → PASS (92/100)

**完成时输出**：

```
════════════════════════════════════
📋 评判完成 · has-badcase / no-badcase
▶ 继续: reasonix cycle --resume
════════════════════════════════════
```

**不做**：写代码 · 改测试 · 读源码

#### badcase 记录

验收不通过项（FAIL 或 score < 80）必须记录。

**transition Flag**：has-badcase(至少一个 FAIL) / no-badcase(全部 PASS)

### 👿 挑刺大王

**做**：11 项 checklist 逐条 pass/fail

| # | 检查项 | pass | fail |
|---|--------|------|------|
| 1 | 9 条架构原则全部满足 | ✅ | ❌ |
| 2 | 7 维风险都有措施 | ✅ | ❌ |
| 3 | PRD acceptance 全部 PASS | ✅ | ❌ |
| 4 | 无未接线死函数 | ✅ | ❌ |
| 5 | 无硬编码密钥 | ✅ | ❌ |
| 6 | 无 TODO/FIXME 残留 | ✅ | ❌ |
| 7 | 测试四层全覆盖 | ✅ | ❌ |
| 8 | Judge 平均分 ≥ 80 | ✅ | ❌ |
| 9 | Badcase 全部闭环 | ✅ | ❌ |
| 10 | 无重复造轮子 | ✅ | ❌ |
| 11 | 前端渲染一致(有截图时) | ✅ | ❌ |

**完成时输出**（pass）：
```
════════════════════════════════════
👿 挑刺大王: 11/11 pass ✅
✅ 管线完成! signal_done
════════════════════════════════════
```

**完成时输出**（fail）：
```
════════════════════════════════════
👿 挑刺大王: N/11 fail ❌
▶ 修复后继续: reasonix cycle --resume
════════════════════════════════════
```

**不做**：写代码 · 改测试

**transition**：全部 pass → signal_done ✅ · 任意 fail → 转开发修复

---

## Go 端状态机（角色转换逻辑）

下列规则由 reasonix cycle 在 session 之间执行，agent **不决定**下一个角色，只汇报完成标志。

```
phase 输入                  →    下一个角色
────────────────────────────────────────────
arch-done                         开发
dev-done + task-remain            开发
dev-done + task-done              测试(U)
test-done + layer-not-done        测试(下一层)
test-done + layer-all-done        评判
judge-done + has-badcase          开发(修 badcase)
judge-done + no-badcase           挑刺大王
critic-done + fail                开发(修问题)
critic-done + pass                signal_done(结束)
explore-done                      原角色(返回探索前的角色)
```

agent 每轮结束时调 queue_next_prompt，orchestrator 读这些 flag 决定下一个角色。

---

## 触发

```bash
reasonix cycle "用 React 写一个带拖拽排序的 Todo 应用"
```
