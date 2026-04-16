---
date: 2026-04-17
repo: https://github.com/stanford-oval/storm
paper: https://arxiv.org/abs/2402.14207
skill: inno-scan
generated_by: RepoStrata
---

# 🎯 Innovation Scan：stanford-oval/storm

> **论文**：[Assisting in Writing Wikipedia-like Articles From Scratch with Large Language Models](https://arxiv.org/abs/2402.14207) (NAACL 2024)  
> **GitHub**：https://github.com/stanford-oval/storm  
> **分析时间**：2026-04-17

---

## 📋 论文-代码映射总表

> 读懂这 3 个函数 = 读懂这篇论文 80% 的技术贡献。

| ID | 论文声称的创新 | 对应代码 | 文件 | 置信度 |
|----|-------------|---------|------|-------|
| C1 | Multi-perspective question asking: simulate diverse Wikipedia editors to ask questions | `QuestionAsker.ask()` | `knowledge_curation.py` | ⭐⭐⭐⭐⭐ |
| C2 | Perspective-guided conversational information seeking | `ConvSimulator.simulate()` | `knowledge_curation.py` | ⭐⭐⭐⭐⭐ |
| C3 | Hierarchical outline generation from collected information table | `OutlineGenerator.generate()` | `article_generation.py` | ⭐⭐⭐⭐ |

---

## 🗂️ 文件结构（创新 vs 套路标注）

```
storm/
  storm_wiki/
    engine.py                → 🔥 [CORE] 主控流：协调多视角搜索 + 文章生成 (C1,C2,C3)
    modules/
      knowledge_curation.py  → 🔥 [CORE] 信息搜集：多视角提问 + 对话模拟 (C1,C2)
      article_generation.py  → 🔥 [CORE] 文章生成：层次大纲 → 段落撰写 (C3)
      storm_dataclass.py     → 📦 [INFRA] 数据结构：InformationTable, StormArticle
      callback.py            → ⚙️  [BOILERPLATE] 回调接口定义
    interface.py             → 📦 [INFRA] 抽象接口
  lm.py                      → ⚙️  [BOILERPLATE] LLM API 封装（OpenAI/Anthropic wrapper）
  rm.py                      → ⚙️  [BOILERPLATE] 检索模型封装（YouRM, BraveRM 等）
  examples/                  → ⚙️  [BOILERPLATE] 使用示例脚本

Legend: 🔥 论文核心创新 | 📦 基础设施 | ⚙️ 套路代码（已跳过）
```

---

## 🔍 创新点定位过程

**从论文 Contributions 提取的关键词**：

| Claim | 搜索关键词 | 命中文件 | 命中函数 | 得分 |
|-------|-----------|---------|---------|------|
| C1 | perspective, question, asking, simulate, editor | knowledge_curation.py | `QuestionAsker.ask()` | 9/10 |
| C2 | conversation, simulate, conv, dialogue | knowledge_curation.py | `ConvSimulator.simulate()` | 8/10 |
| C3 | outline, hierarchical, generate, structure | article_generation.py | `OutlineGenerator.generate()` | 7/10 |

**套路代码已过滤**：`lm.py`, `rm.py`, `callback.py`, `examples/`, `train*.py`（共 8 个文件跳过）

---

## ⚙️ 套路代码清单（已跳过深度分析）

- `lm.py` — OpenAI/Anthropic API 的标准 wrapper
- `rm.py` — 各检索引擎的标准 wrapper（YouRM, BraveRM, SearXNG）
- `callback.py` — 空接口，无实质逻辑
- `examples/storm_examples.py` — 使用示例

---

## ❓ 延伸问题

- [ ] STORM 的多视角发现策略（C1）能否移植到 ARIS-mNGS 的知识检索模块，模拟"不同临床专科医生"的视角？
- [ ] C2 的对话模拟（ConvSimulator）与你当前的 RAG 方案相比，额外的对话轮次是否值得推理成本？
- [ ] C3 的层次大纲生成能否用于 mNGS 报告的自动结构化？

---

> 💡 **下一步**：运行 `/code-explain https://github.com/stanford-oval/storm --file storm_wiki/modules/knowledge_curation.py --func QuestionAsker.ask --paper https://arxiv.org/abs/2402.14207` 获取 C1 的逐行分析
