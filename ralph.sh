#!/bin/bash
# Ralph for Claude Code - Long-running AI agent loop
# Adapted from Ralph Wiggum for Amp (https://github.com/snarktank/ralph)
# Usage: ./ralph.sh [max_iterations]

set -e

MAX_ITERATIONS=${1:-100}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PRD_FILE="$SCRIPT_DIR/prd.json"
PROGRESS_FILE="$SCRIPT_DIR/progress.txt"
ARCHIVE_DIR="$SCRIPT_DIR/archive"
LAST_BRANCH_FILE="$SCRIPT_DIR/.last-branch"
NOTIFY_CONFIG="$SCRIPT_DIR/.notify-config"

# Notification function
send_notification() {
  local title="$1"
  local message="$2"

  # Check for ntfy.sh config
  if [ -f "$NOTIFY_CONFIG" ]; then
    source "$NOTIFY_CONFIG"
    if [ -n "$NTFY_TOPIC" ]; then
      curl -s -d "$message" "ntfy.sh/$NTFY_TOPIC" > /dev/null 2>&1 || true
    fi
    if [ -n "$PUSHOVER_USER" ] && [ -n "$PUSHOVER_TOKEN" ]; then
      curl -s --form-string "token=$PUSHOVER_TOKEN" \
        --form-string "user=$PUSHOVER_USER" \
        --form-string "title=$title" \
        --form-string "message=$message" \
        https://api.pushover.net/1/messages.json > /dev/null 2>&1 || true
    fi
  fi
}

# Archive previous run if branch changed
if [ -f "$PRD_FILE" ] && [ -f "$LAST_BRANCH_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  LAST_BRANCH=$(cat "$LAST_BRANCH_FILE" 2>/dev/null || echo "")

  if [ -n "$CURRENT_BRANCH" ] && [ -n "$LAST_BRANCH" ] && [ "$CURRENT_BRANCH" != "$LAST_BRANCH" ]; then
    DATE=$(date +%Y-%m-%d)
    FOLDER_NAME=$(echo "$LAST_BRANCH" | sed 's|^ralph/||')
    ARCHIVE_FOLDER="$ARCHIVE_DIR/$DATE-$FOLDER_NAME"

    echo "Archiving previous run: $LAST_BRANCH"
    mkdir -p "$ARCHIVE_FOLDER"
    [ -f "$PRD_FILE" ] && cp "$PRD_FILE" "$ARCHIVE_FOLDER/"
    [ -f "$PROGRESS_FILE" ] && cp "$PROGRESS_FILE" "$ARCHIVE_FOLDER/"
    echo "   Archived to: $ARCHIVE_FOLDER"

    echo "# Ralph Progress Log" > "$PROGRESS_FILE"
    echo "Started: $(date)" >> "$PROGRESS_FILE"
    echo "---" >> "$PROGRESS_FILE"
  fi
fi

# Track current branch
if [ -f "$PRD_FILE" ]; then
  CURRENT_BRANCH=$(jq -r '.branchName // empty' "$PRD_FILE" 2>/dev/null || echo "")
  if [ -n "$CURRENT_BRANCH" ]; then
    echo "$CURRENT_BRANCH" > "$LAST_BRANCH_FILE"
  fi
fi

# Initialize progress file if it doesn't exist
if [ ! -f "$PROGRESS_FILE" ]; then
  echo "# Ralph Progress Log" > "$PROGRESS_FILE"
  echo "Started: $(date)" >> "$PROGRESS_FILE"
  echo "---" >> "$PROGRESS_FILE"
fi

# Get project name for notifications
PROJECT_NAME=$(jq -r '.project // "Project"' "$PRD_FILE" 2>/dev/null || echo "Project")

echo "Starting Ralph for Claude Code - Max iterations: $MAX_ITERATIONS"
echo "PRD file: $PRD_FILE"
echo "Progress file: $PROGRESS_FILE"
echo ""

send_notification "Build Started" "$PROJECT_NAME build started with up to $MAX_ITERATIONS iterations"

for i in $(seq 1 $MAX_ITERATIONS); do
  echo ""
  echo "═══════════════════════════════════════════════════════"
  echo "  Ralph Iteration $i of $MAX_ITERATIONS"
  echo "═══════════════════════════════════════════════════════"

  # Run claude with the ralph prompt
  OUTPUT=$(cat "$SCRIPT_DIR/prompts/ralph-agent.md" | claude --dangerously-skip-permissions 2>&1 | tee /dev/stderr) || true

  # Check for completion signal
  if echo "$OUTPUT" | grep -q "<promise>COMPLETE</promise>"; then
    echo ""
    echo "Ralph completed all tasks!"
    echo "Completed at iteration $i of $MAX_ITERATIONS"
    send_notification "Build Complete!" "$PROJECT_NAME finished successfully after $i iterations"
    exit 0
  fi

  # Check for errors that might need attention
  if echo "$OUTPUT" | grep -qi "error\|failed\|exception"; then
    send_notification "Build Needs Attention" "$PROJECT_NAME iteration $i may have errors - check progress"
  fi

  echo "Iteration $i complete. Continuing..."
  sleep 2
done

echo ""
echo "Ralph reached max iterations ($MAX_ITERATIONS) without completing all tasks."
echo "Check $PROGRESS_FILE for status."
send_notification "Build Stopped" "$PROJECT_NAME reached max iterations ($MAX_ITERATIONS). Check progress."
exit 1
