---
name: merge-analysis
description: Merges multiple partial /inno-scan results (from Large/Huge tier repos) into a single consolidated analysis document. Use when user invokes /merge-analysis after running multiple partial scans.
---

# /merge-analysis — 分批结果合并

**定位**：Large / Huge 级仓库分批扫描完成后的收尾步骤。
读取 vault 中所有 `[repo名]-inno-scan-partial-*.md` 文件，合并成最终报告。

---

## 调用格式

```
/merge-analysis [repo名]
# 例：/merge-analysis hipporag
```

---

## WORKFLOW

### Step 1：找到所有 partial 结果

```
03.资料库/代码分析/[repo名]-inno-scan-partial-*.md
```

列出所有文件，确认分批任务全部完成（检查是否有缺号）。

### Step 2：读取并合并

逐一读取每个 partial 文件，提取：
- 各自的论文-代码映射行
- 各自识别的核心函数
- 各自的套路代码清单

### Step 3：去重 + 排序

- 若同一函数在多个 partial 中出现 → 保留置信度最高的一条
- 按置信度降序排列最终映射表

### Step 4：生成最终报告

**输出路径**：`03.资料库/代码分析/[repo名]-inno-scan-FINAL.md`

格式与标准 `/inno-scan` 输出相同，额外增加：

```markdown
## 分批扫描统计

| 批次 | 扫描范围 | 发现核心函数 | token 消耗 |
|------|---------|------------|-----------|
| Batch 1 | src/retrieval/ | 3 个 | ~28,000 |
| Batch 2 | src/generation/ | 2 个 | ~32,000 |
| Batch 3 | src/models/ | 1 个 | ~21,000 |
| **合计** | 全仓库（已跳过套路）| **6 个** | **~81,000** |
```

### Step 5：清理 partial 文件（可选）

询问用户是否删除 partial 文件（保留 FINAL 即可）。
