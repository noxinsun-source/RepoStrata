---
name: repo-compare
description: Side-by-side comparison of two repos solving the same problem. Identifies architectural differences, innovation trade-offs, and which implementation to reference for your own work. Use when user invokes /repo-compare.
---

# /repo-compare — 双仓库对比分析

**定位**：当两篇论文解决同一个问题时（如 STORM vs. HippoRAG 都做知识增强），
对比它们的实现差异，帮助你决定"我的项目应该参考哪个，或者融合哪些设计"。

---

## VAULT PATH MAPPING

- 输出：`03.资料库/代码分析/compare-[repo1]-vs-[repo2].md`

---

## 调用格式

```
/repo-compare https://github.com/A/repo1 https://github.com/B/repo2
/repo-compare https://github.com/A/repo1 https://github.com/B/repo2 --aspect retrieval
```

`--aspect`（可选）：聚焦对比的维度，如 `retrieval`、`generation`、`training`、`architecture`

---

## WORKFLOW

### Step 1：并行克隆两个 repo（仅元数据）

```bash
git clone --depth=1 --filter=blob:none --sparse [URL1] /tmp/repostrata-repo1/ &
git clone --depth=1 --filter=blob:none --sparse [URL2] /tmp/repostrata-repo2/ &
wait
```

### Step 2：为每个 repo 执行轻量扫描

对每个 repo，只做：
- 文件树扫描（同 `/repo-map` Step 2）
- 读取 README（最多 300 词）
- 读取入口文件前 50 行

**不做**完整的 L3/L4 分析（那是 `/code-explain` 的任务）

### Step 3：提取双方的核心模块

对每个 repo，识别：
- **数据输入模块**：如何接收/处理输入
- **核心算法模块**：最可能是论文创新点的文件
- **输出生成模块**：如何产生最终结果
- **外部依赖**：调用哪些第三方服务/库

用文件名 + README 推断（不读完整代码）。

### Step 4：对比分析

对以下维度生成对比表：

| 维度 | Repo 1 | Repo 2 | 差异分析 |
|------|--------|--------|---------|
| 整体架构范式 | Pipeline / End-to-end / Agent | ... | ... |
| 检索策略 | 向量检索 / 图检索 / 混合 | ... | ... |
| LLM 使用方式 | 生成 / 评估 / 两者 | ... | ... |
| 核心数据结构 | ... | ... | ... |
| 依赖复杂度 | X 个核心依赖 | Y 个 | ... |
| 代码可复用性 | 模块化程度 | ... | ... |
| 适合场景 | ... | ... | ... |

### Step 5：生成"选择建议"

基于对比，给出具体建议：

```
对于你的 ARIS-mNGS 项目：

✅ 从 [Repo1] 借鉴：
  - [具体模块/设计]，因为 [原因]

✅ 从 [Repo2] 借鉴：
  - [具体模块/设计]，因为 [原因]

⚠️ 避免直接复用：
  - [某设计] 因为它依赖 [X]，与你的场景不兼容
```

---

## 上下文预算

| 操作 | 估算 tokens |
|------|------------|
| Repo1 文件树 + README | ~3,000 |
| Repo2 文件树 + README | ~3,000 |
| 对比分析生成 | ~2,000 |
| **总计** | **~8,000** |
