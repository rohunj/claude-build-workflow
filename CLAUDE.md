# Claude Code Build Workflow

When a user asks you to "run the workflow" or "start a new project" using this folder, follow these steps in order. Guide the user through each phase conversationally.

**IMPORTANT: Automatic Skill Usage**
Read `skills/SKILLS-INDEX.md` at the start of every project. This tells you which skills to apply automatically based on the project type and tech stack. You should use these skills transparently without requiring manual invocation from the user.

---

## PHASE 0: Check Setup

First, check if this is the workflow folder (contains skills/, prompts/, ralph.sh).

Check if `.github-config` exists in this folder:
- If YES: GitHub is set up for remote builds
- If NO: Tell the user "Let me set up remote access so you can control builds from your phone" and run `./one-time-setup.sh`

Check if `.notify-config` exists:
- If NO: Ask "Would you like phone notifications when builds complete? (takes 30 seconds to set up)"
- If they say yes, run `./setup-notifications.sh`

---

## PHASE 1: Project Setup

Ask the user:
> "What do you want to name this project? (one or two words, like 'habit-tracker' or 'invoice-app')"

Once they give a name, create the project:

1. Read the GitHub config from `.github-config` to get GH_USER and TEMPLATE_REPO

2. Create new repo from template using gh CLI:
```bash
gh repo create [project-name] --template [GH_USER]/[TEMPLATE_REPO] --private --clone
cd [project-name]
```

3. Tell the user:
> "Created your project at ~/[project-name] and on GitHub. You can access it from any device now. Let's start planning!"

---

## PHASE 2: Discovery Interview

Say to the user:
> "Tell me about what you want to build. Just describe your idea in a few sentences - what is it, what problem does it solve, who is it for?"

After they respond, conduct a discovery interview by asking questions ONE AT A TIME:

1. **Problem & Value**: "What specific problem does this solve? What happens if this doesn't exist?"
2. **Users**: "Who exactly will use this? Be specific - is it you, customers, employees, everyone?"
3. **Core Features**: "If this could only do 3 things, what would they be?"
4. **Success**: "How will you know this is working? What does success look like?"
5. **Scope**: "What should this explicitly NOT do? What's out of scope for now?"

Challenge vague answers. Push for specifics. If they say "users can manage things" ask "what things? how do they manage them?"

After gathering answers, summarize:
> "Here's what I understand we're building: [summary]. Does this capture it correctly?"

Wait for confirmation before proceeding.

---

## PHASE 3: Create PRD

Once discovery is confirmed, say:
> "Now I'll create the Product Requirements Document. I have a few clarifying questions first."

Read `skills/prd/SKILL.md` for the PRD format.

Ask 3-5 clarifying questions with lettered options like:
```
1. What's the primary platform?
   A. Web app
   B. Mobile app
   C. Desktop app
   D. API/Backend only

2. What's the scope for v1?
   A. Minimal - just core functionality
   B. Standard - core + nice-to-haves
   C. Full - everything we discussed
```

Tell them they can answer like "1A, 2B" to go fast.

After they answer, generate the PRD following the structure in `skills/prd/SKILL.md` and save it to `tasks/prd.md`.

Say: "PRD created! Let me read it back to you..." and summarize the key user stories.

---

## PHASE 4: Technical Architecture & Security

Say:
> "Now let's figure out the technical approach. Based on what we're building, here's what I'm thinking..."

Propose a tech stack and architecture. Consider:
- What frameworks/languages fit the project
- Database needs
- API structure
- Third-party services needed

Ask:
> "Does this technical approach work for you, or do you have preferences?"

After alignment, save architecture notes to `tasks/architecture.md`.

**Security Threat Modeling:**
Read `skills/security/pytm/SKILL.md` and consider basic threat modeling:
- What data is sensitive? (user data, credentials, etc.)
- What are the main attack surfaces? (APIs, user input, auth)
- What security measures are needed? (input validation, encryption, auth)

Add security notes to `tasks/architecture.md` under a "Security Considerations" section.

---

## PHASE 5: Edge Case Analysis

Say:
> "Before we finalize, let me think through what could go wrong..."

Read `skills/edge-cases/SKILL.md` and analyze the PRD for:
- Input edge cases (empty values, invalid data)
- State edge cases (race conditions, concurrent users)
- Error handling (network failures, validation)
- Security considerations

For each significant edge case found, either:
- Add acceptance criteria to existing stories
- Create new user stories if needed

Update `tasks/prd.md` with the changes.

Say:
> "I found [X] edge cases and updated the PRD. The main additions are: [list key additions]"

---

## PHASE 6: Story Quality Check

Say:
> "Let me make sure all the user stories are properly sized for autonomous building..."

Read `skills/story-quality/SKILL.md` and check each story:

1. **Length**: Must be 1-2 lines max
2. **Scope**: Must be completable in one coding session
3. **Order**: Dependencies must come first (database → backend → frontend)
4. **Criteria**: Must be specific and verifiable, include "Typecheck passes"

Fix any issues by:
- Splitting large stories
- Reordering for dependencies
- Making vague criteria specific

Update `tasks/prd.md` with fixes.

Say:
> "Stories are ready. We have [X] stories total, properly ordered for building."

---

## PHASE 7: Convert to prd.json

**IMPORTANT: Check for existing prd.json first!**

Before creating a new prd.json, check if one already exists:

```bash
if [ -f prd.json ]; then
  # Check what project it's from
  cat prd.json | jq -r '.project, .branchName'
fi
```

**If prd.json exists from a DIFFERENT project:**
1. Archive it first:
```bash
mkdir -p archive
TIMESTAMP=$(date +%Y-%m-%d-%H%M)
OLD_PROJECT=$(cat prd.json | jq -r '.project' | tr ' ' '-' | tr '[:upper:]' '[:lower:]')
mv prd.json "archive/prd-${OLD_PROJECT}-${TIMESTAMP}.json"
[ -f progress.txt ] && mv progress.txt "archive/progress-${OLD_PROJECT}-${TIMESTAMP}.txt"
```
2. Tell the user: "I found an old prd.json from [previous project]. I've archived it to the archive/ folder."

**If prd.json exists from the SAME project:**
- Ask the user: "There's an existing prd.json for this project. Should I replace it with the new one, or keep the existing one?"

**Then create the new prd.json:**

Say:
> "Converting to the format needed for autonomous building..."

Read `skills/ralph/SKILL.md` for the JSON format.

Convert `tasks/prd.md` to `prd.json` with:
- Project name
- Branch name: `ralph/[project-name-kebab-case]`
- All user stories with priority based on order
- **All stories set to `passes: false`** (this is critical - never copy old pass status!)

Save to `prd.json` in the project root.

**Verify the new prd.json:**
```bash
cat prd.json | jq '.project, .userStories | length, (.userStories | map(select(.passes == false)) | length)'
```
This should show: project name, total stories, and stories with passes:false (should match total).

Say:
> "prd.json created with [X] stories ready to build. All stories set to passes: false."

---

## PHASE 8: Push and Prepare for Build

Push everything to GitHub so it's accessible from anywhere:

```bash
git add -A
git commit -m "Project setup complete - ready to build"
git push
```

Say:
> "Everything is saved to GitHub. You can now access this project from any device."

---

## PHASE 9: Start Build or Continue Later

Ask the user:
> "Ready to start the autonomous build? It will run through all [X] stories automatically.
>
> **Option A**: Start now - I'll kick off the build and you can close your laptop, check from phone
> **Option B**: Start later - Just tell me when you're ready
>
> Which would you like?"

**If they choose A (Start now):**

1. Start the build in the background:
```bash
nohup ./ralph.sh > build.log 2>&1 &
echo $! > .build-pid
```

2. Tell them:
> "Build started! Here's what happens now:
>
> - The build runs automatically in the background
> - You'll get a phone notification when it's done (or if it needs attention)
> - You can close your laptop - it keeps running
> - To check progress from phone: go to github.com/codespaces, open this project
> - Or check commits at github.com/[username]/[project-name]
>
> I'll push progress to GitHub as it goes. Go grab a coffee!"

3. Create a codespace for phone access:
```bash
gh codespace create --repo [username]/[project-name] --machine basicLinux32gb
```

4. Tell them the codespace URL they can open on their phone.

**If they choose B (Start later):**

Tell them:
> "No problem! When you're ready, just:
> 1. Open this project folder
> 2. Run: `./ralph.sh`
>
> Or from your phone:
> 1. Go to github.com/codespaces
> 2. Create a codespace on this repo
> 3. Run `./ralph.sh` in the terminal
>
> The project is all set up and waiting."

---

## Important Notes

- Always use `gh` CLI for GitHub operations
- Push to GitHub frequently so phone access stays current
- If the user seems confused, explain what you're doing and why
- Keep the conversation friendly and move at the user's pace

---

## Automatic Skill Application (During Build)

When Ralph is building stories, Claude should automatically apply relevant skills:

### For React/Next.js Projects
- Reference `skills/react-best-practices/SKILL.md` when writing components
- Apply the 45 performance rules automatically (async patterns, bundle optimization, etc.)
- Use proper data fetching patterns from the guidelines

### For All Web Projects
- Reference `skills/web-design-guidelines/SKILL.md` for UI components
- Fetch latest guidelines from the source URL in that skill
- Apply accessibility and UX best practices automatically

### Security Scanning (Every Story)
Before marking any story as complete:

1. **Run Semgrep for vulnerabilities:**
```bash
semgrep --config=auto --severity=ERROR --severity=WARNING .
```
If issues found, fix them before completing the story.

2. **Check for hardcoded secrets:**
```bash
gitleaks protect --staged --redact
```
If secrets detected, remove them and use environment variables instead.

### After Deployment (Test & Fix Loop)
When the app is deployed, use the build-test-fix loop:

1. **Test:** Read `skills/test-and-break/SKILL.md` and test the deployed app
2. **Report:** Generate bug report to `tasks/bug-report-*.md`
3. **Convert:** Read `skills/bugs-to-stories/SKILL.md` to convert bugs to stories
4. **Fix:** Run Ralph again to fix the bugs
5. **Repeat:** Until no bugs found

Or run the automated loop:
```bash
./build-test-fix-loop.sh [deployment_url] [max_cycles]
```

---

## Skill Reference

All skills are in the `skills/` folder. Claude reads and applies them automatically based on context:

| Skill | Auto-Triggers On |
|-------|------------------|
| `security/*` | Every code change |
| `react-best-practices` | React/Next.js projects |
| `web-design-guidelines` | Any web UI |
| `edge-cases` | PRD refinement |
| `story-quality` | Before prd.json conversion |
| `test-and-break` | After deployment |
| `bugs-to-stories` | After testing |

See `skills/SKILLS-INDEX.md` for the complete skill selection matrix.
