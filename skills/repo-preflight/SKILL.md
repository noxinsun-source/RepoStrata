---
name: repo-preflight
description: Pre-analysis size check for any GitHub repo. Counts files, lines, estimates token cost, assigns a tier (Nano/Small/Medium/Large/Huge), and generates a concrete task plan that fits within context limits. Run this FIRST before any other RepoStrata skill on an unknown repo. Use when user invokes /repo-preflight.
---

# /repo-preflight — 仓库体检 + 智能任务规划

**定位**：所有 RepoStrata 技能的"入口网关"。在读取任何代码之前，先做快速体检，
根据仓库规模自动选择最合适的分析策略，并生成一份具体可执行的任务计划。

**原则**：只用 bash 统计命令，**不读任何文件内容**，因此无论多大的仓库都能在 10 秒内完成体检。

---

## VAULT PATH MAPPING

- 任务计划输出：`03.资料库/代码分析/[repo名]-preflight.md`

---

## 调用格式

```
/repo-preflight https://github.com/user/repo
/repo-preflight /local/absolute/path
```

---

## Token 预算标准

| 资源 | 数量 | 说明 |
|------|------|------|
| Claude 上下文窗口 | ~200k tokens | 模型总容量 |
| 系统提示 + 工具定义 | ~20k tokens | 固定消耗 |
| 对话历史 | ~10-30k tokens | 视会话长度 |
| **可用分析预算** | **~120k tokens** | 安全上限 |
| 平均每行代码 | ~13 tokens | 实测估算值 |
| 极限全读行数 | ~9,200 行 | 120k ÷ 13 |
| 套路代码过滤率 | ~70% | 大多数 repo 中 boilerplate 占 60-75% |
| **过滤后可处理行数** | **~30,000 行** | 9,200 ÷ 0.30 |

---

## WORKFLOW

### Step 1：克隆（仅元数据，不下载文件内容）

```bash
git clone --depth=1 --filter=blob:none --sparse \
  [REPO_URL] /tmp/repostrata-preflight-[repo名]/
```

耗时：通常 3-10 秒，与仓库大小无关（只下载 .git 元数据）

### Step 2：统计文件数和行数

```bash
REPO=/tmp/repostrata-preflight-[repo名]

# --- 文件数统计 ---
echo "=== FILE COUNT ==="
find $REPO -type f -name "*.py" | grep -vE "__pycache__|\.git" | wc -l
find $REPO -type f -name "*.js" -o -name "*.ts" | grep -vE "node_modules|\.git" | wc -l

# --- 行数统计（需要先检出所有文件）---
# 注意：这一步需要实际下载文件内容，仅对中小型仓库执行
# 对超大仓库（文件数 > 300），用文件数估算代替

# 如果文件数 <= 300，执行精确统计：
git -C $REPO sparse-checkout set --no-cone '*.py'
git -C $REPO checkout
find $REPO -name "*.py" | grep -vE "__pycache__|test_|_test\.py" \
  | xargs wc -l 2>/dev/null | tail -1

# 如果文件数 > 300，用估算：
# 估算行数 = 文件数 × 150（Python 文件平均行数经验值）
```

### Step 3：识别顶层模块结构

```bash
# 列出顶层目录，识别模块边界
find $REPO -maxdepth 2 -type d \
  | grep -vE "\.git|__pycache__|\.github|node_modules|\.venv" \
  | sort

# 统计每个顶层目录的文件数
for dir in $(find $REPO -maxdepth 1 -type d | grep -v "\.git"); do
  count=$(find $dir -name "*.py" | grep -vE "__pycache__" | wc -l)
  echo "$count $dir"
done | sort -rn
```

### Step 4：估算 token 消耗

```
精确模式（已统计行数）：
  总行数 × 13 tokens/行 = 原始 token 总量
  × (1 - 套路代码比例) = 可读内容 token 量
  套路代码比例参考：ML 训练 repo ≈ 0.70，框架 repo ≈ 0.50，工具 repo ≈ 0.40

估算模式（仅文件数）：
  文件数 × 150行/文件 × 13 tokens/行 × (1 - 0.65) = 估算 token 量
```

### Step 5：分级判定

根据**过滤后估算 token 量**判断级别：

| 级别 | 条件 | 一次性可读？ | 策略 |
|------|------|------------|------|
| 🟢 **Nano** | < 50 文件 / < 5k 行 | ✅ 完全可以 | 全量分析，一次完成 |
| 🟡 **Small** | 50-150 文件 / 5k-20k 行 | ✅ 可以（选择性读）| 读前 20 个非套路文件 |
| 🟠 **Medium** | 150-400 文件 / 20k-60k 行 | ⚠️ 需要策略 | Grep-only + 50 行片段 |
| 🔴 **Large** | 400-1000 文件 / 60k-200k 行 | ❌ 必须拆分 | 按模块拆分，分批执行 |
| ⚫ **Huge** | > 1000 文件 / > 200k 行 | ❌ 必须精准制导 | 纯论文关键词引导，极度聚焦 |

### Step 6：生成智能任务计划

根据级别，生成不同的具体任务计划：

---

#### 🟢 Nano 策略（< 5k 行）

```markdown
## 任务计划（Nano 级）

预估 token：约 X,XXX（安全范围内）

✅ 推荐：直接运行一次完整分析

命令序列：
1. /repo-map [URL]              → 建立地图（~30秒）
2. /inno-scan [URL] --paper [P] → 定位创新点（~60秒）  
3. /code-explain [URL] --file [F] --func [fn] （对每个核心函数各运行一次）

预计总耗时：5-10 分钟
预计总 token 消耗：~25,000
```

---

#### 🟡 Small 策略（5k-20k 行）

```markdown
## 任务计划（Small 级）

预估 token：约 XX,XXX（在安全范围内，需选择性读取）

✅ 推荐：Grep 优先 + 重点文件精读

命令序列：
1. /repo-map [URL]              → 建立地图
2. /inno-scan [URL] --paper [P] → Grep 定位（不全量读文件）
3. /code-explain 针对 Top 3-5 核心函数各运行一次

⚠️ /inno-scan 执行时：读取命中函数片段，不读完整文件
预计总 token 消耗：~40,000-60,000
```

---

#### 🟠 Medium 策略（20k-60k 行）

```markdown
## 任务计划（Medium 级）

预估 token：约 XX,XXX（单次分析会超限，需分模块）

📋 识别到的顶层模块：
  模块 A: src/retrieval/   (XX 文件, ~X,XXX 行)
  模块 B: src/generation/  (XX 文件, ~X,XXX 行)  
  模块 C: models/          (XX 文件, ~X,XXX 行)
  [跳过] utils/, tests/, examples/  → 纯套路

建议执行顺序（按论文相关性排序）：

Task 1: /inno-scan [URL] --paper [P] --scope src/retrieval/
  → 保存到：03.资料库/代码分析/[repo]-inno-scan-retrieval.md

Task 2: /inno-scan [URL] --paper [P] --scope src/generation/  
  → 保存到：03.资料库/代码分析/[repo]-inno-scan-generation.md

Task 3: /code-explain 针对 Task 1+2 找到的核心函数

Task 4: 合并 → 03.资料库/代码分析/[repo]-inno-scan-FINAL.md

每个 Task 预估 token：~30,000-50,000（安全范围内）
```

---

#### 🔴 Large 策略（60k-200k 行）

```markdown
## 任务计划（Large 级）⚠️ 需要多次会话

仓库规模：XX,XXX 行，超出单次分析能力
必须分 N 个独立任务执行，每个任务结果保存到 vault，最后合并

📋 模块切分方案：
  [Module 1] src/core/        → Task 1（估算 ~25k tokens，安全）
  [Module 2] src/models/      → Task 2（估算 ~30k tokens，安全）
  [Module 3] src/pipelines/   → Task 3（估算 ~20k tokens，安全）
  [SKIP]     tests/ utils/ scripts/ → 套路，跳过

执行方式：
  每个 Task 在**单独的 Claude 会话**中执行
  每次执行完成后，分析结果已保存到 vault
  全部完成后，运行合并命令

Task 1: /inno-scan [URL] --paper [P] --scope src/core/ --save-partial 1
Task 2: /inno-scan [URL] --paper [P] --scope src/models/ --save-partial 2
Task 3: /inno-scan [URL] --paper [P] --scope src/pipelines/ --save-partial 3
Task M: /merge-analysis [repo]   ← 合并所有 partial 结果
```

---

#### ⚫ Huge 策略（> 200k 行）

```markdown
## 任务计划（Huge 级）⚠️ 极度精准制导模式

仓库规模：XXX,XXX 行，超大型工程级代码库
只能用论文关键词做精准 grep，不做任何全量扫描

执行方式：
  1. 提供论文 URL（必须）
  2. /inno-scan 只做 grep，绝不读完整文件
  3. 命中函数用 /code-explain 逐个分析

特别说明：
  在 Huge 级仓库中，工程代码（CI/CD、部署、监控等）可能
  大量混入研究代码，建议人工确认哪些目录是核心研究代码：
  
  请告诉我：论文相关的核心代码在哪个目录？
  （通常是 src/model/, lib/core/, 或 paper_name/ 等）
```

---

### Step 7：保存体检报告

---

## OUTPUT FORMAT

```markdown
---
date: YYYY-MM-DD
repo: [URL]
tags: [source/code-analysis]
skill: repo-preflight
---

# 🔬 Repo Preflight：[repo-name]

## 体检结果

| 指标 | 数值 |
|------|------|
| Python 源文件数 | XX 个 |
| 总代码行数 | ~XX,XXX 行 |
| 套路代码估算比例 | ~70% |
| 过滤后有效行数 | ~X,XXX 行 |
| 预估 token 消耗 | ~XX,XXX |
| **仓库级别** | 🟡 Small |
| **是否需要拆分** | 否 |

## 模块分布

| 目录 | 文件数 | 估算行数 | 类型判断 |
|------|--------|---------|---------|
| src/core/ | 12 | ~3,600 | 🔥 可能含创新代码 |
| src/utils/ | 8 | ~2,400 | ⚙️ 套路（跳过）|
| tests/ | 15 | ~4,500 | ⚙️ 套路（跳过）|

## 任务计划

[根据级别，输出上方对应的具体任务计划]

## 执行命令（复制即用）

\`\`\`
/repo-map [URL]
/inno-scan [URL] --paper [PAPER_URL]
/code-explain [URL] --file [FILE] --func [FUNC]
\`\`\`
```

---

## 上下文预算

| 操作 | Token |
|------|-------|
| git clone 元数据 | 0（不下载文件）|
| bash 统计输出 | ~500 |
| 任务计划生成 | ~2,000 |
| **总计** | **< 3,000** |

体检本身几乎不消耗上下文，可以安全地在任何会话开头运行。
