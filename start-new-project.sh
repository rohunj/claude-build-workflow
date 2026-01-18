#!/bin/bash
# One-command setup for new Claude Code projects
# Just run this in your new project folder

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=========================================="
echo "  Setting up Claude Code Build Workflow"
echo "=========================================="
echo ""

# Initialize git
if [ ! -d ".git" ]; then
  echo "Initializing git..."
  git init
  echo ""
fi

# Copy all needed files
echo "Copying workflow files..."
cp -r "$WORKFLOW_DIR/skills" ./
cp -r "$WORKFLOW_DIR/prompts" ./
cp "$WORKFLOW_DIR/ralph.sh" ./
chmod +x ralph.sh

# Create folders
mkdir -p tasks

# Create progress file
cat > progress.txt << 'PROGRESS'
# Ralph Progress Log
---

## Codebase Patterns
(Patterns will be added here as the project is built)

---
PROGRESS

# Create CLAUDE.md
cat > CLAUDE.md << 'CLAUDEMD'
# Project Guide

This project uses automated Claude Code workflows.

## Skills Available
- skills/prd/SKILL.md - Create PRD documents
- skills/edge-cases/SKILL.md - Analyze edge cases
- skills/story-quality/SKILL.md - Review user stories
- skills/ralph/SKILL.md - Convert PRD to JSON

## To Run Autonomous Build
After creating prd.json, run: ./ralph.sh
CLAUDEMD

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Next: Run 'claude' to start Claude Code"
echo ""
echo "Then copy-paste the prompts from:"
echo "$WORKFLOW_DIR/QUICKSTART.md"
echo ""
