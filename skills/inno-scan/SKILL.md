---
name: inno-scan
description: Innovation scanner with automatic paper discovery. Given only a GitHub URL, auto-finds the paper (README scan → WebSearch → user PDF → code-only fallback), extracts contribution claims, then uses grep to locate the exact functions implementing each claim. Use when user invokes /inno-scan.
---

# /inno-scan — 创新点定位（含论文自动发现）

**定位**：DeepDecode 的核心技能。**只给 GitHub URL，自动找论文，自动定位创新函数。**

论文获取三级降级：README 扫描 → Web 搜索 → 用户提供/代码推断。  
找到论文后，用 Grep（非全文读取）精准定位实现每条创新点的函数。

---

## VAULT PATH MAPPING

- 输出：`03.资料库/代码分析/[repo名]-inno-scan.md`

---

## 调用格式

```
# 最简用法（全自动，推荐）
/inno-scan https://github.com/user/repo

# 指定论文（跳过自动发现）
/inno-scan https://github.com/user/repo --paper https://arxiv.org/abs/xxxx.xxxxx

# 用户上传的论文 PDF
/inno-scan https://github.com/user/repo --paper /Users/me/Downloads/paper.pdf

# 本地仓库
/inno-scan /local/absolute/path

# 指定重点文件（跳过自动识别）
/inno-scan https://github.com/user/repo --focus model.py,retriever.py
```

---

## WORKFLOW

### Step 0：克隆仓库（仅元数据）

```bash
git clone --depth=1 --filter=blob:none --sparse \
  [REPO_URL] /tmp/deepdecode-[repo名]/

# 初始 sparse checkout：只取文件树 + README
git -C /tmp/deepdecode-[repo名]/ sparse-checkout init
git -C /tmp/deepdecode-[repo名]/ checkout
```

---

### Step 1：论文自动发现

**若用户已通过 `--paper` 提供** → 跳至 Step 2。

否则，执行三级降级策略：

---

**🥇 级别 1：README 扫描（最快，通常成功）**

```bash
# 全量检出 README
git -C /tmp/deepdecode-[repo名]/ sparse-checkout set README.md README.rst
git -C /tmp/deepdecode-[repo名]/ checkout

# 提取论文链接
grep -oP \
  'https?://arxiv\.org/(abs|pdf)/[\d\.v]+|https?://aclanthology\.org/[\w\.\-]+|https?://openreview\.net/forum\?id=[\w\-]+|https?://proceedings\.mlr\.press/\S+' \
  /tmp/deepdecode-[repo名]/README.md | head -5
```

找到 → 告知用户"在 README 中发现论文链接：[URL]"，进入 Step 2。

---

**🥈 级别 2：Web 搜索（README 无链接时）**

按优先级执行以下搜索，取第一个可信 arXiv / 会议链接：

```
搜索查询 1：site:arxiv.org "[repo名]"
搜索查询 2："[repo名]" "[GitHub owner]" arxiv
搜索查询 3："[repo名]" ICLR OR NeurIPS OR ICML OR ACL OR EMNLP 2024 OR 2025 OR 2026 paper
```

找到 → 告知用户"通过搜索找到论文：[标题]（[URL]）"，进入 Step 2。  
未找到 → 进入级别 3。

---

**🥉 级别 3：用户 PDF / Code-Only 模式**

- 若用户在对话中上传了 PDF → `Read` 工具读取，提取摘要和贡献部分
- 若完全无论文：

```
⚠️ 未找到论文，启动 Code-Only 模式

创新候选函数识别规则（启发式）：
1. 函数名含算法性词汇：calculate, compute, propagate, encode,
   rank, score, retrieve, aggregate, fuse, bridge, activate
2. 被其他函数多次调用（高入度）
3. 函数体包含自定义循环 + 数学/图操作（非纯标准库调用）
4. 文件路径不在 boilerplate 目录下（见 BOILERPLATE_PATTERNS.md）

所有映射标注置信度：⚠️ 推断（无论文佐证）
```

---

### Step 2：读取论文（精准提取，节省 token）

**仅提取以下内容**（不读全文）：

```
1. Abstract（全文）
2. Introduction 末尾或独立的 "Contributions" / "We propose" 段落
3. Method 章节各小节的标题（不读正文）
4. Figure 1 的 caption（通常是最简洁的系统概述）
```

**论文获取方式**：

| 来源 | 获取方式 |
|------|---------|
| `arxiv.org/abs/XXXX` | 优先 WebFetch `arxiv.org/html/XXXX`（内容更完整）；备用 abstract 页 |
| `arxiv.org/pdf/XXXX` | 转换为 `/abs/` 再获取 HTML；直接 PDF 不可读 |
| `aclanthology.org/XXXX` | WebFetch 论文页面（含 abstract） |
| `openreview.net/forum?id=XXX` | WebFetch（含 abstract + reviews） |
| 本地 PDF | `Read` 工具（支持 PDF 直接读取） |

**提取结构化创新声明**：

```yaml
innovations:
  - id: C1
    claim: "We propose X that achieves Y by Z..."
    keywords: [keyword1, keyword2, keyword3]
    novelty_type: pipeline  # pipeline/architecture/loss/data/inference
    expected_location: "核心算法模块"

  - id: C2
    claim: "..."
    keywords: [...]
```

`novelty_type` 分类：
- `pipeline`：整体流程/架构创新
- `architecture`：模型结构（新 attention、新 layer）
- `loss`：训练目标/损失函数
- `data`：数据构建方式
- `inference`：推理策略（reranking、beam search 变体）

---

### Step 3：套路文件过滤

文件名/路径命中以下模式 → **完全跳过，不分析**：

```
train.py, trainer.py, evaluate.py, eval.py, metrics.py
dataloader.py, dataset.py, data_utils.py
args.py, config_parser.py, parse_args.py
logger.py, logging_utils.py, tensorboard_logger.py
checkpoint.py, save_load.py, model_io.py
main.py（仅含 if __name__ == "__main__"）
examples/, scripts/, tests/, notebooks/
```

参见 `../../references/BOILERPLATE_PATTERNS.md`（完整列表）

---

### Step 4：关键词 Grep 定位

对每个 innovation claim 的 keywords，在非套路文件中 Grep：

```bash
# 搜索函数定义、类名、注释中的关键词
grep -rn "keyword1\|keyword2\|keyword3" \
  /tmp/deepdecode-[repo名]/ \
  --include="*.py" \
  --exclude-dir="__pycache__" \
  --exclude-dir="tests" \
  -l  # 只输出命中文件名（极低 token 消耗）
```

命中后，精准读取命中函数：

```bash
# 定位函数起始行
grep -n "def keyword1\|class.*keyword" /tmp/deepdecode-[repo名]/[file].py

# 只读该函数（从 def 到下一个同级 def，通常 20-100 行）
sed -n '[start],[end]p' /tmp/deepdecode-[repo名]/[file].py
```

**无论仓库多大，每次 Grep 读取的内容恒定：~50 行 × 5 个函数 = 3,500 tokens**

---

### Step 5：评分 + 映射表

对每个命中函数打分（见 `../../references/INNOVATION_SCORING.md`）：

| 信号 | 分值 |
|------|-----|
| 函数名直接包含创新关键词 | +3 |
| 注释/docstring 引用论文章节 | +3 |
| 函数体含独特算法逻辑（非标准库） | +2 |
| 被其他核心函数调用 | +1 |
| 同文件有 boilerplate 函数 | -1 |
| 仅含标准 API 调用 | -2 |

每个 Claim 取 Top 1–2，建立映射表：

```markdown
| ID | 论文声称的创新 | 对应代码 | 置信度 |
|----|-------------|---------|-------|
| C1 | 无关系图构建 | `LinearRAG.index()` + `SpacyNER.batch_ner()` | ⭐⭐⭐⭐⭐ |
| C2 | 线性链式结构 | `LinearRAG.add_adjacent_passage_edges()` | ⭐⭐⭐⭐⭐ |
```

---

### Step 6：保存输出

---

## OUTPUT FORMAT

```markdown
---
date: YYYY-MM-DD
tags: [source/code-analysis]
repo: [URL]
paper: [URL 或 "未找到"]
paper_source: readme / websearch / user-pdf / code-only
skill: inno-scan
---

# 🎯 创新点定位：[repo-name]

> **论文**：[标题](URL)（来源：[readme/websearch/user-pdf/推断]）  
> **GitHub**：[URL]

---

## 论文-代码映射总表

| ID | 论文声称的创新 | 对应代码 | 置信度 |
|----|-------------|---------|-------|
| C1 | ... | `file.py::func()` | ⭐⭐⭐⭐⭐ |
| C2 | ... | `file.py::func()` | ⭐⭐⭐⭐ |

> 💡 读懂这 N 个函数 = 读懂这篇论文 80% 的技术贡献。

> **下一步**：`/code-explain [URL] --file [file] --func [func]` 获取逐行 L4 分析

---

## 套路代码清单（已跳过）

[列出跳过的文件]
```

---

## 上下文预算

| 操作 | 估算 tokens |
|------|------------|
| README 扫描（grep 输出）| ~200 |
| Web 搜索结果（若触发）| ~500 |
| 论文 Abstract + Contributions | ~2,000 |
| Grep 结果（文件名列表）| ~300 |
| 命中函数片段（~50行 × 5个）| ~3,500 |
| **总计** | **~6,500** |

**无论仓库多大，上下文消耗几乎恒定。**
