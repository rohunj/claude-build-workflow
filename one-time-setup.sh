#!/bin/bash
# One-time setup - Run this once to set up everything for remote builds
# Usage: ./one-time-setup.sh

set -e

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=========================================="
echo "  One-Time Setup for Remote Builds"
echo "=========================================="
echo ""

# Check for gh CLI
if ! command -v gh &> /dev/null; then
  echo "Installing GitHub CLI..."
  if [[ "$OSTYPE" == "darwin"* ]]; then
    brew install gh
  else
    echo "Please install GitHub CLI: https://cli.github.com/"
    exit 1
  fi
fi

# Check if logged in
if ! gh auth status &> /dev/null; then
  echo "Logging into GitHub..."
  gh auth login
fi

echo ""
echo "GitHub CLI ready!"
echo ""

# Get GitHub username
GH_USER=$(gh api user -q .login)
echo "Logged in as: $GH_USER"
echo ""

# Create template repo
TEMPLATE_REPO="claude-build-template"

echo "Creating template repository: $TEMPLATE_REPO"
if gh repo view "$GH_USER/$TEMPLATE_REPO" &> /dev/null; then
  echo "Template repo already exists. Updating..."
else
  gh repo create "$TEMPLATE_REPO" --private --description "Template for Claude Code builds"
fi

# Clone, add files, push
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

gh repo clone "$GH_USER/$TEMPLATE_REPO" . 2>/dev/null || git init

# Copy workflow files
cp -r "$WORKFLOW_DIR/skills" ./
cp -r "$WORKFLOW_DIR/prompts" ./
cp "$WORKFLOW_DIR/ralph.sh" ./
cp "$WORKFLOW_DIR/CLAUDE.md" ./
[ -f "$WORKFLOW_DIR/.notify-config" ] && cp "$WORKFLOW_DIR/.notify-config" ./
chmod +x ralph.sh

# Create tasks folder
mkdir -p tasks

# Create progress.txt template
cat > progress.txt << 'EOF'
# Ralph Progress Log
---

## Codebase Patterns
(Patterns will be added here as the project is built)

---
EOF

# Create devcontainer for Codespaces with Claude pre-installed
mkdir -p .devcontainer
cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "Claude Build Environment",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code && echo 'Claude Code installed. Run: claude auth login'",
  "features": {
    "ghcr.io/devcontainers/features/node:1": {}
  }
}
EOF

# Git setup
git add -A
git commit -m "Claude build workflow template" 2>/dev/null || git commit --amend -m "Claude build workflow template"

# Set up remote and push
git branch -M main
gh repo view "$GH_USER/$TEMPLATE_REPO" --json sshUrl -q .sshUrl | xargs git remote set-url origin 2>/dev/null || \
  gh repo view "$GH_USER/$TEMPLATE_REPO" --json sshUrl -q .sshUrl | xargs git remote add origin
git push -u origin main --force

# Enable as template
gh repo edit "$GH_USER/$TEMPLATE_REPO" --template

# Cleanup
cd "$WORKFLOW_DIR"
rm -rf "$TEMP_DIR"

# Save config
cat > "$WORKFLOW_DIR/.github-config" << EOF
GH_USER="$GH_USER"
TEMPLATE_REPO="$TEMPLATE_REPO"
EOF

echo ""
echo "=========================================="
echo "  Setup Complete!"
echo "=========================================="
echo ""
echo "Template repo created: github.com/$GH_USER/$TEMPLATE_REPO"
echo ""
echo "Now when you start a new project, Claude will automatically:"
echo "  1. Create a new GitHub repo from the template"
echo "  2. Set up everything for remote access"
echo "  3. You can continue from your phone anytime"
echo ""
echo "To set up phone notifications, run:"
echo "  ./setup-notifications.sh"
echo ""
