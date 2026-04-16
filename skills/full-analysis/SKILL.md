---
name: full-analysis
description: One-command orchestrator that runs the full RepoStrata pipeline automatically. Detects repo size, selects the right strategy, executes all relevant skills in order, saves checkpoints to vault, and produces a consolidated final report. Use when user invokes /full-analysis.
---

# /full-analysis — 全流程一键编排

**定位**：RepoStrata 的总指挥。一条命令启动完整分析 pipeline，
自动检测规模、选择策略、按序执行所有相关 Skill、保存中间结果、输出最终报告。

你不需要手动决定"先跑哪个 Skill"——`/full-analysis` 替你做所有决策。

---

## VAULT PATH MAPPING

- 检查点目录：`03.资料库/代码分析/[repo名]/`
  - `00-preflight.md`：体检报告 + 任务计划
  - `01-architecture.md`：L1 架构图
  - `02-callgraph.md`：调用图 + 类层次
  - `03-interfaces.md`：接口与数据契约
  - `04-dataflow.md`：数据流转图
  - `05-innoscan.md`：创新点定位
  - `06-[funcname]-explain.md`：核心函数深度解析（每个函数一个文件）
  - `FINAL-report.md`：最终综合报告

---

## 调用格式

```
# 标准用法（推荐）
/full-analysis https://github.com/user/repo --paper https://arxiv.org/abs/xxxx

# 无论文（自动从 README 检测）
/full-analysis https://github.com/user/repo

# 快速模式（只做架构 + 创新点，跳过深度解析）
/full-analysis https://github.com/user/repo --paper [URL] --mode quick

# 深度模式（包含每个创新函数的完整 L4 分析）
/full-analysis https://github.com/user/repo --paper [URL] --mode deep

# 本地仓库
/full-analysis /local/path --paper [URL]

# 断点续跑（从上次中断处继续）
/full-analysis https://github.com/user/repo --resume
```

---

## PIPELINE 架构

```
/full-analysis
│
├── Phase 0: PREFLIGHT（总是执行，< 3k tokens）
│   └── /repo-preflight → 体检 + 分级 + 任务计划
│       → 保存：03.资料库/代码分析/[repo名]/00-preflight.md
│
├── Phase 1: ARCHITECTURE（总是执行）
│   ├── /repo-map → 文件树 + 职责摘要
│   ├── /repo-callgraph → AST 调用图 + 类层次 + 参数类型
│   └── /repo-interfaces → 接口契约 + 数据模型
│       → 保存：01-architecture.md + 02-callgraph.md + 03-interfaces.md
│
├── Phase 2: DATA FLOW（标准/深度模式）
│   └── /data-flow → Pipeline 序列图 + 数据变换表
│       → 保存：04-dataflow.md
│
├── Phase 3: INNOVATION SCAN（有论文时执行）
│   └── /inno-scan → 论文创新点 → 代码函数映射
│       → [Large/Huge repos] 自动分批，每批保存 partial 文件
│       → 保存：05-innoscan.md
│
├── Phase 4: DEEP DIVE（深度模式 / 用户确认后）
│   └── /code-explain × N → 每个核心创新函数的 L3+L4 分析
│       → 保存：06-[funcname]-explain.md
│
└── Phase 5: SYNTHESIS（总是执行）
    └── /merge-analysis（若有 partial）
    └── 生成 FINAL-report.md
```

---

## WORKFLOW（详细步骤）

### Step 0：检查断点续跑

```
检查 03.资料库/代码分析/[repo名]/ 是否存在
若存在：
  列出已完成的阶段（哪些文件已存在）
  询问用户：从头开始 / 继续未完成的阶段？
若不存在：
  创建目录，开始全新分析
```

### Step 1：Phase 0 — Preflight

执行 `/repo-preflight` 的完整 workflow，保存结果。

关键输出：
- 仓库级别（Nano / Small / Medium / Large / Huge）
- 模块列表 + 每模块行数
- 是否需要分批（Large/Huge）
- 推荐执行的 Skill 组合

根据级别设置后续策略：

```
Nano / Small  → 单批执行所有 Phase
Medium        → Phase 1-2 全量，Phase 3-4 Grep-only 模式
Large         → Phase 1 全量，Phase 3 分模块批次执行
Huge          → Phase 1 仅文件树，Phase 3 纯关键词制导
```

### Step 2：Phase 1 — Architecture（并行执行）

同时执行三个独立分析（它们不互相依赖）：

**2a. /repo-map**
- 生成文件树 + 职责摘要
- 识别入口文件
- 输出：`01-architecture.md`（L1 部分）

**2b. /repo-callgraph**
- AST 提取函数签名 + 调用关系
- 生成 Mermaid classDiagram + 调用图
- 输出：追加到 `01-architecture.md`（L2 部分）+ `02-callgraph.md`

**2c. /repo-interfaces**
- 提取 ABC / Protocol / Pydantic / dataclass
- 生成接口契约文档
- 输出：`03-interfaces.md`

> **进度汇报**：Phase 1 完成后，向用户展示架构摘要，询问是否继续。

### Step 3：Phase 2 — Data Flow

执行 `/data-flow`：
- 以入口函数（从 Phase 1 识别）为起点
- 追踪数据变换链
- 生成 Sequence Diagram + Flowchart
- 输出：`04-dataflow.md`

### Step 4：Phase 3 — Innovation Scan

**若提供了论文 URL**：
执行 `/inno-scan`：
- 读取论文 Contributions
- Grep 定位创新函数
- 建立论文-代码映射表

**若为 Large/Huge 级**：
- 自动分批（每批一个顶层模块）
- 每批结果保存为 `05-innoscan-partial-N.md`
- 全部完成后合并

**若无论文**：
- 跳过 inno-scan
- 基于 callgraph 中调用频率 + 文件名启发式识别候选核心函数
- 标注置信度为"推断"

输出：`05-innoscan.md`

> **进度汇报**：展示映射总表，询问用户：
> "发现 N 个核心函数，是否对全部进行 L3+L4 深度解析？（预计 token 消耗：~Xk）"

### Step 5：Phase 4 — Deep Dive（需用户确认）

对 Phase 3 找到的每个核心创新函数，执行 `/code-explain`：

```
核心函数 1: knowledge_curation.py::QuestionAsker.ask
  → L3 Mermaid 流程图
  → L4 逐行任务-代码对照表（含论文出处）
  → 保存：06-QuestionAsker-ask-explain.md

核心函数 2: article_generation.py::OutlineGenerator.generate
  → ...
  → 保存：06-OutlineGenerator-generate-explain.md
```

每个函数独立保存，支持随时中断、后续补充。

### Step 6：Phase 5 — Synthesis（最终报告）

读取所有已生成的检查点文件，生成综合报告：

输出：`03.资料库/代码分析/[repo名]/FINAL-report.md`

---

## FINAL REPORT FORMAT

```markdown
---
date: YYYY-MM-DD
repo: [URL]
paper: [URL]
tags: [source/code-analysis]
skill: full-analysis
mode: deep / quick / standard
tier: Small / Medium / Large
total_tokens_used: ~XXX,XXX
---

# 🪨 完整代码分析报告：[repo-name]

> **论文**：[标题](arXiv) | **GitHub**：[URL]  
> **分析模式**：[模式] | **仓库级别**：[级别] | **分析时间**：YYYY-MM-DD

---

## 📋 一句话总结

[从论文 Abstract + 代码 README 综合提炼的一句话，说明这个系统"做什么、怎么做"]

---

## 🗺️ 阶段导航

| 阶段 | 文件 | 状态 |
|------|------|------|
| 架构概览 | [[00-preflight]] [[01-architecture]] | ✅ |
| 调用图 | [[02-callgraph]] | ✅ |
| 接口契约 | [[03-interfaces]] | ✅ |
| 数据流转 | [[04-dataflow]] | ✅ |
| 创新点定位 | [[05-innoscan]] | ✅ |
| 核心函数解析 | [[06-*-explain]] × N | ✅ |

---

## 🎯 核心发现

### 论文-代码创新点映射

[复制自 05-innoscan.md 的映射总表]

> 读懂这 N 个函数 = 读懂这篇论文 80% 的技术贡献

### 架构关键洞察

[3-5 条关于架构设计的核心观察]

### 数据流关键节点

[Pipeline 中最重要的 2-3 个数据变换点]

---

## 📊 分析统计

| 指标 | 数值 |
|------|------|
| 源文件数 | XX 个 |
| 总代码行数 | ~XX,XXX 行 |
| 识别的核心创新函数 | N 个 |
| 深度解析的函数 | N 个 |
| 套路代码跳过比例 | ~XX% |
| 总 token 消耗 | ~XXX,XXX |

---

## 🗺️ 建议阅读顺序

[具体的代码阅读路径，从哪个文件的哪个函数开始]

## ❓ 延伸问题

[3-5 个面向用户科研方向的追问]
```

---

## 模式对比

| 模式 | 执行的 Phase | 适用场景 | 预计 token | 预计时间 |
|------|------------|---------|-----------|---------|
| `--mode quick` | 0 + 1 + 3 | 快速了解创新点，不需要深度 | ~30k | 5 分钟 |
| `--mode standard`（默认）| 0 + 1 + 2 + 3 | 平衡深度与效率 | ~60k | 10 分钟 |
| `--mode deep` | 0 + 1 + 2 + 3 + 4 | 完全读懂，准备复现或借鉴 | ~120k+ | 20-30 分钟 |

---

## 断点续跑机制

每个 Phase 完成后立即保存检查点文件。
若分析中途中断（网络、context 限制等），重新运行 `/full-analysis --resume` 会：
1. 读取已存在的检查点文件
2. 跳过已完成的阶段
3. 从上次中断的 Phase 继续

这对 Large/Huge 级仓库尤其重要（可能需要多个会话才能完成）。
