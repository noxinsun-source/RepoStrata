#!/bin/bash
# RepoStrata installer
# Usage: bash install.sh [target_skills_dir]
# Example: bash install.sh ~/.claude/skills/
# Example: bash install.sh "/Users/me/Documents/Obsidian Vault/.claude/skills/"

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${1:-$HOME/.claude/skills}"

echo "🪨 RepoStrata Installer"
echo "Installing skills to: $TARGET"
echo ""

mkdir -p "$TARGET"

SKILLS=(
  "full-analysis"
  "repo-preflight"
  "repo-map"
  "repo-callgraph"
  "repo-interfaces"
  "data-flow"
  "inno-scan"
  "code-explain"
  "repo-compare"
  "merge-analysis"
)

for skill in "${SKILLS[@]}"; do
  src="$SCRIPT_DIR/skills/$skill"
  dst="$TARGET/$skill"
  if [ -d "$src" ]; then
    cp -r "$src" "$dst"
    echo "  ✅ $skill"
  else
    echo "  ⚠️  $skill (not found, skipping)"
  fi
done

echo ""
echo "Done! Open Claude Code and type /full-analysis to get started."
