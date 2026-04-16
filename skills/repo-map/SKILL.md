---
name: repo-map
description: L1 architecture scan. Generates a file-tree overview with one-line role summaries for every file. Works on ANY size repo — reads only metadata, never full file contents. Use when user invokes /repo-map.
---

# /repo-map — 仓库架构速览（L1 层）

**定位**：最轻量的入口技能。只读文件树 + 关键配置，不读代码正文。
任意大小的仓库都能在 30 秒内完成，输出结构化的"地图"。

**适合场景**：
- 第一次接触一个陌生 repo，想先建立整体认知
- 决定接下来用 `/inno-scan` 还是 `/code-explain` 深入哪里

---

## VAULT PATH MAPPING

- 输出：`03.资料库/代码分析/[repo名]-map.md`

---

## 调用格式

```
/repo-map https://github.com/user/repo
/repo-map /local/path
```

---

## WORKFLOW

### Step 1：克隆（仅元数据）

```bash
git clone --depth=1 --filter=blob:none --sparse \
  https://github.com/[user]/[repo] /tmp/deepdecode-[repo]/
```

`--filter=blob:none --sparse`：只下载文件树，不下载文件内容。速度极快，任意大小仓库均适用。

### Step 2：生成文件树

```bash
find /tmp/deepdecode-[repo]/ \
  -type f \( -name "*.py" -o -name "*.js" -o -name "*.ts" -o -name "*.go" -o -name "*.java" \) \
  | grep -vE "__pycache__|node_modules|\.git|test_|\.pyc" \
  | sort
```

### Step 3：只读以下文件（完整内容）

按优先级，最多读 5 个文件：
1. `README.md` / `README.rst`
2. `requirements.txt` / `pyproject.toml` / `package.json`
3. `setup.py` / `Makefile`
4. 入口文件（`main.py` / `train.py` / `run.py` / `app.py`）—— **只读前 60 行**

### Step 4：为每个文件生成一行摘要

基于文件名 + 所在目录路径推断职责（**不读文件内容**）。
对入口文件（已读前 60 行），生成更准确的摘要。

分类标注：
- `🔥 [CORE?]`：文件名含 model/core/engine/algorithm/novel 等词，可能是创新点
- `📦 [INFRA]`：数据结构、接口定义
- `⚙️  [BOILERPLATE]`：train/eval/config/logger/utils 等明显套路

### Step 5：生成依赖生态摘要

从 `requirements.txt` / `package.json` 提取主要依赖：
```
核心框架：PyTorch 2.x
检索：FAISS, sentence-transformers
LLM 调用：openai, anthropic
数据：datasets (HuggingFace)
```

### Step 6：保存输出

---

## OUTPUT FORMAT

```markdown
---
date: YYYY-MM-DD
tags: [source/code-analysis]
repo: [URL]
skill: repo-map
---

# 🗺️ Repo Map：[repo-name]

> **一句话**：[从 README 提取]  
> **语言**：Python | **规模**：约 XX 个源文件

---

## 文件结构

[repo-name]/
  engine.py          → 🔥 [CORE?] 主控制流（入口，含 run() 函数）
  models/
    transformer.py   → 🔥 [CORE?] 模型定义
    attention.py     → 🔥 [CORE?] 注意力机制
  data/
    loader.py        → 📦 [INFRA] 数据加载
    preprocess.py    → ⚙️  [BOILERPLATE] 预处理
  utils/
    logger.py        → ⚙️  [BOILERPLATE] 日志
    metrics.py       → ⚙️  [BOILERPLATE] 标准评估指标
  train.py           → ⚙️  [BOILERPLATE] 训练循环
  evaluate.py        → ⚙️  [BOILERPLATE] 评估循环
  config.yaml        → ⚙️  [BOILERPLATE] 配置

## 核心依赖

| 库 | 用途 |
|----|------|
| torch | 深度学习框架 |
| ... | ... |

## 建议下一步

- 运行 `/inno-scan [URL] --paper [arXiv]` 定位论文创新点
- 或运行 `/code-explain [URL] --file engine.py --func run` 深入具体函数
```

---

## 上下文预算

| 操作 | 估算 tokens |
|------|------------|
| 文件树（500 个文件）| ~3,000 |
| README | ~2,000 |
| requirements.txt | ~500 |
| 入口文件前 60 行 | ~800 |
| **总计** | **~6,300** |

任意大小的仓库都不会超出上下文限制。
