# Contributing to RepoStrata

Thank you for your interest in improving RepoStrata!

## Ways to Contribute

### 1. Add Example Outputs (`examples/`)
The most valuable contribution. Run a skill on a real repo and submit the output.

Format: `examples/[repo-name]-[skill].md`

Example: `examples/hipporag-inno-scan.md`

### 2. Improve Boilerplate Patterns (`references/BOILERPLATE_PATTERNS.md`)
If you find false positives (innovative functions being wrongly skipped) or false negatives (boilerplate being analyzed), open an issue or PR with the pattern fix.

### 3. Add Language Support
Current best support: Python. Add grep patterns for:
- JavaScript / TypeScript
- Java
- Go
- C++

### 4. New Skills
Ideas for additional skills:
- `/paper-ingest` — summarize arXiv paper into structured vault note
- `/func-trace` — trace data flow through multiple functions
- `/dependency-explain` — explain why specific libraries were chosen

## PR Guidelines

1. One skill / one fix per PR
2. Include a real example output in `examples/` if adding/modifying a skill
3. Update `CHANGELOG.md` under `[Unreleased]`
4. Test with at least one real GitHub repo before submitting

## Issues

Use GitHub Issues for:
- False positives/negatives in innovation localization
- Repos where skills failed or produced poor results
- Feature requests
