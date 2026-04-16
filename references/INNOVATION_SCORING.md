# Innovation Scoring Algorithm

Used by `/inno-scan` to rank candidate functions by likelihood of implementing a paper's contribution.

---

## Scoring Formula

**Score = Σ(signal weights)**  
Threshold: Score ≥ 4 → include in mapping table

---

## Positive Signals

| Signal | Weight | Detection Method |
|--------|--------|-----------------|
| Function name contains innovation keyword | **+3** | Direct string match vs. claim keywords |
| Docstring / comment cites paper section | **+3** | Regex: `Section \d`, `Eq. \d`, `Algorithm \d`, `as described in` |
| Function body contains unique algorithmic logic | **+2** | Presence of non-trivial loops/recursion NOT calling standard library only |
| Called by other high-scoring candidate functions | **+1** | Reverse call graph (grep who calls this function) |
| File name contains innovation keyword | **+1** | File-level match vs. claim keywords |
| Function is referenced in README | **+1** | Grep function name in README.md |

---

## Negative Signals

| Signal | Weight | Detection Method |
|--------|--------|-----------------|
| Function only calls standard library (torch, numpy, etc.) | **-2** | All calls are to known standard APIs |
| Matches boilerplate pattern from BOILERPLATE_PATTERNS.md | **-3** | Pattern match |
| Function is in a file matching boilerplate directory pattern | **-1** | Directory-level pattern match |
| Function body < 5 lines | **-1** | Usually a wrapper/property |

---

## Confidence Stars (for display in output)

| Score | Stars | Interpretation |
|-------|-------|----------------|
| ≥ 8 | ⭐⭐⭐⭐⭐ | Almost certainly the implementation |
| 6–7 | ⭐⭐⭐⭐ | Very likely, minor uncertainty |
| 4–5 | ⭐⭐⭐ | Probable, worth reading |
| 2–3 | ⭐⭐ | Possible, use as fallback |
| < 2 | ⭐ | Weak match, flag for user confirmation |

---

## When No Function Scores ≥ 4

Fall back to showing **Top 5 candidates by score** regardless of threshold,
and prompt user to manually confirm:

```
⚠️  Innovation localization confidence is low for Claim C2.
    Best candidates found (please confirm):
    
    1. [file.py::function()]  Score: 3  ⭐⭐
    2. [file.py::other()]     Score: 2  ⭐⭐
    
    Type the number to confirm, or describe the function you're looking for:
```
