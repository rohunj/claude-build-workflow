# Skills Index

This file helps Claude automatically select and use the right skills based on the project type, tech stack, and current task. **Do not invoke skills manually - Claude will reference this index and apply relevant skills automatically.**

---

## Skill Selection Matrix

| Project Type | Auto-Apply Skills |
|-------------|-------------------|
| Web App (React/Next.js) | `react-best-practices`, `web-design-guidelines`, `security/*` |
| Web App (Other) | `web-design-guidelines`, `security/*` |
| API/Backend | `security/*` |
| Mobile App | `security/*` |
| Any with UI | `web-design-guidelines`, `frontend-design` |

---

## When to Use Each Skill

### Always Apply (Every Build)

| Skill | When | Purpose |
|-------|------|---------|
| `security/sast-semgrep` | Before marking any story complete | Scan code for vulnerabilities (SQLi, XSS, etc.) |
| `security/secrets-gitleaks` | Before any git commit | Detect hardcoded secrets/API keys |
| `edge-cases` | During PRD refinement | Find input/state edge cases |
| `story-quality` | Before converting to prd.json | Ensure stories are properly scoped |

### Apply Based on Tech Stack

| Skill | Trigger Condition | Purpose |
|-------|-------------------|---------|
| `react-best-practices` | Project uses React or Next.js | Performance optimization patterns |
| `web-design-guidelines` | Project has web UI | UI/UX best practices |
| `security/sca-trivy` | Project has dependencies (package.json, requirements.txt) | Scan dependencies for CVEs |
| `security/pytm` | New project architecture | Threat modeling |

### Apply Based on Task

| Skill | Trigger Task | Purpose |
|-------|--------------|---------|
| `test-and-break` | After deployment | Find bugs through systematic testing |
| `bugs-to-stories` | After test-and-break | Convert bug reports to fixable stories |
| `prd` | Starting new project | Create Product Requirements Document |
| `ralph` | Building stories | Autonomous iteration loop |

---

## Automatic Skill Application Rules

When building, Claude should automatically:

1. **At project start:**
   - Read `security/pytm` and do basic threat modeling
   - Consider attack surfaces based on project type

2. **When writing code:**
   - If React/Next.js: Apply rules from `react-best-practices`
   - If web UI: Apply rules from `web-design-guidelines`

3. **Before marking a story complete:**
   - Run `semgrep --config=auto` to scan for security issues
   - Check for hardcoded secrets with gitleaks

4. **Before any git commit:**
   - Run `gitleaks protect --staged` to prevent secret leakage

5. **After deployment:**
   - Use `test-and-break` to systematically test the app
   - Use `bugs-to-stories` to convert findings to prd.json

---

## Skill Descriptions

### Building & Planning
- **prd** - Create Product Requirements Documents with user stories
- **ralph** - Autonomous build loop (iterate through stories)
- **edge-cases** - Analyze PRD for edge cases and add to acceptance criteria
- **story-quality** - Ensure stories are 1-2 lines, properly scoped, sequenced

### Security (CRITICAL)
- **security/sast-semgrep** - Static analysis for vulnerabilities (OWASP Top 10)
- **security/secrets-gitleaks** - Detect hardcoded secrets before commit
- **security/sca-trivy** - Scan dependencies for known vulnerabilities
- **security/pytm** - Threat modeling for architecture decisions

### UI/UX
- **react-best-practices** - 45 performance rules for React/Next.js
- **web-design-guidelines** - Web Interface Guidelines compliance
- **frontend-design** - General frontend design principles

### Testing
- **test-and-break** - Systematically test deployed apps, find bugs
- **bugs-to-stories** - Convert bug reports to prd.json stories
- **agent-browser** - Browser automation for testing

### Utilities
- **pdf** - Read and extract content from PDFs
- **docx** - Read and extract content from Word documents
- **compound-engineering** - Multi-step engineering workflows

---

## How This Works

Claude reads this index automatically when:
1. Starting a new project (to know which skills apply)
2. Writing/reviewing code (to apply relevant patterns)
3. Completing stories (to run security checks)
4. Testing deployments (to find and fix bugs)

**No manual skill invocation needed.** Claude will reference the appropriate skill files based on context and apply them transparently.
