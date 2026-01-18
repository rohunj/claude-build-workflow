# Claude Code Build Workflow

A complete workflow for building apps, systems, and automations with Claude Code. This combines the BMAD method for discovery/planning with Ralph for autonomous execution.

## Overview

This workflow takes you from idea to implementation:

1. **Discovery & Interview** (BMAD) - Define what you're building
2. **PRD Creation** - Document requirements and user stories
3. **Technical Architecture** - Design the system
4. **PRD Enhancement** - Refine with edge cases and quality checks
5. **Convert to prd.json** - Prepare for autonomous execution
6. **Autonomous Execution** (Ralph) - Build it automatically

---

## Prerequisites

### Required
- **Claude Code CLI** installed and authenticated (`claude` command available)
- **jq** for JSON parsing (`brew install jq` on macOS)
- **Git** initialized in your project

### Optional (for browser testing)
- **agent-browser** for UI verification (`npm install -g agent-browser && agent-browser install`)

---

## Workflow Steps

### Step 1: Start a New Project

```bash
# Create your project folder
mkdir my-project && cd my-project

# Initialize git
git init

# Copy workflow files to your project
cp -r /path/to/claude-build-workflow/skills ./
cp -r /path/to/claude-build-workflow/prompts ./
cp /path/to/claude-build-workflow/ralph.sh ./
chmod +x ralph.sh

# Create tasks folder
mkdir tasks
```

### Step 2: Discovery Interview (BMAD Method)

Start Claude Code and begin the discovery process:

```bash
claude
```

Then tell Claude:

```
I want to build [describe your idea]. Let's do a discovery interview to figure out
exactly what I'm building. Act as a product manager and interview me about:

1. What problem am I solving?
2. Who are the users?
3. What are the core features?
4. What's the scope (MVP vs full)?
5. What are the success criteria?

Ask me questions one at a time. Challenge my assumptions. Help me think through
edge cases I might be missing. Once we've covered everything, summarize what
we've discussed.
```

**Tips:**
- Be honest about what you don't know
- Let Claude push back on scope
- Focus on the "why" not just the "what"
- Take notes or ask Claude to summarize

### Step 3: Create the PRD

Once discovery is complete, use the PRD skill:

```
Read the skills/prd/SKILL.md file and use it to create a PRD for what we
discussed. Save it to tasks/prd-[project-name].md.

Remember to:
- Ask clarifying questions with lettered options
- Keep user stories small (completable in one session)
- Make acceptance criteria specific and verifiable
- Include "Typecheck passes" on every story
- Include "Verify in browser" on UI stories
```

### Step 4: Technical Architecture

After the PRD is created:

```
Now let's design the technical architecture. Based on the PRD, help me decide:

1. What tech stack should we use?
2. How should the system be structured?
3. What are the key components and how do they interact?
4. What database schema do we need?
5. What APIs/endpoints are required?
6. Are there any third-party integrations?

Document key decisions and trade-offs. Save to tasks/architecture.md.
```

### Step 5: Edge Case Analysis

With PRD and architecture in place, analyze for edge cases:

```
Read skills/edge-cases/SKILL.md and use it to analyze the PRD at
tasks/prd-[project-name].md.

Identify edge cases, failure modes, and scenarios we might have missed.
Update the PRD with additional acceptance criteria and user stories
as needed.
```

### Step 6: User Story Quality Review

Before converting to JSON, validate story quality:

```
Read skills/story-quality/SKILL.md and use it to review the user stories
in tasks/prd-[project-name].md.

Check that:
- Each story is 1-2 lines max
- Each story is small enough for one iteration
- Stories are properly sequenced by dependency
- All acceptance criteria are specific and verifiable
- Typecheck and browser verification criteria are included

Fix any issues before proceeding.
```

### Step 7: Convert to prd.json

Now convert the validated PRD to Ralph's JSON format:

```
Read skills/ralph/SKILL.md and use it to convert the PRD at
tasks/prd-[project-name].md into prd.json format.

Remember:
- Each story must be completable in one context window
- Order by dependencies (schema → backend → frontend)
- All stories start with passes: false
- branchName should be ralph/[feature-name-kebab-case]

Save to ./prd.json in the project root.
```

### Step 8: Initialize Progress File

Create the progress tracking file:

```bash
echo "# Ralph Progress Log" > progress.txt
echo "Started: $(date)" >> progress.txt
echo "---" >> progress.txt
echo "" >> progress.txt
echo "## Codebase Patterns" >> progress.txt
echo "(Patterns discovered during implementation will be added here)" >> progress.txt
echo "" >> progress.txt
echo "---" >> progress.txt
```

### Step 9: Run Autonomous Execution

Now run Ralph to build everything:

```bash
./ralph.sh 100
```

This will:
- Read prd.json and select the highest priority incomplete story
- Implement the story
- Run quality checks (typecheck, lint, tests)
- Commit if passing
- Mark the story complete in prd.json
- Log progress and learnings
- Repeat until all stories pass or 100 iterations reached

**Monitor progress:**
- Watch the terminal output
- Check `progress.txt` for detailed logs
- Check `prd.json` to see which stories are complete

---

## Folder Structure

After setup, your project should look like:

```
my-project/
├── skills/                    # Skill definitions for Claude
│   ├── prd/SKILL.md          # PRD generation skill
│   ├── ralph/SKILL.md        # PRD to JSON conversion
│   ├── edge-cases/SKILL.md   # Edge case analysis
│   ├── story-quality/SKILL.md # Story review skill
│   ├── agent-browser/SKILL.md # Browser automation
│   └── ...                   # Other utility skills
├── prompts/
│   └── ralph-agent.md        # Instructions for each Ralph iteration
├── tasks/
│   ├── prd-[name].md         # Your PRD document
│   └── architecture.md       # Technical architecture
├── ralph.sh                  # Autonomous execution script
├── prd.json                  # Structured task list for Ralph
├── progress.txt              # Execution log and learnings
└── [your source code]        # Built by Ralph
```

---

## Tips for Success

### PRD Writing
- **Small stories:** If in doubt, split it smaller
- **Dependencies first:** Schema before code that uses it
- **Be specific:** Vague criteria = bad implementation
- **Think in iterations:** Each story = one Claude session

### During Execution
- **Let it run:** Don't interrupt unless stuck
- **Check progress.txt:** See what's being learned
- **Review commits:** Each story should be one focused commit
- **Fix forward:** If something breaks, add a new story to fix it

### If Something Goes Wrong
1. Check which story failed in prd.json
2. Read progress.txt for error details
3. Fix the issue manually or add clarifying notes
4. Re-run ralph.sh to continue

---

## Customization

### Adjust Max Iterations
```bash
./ralph.sh 50   # Run up to 50 iterations
./ralph.sh 200  # Run up to 200 iterations
```

### Modify the Agent Prompt
Edit `prompts/ralph-agent.md` to customize how Claude approaches each iteration.

### Add Project-Specific Patterns
Create a `CLAUDE.md` or `AGENTS.md` file in your project root with patterns specific to your codebase.

### Skip Browser Verification
If you don't need UI testing, remove agent-browser references from skills.

---

## Troubleshooting

### "jq: command not found"
Install jq: `brew install jq` (macOS) or `apt-get install jq` (Linux)

### Claude CLI not found
Make sure Claude Code is installed and in your PATH.

### Stories keep failing
- Check if stories are too large (split them)
- Check if dependencies are ordered wrong
- Look at progress.txt for specific errors

### Stuck in a loop
- Check if acceptance criteria are actually achievable
- Manually mark problematic story as complete
- Add notes to prd.json explaining the issue

---

## Quick Reference

| Command | Purpose |
|---------|---------|
| `claude` | Start Claude Code interactive session |
| `./ralph.sh` | Run autonomous execution (default 100 iterations) |
| `./ralph.sh 50` | Run with custom iteration limit |
| `cat prd.json \| jq '.userStories[] \| select(.passes==false)'` | See incomplete stories |
| `tail -50 progress.txt` | See recent progress |

---

## Credits

This workflow combines:
- [BMAD Method](https://github.com/bmad-code-org/BMAD-METHOD) - Discovery and planning methodology
- [Ralph](https://github.com/snarktank/ralph) - Autonomous execution loop (adapted for Claude Code)
- [Amp Skills](https://github.com/snarktank/amp-skills) - Utility skills (adapted for Claude Code)
