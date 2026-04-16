<div align="center">

# 🪨 RepoStrata

### *Peel back the layers. Understand the code.*
### *逐层剖析，读懂代码背后的真正逻辑。*

[![Claude Code Skill](https://img.shields.io/badge/Claude%20Code-4%20Skills-blueviolet?logo=anthropic&logoColor=white)](https://claude.ai/code)
[![Stars](https://img.shields.io/github/stars/noxinsun-source/RepoStrata?style=social)](https://github.com/noxinsun-source/RepoStrata)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Obsidian](https://img.shields.io/badge/Obsidian-Compatible-7C3AED?logo=obsidian&logoColor=white)](https://obsidian.md)

**English** | [中文](#中文说明)

> A suite of 4 Claude Code skills that decompose any GitHub repository into layered understanding —  
> from high-level architecture down to why each line of code exists.  
> Core feature: **Innovation Localization** — automatically maps paper contribution claims to the exact functions that implement them.

</div>

---

## 🧩 The 4 Skills

| Skill | Command | What it does | Context cost |
|-------|---------|-------------|-------------|
| **Repo Map** | `/repo-map` | L1: File tree + role summaries. Works on ANY size repo. | ~6k tokens |
| **Inno Scan** | `/inno-scan` | Maps paper claims → exact code functions via targeted grep, never reads boilerplate | ~6k tokens |
| **Code Explain** | `/code-explain` | L3 flowchart + L4 line-by-line decision table for ONE function | ~7k tokens |
| **Repo Compare** | `/repo-compare` | Side-by-side comparison of two repos solving the same problem | ~8k tokens |

Each skill is **independently usable** and **context-efficient** — designed to handle repos of any size without hitting LLM context limits.

---

## ⚡ Quick Start

```bash
# Install into your Claude Code skills directory
git clone https://github.com/noxinsun-source/RepoStrata ~/.claude/skills/RepoStrata

# Or for Obsidian vault users:
git clone https://github.com/noxinsun-source/RepoStrata \
  "/path/to/vault/.claude/skills/RepoStrata"
```

Then in Claude Code:

```
# Step 1: Get the lay of the land (always start here)
/repo-map https://github.com/stanford-oval/storm

# Step 2: Find the paper's core innovations in code
/inno-scan https://github.com/stanford-oval/storm --paper https://arxiv.org/abs/2402.14207

# Step 3: Deep-dive into a specific function
/code-explain https://github.com/stanford-oval/storm \
  --file storm_wiki/modules/knowledge_curation.py \
  --func QuestionAsker.ask \
  --paper https://arxiv.org/abs/2402.14207

# Compare two competing implementations
/repo-compare https://github.com/stanford-oval/storm \
  https://github.com/OSU-NLP-Group/HippoRAG
```

---

## 🎯 The Innovation Localization Engine

The standout feature. Most code in any ML repo is **boilerplate** — training loops, data loaders, loggers, config parsers. RepoStrata automatically filters it out and hunts down what's *actually* novel.

```
Paper Abstract / Contributions
  ↓  Extract N innovation claims + keywords
  
Full codebase scan
  ↓  Filter boilerplate (see references/BOILERPLATE_PATTERNS.md)
  ↓  Targeted grep — finds files, NOT full reads
  
Per-function scoring (references/INNOVATION_SCORING.md)
  +3  Function name matches innovation keyword
  +3  Docstring cites paper section
  +2  Contains unique algorithmic logic
  +1  Called by other novel functions
  -2  Only wraps standard library APIs
  -3  Matches boilerplate pattern
  
Paper ↔ Code Mapping Table
  C1 → knowledge_curation.py::QuestionAsker.ask()   ⭐⭐⭐⭐⭐
  C2 → knowledge_curation.py::ConvSimulator.simulate() ⭐⭐⭐⭐⭐
  C3 → article_generation.py::OutlineGenerator.generate() ⭐⭐⭐⭐
```

**"Reading these 3 functions = understanding 80% of the paper's technical contribution."**

---

## 📐 Why 4 Separate Skills? (The Context Window Problem)

A typical ML research repo has 50–500 source files. Reading everything at once would exceed any LLM's context window. RepoStrata's solution: **each skill reads only what it needs**.

| Skill | What it reads | What it skips |
|-------|--------------|---------------|
| `/repo-map` | File names + README only | Every file's content |
| `/inno-scan` | Grep hits (50-line snippets) | All boilerplate files |
| `/code-explain` | 1 function (20–150 lines) | The rest of the repo |
| `/repo-compare` | README + entry file × 2 | Deep code of either repo |

**Recommended workflow:**
```
/repo-map     →  understand structure
/inno-scan    →  find the 2-5 core functions
/code-explain →  deeply understand each core function (run N times)
/repo-compare →  compare against a competing approach
```

---

## 📄 Example Output

See [`examples/storm-inno-scan.md`](examples/storm-inno-scan.md) for a real `/inno-scan` run on `stanford-oval/storm`.

**Sample mapping table:**

| ID | Paper Claim | Code | Confidence |
|----|-------------|------|-----------|
| C1 | Multi-perspective question asking | `QuestionAsker.ask()` | ⭐⭐⭐⭐⭐ |
| C2 | Conversational information seeking | `ConvSimulator.simulate()` | ⭐⭐⭐⭐⭐ |
| C3 | Hierarchical outline generation | `OutlineGenerator.generate()` | ⭐⭐⭐⭐ |

**Sample L4 line-by-line table** (from `/code-explain` on bubble sort as a toy example):

| Code | Sub-problem | Why this way | Paper ref |
|------|------------|--------------|-----------|
| `n = len(arr)` | Determine sort boundary | Pre-computed for `n-i-1`; avoids repeated len() calls | — |
| `range(0, n-i-1)` | Skip sorted tail | After pass i, last i elements are final — no need to recheck | Sec 3.1 |
| `arr[j] > arr[j+1]` | Detect adjacent inversion | `>=` would break stability (equal elements swapped) | — |

---

## 🗂️ Repository Structure

```
RepoStrata/
├── README.md
├── CHANGELOG.md
├── CONTRIBUTING.md
├── LICENSE
│
├── skills/
│   ├── repo-map/
│   │   └── SKILL.md          ← /repo-map skill
│   ├── inno-scan/
│   │   └── SKILL.md          ← /inno-scan skill  ★ core
│   ├── code-explain/
│   │   └── SKILL.md          ← /code-explain skill
│   └── repo-compare/
│       └── SKILL.md          ← /repo-compare skill
│
├── references/
│   ├── BOILERPLATE_PATTERNS.md   ← What to skip (train/eval/logger/etc.)
│   ├── INNOVATION_SCORING.md     ← Scoring algorithm for candidate functions
│   └── OUTPUT_TEMPLATES.md       ← Mermaid + table templates for all skills
│
└── examples/
    └── storm-inno-scan.md        ← Real output: /inno-scan on stanford-oval/storm
```

---

## 🔬 Tested Repositories

| Repo | Paper | Domain |
|------|-------|--------|
| [stanford-oval/storm](https://github.com/stanford-oval/storm) | [arXiv:2402.14207](https://arxiv.org/abs/2402.14207) | LLM Knowledge Curation |
| [OSU-NLP-Group/HippoRAG](https://github.com/OSU-NLP-Group/HippoRAG) | [arXiv:2405.14831](https://arxiv.org/abs/2405.14831) | Graph-based RAG |
| [FasterDecoding/Medusa](https://github.com/FasterDecoding/Medusa) | [arXiv:2401.10774](https://arxiv.org/abs/2401.10774) | LLM Inference |

---

## 🤝 Contributing

Issues and PRs welcome! High-priority areas:
- 🌐 Support for more paper sources (Semantic Scholar, PubMed, ACL Anthology)
- 🔧 Boilerplate patterns for more frameworks (JAX, HuggingFace Trainer, PyTorch Lightning)
- 📊 More real example outputs in `examples/`
- 🌍 Multi-language support (JavaScript, Go, Java)

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

---

<a name="中文说明"></a>

## 中文说明

### RepoStrata 是什么？

一套 4 个 Claude Code Skill，能将任意 GitHub 仓库分层剖析——从整体架构到每一行代码存在的原因。

**核心功能**：**创新点定位**——自动将论文的贡献声明映射到代码中对应的具体函数。

### 为什么叫 RepoStrata？

`Strata`（地层）= 地质学中的岩层概念。就像地质学家通过钻取岩芯来理解地层结构，RepoStrata 通过四个层级来理解代码结构：

- **L1 架构层**：文件树 + 每个文件的职责摘要
- **L2 调用层**：函数间的调用关系图（Mermaid）
- **L3 算法层**：单个函数的内部逻辑流程图
- **L4 决策层**：逐行"这行代码为什么在这里"的对照表

### 四个 Skill 的分工

| Skill | 命令 | 功能 | 适合场景 |
|-------|------|------|---------|
| **Repo Map** | `/repo-map` | 快速生成仓库地图，任意大小均可 | 第一次接触陌生 repo |
| **Inno Scan** | `/inno-scan` | 论文创新点 → 代码函数精准映射 | 读完论文想找对应实现 |
| **Code Explain** | `/code-explain` | 单函数深度解析（流程图 + 逐行决策表）| 对某个函数想彻底读懂 |
| **Repo Compare** | `/repo-compare` | 两个仓库实现对比，给出"应借鉴哪个"建议 | 选择参考实现 |

### 安装

```bash
# Obsidian vault 用户
git clone https://github.com/noxinsun-source/RepoStrata \
  "/path/to/your/vault/.claude/skills/RepoStrata"

# 独立 Claude Code 用户
git clone https://github.com/noxinsun-source/RepoStrata \
  ~/.claude/skills/RepoStrata
```

### 典型工作流

```
1. /repo-map     → 建立整体认知（文件树 + 职责摘要）
2. /inno-scan    → 找到论文创新点对应的 2-5 个核心函数
3. /code-explain → 对每个核心函数做逐行深度分析
4. /repo-compare → 与竞争方案对比，决定自己的实现参考哪个
```

---

<div align="center">

**Built for researchers who read code as seriously as papers.**  
**为那些像认真读论文一样认真读代码的研究者而生。**

⭐ Star this repo if RepoStrata helped you understand a codebase!

</div>
