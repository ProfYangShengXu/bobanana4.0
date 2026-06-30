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

## 🚀 30 秒安装

打开你的 Reasonix（TUI 或桌面端），在聊天框里输入：

```
/skill cycle-install
```

Agent 会全自动帮你装好：
1. 检查你是否已经装过（装过就不重复了）
2. 读取 `cycle-install` skill 中的安装脚本
3. 把 `cyclic-workflow` skill 写到你的 `~/.reasonix/skills/` 和项目 `.reasonix/skills/` 下
4. 把 `/cycle` 命令写到 `~/.reasonix/commands/` 和项目 `.reasonix/commands/` 下
5. 检查 `reasonix.toml` 是否已配置 `cycle-bridge` 插件

全程不需要你动手。装完后提示你：

```
✅ cyclic-workflow 已安装到：
  全局：~/.reasonix/skills/cyclic-workflow/SKILL.md
        ~/.reasonix/commands/cycle.md
  项目：.reasonix/skills/cyclic-workflow/SKILL.md
        .reasonix/commands/cycle.md
```

> **为什么装一次就行？** 因为技能和命令都装在 `~/.reasonix/` 全局目录下，以后你换任何项目、任何 workspace，都不需要重新安装。一次安装，所有 Reasonix 前端（TUI、桌面端、Web GUI）通用。

---

## 🎮 使用

### 终端

```bash
reasonix cycle "用 React 写一个带拖拽排序的 Todo 应用"
```

三阶段依次输出到终端，最后打印完成摘要。

### TUI / 桌面端 / Web GUI

输入：

```
/cycle 用 React 写一个带拖拽排序的 Todo 应用
```

Agent 会在当前会话中直接执行三阶段，所有工具调用通过事件流实时推送到前端。

---

## 🍿 然后发生了什么

```
你输入 /cycle 目标
     │
     ▼
┌──────────────────────────────────────┐
│ Phase 1 🎨                           │
│  · get_cycle_state → phase=none       │
│  · write_file → design.html          │
│  · write_file → verify.sh            │
│  · queue_next_prompt → Phase 2       │
└──────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Phase 2 🔧                           │
│  · read_file → 读取设计文档中的计划    │
│  · todo_write → 创建任务看板          │
│  · task("模块A") → 子 agent 编码      │
│  · complete_step → 签收 + 证据       │
│  · task("模块B") → ...               │
│  · 每3个任务抽查1个 → spot-check: OK  │
│  · 填充 verify.sh → 替换占位符为真命令 │
└──────────────────────────────────────┘
     │
     ▼
┌──────────────────────────────────────┐
│ Phase 3 ✅                           │
│  · 完整性检查 → 不是空壳 ✓            │
│  · bash verify.sh → 退出码 0?        │
│    ├─ 是 → signal_done → 🎉          │
│    └─ 否 → 分析失败 → 修复 → 重跑     │
│          （最多 5 轮）                 │
└──────────────────────────────────────┘
     │
     ▼
🚀 全部搞定，等你验收
```

### 每一步你都看得见

在 TUI 或桌面端中，每个工具调用（`write_file`、`task`、`bash verify.sh`）的输出都会实时推送到你的聊天窗口。设计文档写好了你知道、子 agent 开始干活了你看到、验证脚本跑的结果你也看到——不是一个黑盒等半小时。

---

## ☕ 三种使用场景对比

| 场景 | 命令 | 适合 |
|------|------|------|
| 在终端里一键跑完 | `reasonix cycle "目标"` | 长时间任务、CI/CD、不想盯着 |
| 在 TUI/桌面端里交互式 | `/cycle 目标` | 想实时看每一步、Phase 1 后想改设计 |
| 中断后续跑 | `reasonix cycle --resume` | 跑到一半断电/Ctrl+C 了 |

---

## 🛡️ 防呆机制

| 事故 | 怎么防 |
|------|--------|
| AI 把"React + 拖拽"简化成"写个 Todo" | **哈希锚定**——`cycle-bridge` 校验 [GOAL] 段哈希，改一个字就拒绝写入 |
| AI 声称跑了测试但实际没跑 | **verify.sh 二段检查**：先查占位符残留，再逐段查有没有真实命令 |
| 写到一半断电了 | **原子写入**——先写 `.tmp` 再 `rename`，不会出现半新半旧的状态文件 |
| 不知道上一阶段干了什么 | **[DONE] 强制结构**——必须有 `Artifacts:` 路径列表和 `Fingerprint:` 指纹 |

---

## 📦 文件结构

```
bobanana4.0/
├── README.md                   ← 就是这个文件 🍌
├── install.bat                 ← 离线安装脚本（没有网络时用）
├── bin/
│   ├── cycle-bridge.exe        ← MCP 插件（queue_next_prompt / signal_done）
│   └── reasonix.exe             ← 主程序（含 cycle 子命令）
├── skills/
│   ├── cyclic-workflow/
│   │   └── SKILL.md             ← 三阶段元指令（Phase 1/2/3 怎么走）
│   └── cycle-install/
│       └── SKILL.md             ← 安装器（/skill cycle-install 的执行体）
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
