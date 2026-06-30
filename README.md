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

## 这是啥

一个 Reasonix 插件，让 AI 替你跑完**完整的三阶段开发流程**：

| 阶段 | AI 干啥 | 你干啥 |
|------|---------|--------|
| **Phase 1 🎨** | 写 HTML 设计文档（架构、计划、验证方案、验收标准） | 打开浏览器看看，说"改这里" |
| **Phase 2 🔧** | 按计划逐任务编码，每步自检，错了重试，每3个抽查1个 | 喝咖啡 |
| **Phase 3 ✅** | 跑自动化检查脚本，过不了就修，修完再跑，全通过喊你验收 | 点个赞 👍 |

## 安装

```bash
# 1. 把 banana4.0/ 扔到你项目根目录
# 2. 运行一键安装
cd 你的项目
install.bat

# 3. 在 reasonix.toml 添加
[[plugins]]
name    = "cycle-bridge"
command = "bin/cycle-bridge.exe"
```

或者在任意 Reasonix TUI/桌面端里输入：

```
/skill cycle-install
```

Agent 会自动帮你装好。

## 使用

```bash
# 终端（哪都能跑）
reasonix cycle "用 React 写一个带拖拽排序的 Todo 应用"

# TUI / 桌面端
/cycle 用 React 写一个带拖拽排序的 Todo 应用
```

然后去喝咖啡。AI 会：
1. 🎨 生成 `docs/design/<项目>-design.html` → 你浏览器打开审阅
2. 🔧 逐任务编码，`todo_write` 看板实时更新
3. ✅ `bash verify.sh` 全自动验证，17 项检查全部通过后喊你验收

## 三阶段背后发生了什么

```
你输入目标
    │
    ▼
┌──────────────────────────────────────┐
│ Phase 1 🎨                           │
│  write_file → design.html            │
│  write_file → verify.sh              │
│  queue_next_prompt → Phase 2         │
└──────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────┐
│ Phase 2 🔧                           │
│  todo_write → 任务看板               │
│  task("模块A") → 子 agent 执行       │
│  complete_step → 签收                │
│  task("模块B") → ...                 │
│  抽查 → spot-check: OK              │
│  填充 verify.sh                      │
└──────────────────────────────────────┘
    │
    ▼
┌──────────────────────────────────────┐
│ Phase 3 ✅                           │
│  bash verify.sh → 退出码 0?          │
│    ├─ 是 → signal_done → 🎉          │
│    └─ 否 → 修复 → 重启验证(最多5次)   │
└──────────────────────────────────────┘
    │
    ▼
🚀 全部搞定，等你验收
```

## 防呆机制

| 事故 | 怎么防 |
|------|--------|
| AI 把"React + 拖拽"简化成"Todo" | 哈希锚定——改一个字就拒绝写入 |
| AI 声称跑了测试但实际没跑 | verify.sh 二段检查：查占位符 + 查实际命令 |
| 写到一半断电 | 先写 `.tmp` 再改名，不会出现半新半旧 |
| 不知道上一阶段干了啥 | [DONE] 强制含 `Artifacts:` 路径 + `Fingerprint:` 指纹 |

## 文件结构

```
bobanana4.0/
├── bin/
│   ├── cycle-bridge.exe    ← MCP 状态管理插件
│   └── reasonix.exe         ← 主程序（含 cycle 子命令）
├── skills/
│   ├── cyclic-workflow/
│   │   └── SKILL.md         ← 三阶段元指令
│   └── cycle-install/
│       └── SKILL.md         ← 自动安装器
├── commands/
│   └── cycle.md              ← /cycle 斜杠命令
├── install.bat               ← 一键安装
└── README.md                 ← 就这个文件
```

## 从源码构建

```bash
go build -o bin/reasonix.exe  ./cmd/reasonix/
go build -o bin/cycle-bridge.exe ./cmd/cycle-bridge/
```

需要 Go 1.25+。

## 许可证

MIT — 随便用，别把香蕉皮踩滑了 🍌
