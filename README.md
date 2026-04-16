<div align="center">

# 🪨 RepoStrata

### *Peel back the layers. Understand the code.*
### *逐层剖析，读懂代码背后的真正逻辑。*

[![Claude Code](https://img.shields.io/badge/Claude%20Code-10%20Skills-blueviolet?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Stars](https://img.shields.io/github/stars/noxinsun-source/RepoStrata?style=social)](https://github.com/noxinsun-source/RepoStrata)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Obsidian](https://img.shields.io/badge/Obsidian-Ready-7C3AED?logo=obsidian&logoColor=white)](https://obsidian.md)
[![VS Code](https://img.shields.io/badge/VS%20Code-Ready-007ACC?logo=visualstudiocode&logoColor=white)](https://code.visualstudio.com)

**English** · [中文](#-中文说明)

> A suite of **10 Claude Code skills** that decompose any GitHub repository into layered understanding —  
> from high-level architecture down to why each line of code exists.  
>
> **One command. Full pipeline. Any repo size.**

```
/full-analysis https://github.com/stanford-oval/storm --paper https://arxiv.org/abs/2402.14207
```

</div>

---

## 📖 Table of Contents

- [What is RepoStrata?](#-what-is-repostrata)
- [The 10 Skills](#-the-10-skills)
- [Full Pipeline](#-full-pipeline)
- [Installation](#-installation)
- [Platform Guide](#-platform-guide-where-to-run)
- [Usage Recipes](#-usage-recipes)
- [How Innovation Localization Works](#-how-innovation-localization-works)
- [Context Window Strategy](#-context-window-strategy)
- [中文说明](#-中文说明)

---

## 🔍 What is RepoStrata?

Most people read papers and then struggle to connect them to code. RepoStrata bridges that gap with a structured, multi-layer pipeline:

| Layer | What it reveals |
|-------|----------------|
| **L1 Architecture** | File tree with role labels — what exists and why |
| **L2 Call Graph** | Who calls whom, with real parameter types (via Python AST) |
| **L3 Interfaces** | Data contracts: ABC, Protocol, Pydantic, dataclass |
| **L4 Data Flow** | How data transforms from input to output across the pipeline |
| **L5 Innovation** | Which functions implement which paper contribution claims |
| **L6 Decision** | Why each line of code exists — task↔code mapping |

**Core innovation**: Unlike grep-based tools, RepoStrata uses **Python AST static analysis** to extract real function signatures, parameter types, return types, and call relationships — no code execution, no extra dependencies.

---

## 🧩 The 10 Skills

### 🚀 Orchestrator

| Skill | Command | Description |
|-------|---------|-------------|
| **Full Analysis** | `/full-analysis` | ⭐ **Start here.** One command runs the entire pipeline automatically. Auto-detects size, selects strategy, saves checkpoints, produces final report. |

### 📐 Phase 0 — Sizing

| Skill | Command | Description | Context |
|-------|---------|-------------|---------|
| **Preflight** | `/repo-preflight` | Bash-only size check (no file reads). Counts files/lines, assigns tier (Nano→Huge), generates ready-to-run task plan. | < 3k |

### 🗺️ Phase 1 — Architecture

| Skill | Command | Description | Context |
|-------|---------|-------------|---------|
| **Repo Map** | `/repo-map` | L1: File tree with role summaries. Flags 🔥 novel / 📦 infra / ⚙️ boilerplate. Works on ANY size repo. | ~6k |
| **Call Graph** | `/repo-callgraph` | L2: AST-extracted call graph with **real parameter types on edges**. Generates `classDiagram` + dependency graph. | ~8k |
| **Interfaces** | `/repo-interfaces` | L3: Extracts all data contracts — ABC, Protocol, Pydantic, dataclass, TypedDict. Field types + constraints table. | ~8k |

### 🌊 Phase 2 — Data Flow

| Skill | Command | Description | Context |
|-------|---------|-------------|---------|
| **Data Flow** | `/data-flow` | Traces data shape transformations across the full pipeline. Generates Mermaid `sequenceDiagram` + type transformation table. | ~9k |

### 🎯 Phase 3 — Innovation

| Skill | Command | Description | Context |
|-------|---------|-------------|---------|
| **Inno Scan** | `/inno-scan` | Maps paper contribution claims → exact code functions via targeted grep. Never reads boilerplate. | ~6k |

### 🔬 Phase 4 — Deep Dive

| Skill | Command | Description | Context |
|-------|---------|-------------|---------|
| **Code Explain** | `/code-explain` | L6: Single-function deep dive. Mermaid flowchart (L3) + line-by-line task↔code table with paper citations (L4). | ~7k |

### 🛠️ Utilities

| Skill | Command | Description | Context |
|-------|---------|-------------|---------|
| **Repo Compare** | `/repo-compare` | Side-by-side comparison of two repos solving the same problem. Outputs "borrow X from A, Y from B" recommendation. | ~8k |
| **Merge Analysis** | `/merge-analysis` | Combines partial `/inno-scan` results from Large/Huge repos into one final report. | ~5k |

---

## 🔄 Full Pipeline

```
/full-analysis (orchestrator)
│
├─── Phase 0: PREFLIGHT ──────────────────────────── always runs, < 3k tokens
│    └── /repo-preflight
│        Measure: file count, line count, module distribution
│        Assign:  Nano / Small / Medium / Large / Huge
│        Output:  task plan with exact commands to run
│        Save:    00-preflight.md
│
├─── Phase 1: ARCHITECTURE ───────────────────────── always runs
│    ├── /repo-map         → file tree + role labels
│    ├── /repo-callgraph   → AST call graph + class hierarchy + param types
│    └── /repo-interfaces  → data contracts (ABC / Pydantic / dataclass)
│        Save: 01-architecture.md, 02-callgraph.md, 03-interfaces.md
│
├─── Phase 2: DATA FLOW ──────────────────────────── standard + deep mode
│    └── /data-flow        → sequenceDiagram + type transformation table
│        Save: 04-dataflow.md
│
├─── Phase 3: INNOVATION SCAN ────────────────────── when paper URL provided
│    └── /inno-scan        → paper claims → code function mapping
│        [Large/Huge]      → auto-batched by module, saves partials
│        Save: 05-innoscan.md (or 05-innoscan-partial-N.md)
│
├─── Phase 4: DEEP DIVE ──────────────────────────── deep mode / user confirms
│    └── /code-explain × N → L3 flowchart + L4 line-by-line table per function
│        Save: 06-[funcname]-explain.md (one file per function)
│
└─── Phase 5: SYNTHESIS ──────────────────────────── always runs
     └── /merge-analysis (if batched) + final report generation
         Save: FINAL-report.md
```

### Pipeline Modes

```
--mode quick     Phases: 0 → 1 → 3        ~30k tokens    ~5 min
--mode standard  Phases: 0 → 1 → 2 → 3   ~60k tokens    ~10 min  ← default
--mode deep      Phases: 0 → 1 → 2 → 3 → 4  ~120k+     ~20-30 min
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
git clone https://github.com/noxinsun-source/RepoStrata \
  "/path/to/your/vault/.claude/skills/RepoStrata"

# Install individual skills into .claude/skills/ root
# (required for Claude Code to discover them as slash commands)
cd "/path/to/your/vault/.claude/skills/RepoStrata"
bash install.sh "/path/to/your/vault/.claude/skills/"
```

### Option B — Standalone Claude Code

```bash
git clone https://github.com/noxinsun-source/RepoStrata \
  ~/.claude/skills/RepoStrata

bash ~/.claude/skills/RepoStrata/install.sh ~/.claude/skills/
```

### Option C — Manual (copy skill folders)

```bash
# Copy each skill folder individually
cp -r RepoStrata/skills/full-analysis  ~/.claude/skills/
cp -r RepoStrata/skills/repo-preflight ~/.claude/skills/
cp -r RepoStrata/skills/repo-map       ~/.claude/skills/
# ... etc
```

### Verify installation

Open Claude Code and type `/full-analysis` — if it shows the help text, installation succeeded.

---

## 🖥️ Platform Guide: Where to Run

RepoStrata works in **any environment where Claude Code runs**. Here's how each platform works and which is best for you.

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

### Recipe 1: 快速了解一个陌生 repo（10 分钟）

```
/repo-preflight https://github.com/user/repo
/repo-map https://github.com/user/repo
/inno-scan https://github.com/user/repo --paper [URL]
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

### Recipe 5: 大型 repo 多会话分析

```bash
# 会话 1：做体检和架构
/repo-preflight https://github.com/user/repo --paper [URL]
/repo-map https://github.com/user/repo

# 会话 2：第一批模块
/inno-scan https://github.com/user/repo --paper [URL] --scope src/retrieval/ --save-partial 1

# 会话 3：第二批模块
/inno-scan https://github.com/user/repo --paper [URL] --scope src/generation/ --save-partial 2

# 会话 4：合并 + 深度分析
/merge-analysis repo-name
/code-explain ... --func CoreFunction1
```

### Recipe 6: 只看接口和数据流（理解系统边界）

```
/repo-interfaces https://github.com/user/repo
/data-flow https://github.com/user/repo --entry main.py::run
```

---

## 🎯 How Innovation Localization Works

```
Paper Abstract / Contributions
  │
  ▼ Extract N innovation claims + keywords
  
  C1: "multi-perspective question asking"
      keywords: [perspective, question, asking, simulate, editor]
  C2: "hierarchical outline generation"
      keywords: [outline, hierarchical, generate, structure]
  
Codebase Scan
  │
  ▼ Filter boilerplate (references/BOILERPLATE_PATTERNS.md)
    Skip: train.py, evaluate.py, logger.py, config.py, utils/, tests/...
  
  ▼ Targeted grep (never reads full files)
    grep -rn "perspective|question|simulate" *.py
  
  ▼ Score each hit (references/INNOVATION_SCORING.md)
    +3: function name matches keyword
    +3: docstring cites paper section
    +2: contains unique algorithmic logic
    +1: called by other novel functions
    −2: only wraps standard library APIs
    −3: matches boilerplate pattern
  
Paper ↔ Code Mapping Table
  C1 → knowledge_curation.py::QuestionAsker.ask()    ⭐⭐⭐⭐⭐
  C2 → article_generation.py::OutlineGenerator.gen() ⭐⭐⭐⭐

"Reading these 2 functions = understanding 80% of the paper's contribution."
```

---

## 📐 Context Window Strategy

A large ML repo can have 50k–500k lines of code — far beyond any LLM's context window. RepoStrata's approach: **measure first, then read only what matters**.

| Skill | What it reads | What it skips | Tokens |
|-------|--------------|---------------|--------|
| `/repo-preflight` | File tree only (metadata) | Every file's content | < 3k |
| `/repo-map` | README + entry file (60 lines) | All other content | ~6k |
| `/repo-callgraph` | AST signatures (compressed) | Function bodies | ~8k |
| `/inno-scan` | Grep hits (50-line snippets) | All boilerplate files | ~6k |
| `/code-explain` | 1 function (20–150 lines) | The rest of the repo | ~7k |

**Why this works**: AST analysis extracts signatures from 3 files of 1000 lines each into ~200 lines of structured data. That's 15× compression before Claude even starts.

---

## 🗂️ Repository Structure

```
RepoStrata/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
├── install.sh                    ← one-line installer
│
├── skills/
│   ├── full-analysis/SKILL.md    ← ⭐ orchestrator (start here)
│   ├── repo-preflight/SKILL.md   ← Phase 0: sizing
│   ├── repo-map/SKILL.md         ← Phase 1a: architecture
│   ├── repo-callgraph/SKILL.md   ← Phase 1b: AST call graph
│   ├── repo-interfaces/SKILL.md  ← Phase 1c: data contracts
│   ├── data-flow/SKILL.md        ← Phase 2: data flow
│   ├── inno-scan/SKILL.md        ← Phase 3: innovation scan ★ core
│   ├── code-explain/SKILL.md     ← Phase 4: deep dive
│   ├── repo-compare/SKILL.md     ← utility: comparison
│   └── merge-analysis/SKILL.md   ← utility: merge batches
│
├── references/
│   ├── BOILERPLATE_PATTERNS.md   ← what to skip
│   ├── INNOVATION_SCORING.md     ← scoring algorithm
│   └── OUTPUT_TEMPLATES.md       ← Mermaid + table templates
│
└── examples/
    └── storm-inno-scan.md        ← real output: stanford-oval/storm
```

---

## 🔬 Tested Repositories

| Repo | Paper | Domain | Tier |
|------|-------|--------|------|
| [stanford-oval/storm](https://github.com/stanford-oval/storm) | [arXiv:2402.14207](https://arxiv.org/abs/2402.14207) | LLM Knowledge Curation | 🟡 Small |
| [OSU-NLP-Group/HippoRAG](https://github.com/OSU-NLP-Group/HippoRAG) | [arXiv:2405.14831](https://arxiv.org/abs/2405.14831) | Graph-based RAG | 🟡 Small |
| [FasterDecoding/Medusa](https://github.com/FasterDecoding/Medusa) | [arXiv:2401.10774](https://arxiv.org/abs/2401.10774) | LLM Inference | 🟠 Medium |

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

### RepoStrata 是什么？

10 个 Claude Code Skill 组成的代码分析套件，能将任意 GitHub 仓库分层剖析。

**核心能力**：
- 🔍 **创新点定位**：自动将论文贡献声明映射到代码中的具体函数
- 🧬 **AST 静态分析**：用 Python `ast` 模块提取真实参数类型，而非猜测
- 📏 **智能分级**：先量体裁衣（体检），再决定策略，永不超出上下文限制
- 🔄 **断点续跑**：大型仓库分多会话完成，每步结果自动存入 vault

### 一键启动

```
/full-analysis https://github.com/stanford-oval/storm --paper https://arxiv.org/abs/2402.14207
```

### 安装方式

**Obsidian vault 用户**：
```bash
git clone https://github.com/noxinsun-source/RepoStrata \
  "/path/to/vault/.claude/skills/RepoStrata"
bash "/path/to/vault/.claude/skills/RepoStrata/install.sh" \
  "/path/to/vault/.claude/skills/"
```

**独立 Claude Code 用户**：
```bash
git clone https://github.com/noxinsun-source/RepoStrata ~/.claude/skills/RepoStrata
bash ~/.claude/skills/RepoStrata/install.sh ~/.claude/skills/
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

⭐ Star this repo if RepoStrata helped you understand a codebase!

[🐛 Report Issue](https://github.com/noxinsun-source/RepoStrata/issues) · [💡 Request Feature](https://github.com/noxinsun-source/RepoStrata/issues) · [📄 Examples](examples/)

</div>
