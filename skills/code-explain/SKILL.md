---
name: code-explain
description: Deep single-function analysis. Given a repo URL (or local path) + file + function name, generates L3 algorithm flowchart and L4 task-code mapping table. Context budget is tiny — only reads the target function. Use when user invokes /code-explain.
---

# /code-explain — 单函数深度解析（L3 + L4 层）

**定位**：精准的"手术刀"。只读**一个函数**，但把它分析到极致——
算法流程图（L3）+ 逐行任务对照表（L4）+ 论文出处标注。

通常在 `/inno-scan` 确认目标函数后调用。

---

## VAULT PATH MAPPING

- 输出：`03.资料库/代码分析/[repo名]-[函数名]-explain.md`

---

## 调用格式

```
# 标准用法（推荐：先跑 /inno-scan 得到函数名）
/code-explain https://github.com/user/repo --file knowledge_curation.py --func QuestionAsker.ask

# 直接粘贴代码（无需克隆 repo）
/code-explain --paste
[粘贴代码后按 Enter]

# 指定论文，自动标注论文出处
/code-explain https://github.com/user/repo --file engine.py --func generate_perspectives --paper https://arxiv.org/abs/2402.14207
```

---

## WORKFLOW

### Step 1：获取目标函数代码

**方式 A（repo URL + 文件名 + 函数名）**：
```bash
# 克隆（仅元数据）
git clone --depth=1 --filter=blob:none --sparse \
  [URL] /tmp/repostrata-[repo]/

# 稀疏检出目标文件
git -C /tmp/repostrata-[repo]/ sparse-checkout set [file.py]
git -C /tmp/repostrata-[repo]/ checkout

# 提取目标函数（从 def 开始到下一个同级 def 结束）
grep -n "def [func_name]\|class [class_name]" /tmp/repostrata-[repo]/[file.py]
# → 得到行号范围，用 sed 提取
```

**方式 B（直接粘贴）**：用户粘贴代码，直接进入分析。

### Step 2：（若提供论文）提取相关章节

WebFetch 论文，只读与该函数最相关的 1 个章节（通过函数名/关键词定位章节）。

### Step 3：生成 L3 算法流程图

为函数生成 Mermaid flowchart，标注：
- `🔥` 节点：论文所声称的创新操作（与论文描述对应的步骤）
- `standard` 标注：调用标准库/通用操作的步骤

格式参见 `../../references/OUTPUT_TEMPLATES.md#L3`

### Step 4：生成 L4 逐行任务对照表

四列格式：

| 代码行 | 解决的子问题 | 为什么这样写（反事实） | 论文出处 |
|--------|------------|---------------------|---------|

分析维度（对每行/每个语句）：
1. **子问题**：这行最小化解决了什么问题？
2. **约束类型**：数学正确性 / 效率 / 语言特性 / 工程习惯
3. **反事实**：如果不这样写会怎样？（这是理解"为什么"最直接的路径）
4. **论文出处**：对应论文哪一节的哪句话（若提供了论文）

### Step 5：生成理解路径建议

```
建议的理解顺序：
1. 先理解函数的输入/输出（忽略内部细节）
2. 找到函数的"主干"（最外层的 for/while 循环或主要分支）
3. 理解主干的每一步，再向内展开
```

### Step 6：生成追问问题

3 个面向用户科研方向的追问（结合 mNGS / RAG / KG 背景）：
```
- 这个函数的设计能否移植到 ARIS 的 [某模块] 中？
- 它与 [相关工作] 的实现有何本质差异？
- 这里的 [某设计决策] 对你的实验有什么启发？
```

---

## OUTPUT FORMAT

参见 `../../references/OUTPUT_TEMPLATES.md`

---

## 上下文预算

| 操作 | 估算 tokens |
|------|------------|
| 目标函数代码（通常 20-150 行）| ~2,000 |
| 论文相关章节（1个，可选）| ~1,500 |
| L3 Mermaid 图生成 | ~500 |
| L4 对照表生成 | ~3,000 |
| **总计** | **~7,000** |

可以对同一仓库的多个函数**连续调用**，每次预算独立，不累积。
