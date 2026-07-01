---
name: cycle-install
description: 安装/更新 banana4.0 全部技能到当前项目（cyclic-workflow + iterative-loop + cycle 命令）。
runAs: inline
---

# cycle-install — 安装/更新 banana4.0 插件

将 banana4.0 全部技能安装或更新到当前项目。如果全局已安装，则从全局复制最新版本到项目级。

## 步骤 0：检查全局是否已安装

检查以下全局路径是否存在：
- `~/.reasonix/skills/cyclic-workflow/SKILL.md`
- `~/.reasonix/skills/cycle-install/SKILL.md`（就是正在运行的它自己）
- `~/.reasonix/skills/iterative-loop/SKILL.md`
- `~/.reasonix/commands/cycle.md`

需要 **至少要有一个 skill 存在**（`cyclic-workflow` 或 `iterative-loop`），否则说明全局根本没有装过 banana4.0。此时报错，让用户去 GitHub 下载后运行 `install.bat`。

## 步骤 1：读取源文件

从全局读取以下文件内容（`read_file`），全部准备就绪再进入写入阶段：

| 源路径 | 读给谁用 |
|--------|---------|
| `~/.reasonix/skills/cyclic-workflow/SKILL.md` | 安装/更新 cyclic-workflow |
| `~/.reasonix/skills/cycle-install/SKILL.md` | **自更新**——更新 cycle-install 自己 |
| `~/.reasonix/skills/iterative-loop/SKILL.md` | 安装/更新 iterative-loop |
| `~/.reasonix/commands/cycle.md` | 安装/更新 cycle 命令 |

如果某个文件在全局不存在（例如老版本没有 `iterative-loop`），跳过它并记录"全局无此文件，跳过"。

## 步骤 2：写入/更新到项目级

对上述每个源文件，**始终写入**（覆盖，不跳过）。不只是"存在就跳过"——因为用户调用 `cycle-install` 的目的往往是更新到最新版。

| 目标路径 | 用哪个源 |
|---------|---------|
| `.reasonix/skills/cyclic-workflow/SKILL.md` | 全局 cyclic-workflow 内容 |
| `.reasonix/skills/cycle-install/SKILL.md` | 全局 cycle-install 内容（自更新） |
| `.reasonix/skills/iterative-loop/SKILL.md` | 全局 iterative-loop 内容 |
| `.reasonix/commands/cycle.md` | 全局 cycle.md 内容（如果全局没有则用内联模板） |

**注意 `cycle-install` 的自更新**：你正在运行这个 skill，写入的新版本会在下次调用时生效。这没问题——写入后告知用户"cycle-install 已自更新，下次调用生效"。

## 步骤 3：检查 reasonix.toml 并修复

检查当前项目的 `reasonix.toml` 配置。**不要只是口头告知——能修复的直接修复。**

### 3a：`reasonix.toml` 不存在

如果项目根目录没有 `reasonix.toml`，直接调用 `write_file` 创建一个：

```toml
default_model = "deepseek-flash"
language      = "zh"

[[providers]]
name        = "deepseek-flash"
kind        = "openai"
base_url    = "https://api.deepseek.com"
model       = "deepseek-v4-flash"
api_key_env = "DEEPSEEK_API_KEY"

[[plugins]]
name    = "cycle-bridge"
command = "bin/cycle-bridge.exe"
```

创建后告知用户：`✅ 已创建 reasonix.toml（含 cycle-bridge 插件配置）`

### 3b：`reasonix.toml` 存在但缺少 `[[plugins]]` 段

如果文件存在但没有 `[[plugins]]` 段，用 `read_file` 读出内容，在末尾追加：

```toml
[[plugins]]
name    = "cycle-bridge"
command = "bin/cycle-bridge.exe"
```

然后用 `write_file` 写回。

### 3c：`reasonix.toml` 存在且有 `[[plugins]]` 但没有 `cycle-bridge`

在 `[[plugins]]` 段末尾添加一个 cycle-bridge 条目：

```toml
name    = "cycle-bridge"
command = "bin/cycle-bridge.exe"
```

### 3d：已有 cycle-bridge 配置

✅ 跳过，无需修改。

### 3e：检查 `bin/cycle-bridge.exe`

无论上述哪种情况，最后检查项目目录下是否存在 `bin/cycle-bridge.exe`。如果不存在，告知用户需要从 bobanana4.0 的 `bin/` 目录复制一份。

## 完成提示

告知用户实际更新了哪些文件：
```
✅ cyclic-workflow  ✓
✅ cycle-install    ✓（自更新）
✅ iterative-loop   ✓（新装 或 更新）
✅ /cycle 命令      ✓

如果有任何文件显示"全局无此文件，跳过"，通知用户重新下载最新版 install.bat
```
