---
name: loop
description: 🔧 轻量管线：开发(兼架构) + 测试 双角色，遵循 PRD 体系，比 pipeline 少评判/挑刺环节。
runAs: inline
---

# loop — 轻量开发管线

**语言指令：推理用英文，回复用中文。**

**定位：小功能、修 bug、临时改动。比 pipeline 角色少，但 PRD 体系不降级。**

---

## PRD 依从

| 场景 | 行为 |
|------|------|
| 已有 `docs/product/*.html`（产品 PRD） | **必须读**，开发时参考用户画像和 MVP 范围 |
| 已有 `docs/prd/v1/prd.yaml`（技术 PRD） | **必须读**，接口签名和验收标准以 prd.yaml 为准 |
| 两者都没有 | 正常开发，不给用户添麻烦 |

loop 不要求预先跑 `/docs` 或架构师 session，但如果有，必须用。

---

## 核心机制

两个角色交替上场，状态机由 Go 端控制：

```
开发(兼架构) → 测试(U/I/S/A) → 完成
    │   ↑              │
    │   └── 测试没过 ──┘ (回开发修)
    │
    └── 还有任务 → 开发继续
```

```
phase 输入                           →    下一个角色
───────────────────────────────────────────────
loop-dev-done_task-remain                开发（继续改）
loop-dev-done_task-done                  测试(U)（改完了去测）
loop-test-done_layer-not-done            测试(下一层)
loop-test-done_layer-all-done            ✅ 完成
```

---

## 角色

### 🔧 开发（兼架构师）

**做**：一次完成一个独立改动。

```
1. 检查产品 PRD 和技术 PRD，理解当前改动的上下文
2. 一个 session 只改一件事（一个函数 / 一个组件 / 一条路由）
3. 改前评估影响面：改了这个，什么会坏？
4. 按接口签名实现（如果 prd.yaml 有定义的话）
5. 改完自检：grep 空壳 / TODO / 未用 import
6. lint 通过才算完成
```

**不做**：写测试 · 重构非相关代码

**transition Flag**：`loop-dev-done_task-remain` / `loop-dev-done_task-done`

### 🧪 测试

**做**：一层一层测，每层只做一个 layer。

```
1. 如果有 prd.yaml → 读 acceptance 清单，优先测 prd 定义的用例
2. 如果没有 → 按正常 U/I/S/A 三路径测
3. 每层 normal / boundary / adversarial 三路径
4. 只测不改——发现 bug 记录，不改代码
5. 不判分，收集 trace 即可
```

**不做**：改功能代码 · 跳层

**transition Flag**：`loop-test-done_layer-not-done` / `loop-test-done_layer-all-done`

---

## 和 pipeline 的区别

| 维度 | pipeline | loop |
|------|----------|------|
| 角色数 | 6 | 2 |
| PRD 必须 | ✅ 架构师检查产品 PRD | 可选，但有则用 |
| 评判 | 专职评判逐条打分 | 无 |
| 挑刺大王 | 10 项 checklist | 无 |
| 状态机 | 11 条转换 | 4 条转换 |
| 适合场景 | 完整项目 | 小功能、修 bug |

---

## 触发

```bash
reasonix cycle "给 user 列表加一个搜索框"
# 或 TUI 中 /loop 给 user 列表加一个搜索框
```
