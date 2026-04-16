<div align="center">

# 🔍 DeepDecode · 深度解码

### *From paper claim to operator-level code — understand the why behind every line.*
### *从论文创新点到算子级代码 · 解码任务与代码之间的内在逻辑 · 为研究者打造的代码学习工具*

[![Claude Code](https://img.shields.io/badge/Claude%20Code-7%20Skills-blueviolet?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Stars](https://img.shields.io/github/stars/noxinsun-source/DeepDecode?style=social)](https://github.com/noxinsun-source/DeepDecode)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Obsidian](https://img.shields.io/badge/Obsidian-Ready-7C3AED?logo=obsidian&logoColor=white)](https://obsidian.md)
[![VS Code](https://img.shields.io/badge/VS%20Code-Ready-007ACC?logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com)

**English** · [中文](#-中文说明)

> **DeepDecode** is a suite of **7 Claude Code skills** that bridge research papers and their implementation —  
> auto-discovering the paper, locating innovation functions, and generating **operator-level L4 task↔code tables**  
> that explain *why each expression exists*, not just what it does.
>
> **One command. Any GitHub repo. No paper URL needed.**

```
/full-analysis https://github.com/DEEP-PolyU/LinearRAG
```

</div>

---

## 📖 Table of Contents

- [What is DeepDecode?](#-what-is-deepdecode)
- [The 10 Skills](#-the-10-skills)
- [Full Pipeline](#-full-pipeline)
- [Installation](#-installation)
- [Platform Guide](#-platform-guide-where-to-run)
- [Usage Recipes](#-usage-recipes)
- [How Innovation Localization Works](#-how-innovation-localization-works)
- [Context Window Strategy](#-context-window-strategy)
- [中文说明](#-中文说明)

---

## 🔍 What is DeepDecode?

Most people read papers and then struggle to connect them to code. DeepDecode bridges that gap with a structured, multi-layer pipeline:

| Layer | What it reveals |
|-------|----------------|
| **L1 Architecture** | File tree with role labels — what exists and why |
| **L2 Call Graph** | Who calls whom, with real parameter types (via Python AST) |
| **L3 Interfaces** | Data contracts: ABC, Protocol, Pydantic, dataclass |
| **L4 Data Flow** | How data transforms from input to output across the pipeline |
| **L5 Innovation** | Which functions implement which paper contribution claims |
| **L6 Decision** | Why each line of code exists — task↔code mapping |

**Core innovation**: Unlike grep-based tools, DeepDecode uses **Python AST static analysis** to extract real function signatures, parameter types, return types, and call relationships — no code execution, no extra dependencies.

---

## 🧩 The 7 Skills

### 🚀 Orchestrator (start here)

| Skill | Command | What it does | Context |
|-------|---------|-------------|---------|
| **Full Analysis** | `/full-analysis` | ⭐ One command runs the entire pipeline. Built-in size triage, paper auto-discovery, all phases in order, final report. | ~120k max |

### 🗺️ Structural Analysis (Phase 1)

| Skill | Command | What it does | Context |
|-------|---------|-------------|---------|
| **Repo Map** | `/repo-map` | L1: File tree with role labels. Flags 🔥 CORE / 📦 INFRA / ⚙️ BOILERPLATE. Works on any size. | ~6k |
| **Call Graph** | `/repo-callgraph` | L2: AST call graph + **data contracts** (dataclass/Pydantic/ABC). Real parameter types on edges. | ~8k |
| **Data Flow** | `/data-flow` | Traces how data transforms from entry to output. Mermaid `sequenceDiagram` + shape-change table. | ~9k |

### 🎯 Innovation Analysis (Phase 2)

| Skill | Command | What it does | Context |
|-------|---------|-------------|---------|
| **Inno Scan** | `/inno-scan` | **Auto-finds the paper** (README → WebSearch → PDF → code-only). Maps contribution claims → functions via grep. | ~6.5k |
| **Code Explain** | `/code-explain` | Single-function: Mermaid L3 flowchart + L4 line-by-line task↔code table with paper citations. | ~7k |

### 🔀 Utility

| Skill | Command | What it does | Context |
|-------|---------|-------------|---------|
| **Repo Compare** | `/repo-compare` | Two-repo side-by-side: which system does what better, borrow recommendations. | ~8k |

> **Merged into `/full-analysis`**: sizing/preflight (Step 0) and batch-merge logic (Phase 5) — no longer separate commands.  
> **Merged into `/repo-callgraph`**: interface/data-contract extraction (formerly `/repo-interfaces`).

---

## 🔄 Full Pipeline

```
/full-analysis https://github.com/user/repo
│
├─── Step 0: TRIAGE (built-in, < 30s) ──────────────── always
│    Bash stat: count files/lines → assign tier Nano/Small/Medium/Large/Huge
│    Check resume: skip already-completed phases if --resume
│
├─── Step 1: ARCHITECTURE ───────────────────────────── always
│    /repo-map         → file tree + 🔥/📦/⚙️ role labels
│    /repo-callgraph   → AST call graph + data contracts (merged)
│    Save: 01-architecture.md, 02-callgraph.md
│
├─── Step 2: DATA FLOW ──────────────────────────────── standard + deep mode
│    /data-flow        → sequenceDiagram + shape-change table
│    Save: 03-dataflow.md
│
├─── Step 3: INNOVATION SCAN ────────────────────────── always
│    /inno-scan        → [auto-find paper] → claims → function mapping
│    Paper discovery:
│      Level 1: grep README for arxiv/ACL/openreview links
│      Level 2: WebSearch "[repo] arxiv paper"
│      Level 3: user --paper URL/PDF, or code-only fallback
│    [Large/Huge]: batch by module, merge inline
│    Save: 04-innoscan.md
│
├─── Step 4: DEEP DIVE ──────────────────────────────── deep mode / confirmed
│    /code-explain × N → per function: L3 flowchart + L4 task↔code table
│    Save: 05-[funcname]-explain.md
│
└─── Step 5: SYNTHESIS (built-in) ──────────────────── always
     Read all checkpoints → generate REPORT.md
```

### Pipeline Modes

```
--mode quick     Steps: 0 → 1 → 3              ~25k tokens    ~5 min
--mode standard  Steps: 0 → 1 → 2 → 3 → 5     ~50k tokens    ~10 min  ← default
--mode deep      Steps: 0 → 1 → 2 → 3 → 4 → 5 ~100k+ tokens  ~20-30 min
```

### Tier-Based Strategy (auto-selected by Preflight)

| Tier | Size | Strategy |
|------|------|----------|
| 🟢 Nano | < 50 files / < 5k lines | All phases in one pass |
| 🟡 Small | 50–150 files / 5–20k lines | All phases, selective reads |
| 🟠 Medium | 150–400 files / 20–60k lines | Grep-only for Phase 3, snippets only |
| 🔴 Large | 400–1000 files / 60–200k lines | Phase 3 batched by module, multi-session |
| ⚫ Huge | > 1000 files / > 200k lines | Paper-keyword-guided only |

### Token Budget (all skills combined)

```
Safe budget per session:        ~120,000 tokens
Average line of code:           ~13 tokens
Max full-read lines per session: ~9,200 lines
After boilerplate filter (70%): handles ~30,000 lines in one pass
```

---

## ⚡ Installation

### Option A — Into an Obsidian Vault (recommended)

```bash
# Clone the whole suite into your vault's skills directory
git clone https://github.com/noxinsun-source/DeepDecode \
  "/path/to/your/vault/.claude/skills/DeepDecode"

# Install individual skills into .claude/skills/ root
# (required for Claude Code to discover them as slash commands)
cd "/path/to/your/vault/.claude/skills/DeepDecode"
bash install.sh "/path/to/your/vault/.claude/skills/"
```

### Option B — Standalone Claude Code

```bash
git clone https://github.com/noxinsun-source/DeepDecode \
  ~/.claude/skills/DeepDecode

bash ~/.claude/skills/DeepDecode/install.sh ~/.claude/skills/
```

### Option C — Manual (copy skill folders)

```bash
# Copy each skill folder individually
cp -r DeepDecode/skills/full-analysis  ~/.claude/skills/
cp -r DeepDecode/skills/repo-preflight ~/.claude/skills/
cp -r DeepDecode/skills/repo-map       ~/.claude/skills/
# ... etc
```

### Verify installation

Open Claude Code and type `/full-analysis` — if it shows the help text, installation succeeded.

---

## 🖥️ Platform Guide: Where to Run

DeepDecode works in **any environment where Claude Code runs**. Here's how each platform works and which is best for you.

---

### 🅰️ Claude Code CLI (Terminal)

**最适合**：程序员用户、需要完整功能

**使用方法**：

```bash
# 1. 进入你的项目目录（或 Obsidian vault）
cd "/Users/you/Documents/Obsidian Vault"

# 2. 启动 Claude Code
claude

# 3. 在交互界面中直接输入 Skill 命令
> /full-analysis https://github.com/stanford-oval/storm --paper https://arxiv.org/abs/2402.14207
```

**特点**：
- ✅ 完整 Bash 工具访问（AST 分析、git clone 等都能运行）
- ✅ 可以 git clone 任意 repo 到本地
- ✅ 生成的文件直接写入 vault，在 Obsidian 中可见
- ✅ 支持长时间运行（Deep 模式）

---

### 🅱️ VS Code + Claude Code Extension

**最适合**：习惯 IDE 环境的用户

**安装步骤**：

```
1. 打开 VS Code
2. 搜索扩展："Claude Code"（Anthropic 官方）
3. 安装并登录
4. 用 VS Code 打开你的 vault 文件夹（File → Open Folder）
5. 左侧边栏出现 Claude Code 图标，点击打开面板
6. 在面板底部的输入框输入命令
```

**使用**：

```
在 VS Code Claude Code 面板中输入：
> /full-analysis https://github.com/user/repo --paper [URL]
```

**特点**：
- ✅ 可以边看代码文件边看分析
- ✅ 点击生成的 Obsidian wikilink 直接跳转
- ✅ 支持完整 Bash 工具
- ⚠️ 需要 vault 文件夹作为工作区根目录

---

### 🅲️ Obsidian + Claudian Plugin

**最适合**：重度 Obsidian 用户，不想离开 Obsidian 界面

**安装步骤**：

```
1. 打开 Obsidian → 设置 → 第三方插件
2. 关闭安全模式
3. 浏览 → 搜索 "Claudian"
4. 安装并启用
5. 在 Claudian 设置中填入你的 Claude API Key
6. 右侧边栏出现 Claudian 面板
```

**使用**：

```
在 Obsidian 右侧 Claudian 面板中输入：
> /full-analysis https://github.com/user/repo
```

**特点**：
- ✅ 完全不用离开 Obsidian
- ✅ 生成的分析文档直接在 vault 中可链接
- ✅ Mermaid 图在 Obsidian 中原生渲染（无需额外插件）
- ⚠️ 部分 Bash 操作（git clone）可能受权限限制，建议用 Claude Code CLI

---

### 平台选择建议

```
第一次用 → Claude Code CLI（最稳定）
日常使用 → VS Code 或 Claudian（根据习惯）
查看结果 → 始终在 Obsidian（Mermaid 渲染最好）
```

**完整工作流示例**：
```
Claude Code CLI：运行 /full-analysis（生成分析文件）
         ↓
Obsidian：打开 03.资料库/代码分析/[repo名]/FINAL-report.md（查看和链接）
         ↓
继续研究：在 Obsidian 中记录笔记，链接到分析文档
```

---

## 📚 Usage Recipes

### Recipe 1: 快速了解一个陌生 repo（5 分钟）

```
# 只需 GitHub URL，论文自动发现
/inno-scan https://github.com/user/repo

# 或者一键全流程（快速模式）
/full-analysis https://github.com/user/repo --mode quick
```

### Recipe 2: 标准完整分析（适合大多数论文）

```
/full-analysis https://github.com/user/repo --paper [URL]
```

### Recipe 3: 深度读懂一个核心函数

```bash
# 先定位（用 inno-scan 或自己知道函数名）
/code-explain https://github.com/user/repo \
  --file path/to/file.py \
  --func FunctionName \
  --paper [URL]
```

### Recipe 4: 比较两个竞争方案，决定参考哪个

```
/repo-compare https://github.com/A/repo1 https://github.com/B/repo2
```

### Recipe 5: 大型 repo 多会话分析（断点续跑）

```bash
# 会话 1：开始，自动中断在合适的 checkpoint
/full-analysis https://github.com/user/repo --mode deep

# 后续会话：从上次断点继续
/full-analysis https://github.com/user/repo --resume
```

### Recipe 6: 只看调用结构和数据契约

```
/repo-callgraph https://github.com/user/repo
# 输出：调用图 + dataclass/Pydantic/ABC 接口定义（合并在一个文档）
```

---

## 🎯 How Innovation Localization Works

```
GitHub URL only → /inno-scan auto-starts:
  │
  ├─ Level 1: grep README.md for arxiv.org / aclanthology / openreview links
  │           → Found: https://arxiv.org/abs/2510.10114
  │
  ├─ Level 2 (if Level 1 fails): WebSearch "LinearRAG arxiv paper"
  │           → Returns paper title + URL
  │
  └─ Level 3 (if all else fails): code-only mode, inference from code patterns

Paper fetch → WebFetch arxiv.org/html/[id] (HTML richer than abstract)

Extract contribution claims:
  C1: "relation-free Tri-Graph using NER + semantic linking"
      keywords: [relation_free, NER, entity, semantic, graph]
  C2: "linear complexity, adjacent passage chain"
      keywords: [adjacent, passage, chain, linear, index]

Codebase Scan:
  ▼ Filter boilerplate (references/BOILERPLATE_PATTERNS.md)
    Skip: run.py, evaluate.py, utils.py, config.py
  
  ▼ Targeted grep (never reads full files, ~300 tokens)
    grep -rn "adjacent|passage.*chain|NER|entity.*extract" src/ --include="*.py"
  
  ▼ Read only hit function bodies (~50 lines × 5 functions)
  
  ▼ Score each hit (references/INNOVATION_SCORING.md)
    +3: function name matches keyword
    +3: docstring cites paper section
    +2: contains unique algorithmic logic (custom loop/math)
    +1: called by other novel functions
    −2: only wraps standard library APIs
    −1: same file as boilerplate
  
Paper ↔ Code Mapping Table:
  C1 → LinearRAG.index() + SpacyNER.batch_ner()          ⭐⭐⭐⭐⭐
  C2 → LinearRAG.add_adjacent_passage_edges()             ⭐⭐⭐⭐⭐
  C3 → LinearRAG.calculate_entity_scores()               ⭐⭐⭐⭐⭐
  C4 → LinearRAG.calculate_entity_scores_vectorized()    ⭐⭐⭐⭐⭐
  C5 → LinearRAG.calculate_passage_scores() + run_ppr()  ⭐⭐⭐⭐

"Reading these 5 functions = understanding 85% of the paper's contribution."
```

---

## 📐 Context Window Strategy

A large ML repo can have 50k–500k lines of code — far beyond any LLM's context window. DeepDecode's approach: **measure first, then read only what matters**.

| Skill | What it reads | What it skips | Tokens |
|-------|--------------|---------------|--------|
| `/full-analysis` Step 0 | `find`/`wc` output (metadata only) | Every file's content | < 1k |
| `/repo-map` | README + entry file (60 lines) | All other content | ~6k |
| `/repo-callgraph` | AST signatures + interfaces | Function bodies | ~8k |
| `/inno-scan` | README grep + paper abstract + grep hits | All boilerplate files | ~6.5k |
| `/code-explain` | 1 function (20–150 lines) | The rest of the repo | ~7k |

**Why this works**: AST analysis extracts signatures from 3 files of 1000 lines each into ~200 lines of structured data. That's 15× compression before Claude even starts.

**Paper discovery is essentially free**: README grep + WebSearch ≈ 700 tokens. In most cases the paper is found before any code is read.

---

## 🗂️ Repository Structure

```
DeepDecode/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── install.sh                    ← one-line installer
│
├── skills/                       ← 7 skills (trimmed from 10)
│   ├── full-analysis/SKILL.md    ← ⭐ orchestrator (start here)
│   │                                 includes: triage + batch-merge (built-in)
│   ├── repo-map/SKILL.md         ← Phase 1a: L1 file tree + role labels
│   ├── repo-callgraph/SKILL.md   ← Phase 1b: AST call graph + data contracts
│   │                                 includes: interface extraction (merged)
│   ├── data-flow/SKILL.md        ← Phase 2: data transformation pipeline
│   ├── inno-scan/SKILL.md        ← Phase 3: paper auto-discovery + innovation map ★
│   ├── code-explain/SKILL.md     ← Phase 4: L3 flowchart + L4 task↔code table
│   └── repo-compare/SKILL.md     ← utility: two-repo comparison
│
├── references/
│   ├── BOILERPLATE_PATTERNS.md   ← what to skip
│   ├── INNOVATION_SCORING.md     ← scoring algorithm
│   └── OUTPUT_TEMPLATES.md       ← Mermaid + table templates
│
└── examples/
    ├── linearrag-full-analysis.md  ← 🆕 real output: DEEP-PolyU/LinearRAG (ICLR'26)
    └── storm-inno-scan.md          ← real output: stanford-oval/storm
```

---

## 🔬 Tested Repositories

| Repo | Paper | Domain | Tier | Paper Discovery |
|------|-------|--------|------|----------------|
| [DEEP-PolyU/LinearRAG](https://github.com/DEEP-PolyU/LinearRAG) | [arXiv:2510.10114](https://arxiv.org/abs/2510.10114) | Graph RAG | 🟢 Nano | README link |
| [stanford-oval/storm](https://github.com/stanford-oval/storm) | [arXiv:2402.14207](https://arxiv.org/abs/2402.14207) | LLM Knowledge Curation | 🟡 Small | README link |
| [OSU-NLP-Group/HippoRAG](https://github.com/OSU-NLP-Group/HippoRAG) | [arXiv:2405.14831](https://arxiv.org/abs/2405.14831) | Graph-based RAG | 🟡 Small | WebSearch |
| [FasterDecoding/Medusa](https://github.com/FasterDecoding/Medusa) | [arXiv:2401.10774](https://arxiv.org/abs/2401.10774) | LLM Inference | 🟠 Medium | WebSearch |

---

## 🤝 Contributing

High-value contributions:
- 📄 **Example outputs** in `examples/` (run any skill on a real repo)
- 🔧 **Boilerplate patterns** for more frameworks (JAX, HF Trainer, Lightning)
- 🌍 **Language support** for JavaScript, Java, Go, C++
- 💡 **New skill ideas** — open an issue

See [CONTRIBUTING.md](CONTRIBUTING.md).

---

---

## 🇨🇳 中文说明

### DeepDecode 是什么？

**7 个 Claude Code Skill** 组成的代码分析套件，能将任意 GitHub 仓库分层剖析。只给 GitHub URL，自动找论文，自动定位创新代码，生成逐行"为什么"对照表。

**核心能力**：
- 📄 **论文自动发现**：README 扫描 → Web 搜索 → PDF 上传 → 无论文代码推断（三级降级）
- 🔍 **创新点定位**：自动将论文贡献声明映射到代码中的具体函数（Grep，非全文读取）
- 🧬 **AST 静态分析**：用 Python `ast` 模块提取真实参数类型和调用关系
- 📏 **智能规模分级**：先统计代码量，按 Nano/Small/Medium/Large/Huge 选择策略
- 🔄 **断点续跑**：大型仓库分多会话完成，每阶段自动保存检查点

### 一键启动（只需 GitHub URL）

```
# 最简用法：自动发现论文，自动分析
/full-analysis https://github.com/DEEP-PolyU/LinearRAG

# 或直接定位创新点
/inno-scan https://github.com/DEEP-PolyU/LinearRAG
```

### 安装方式

**Obsidian vault 用户**：
```bash
git clone https://github.com/noxinsun-source/DeepDecode \
  "/path/to/vault/.claude/skills/DeepDecode"
bash "/path/to/vault/.claude/skills/DeepDecode/install.sh" \
  "/path/to/vault/.claude/skills/"
```

**独立 Claude Code 用户**：
```bash
git clone https://github.com/noxinsun-source/DeepDecode ~/.claude/skills/DeepDecode
bash ~/.claude/skills/DeepDecode/install.sh ~/.claude/skills/
```

### 使用平台对比

| 平台 | 使用方式 | 推荐场景 |
|------|---------|---------|
| **Claude Code CLI** | 终端运行 `claude`，输入 `/full-analysis ...` | 首次使用、完整功能 |
| **VS Code + Claude Code 插件** | 左侧边栏面板输入命令 | 边看代码边分析 |
| **Obsidian + Claudian 插件** | 右侧边栏面板输入命令 | 不离开 Obsidian |

> 推荐工作流：Claude Code CLI 运行分析 → Obsidian 查看和链接结果

### 分析 Pipeline

```
/full-analysis 启动 →

Phase 0: 体检（统计代码量，分配 Nano/Small/Medium/Large/Huge 级别）
Phase 1: 架构（文件树 + AST 调用图 + 类层次 + 接口契约）
Phase 2: 数据流（从输入到输出的类型变换链）
Phase 3: 创新点定位（论文声明 → 代码函数映射）
Phase 4: 深度解析（逐行"为什么"对照表，含论文出处）
Phase 5: 综合报告

每个 Phase 结果自动保存到 vault，支持随时中断和续跑
```

---

<div align="center">

**Built for researchers who read code as seriously as papers.**
**为那些像认真读论文一样认真读代码的研究者而生。**

⭐ Star this repo if DeepDecode helped you understand a codebase!

[🐛 Report Issue](https://github.com/noxinsun-source/DeepDecode/issues) · [💡 Request Feature](https://github.com/noxinsun-source/DeepDecode/issues) · [📄 Examples](examples/)

</div>
