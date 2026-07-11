# 🍌 banana4.0 — Reasonix 自驱开发管线

**让 AI 自己画图纸、自己写代码、自己测试、自己挑刺，你负责验收。**

```
                          🍌
                       banana4.0

  ┌─ 终端 ─────────────────────────────┐
  │  reasonix cycle "用React写一个Todo"  │
  └────────────────────────────────────┘
         │
         ▼  每个 session 一个角色，自动切换
  ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐   ┌──────────┐
  │ 🏗️ 架构师 │→ │ 🔧 开发  │→ │ 🧪 测试  │→ │ 📋 评判  │→ │ 👿 挑刺  │→ ✅
  │ 设计     │   │ 编码     │   │ U/I/S/A  │   │ trace打分│   │ checklist│
  └──────────┘   └──────────┘   └──────────┘   └──────────┘   └──────────┘
       │              │                              │              │
       └── badcase ───┘         架构师修方案 ─────────┘              │
                                                                     │
                                                           全部pass ─┘
```

---

## 📥 安装

```bash
# 1. 下载
git clone https://github.com/ProfYangShengXu/bobanana4.0.git

# 2. 进入你的项目目录
cd 你的项目

# 3. 一键安装（装到全局 ~/.reasonix/）
..\bobanana4.0\install.bat
```

**装一次 = 所有项目通用**。skill 装在 `~/.reasonix/skills/` 下，任何 Reasonix 会话自动加载。换项目不用重装。

---

## 🎮 使用

### 终端（推荐）

```bash
reasonix cycle "用 React + TypeScript 写一个带拖拽排序的 Todo 应用"
```

自动跑完整管线：架构师→开发→测试→评判→挑刺大王。每轮一个 session，跑几个小时。

### TUI / 桌面端

聊天框输入：

```
/pipeline 用 React + TypeScript 写一个带拖拽排序的 Todo 应用
```

效果同上，所有工具调用实时推送到前端。

---

## 📖 管线流程详解

### 6 个角色

| 角色 | 一轮只做一件事 | 产出 |
|------|-------------|------|
| 🏗️ **架构师** | 设计架构、拆任务、9条原则审查、7维风险分析 | `docs/design/*.html` |
| 🔧 **开发** | 实现一个 task（严格按 PRD，不准写空壳） | 完整代码文件 |
| 🧪 **测试** | 一层测试（U / I / S / A），三路径（normal/boundary/adversarial） | 测试文件 + trace |
| 📋 **评判** | 读 trace + LLM Judge 打分（不读源码） | 评分 + badcase |
| 👿 **挑刺大王** | 10 项 checklist 逐条 pass/fail | pass/fail 表 |
| 🔍 **自由探索** | 调研瓶颈、搜索方案、读文档（不写代码） | ≤300 字分析报告 |

### 状态转换规则（Go 端强制）

```
架构师完成     → 开发
开发有任务     → 开发（继续）
开发无任务     → 测试(U)
测试未全覆盖   → 测试（下一层）
测试全覆盖     → 评判
评判有badcase  → 架构师（修方案）→ 开发（修复）
评判无badcase  → 挑刺大王
挑刺大王发现问题 → 开发（修复）
挑刺大王全部pass → ✅ 结束

自由探索完成   → 回到探索前的角色
```

**agent 不决定下一个角色。** agent 只设 flag（`task_done`、`has_badcase`），`reasonix cycle` 的 Go 代码根据映射表算下一个角色。

### 完整管线示例

```
reasonix cycle "用 React 写一个带拖拽排序的 Todo"
```

| Session | 角色 | 做了什么 | 简报 |
|---------|------|---------|------|
| 1 | 🏗️ 架构师 | 拆 5 个模块，写设计文档 | arch-1 |
| 2 | 🔧 开发 | 实现 model/todo.ts | dev-1 |
| 3 | 🔧 开发 | 实现 TodoItem.tsx | dev-2 |
| 4 | 🔧 开发 | 实现 TodoList + 拖拽 | dev-3 |
| 5 | 🔧 开发 | 实现 AddTodo + App.tsx | dev-4, task-done |
| 6 | 🧪 测试 | U 层 18 个用例 | test-U |
| 7 | 🧪 测试 | I 层 10 个用例 | test-I |
| 8 | 🧪 测试 | S 层 5 个用例 | test-S |
| 9 | 🧪 测试 | A 层 4 个用例, layer-all-done | test-A |
| 10 | 📋 评判 | trace 评分 92/100，发现 2 badcase | judge, has-badcase |
| 11 | 🏗️ 架构师 | 分析 badcase 修方案 | fix-arch |
| 12 | 🔧 开发 | 修复 2 个问题 | fix-dev |
| 13 | 📋 评判 | 确认 badcase 闭环 | judge, no-badcase |
| 14 | 👿 挑刺大王 | 10 项 checklist 全 pass | ✅ signal_done |

---

## 🔄 管线 vs 循环

banana4.0 提供两种工作模式：

```
管线（pipeline）                         循环（loop）
─────────────────────────────────────────────────
多个角色轮流上场                       只有一个角色
架构师→开发→测试→评判→挑刺大王         自己改自己验
适合：从零建项目                       适合：已有代码打磨
每轮切换角色                           每轮改一件事
Go 端控制下一个角色                     自己决定下一轮
专职测试 + 评判打分                     铁律 4 条自检
完整交付：设计+代码+测试+审查           单一指标提升
```

**管线模式（从零建项目）：**
```
Session 1:  架构师   → 写设计文档
Session 2-6: 开发    → 逐个实现 5 个模块
Session 7:  测试(U)  → 20 个单元测试
Session 8-9: 测试    → I/S 层
Session 10: 评判     → 发现 2 badcase
Session 11: 架构师   → 修方案
Session 12: 开发     → 修复
Session 13: 评判     → 确认闭环
Session 14: 挑刺大王 → 全 pass → ✅
```

**循环模式（打磨已有代码）：**
```
Session 1: 覆盖率 40% → 加测试 → 55%
Session 2: 覆盖率 55% → 加测试 → 70%
Session 3: 覆盖率 70% → 加测试 → 92% → ✅
```

---

## 🛡️ 硬约束与自由区

### RED LINE（不可触碰，Go + MCP 强制）

| 红线 | 违反后果 |
|------|---------|
| GOAL 不能改一个字 | 哈希锚定拒绝（cycle-bridge） |
| queue_next_prompt 必须 ≥200 字符 | 质量门拒绝 |
| [STATE] 必须有进展数据 | 质量门拒绝 |
| phase 必须在转换表中 | cycle.go 校验失败 |
| agent 不能自己决定下一个角色 | cycle.go 覆盖 |
| 不准说"应该没问题" | 必须贴退出码+输出 |

### FREE ZONE（不干预，完全自由）

```
- 代码风格（type 在前/在后、空格/tab）
- 测试用例具体内容（只要三路径覆盖）
- 任务执行顺序（只要依赖先完成）
- 技术选型（React/Vue、SQLite/Postgres）
- 实现路径（先 interface 还是先 impl）
- 测试框架（jest/vitest、pytest/go test）
```

---

## 🧪 分层测试体系

每层一个 session，逐层覆盖：

```
U 层（单元测试）    每个函数 × normal/boundary/adversarial
I 层（集成测试）    模块间交互链路 × 3 路径
S 层（场景测试）    完整用户操作 × 3 路径
A 层（安全测试）    攻击面 × 3 路径
```

测试角色只负责生成用例 + 跑 + 收 trace。不判分。
评判角色只读 trace，不读源码，用 LLM Judge 打分。
badcase 记录到 `.reasonix/badcases/`，自动进入修复管线。

---

## 🛠️ 自己编译

```bash
# 在 reasonix 源码目录下编译
cd /path/to/reasonix
go build -o ./bobanana4.0/bin/reasonix.exe    ./cmd/reasonix/
go build -o ./bobanana4.0/bin/cycle-bridge.exe ./cmd/cycle-bridge/
```

---

## ⬆️ 更新

```bash
cd bobanana4.0
git pull
cd 你的项目
..\bobanana4.0\install.bat    # 覆盖更新，新增 skill 自动补
```

---

## 📦 仓库结构

```
bobanana4.0/
├── README.md
├── install.bat            ← 一键安装
├── Bobanana.md            ← 核心工程大纲
├── commands/cycle.md      ← /cycle 命令
└── skills/
    ├── pipeline/          ← 🏭 多角色管线（入口）
    ├── docs/              ← 📄 设计文档
    ├── cycle/             ← 🔄 多 agent 并行
    ├── loop/              ─ 🌀 单 agent 串行
    └── install/           ← 🍌 安装器
```

---

## 📜 许可证

MIT
