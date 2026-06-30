# 🍌 banana4.0 — Reasonix 循环工作流插件

**让 AI 自己画图纸、自己搬砖、自己检查，你去喝咖啡。**

```
                       🍌
                    ╱  ╲
        ┌──────────┴────┴──────────┐
        │        banana4.0          │
        │   🎨 设计 → 🔧 执行 → ✅ 验证 │
        └───────────────────────────┘
```

---

## 🚀 安装（两种方式）

### 方式 A：新用户入门（推荐）

```bash
# 1. 把仓库拉到本地
git clone https://github.com/ProfYangShengXu/bobanana4.0.git

# 2. 进入你的项目目录
cd 你的项目

# 3. 运行安装脚本
..\bobanana4.0\install.bat
```

安装脚本做三件事：

**① 装到全局 `~/.reasonix/`（所有项目通用）**
- `~/.reasonix/skills/cyclic-workflow/SKILL.md`
- `~/.reasonix/skills/cycle-install/SKILL.md`
- `~/.reasonix/commands/cycle.md`

**② 装到当前项目**
- `.reasonix/skills/cyclic-workflow/SKILL.md`
- `.reasonix/commands/cycle.md`

**③ 检查 `reasonix.toml`** 插件配置

> **装一次，换项目不用重装。** 因为 skill 和命令都在 `~/.reasonix/` 全局目录下，所有 workspace 都能看到。

### 方式 B：换项目时（全局已有 skill）

如果已经通过方式 A 装过（全局 `~/.reasonix/` 下有 `cycle-install` skill），换到新项目时直接在 Reasonix 聊天框输入：

```
/skill cycle-install
```

Agent 会检测新项目缺了哪些文件，自动补上。

> **第一次装不能用 `/skill cycle-install`**——因为你还没有全局 skill。必须先走一次方式 A。

---

## 🎮 使用

### 终端（哪都能跑，不挑环境）

```bash
reasonix cycle "用 React 写一个带拖拽排序的 Todo 应用"
```

三阶段依次输出到终端，最后打印完成摘要。

### TUI / 桌面端 / Web GUI

输入：

```
/cycle 用 React 写一个带拖拽排序的 Todo 应用
```

Agent 在当前会话中直接执行三阶段，所有工具调用实时推送到前端。

---

## 🍿 三阶段流水线

```
你输入 /cycle 目标
     │
     ▼
┌──────────────────────────────────────┐
│ Phase 1 🎨  设计                      │
│                                      │
│  · get_cycle_state → phase=none      │
│  · write_file → design.html          │
│  · write_file → verify.sh            │
│  · queue_next_prompt → Phase 2       │
└──────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Phase 2 🔧  执行                      │
│                                      │
│  · todo_write → 创建任务看板          │
│  · task("模块A") → 子 agent 编码      │
│  · complete_step → 签收 + 证据       │
│  · 每3个任务抽查1个 → spot-check      │
│  · 填充 verify.sh → 实命令替换占位符   │
└──────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Phase 3 ✅  验证                      │
│                                      │
│  · 完整性检查 → 不是空壳 ✓            │
│  · bash verify.sh → 退出码 0?        │
│    ├─ 是 → signal_done → 🎉          │
│    └─ 否 → 修复 → 重跑（最多5轮）     │
└──────────────────────────────────────┘
     │
     ▼
🚀 全部搞定，等你验收
```

每一步都实时推送到你的聊天窗口——不是黑盒等半小时。

---

## ☕ 三种使用场景

| 场景 | 命令 | 适合谁 |
|------|------|--------|
| 终端一键跑完 | `reasonix cycle "目标"` | 长时间任务、不想盯着看 |
| TUI/桌面端交互 | `/cycle 目标` | 想实时看进度、Phase 1 后想改设计 |
| 中断后续跑 | `reasonix cycle --resume` | Ctrl+C 了或断电了 |

---

## 🛡️ 防呆机制

| 事故 | 怎么防 |
|------|--------|
| AI 把"React + 拖拽"简化成"写个 Todo" | **哈希锚定**——[GOAL] 改了 hash 不匹配，拒绝写入 |
| AI 声称跑了测试但实际没跑 | **verify.sh 二段检查**——先查占位符，再逐段查真实命令关键字 |
| 写到一半断电 | **原子写入**——`.tmp` → `rename`，不会半新半旧 |
| 不知道上一阶段干了什么 | **[DONE] 强制结构**——`Artifacts:` 路径 + `Fingerprint:` 指纹 |

---

## 📦 仓库结构

```
bobanana4.0/
├── README.md                   ← 🍌
├── install.bat                 ← 安装脚本（新用户入口 → 方式 A）
├── bin/
│   ├── cycle-bridge.exe        ← MCP 插件（queue_next_prompt / signal_done）
│   └── reasonix.exe             ← 主程序（含 cycle 子命令）
├── skills/
│   ├── cyclic-workflow/
│   │   └── SKILL.md             ← 三阶段元指令（17KB，Phase 1/2/3 怎么走）
│   └── cycle-install/
│       └── SKILL.md             ← 安装器 skill（已有用户 → 方式 B）
└── commands/
    └── cycle.md                  ← /cycle 斜杠命令模板
```

---

## 🔧 自己编译

```bash
git clone https://github.com/ProfYangShengXu/bobanana4.0.git
cd bobanana4.0
go build -o bin/reasonix.exe  ./cmd/reasonix/
go build -o bin/cycle-bridge.exe ./cmd/cycle-bridge/
```

需要 Go 1.25+。编译完 `bin/` 下就有两个 exe。

---

## 📜 许可证

MIT — 随便用。香蕉皮别乱扔 🍌
