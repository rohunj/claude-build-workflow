# All Prompts - Copy & Paste

Keep this file open when building a new project. Just copy each prompt when you're ready for that step.

---

## PROMPT 1: Discovery Interview

```
I want to build: [DESCRIBE YOUR IDEA HERE IN 1-2 SENTENCES]

Please interview me about this project using the BMAD method. Act as a product manager and ask me questions ONE AT A TIME about:
- What problem I'm solving
- Who the users are
- What the core features should be
- What's in scope vs out of scope
- How we'll know it's successful

Challenge my assumptions and help me think through things I might be missing. After we've covered everything, summarize what we discussed.
```

---

## PROMPT 2: Create PRD

```
Now read skills/prd/SKILL.md and create a PRD based on our discussion. Save it to tasks/prd.md

Remember to ask me clarifying questions with lettered options (like 1A, 2B, 3C) so I can answer quickly.
```

---

## PROMPT 3: Technical Architecture

```
Now let's design the technical architecture. Based on the PRD, help me decide on:
- Tech stack (languages, frameworks, databases)
- System structure and components
- Database schema
- APIs needed

Save your recommendations to tasks/architecture.md
```

---

## PROMPT 4: Edge Case Analysis

```
Read skills/edge-cases/SKILL.md and analyze tasks/prd.md for edge cases, failure modes, and scenarios we might have missed.

Update the PRD with any new acceptance criteria or user stories needed to handle these cases.
```

---

## PROMPT 5: Story Quality Review

```
Read skills/story-quality/SKILL.md and review all user stories in tasks/prd.md.

Make sure each story is:
- 1-2 lines max
- Small enough for one coding session
- Ordered correctly by dependencies (database first, then backend, then frontend)
- Has specific, verifiable acceptance criteria
- Includes "Typecheck passes"
- UI stories include "Verify in browser"

Fix any issues you find and update the PRD.
```

---

## PROMPT 6: Convert to prd.json

```
Read skills/ralph/SKILL.md and convert tasks/prd.md into prd.json format.

Make sure:
- Each story is small enough to complete in one iteration
- Stories are ordered by dependencies
- All stories have passes: false
- branchName is set to ralph/[project-name]

Save it to ./prd.json in the project root.
```

---

## After All Prompts: Exit & Run

1. Press `Ctrl+C` to exit Claude
2. Run: `./ralph.sh`
3. Wait for it to build everything (up to 100 iterations)
4. Check `progress.txt` to see what's happening
