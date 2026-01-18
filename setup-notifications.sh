#!/bin/bash
# Set up phone notifications
# Usage: ./setup-notifications.sh

WORKFLOW_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo "=========================================="
echo "  Phone Notifications Setup"
echo "=========================================="
echo ""
echo "This uses ntfy.sh (free, no account needed)"
echo ""

# Generate a random topic
RANDOM_TOPIC="claude-builds-$(openssl rand -hex 4)"

echo "Your notification topic: $RANDOM_TOPIC"
echo ""
echo "To receive notifications:"
echo "  1. Install 'ntfy' app on your phone (free)"
echo "  2. Open the app, tap +"
echo "  3. Enter this topic: $RANDOM_TOPIC"
echo "  4. Tap Subscribe"
echo ""

read -p "Press Enter after you've subscribed in the app..."

# Save config
echo "NTFY_TOPIC=\"$RANDOM_TOPIC\"" > "$WORKFLOW_DIR/.notify-config"

# Test notification
echo ""
echo "Sending test notification..."
curl -s -d "Notifications are working! You'll get alerts when builds start, complete, or need attention." "ntfy.sh/$RANDOM_TOPIC"

echo ""
echo "Done! Check your phone - you should see a test notification."
echo ""
echo "Config saved to: $WORKFLOW_DIR/.notify-config"
echo ""
