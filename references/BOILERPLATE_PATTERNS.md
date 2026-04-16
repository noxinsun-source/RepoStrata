# Boilerplate Detection Patterns

Files and functions matching these patterns are **automatically skipped** during innovation analysis.
They represent standard ML/software infrastructure, not paper contributions.

---

## File-level patterns (skip entire file if path matches)

### By directory name
```
tests/, test/, testing/
examples/, demo/, demos/
scripts/ (exception: scripts/core*, scripts/model* may be relevant)
docs/, documentation/
notebooks/, notebook/
.github/, .ci/
```

### By filename pattern
```
train.py, trainer.py, training.py
evaluate.py, eval.py, evaluation.py
test_*.py, *_test.py
config.py, configs.py, configuration.py, settings.py
logger.py, logging_utils.py
utils.py, helpers.py, common.py, misc.py
setup.py, setup_env.py
requirements*.txt, pyproject.toml, package.json
Makefile, Dockerfile, docker-compose.yml
*.yaml, *.yml (exception: model_config.yaml may define architecture)
__init__.py (usually just exports)
```

---

## Function-level patterns (skip individual function if name matches)

### Training & Optimization
```python
train(), train_epoch(), train_step(), training_loop()
fit(), fit_one_epoch()
optimize(), update_weights()
backward(), compute_gradients()
clip_gradients(), gradient_clipping()
```

### Evaluation & Metrics
```python
evaluate(), eval_epoch(), val_step()
compute_metrics(), calculate_metrics()
accuracy(), f1_score(), bleu_score(), rouge_score()
perplexity()
```

### Data Loading & Processing
```python
load_data(), load_dataset(), read_data()
preprocess(), tokenize(), encode()
collate_fn(), collate_batch()
__getitem__(), __len__()  # DataLoader interface
build_dataloader(), create_dataloader()
```

### Configuration & Setup
```python
parse_args(), get_args(), setup_args()
load_config(), read_config(), get_config()
setup_logging(), init_logger(), get_logger()
set_seed(), fix_seed()
```

### Checkpointing & I/O
```python
save_model(), load_model(), save_checkpoint(), load_checkpoint()
save_results(), write_output()
```

### Standard Model Components (unless significantly modified)
```python
__init__()  # of standard nn.Module subclasses with only standard layers
forward()   # if body only calls super().forward() or standard layers
```

---

## Exception Rules

Even if a file/function matches the above patterns, **keep it** if:

1. The README or paper explicitly mentions it by name as a contribution
2. The function contains a non-standard loss calculation (custom loss = often a contribution)
3. The function name appears in the paper's method section
4. The function calls other clearly-novel functions (it may be the "glue" of a novel pipeline)
