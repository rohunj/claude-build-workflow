#!/bin/bash
# Build-Test-Fix Loop
# Full autonomous cycle: Build → Deploy → Test → Find Bugs → Fix → Repeat
# Usage: ./build-test-fix-loop.sh [deployment_url] [max_cycles]

set -e

DEPLOYMENT_URL=${1:-""}
MAX_CYCLES=${2:-3}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$DEPLOYMENT_URL" ]; then
  echo "Usage: ./build-test-fix-loop.sh <deployment_url> [max_cycles]"
  echo "Example: ./build-test-fix-loop.sh https://my-app.vercel.app 3"
  exit 1
fi

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Build-Test-Fix Loop"
echo "  URL: $DEPLOYMENT_URL"
echo "  Max Cycles: $MAX_CYCLES"
echo "════════════════════════════════════════════════════════════"
echo ""

# Notification function (reuse from ralph.sh)
send_notification() {
  local title="$1"
  local message="$2"

  if [ -f "$SCRIPT_DIR/.notify-config" ]; then
    source "$SCRIPT_DIR/.notify-config"
    if [ -n "$NTFY_TOPIC" ]; then
      curl -s -d "$message" "ntfy.sh/$NTFY_TOPIC" > /dev/null 2>&1 || true
    fi
  fi
}

for cycle in $(seq 1 $MAX_CYCLES); do
  echo ""
  echo "╔══════════════════════════════════════════════════════════╗"
  echo "║  CYCLE $cycle of $MAX_CYCLES"
  echo "╚══════════════════════════════════════════════════════════╝"
  echo ""

  # ═══════════════════════════════════════════════════════════════
  # PHASE 1: Build (Ralph)
  # ═══════════════════════════════════════════════════════════════
  echo "▶ Phase 1: Building with Ralph..."

  INCOMPLETE=$(cat prd.json 2>/dev/null | jq '[.userStories[] | select(.passes == false)] | length' || echo "0")

  if [ "$INCOMPLETE" -gt 0 ]; then
    echo "  Found $INCOMPLETE incomplete stories. Running Ralph..."
    ./ralph.sh 50  # Limit iterations per cycle

    # Check if build completed
    STILL_INCOMPLETE=$(cat prd.json | jq '[.userStories[] | select(.passes == false)] | length')
    if [ "$STILL_INCOMPLETE" -gt 0 ]; then
      echo "  Warning: $STILL_INCOMPLETE stories still incomplete after Ralph run"
    fi
  else
    echo "  All stories complete. Skipping build phase."
  fi

  # ═══════════════════════════════════════════════════════════════
  # PHASE 2: Test
  # ═══════════════════════════════════════════════════════════════
  echo ""
  echo "▶ Phase 2: Testing deployed app..."

  # Run testing with Claude
  TEST_PROMPT="Read skills/test-and-break/SKILL.md and test the app at $DEPLOYMENT_URL.
Read tasks/prd.md first to understand what to test.
Save your bug report to tasks/bug-report-cycle-$cycle.md.
Be thorough - try to break things!"

  echo "$TEST_PROMPT" | claude --dangerously-skip-permissions 2>&1 | tee "test-output-cycle-$cycle.log" || true

  # ═══════════════════════════════════════════════════════════════
  # PHASE 3: Check for bugs
  # ═══════════════════════════════════════════════════════════════
  echo ""
  echo "▶ Phase 3: Checking for bugs..."

  BUG_REPORT="tasks/bug-report-cycle-$cycle.md"

  if [ ! -f "$BUG_REPORT" ]; then
    echo "  No bug report generated. Testing may have failed."
    send_notification "Test Cycle $cycle" "No bug report generated - check test output"
    continue
  fi

  # Count bugs by severity
  CRITICAL=$(grep -c "Severity.*Critical" "$BUG_REPORT" 2>/dev/null || echo "0")
  HIGH=$(grep -c "Severity.*High" "$BUG_REPORT" 2>/dev/null || echo "0")
  MEDIUM=$(grep -c "Severity.*Medium" "$BUG_REPORT" 2>/dev/null || echo "0")
  LOW=$(grep -c "Severity.*Low" "$BUG_REPORT" 2>/dev/null || echo "0")
  TOTAL=$((CRITICAL + HIGH + MEDIUM + LOW))

  echo "  Bugs found: $TOTAL (Critical: $CRITICAL, High: $HIGH, Medium: $MEDIUM, Low: $LOW)"

  if [ "$TOTAL" -eq 0 ]; then
    echo ""
    echo "════════════════════════════════════════════════════════════"
    echo "  NO BUGS FOUND! Build-Test-Fix loop complete."
    echo "════════════════════════════════════════════════════════════"
    send_notification "Build Complete!" "No bugs found after $cycle cycles. App is ready!"
    exit 0
  fi

  # ═══════════════════════════════════════════════════════════════
  # PHASE 4: Convert bugs to stories
  # ═══════════════════════════════════════════════════════════════
  echo ""
  echo "▶ Phase 4: Converting bugs to user stories..."

  CONVERT_PROMPT="Read skills/bugs-to-stories/SKILL.md and convert the bugs in $BUG_REPORT to user stories.
Add them to prd.json with appropriate priorities.
Critical and High bugs should be fixed first."

  echo "$CONVERT_PROMPT" | claude --dangerously-skip-permissions 2>&1 | tee "convert-output-cycle-$cycle.log" || true

  # Verify stories were added
  NEW_INCOMPLETE=$(cat prd.json | jq '[.userStories[] | select(.passes == false)] | length')
  echo "  Stories now pending: $NEW_INCOMPLETE"

  send_notification "Cycle $cycle Complete" "Found $TOTAL bugs. $NEW_INCOMPLETE stories pending. Starting fixes..."

  echo ""
  echo "  Cycle $cycle complete. Starting next cycle to fix bugs..."
  sleep 5

done

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  Reached max cycles ($MAX_CYCLES)"
echo "  Check prd.json and bug reports for remaining issues."
echo "════════════════════════════════════════════════════════════"

# Final status
FINAL_INCOMPLETE=$(cat prd.json | jq '[.userStories[] | select(.passes == false)] | length')
send_notification "Loop Finished" "Completed $MAX_CYCLES cycles. $FINAL_INCOMPLETE stories still pending."
