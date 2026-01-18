# Claude Build Workflow

An automated workflow for building apps, systems, and automations with Claude Code. Just describe what you want to build, answer some questions, and let it build autonomously.

## What This Does

1. **Interviews you** about what you're building (BMAD method)
2. **Creates a PRD** with user stories
3. **Designs the architecture**
4. **Analyzes edge cases** you might miss
5. **Validates story quality** for autonomous execution
6. **Builds it automatically** using the Ralph loop
7. **Notifies you** on your phone when done

## Features

- **Fully guided** - Just say "Run the workflow" and answer questions
- **Phone access** - Start on laptop, continue from phone via GitHub Codespaces
- **Notifications** - Get notified when builds complete or need attention
- **Autonomous execution** - Runs up to 100 iterations without intervention

## Quick Start

### 1. Clone and Setup

```bash
git clone https://github.com/rohunj/claude-build-workflow.git
cd claude-build-workflow

./one-time-setup.sh    # Sets up GitHub template
./setup-notifications.sh   # Sets up phone notifications
```

Install the **ntfy** app on your phone and subscribe to your topic.

### 2. Build Something

```bash
cd /path/to/claude-build-workflow && claude
```

Then say:
```
Run the workflow
```

Answer the questions. When ready, say "Start now" and close your laptop.

## How It Works

The workflow combines:

- **[BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD)** - Discovery and planning methodology
- **[Ralph](https://github.com/snarktank/ralph)** - Autonomous execution loop (adapted for Claude Code)
- **[Amp Skills](https://github.com/snarktank/amp-skills)** - Utility skills (adapted for Claude Code)

### The Flow

```
You: "I want to build a habit tracker"
    ↓
Claude interviews you (5-10 min)
    ↓
PRD + Architecture created
    ↓
Edge cases analyzed
    ↓
Stories validated
    ↓
Autonomous build starts
    ↓
[You close laptop, go about your day]
    ↓
Phone notification: "Build complete!"
```

## Requirements

- [Claude Code CLI](https://github.com/anthropics/claude-code) installed
- GitHub account
- `jq` for JSON parsing (`brew install jq` on macOS)

## Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Main workflow instructions (Claude reads this) |
| `ralph.sh` | Autonomous build loop |
| `skills/` | PRD generation, edge cases, story quality, etc. |
| `one-time-setup.sh` | Sets up GitHub template repo |
| `setup-notifications.sh` | Sets up phone notifications |

## License

MIT

## Credits

Built on top of:
- [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) by bmad-code-org
- [Ralph](https://github.com/snarktank/ralph) by snarktank
- [Amp Skills](https://github.com/snarktank/amp-skills) by snarktank
