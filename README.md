# 🍌 banana4.0 — Reasonix 自驱开发管线

**让 AI 自己画图纸、自己写代码、自己测试、自己挑刺，你负责验收。**

> 适配 Reasonix v0.54+（Desktop / TUI / CLI），含 Runtime Profiles 和 Goal Mode 支持。
> 内附预编译二进制（`reasonix.exe` + `cycle-bridge.exe`），clone 即用。

---

## 📥 安装

### 🧑 新手安装（5 分钟上手）

> 适用于：没有编程经验、不熟悉命令行的用户。
> 提供了两种方式：**自动下载**（推荐，不用装 Git）或 **Git 克隆**。

#### 第 1 步：下载项目

**方式 A——直接下载 ZIP（推荐，不用装 Git）：**

1. 打开浏览器访问 https://github.com/ProfYangShengXu/bobanana4.0
2. 点绿色的 **"Code"** 按钮，选 **"Download ZIP"**
3. 解压到 `C:\Users\你的用户名\bobanana4.0`（右键压缩包 → 解压到当前文件夹，然后把文件夹名改成 `bobanana4.0`）
4. 进入 `C:\Users\你的用户名\bobanana4.0`，**双击 `install.bat`**（看到黑色窗口弹出就对了）

> 如果双击后一闪而过没反应，右键 `install.bat` → **"以管理员身份运行"**。

**方式 B——Git 克隆（需要装 Git）：**

打开文件夹 `C:\Users\你的用户名`，在地址栏输入 `cmd` 回车，在弹出的黑窗口中粘贴：

```powershell
git clone https://github.com/ProfYangShengXu/bobanana4.0.git
```

> 如果提示"git 不是内部或外部命令"，先百度搜索"Git 下载安装"，装完重启黑窗口。

#### 第 2 步：找到你的项目文件夹

假设你的项目在 `D:\我的项目`，在黑窗口中输入：

```powershell
cd /d D:\我的项目
```

#### 第 3 步：一键安装

```powershell
C:\Users\你的用户名\bobanana4.0\install.bat
```

看到 `=== Done ===` 就装好了。

#### 第 4 步：启动 Reasonix

```powershell
reasonix chat
```

如果提示"reasonix 不是命令"，把 `C:\Users\你的用户名\bobanana4.0\bin` 加到系统环境变量 Path 中（百度"Windows 添加环境变量"）。

#### 第 5 步：开始使用

在 Reasonix 聊天框输入：

```
/pipeline 帮我用 React 写一个 Todo 应用
```

开始你的第一个全自动开发管线 🎉

---

### 👨‍💻 开发者安装

```powershell
# 1. 下载
git clone https://github.com/ProfYangShengXu/bobanana4.0.git

# 2. 进入你的项目目录
cd 你的项目

# 3. 一键安装
..\bobanana4.0\install.bat
```

**装一次 = 所有项目通用**。skill 装在 `~/.reasonix/skills/` 下，任何 Reasonix 桌面端或 CLI 会话自动加载。换项目不用重装。

---

## 🏗️ 架构总览

### 角色管线

```
┌─────────────────────────────────────────────────────────┐
│                    用户入口（三选一）                      │
│                                                         │
│  🖥️ 桌面端 (Wails)     💬 TUI (终端)     ⌨️ CLI (终端)  │
│  /pipeline 目标        /pipeline 目标    reasonix cycle  │
└───────────────────────┬─────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────┐
│                🏗️ 架构师 → 拆任务、出 PRD                │
├─────────────────────────────────────────────────────────┤
│                🔧 开发 → 逐个实现 task                   │
│                    ↻ task-remain                         │
├─────────────────────────────────────────────────────────┤
│  🧪 测试 → 逐层覆盖（U → I → S → A）                    │
│  每层 normal / boundary / adversarial 三路径             │
├─────────────────────────────────────────────────────────┤
│  📋 评判 → 对照 PRD acceptance 逐条判分                 │
│           ↻ has-badcase → 回开发修复                     │
├─────────────────────────────────────────────────────────┤
│  👿 挑刺大王 → 11 项 checklist，全部 pass → ✅          │
│           ↻ fail → 回开发修复                            │
└─────────────────────────────────────────────────────────┘
```

### 每 Session 一个角色

每个角色跑一个独立的 Reasonix session。角色完成后：

1. Agent 调用 `queue_next_prompt` 写状态到 `.reasonix/cycle/`
2. 用户执行 `reasonix cycle --resume` 切换到下一角色
3. Orchestrator（Go）读取 `state.json` 的 `phase`，查 `roleTransitions` 表决定下一角色

**agent 不决定下一个角色**——只汇报完成标志（task-done / has-badcase 等），orchestrator 精确映射。

### 核心组件

```
bobanana4.0/
│
├── skills/pipeline/SKILL.md     ← 管线 playbook（核心，~500 行）
│   ├── RED LINE #1-7            不可触碰规则
│   ├── 📋 Prompt 模板            [GOAL][PHASE][ROLE][DONE][STATE][NEXT]
│   ├── 5 个角色铁律              架构师/开发/测试/评判/挑刺大王
│   └── 🚨 强制过渡段             每个角色尾部强制 queue_next_prompt
│
├── skills/loop/SKILL.md         轻量管线（开发+测试，2 角色）
├── skills/cycle/SKILL.md        并行循环（每批多 task 并行）
├── skills/docs/SKILL.md         产品设计文档（HTML + YAML）
├── skills/install/SKILL.md      安装器
│
├── bin/
│   ├── reasonix.exe             预编译 Reasonix 引擎
│   └── cycle-bridge.exe         跨 session 状态桥梁（MCP 插件）
│
├── commands/cycle.md             /cycle 斜杠命令定义
└── install.bat                   一键安装脚本
```

### 状态桥梁：cycle-bridge MCP

`cycle-bridge` 是一个独立的 MCP stdio 插件，Reasonix 启动时作为子进程拉起。提供三个工具：

| MCP 工具 | 调用者 | 作用 |
|----------|--------|------|
| `queue_next_prompt(phase, prompt, goal)` | Agent（角色完成时） | 校验 phase + prompt → 写入 state.json + next_prompt.txt |
| `get_cycle_state()` | Agent（管线入口） | 读取当前 cycle 状态 |
| `signal_done(summary)` | Agent（全部完成） | 标记完成，orchestrator 退出 |

**校验链**（每次 queue_next_prompt 执行）：
1. `validPhases[phase]` — 26 个合法阶段名
2. prompt ≥ 200 字符 — 拒绝空壳
3. 含 `[GOAL][PHASE][DONE][NEXT]` — 拒绝遗漏段
4. `[STATE]` 含 task_list / test_coverage / badcase — 拒绝无进展数据
5. `[NEXT]` ≥ 50 字符 — 拒绝模糊指令
6. `[GOAL]` hash 防漂移 — 哈希锚定，拒绝目标篡改

---

## 🎮 使用指南（桌面端优先）

### 场景一：完整项目开发

桌面端聊天框输入：

```
/pipeline 用 React + TypeScript 写一个带拖拽排序的 Todo 应用
```

当前 session 跑 **架构师角色**——产出技术 PRD、拆分任务。完成后 agent 自动调用 `queue_next_prompt` 保存状态。

切换到终端（或桌面端内置终端）：

```powershell
reasonix cycle --resume
```

自动进入 **开发角色**——逐个实现 task。再 `--resume` 进入测试→评判→挑刺，直到 `signal_done`。

**桌面端视觉反馈**：所有工具调用（write_file、bash、task）通过事件流实时推送到前端，你可以看到 AI 一步步操作。

### 场景二：小功能 / 修 Bug

```
/loop 给 user 列表加一个搜索框
```

比 pipeline 角色少（只有开发+测试），适合快速改动。

### 场景三：长线目标（Goal 模式）

1. 点击输入框左下角 **协作方式 → 目标**
2. 输入：

```
/pipeline 持续优化数据库查询，直到单次查询 < 100ms
```

管线自动推进，Goal 的 TASK_CONTRACT 通过 `[GOAL]` 哈希锚定跨 session 保留。你只需在终端跑 `reasonix cycle --resume` 继续下一角色，最终 `signal_done` 自动结束。

### 场景四：质量优先（Delivery 模式）

点击左下角菜单 → **运行模式 → 交付优先**，然后：

```
/pipeline 修复登录页 CSRF 漏洞
```

Delivery 模式增加额外合约：

| 合约 | 说明 |
|------|------|
| 验收清单前置 | 变更前必须有 `todo_write` 看板 |
| 变更后复查 | 每次变更后必须有 `complete_step` 引用验证命令 |
| 中高风险 review | 认证/I/O/跨模块变更必须调 `review`/`security_review` |
| 证据链完整 | `complete_step` 必须有 `kind: verification` 或 `kind: diff` |
| 禁止空壳 | "已实现"无代码变更、"已测试"无退出码 → 宿主拒绝 |

---

## 🔄 管线流程详解

### 6 个角色

| 角色 | 一轮只做 | 产出 |
|------|---------|------|
| 🏗️ **架构师** | 读产品 PRD / 基于目标推断 → 输出结构化技术 PRD | `docs/prd/v1/prd.yaml` + `architecture.html` |
| 🔧 **开发** | 实现一个 task（严格按 PRD 接口签名） | 完整代码文件 |
| 🧪 **测试** | 只做**一层**（U / I / S / A），三路径覆盖 | 测试文件 + trace |
| 📋 **评判** | 读 trace + LLM Judge 打分 | 评分 + badcase 清单 |
| 👿 **挑刺大王** | 11 项 checklist 逐条 pass/fail | pass/fail 表 |
| 🔍 **自由探索** | 调研瓶颈、搜索方案、读文档（不写代码） | ≤300 字分析报告 |

### 状态转换

```
phase 输入                  →    下一个角色
────────────────────────────────────────────
arch-done                         开发
dev-done_task-remain              开发（继续）
dev-done_task-done                测试(U)
test-done_layer-not-done          测试(下一层)
test-done_layer-all-done          评判
judge-done_has-badcase            开发（修复）
judge-done_no-badcase             挑刺大王
critic-done_fail                  开发（修复）
critic-done_pass                  ✅ signal_done
```

### 完整示例（14 sessions）

```
Session  1: 🏗️ 架构师   → 拆 5 个模块，写设计文档         arch-1
Session  2-5: 🔧 开发   → 逐个实现模块                    dev-1~4, task-done
Session  6: 🧪 测试(U)  → 18 个单元测试                    test-U
Session  7: 🧪 测试(I)  → 10 个集成测试                    test-I
Session  8: 🧪 测试(S)  → 5 个场景测试                      test-S
Session  9: 🧪 测试(A)  → 4 个安全测试                      test-A, layer-all-done
Session 10: 📋 评判     → 评分 92/100，发现 2 badcase       judge, has-badcase
Session 11: 🏗️ 架构师   → 分析 badcase 修方案               fix-arch
Session 12: 🔧 开发     → 修复 2 个问题                     fix-dev
Session 13: 📋 评判     → 确认 badcase 闭环                 judge, no-badcase
Session 14: 👿 挑刺大王 → 11/11 pass → ✅ signal_done       critic-done_pass
```

### 分层测试体系

```
U 层（单元测试）    每个函数 × normal / boundary / adversarial
I 层（集成测试）    模块间交互链路 × 3 路径
S 层（场景测试）    完整用户操作 × 3 路径
A 层（安全测试）    攻击面 × 3 路径
```

测试角色只负责生成用例 + 跑 + 收 trace，不判分。评判角色只读 trace，不读源码，用 LLM Judge 打分。badcase 记录到 `.reasonix/badcases/` 进入修复管线。

### S 层可视化验证

前端项目测试时，S 层会自动截图并调用 MCP 识图比对渲染结果与 PRD 设计文档，标记 UI 偏离。

---

## 📋 Prompt 模板（跨 session 上下文传递）

每个角色完成时传递给下一 session 的 prompt 必须严格按以下结构：

```
[GOAL] <原始目标，一字不改>
[PHASE] <当前阶段名>
[ROLE] <当前角色名>
[DONE] <完成了什么，3-5 条 bullet，包含 Artifacts: 路径列表>
[STATE] task_list: M1✅ M2⏳ M3⬜    ← ≥2 项任务
         或 test_coverage: U:18/18(100%) I:10/10(100%)   ← 含百分比
         或 badcase: 数量及描述
[NEXT] <下一阶段的具体指令，≥50 字符>
```

**质量门**：prompt ≥ 200 字符 | [STATE] 必须有数据 | [NEXT] ≥ 50 字符 | task_list ≥ 2 项 | test_coverage 含百分比

---

## 🛡️ RED LINE（不可触碰）

| 红线 | 违反后果 |
|------|---------|
| GOAL 不能改一个字 | 哈希锚定拒绝 |
| queue_next_prompt 必须 ≥200 | 质量门拒绝 |
| [STATE] 必须有进展数据 | 质量门拒绝 |
| phase 必须在转换表中 | 校验失败 |
| agent 不能自己决定下一角色 | cycle.go 覆盖 |
| 不准说"应该没问题" | 必须贴退出码+输出 |
| **角色完成 = 立即 queue_next_prompt** | 不准停顿、不准征求同意 |

---

## 🛠️ 自己编译

```bash
# 需要 Go 1.25+
cd /path/to/reasonix
go build -o ./bobanana4.0/bin/reasonix.exe    ./cmd/reasonix/
go build -o ./bobanana4.0/bin/cycle-bridge.exe ./cmd/cycle-bridge/
```

---

## 📦 仓库结构

```
bobanana4.0/
├── README.md                  ← 本文件
├── install.bat                ← 一键安装到全局
├── Bobanana.md                ← 核心工程大纲（agent 必读）
├── commands/
│   ├── cycle.md               ← /cycle 斜杠命令
│   └── pipeline.md            ← /pipeline 斜杠命令（自动生成）
├── skills/
│   ├── pipeline/              ← 🏭 多角色管线（核心）
│   ├── docs/                  ← 📄 产品设计文档
│   ├── cycle/                 ← 🔄 多 agent 并行循环
│   ├── loop/                  ─ 🌀 单 agent 串行循环
│   └── install/               ← 🍌 安装器
└── bin/
    ├── reasonix.exe           ← 预编译引擎
    └── cycle-bridge.exe       ← MCP 状态桥梁
```

---

## 📜 许可证

MIT
