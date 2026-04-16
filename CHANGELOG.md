# Changelog

All notable changes to RepoStrata will be documented in this file.

## [1.1.0] - 2026-04-17

### Added
- `/repo-map` skill: ultra-lightweight L1 architecture scan using sparse git clone
- `/inno-scan` skill: innovation localization via targeted grep (replaces full-file reads)
- `/code-explain` skill: single-function L3+L4 deep analysis
- `/repo-compare` skill: side-by-side comparison of two repos
- `references/BOILERPLATE_PATTERNS.md`: comprehensive boilerplate detection rules
- `references/INNOVATION_SCORING.md`: scoring algorithm for candidate functions
- `references/OUTPUT_TEMPLATES.md`: Mermaid + table templates for consistent output
- `examples/storm-inno-scan.md`: real example output for stanford-oval/storm

### Changed
- Decomposed original monolithic `/analyze-repo` into 4 focused skills
- Each skill now has explicit context budget (< 10k tokens per invocation)

### Why This Change
The original single skill would attempt to read entire repos at once,
hitting LLM context limits on repos with 50+ source files.
The new 4-skill architecture ensures any skill works on any size repo.

## [1.0.0] - 2026-04-16

### Added
- Initial release as `PaperTrace` (renamed to `RepoStrata` in v1.1.0)
- Single `/analyze-repo` skill with 4-layer analysis (L1–L4)
- Innovation Localization concept: paper claims → code mapping
- Boilerplate detection to filter standard ML infrastructure
- Bilingual README (English + 中文)
