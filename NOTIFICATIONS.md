# Set Up Phone Notifications

Get notified when your build completes, fails, or needs attention.

---

## Option 1: ntfy.sh (Free & Easy)

### Step 1: Install the App
- **iPhone**: Search "ntfy" in App Store
- **Android**: Search "ntfy" in Play Store

### Step 2: Pick a Topic Name
Choose a random/unique topic name like `rohun-builds-abc123`
(Anyone who knows the topic can see notifications, so make it random)

### Step 3: Subscribe in the App
Open ntfy app → tap + → enter your topic name → Subscribe

### Step 4: Configure Your Workflow
Create a file called `.notify-config` in your project folder:

```bash
echo 'NTFY_TOPIC="rohun-builds-abc123"' > .notify-config
```

Replace `rohun-builds-abc123` with your topic name.

### Done!
You'll now get notifications for:
- Build started
- Build complete
- Build needs attention (errors)
- Build stopped (max iterations)

---

## Option 2: Pushover ($5 One-Time)

More reliable, more features, but costs $5 once.

### Step 1: Buy & Install
- Go to pushover.net and create account ($5 for the app)
- Install Pushover app on your phone

### Step 2: Get Your Credentials
- Log into pushover.net
- Copy your **User Key** (on the main page)
- Click "Create Application/API Token"
  - Name it "Claude Builds"
  - Copy the **API Token**

### Step 3: Configure Your Workflow
Create `.notify-config` in your project folder:

```bash
cat > .notify-config << 'EOF'
PUSHOVER_USER="your-user-key-here"
PUSHOVER_TOKEN="your-api-token-here"
EOF
```

### Done!
Same notifications as ntfy, but through Pushover.

---

## Using Both

You can use both services - just put both in `.notify-config`:

```bash
cat > .notify-config << 'EOF'
NTFY_TOPIC="rohun-builds-abc123"
PUSHOVER_USER="your-user-key"
PUSHOVER_TOKEN="your-api-token"
EOF
```

---

## Notifications You'll Receive

| Event | Message |
|-------|---------|
| Build starts | "ProjectName build started with up to 100 iterations" |
| Build completes | "ProjectName finished successfully after X iterations" |
| Possible error | "ProjectName iteration X may have errors - check progress" |
| Max iterations | "ProjectName reached max iterations. Check progress." |

---

## Testing Notifications

To test if notifications work:

```bash
# For ntfy
curl -d "Test notification!" ntfy.sh/your-topic-name

# For Pushover
curl -s --form-string "token=YOUR_TOKEN" \
  --form-string "user=YOUR_USER" \
  --form-string "message=Test notification!" \
  https://api.pushover.net/1/messages.json
```

---

## Per-Project vs Global Config

**Per-project**: Put `.notify-config` in each project folder
**Global**: Put `.notify-config` in the workflow folder, it will be copied to new projects

To set up global notifications:
```bash
# Create global config
cat > ~/Library/CloudStorage/Dropbox-Rohun/Ro\ J/Rohun\ Personal/01\ -\ Areas/06\ -\ Coding/claude-build-workflow/.notify-config << 'EOF'
NTFY_TOPIC="your-topic"
EOF
```

Then update the setup script to copy it to new projects.
