---
name: inno-scan
description: Innovation scanner. Reads a paper's contribution claims, then uses targeted grep (NOT full file reads) to locate the exact functions that implement each claim. Extremely context-efficient — never reads boilerplate files. Use when user invokes /inno-scan.
---

# /inno-scan — 创新点精准定位（核心技能）

**定位**：RepoStrata 的核心技能。用论文的 Contribution 声明作为"寻宝图"，
在代码库中用 **Grep 而非全文读取**，精准找到创新函数。

**关键设计**：只用 grep 搜索关键词，命中后**只读命中函数的那几十行**，
而不是读整个文件。这使得它能处理任意大小的仓库。

---

## VAULT PATH MAPPING

- 输出：`03.资料库/代码分析/[repo名]-inno-scan.md`

---

## 调用格式

```
/inno-scan https://github.com/user/repo --paper https://arxiv.org/abs/xxxx.xxxxx
/inno-scan /local/path --paper https://arxiv.org/abs/xxxx.xxxxx
/inno-scan https://github.com/user/repo   # 无论文时，从 README 推断
```

---

## WORKFLOW

### Step 1：克隆（仅元数据）

同 `/repo-map`，使用 `--filter=blob:none --sparse`，只取文件树。

### Step 2：读取论文（精准提取）

WebFetch 论文 URL，**只提取以下内容**（不读全文）：
- Abstract（前 200 词）
- "Contributions" / "We propose" / "Our method" 相关段落
- Method 章节的各小节**标题**（不读正文）

目标：提取 N 条结构化创新声明 + 关键词列表

```yaml
C1:
  claim: "We propose multi-perspective question asking..."
  keywords: [perspective, question_asking, multi, simulate, editor]
  
C2:
  claim: "Hierarchical outline generation from collected information"
  keywords: [outline, hierarchical, generate, structure]
```

### Step 3：套路文件过滤（直接跳过，不读）

文件名/路径匹配以下模式 → **完全不读，不分析**：

参见 `../../references/BOILERPLATE_PATTERNS.md`

### Step 4：关键词 Grep（不读文件，只搜索）

对每个 innovation claim 的 keywords，在非套路文件中 grep：

```bash
grep -rn "perspective\|question_asking\|simulate" \
  /tmp/repostrata-[repo]/ \
  --include="*.py" \
  --exclude-dir="__pycache__" \
  -l  # 只输出命中的文件名，不输出内容
```

### Step 5：精准读取命中位置

对每个 grep 命中：
1. 定位到命中行号
2. **只读该函数的完整定义**（上下各扩展 20 行，而非读整个文件）

```bash
# 读取命中行附近的函数
sed -n '[start_line],[end_line]p' /tmp/repostrata-[repo]/[file].py
```

### Step 6：评分 + 建立映射表

对每个命中函数评分，参见 `../../references/INNOVATION_SCORING.md`

取每个 Claim 的 Top 1-2 函数，建立映射表：

```markdown
| ID | 论文创新点 | 对应函数 | 文件 | 置信度 |
|----|-----------|---------|------|-------|
| C1 | 多视角提问 | `QuestionAsker.ask()` | knowledge_curation.py | ⭐⭐⭐⭐⭐ |
| C2 | 层次大纲生成 | `OutlineGenerator.generate()` | article_generation.py | ⭐⭐⭐⭐ |
```

### Step 7：保存输出

---

## OUTPUT FORMAT

```markdown
---
date: YYYY-MM-DD
tags: [source/code-analysis]
repo: [URL]
paper: [URL]
skill: inno-scan
---

# 🎯 Innovation Scan：[repo-name]

> **论文**：[标题](URL)  
> **GitHub**：[URL]

---

## 论文-代码映射总表

| ID | 论文声称的创新 | 对应代码 | 置信度 |
|----|-------------|---------|-------|
| C1 | ... | `file.py::func()` | ⭐⭐⭐⭐⭐ |

> 💡 **下一步**：对每个核心函数运行 `/code-explain [URL] --file [file] --func [func]` 获取逐行分析

---

## 套路代码清单（已跳过）

[列出跳过的文件，供参考]
```

---

## 上下文预算

| 操作 | 估算 tokens |
|------|------------|
| 论文 Abstract + Contributions | ~2,000 |
| Grep 结果（文件名列表）| ~500 |
| 命中函数片段（每个 ~50 行 × 5 个函数）| ~3,500 |
| **总计** | **~6,000** |

无论仓库多大，上下文消耗几乎恒定。
