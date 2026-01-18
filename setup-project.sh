#!/bin/bash
# Setup a new project with Claude Code Build Workflow
# Usage: ./setup-project.sh /path/to/new-project

set -e

if [ -z "$1" ]; then
  echo "Usage: ./setup-project.sh /path/to/new-project"
  echo "Example: ./setup-project.sh ~/projects/my-new-app"
  exit 1
fi

PROJECT_DIR="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Setting up Claude Code Build Workflow in: $PROJECT_DIR"
echo ""

# Create project directory
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Initialize git if not already
if [ ! -d ".git" ]; then
  echo "Initializing git repository..."
  git init
fi

# Copy workflow files
echo "Copying workflow files..."
cp -r "$SCRIPT_DIR/skills" ./
cp -r "$SCRIPT_DIR/prompts" ./
cp "$SCRIPT_DIR/ralph.sh" ./
chmod +x ralph.sh

# Create tasks folder
mkdir -p tasks

# Initialize progress file
echo "Creating progress.txt..."
cat > progress.txt << 'EOF'
# Ralph Progress Log
Started: $(date)
---

## Codebase Patterns
(Patterns discovered during implementation will be added here)

---
EOF

# Create CLAUDE.md with project instructions
echo "Creating CLAUDE.md..."
cat > CLAUDE.md << 'EOF'
# Project Instructions

## Workflow

This project uses the Claude Code Build Workflow. See INSTRUCTIONS.md in the
workflow folder for the complete guide.

## Quick Reference

1. **Discovery:** Interview about what you're building
2. **PRD:** Create tasks/prd-[name].md using skills/prd/SKILL.md
3. **Architecture:** Create tasks/architecture.md
4. **Edge Cases:** Analyze with skills/edge-cases/SKILL.md
5. **Quality Check:** Review stories with skills/story-quality/SKILL.md
6. **Convert:** Create prd.json using skills/ralph/SKILL.md
7. **Execute:** Run ./ralph.sh 100

## Project-Specific Patterns

(Add patterns discovered during development here)

EOF

# Copy templates
echo "Copying templates..."
mkdir -p templates
cp "$SCRIPT_DIR/templates/"* templates/ 2>/dev/null || true

echo ""
echo "Setup complete!"
echo ""
echo "Next steps:"
echo "1. cd $PROJECT_DIR"
echo "2. Start Claude Code: claude"
echo "3. Begin discovery interview"
echo ""
echo "See $SCRIPT_DIR/INSTRUCTIONS.md for the full workflow guide."
