---
description: Create pull requests for Performance FE and UI Library repos (amelio-performance-fe, amelio-ui-library) on Azure DevOps
---

# Create Performance Frontend PR Workflow

**Scope**: `amelio-performance-fe` and `amelio-ui-library` (both React/TypeScript/Vitest)
**Not covered**: `amelio-performance-backend` (.NET) — see `/create-perfo-be-pr` workflow

## Prerequisites
- Changes are already implemented and tests pass
- Azure DevOps MCP tools are available
- Repo ID and project name are known

## Conventions

### Branch naming
```
<type>/#<task-number>-<short-description>
```

### Commit message
```
<type>(#<task-number>): <Short imperative description>

- Detail point 1
- Detail point 2
```

### Types
- **feat** : New feature
- **fix** : Bug fix
- **refactor** : Code improvement without feature/bug changes
- **chore** : Maintenance tasks, dependencies, tooling
- **docs** : Documentation changes
- **test** : Adding or updating tests

### PR Templates (per repo — MANDATORY)
Every repo has a PR template at `<repo-root>/.azuredevops/pull_request_template.md`.
This is the **single source of truth** — always read it fresh from the current repo before creating a PR.

Known repos and their templates:
- **amelio-performance-fe**: `<repo-root>/.azuredevops/pull_request_template.md`
- **amelio-ui-library**: `<repo-root>/.azuredevops/pull_request_template.md`

Never use a cached, hardcoded, or memorized template. Always `read_file` the template from disk.

---

## Workflow Steps

### Step 0: Detect environment (auto — runs silently at every invocation)

Do NOT ask the user for anything here. Detect everything automatically.

1. **Detect repo root**: Run `git rev-parse --show-toplevel` from the current working directory
2. **Detect repo name**: Extract from the directory name (e.g., `amelio-performance-fe`)
3. **Validate scope**: Confirm repo is `amelio-performance-fe` or `amelio-ui-library`. If the repo is `amelio-performance-backend`, inform the user to use `/create-perfo-be-pr` instead and stop.
4. **Map to ADO project**:
   - `amelio-performance-fe` → `Amelio-Performance Management`
   - `amelio-ui-library` → `Amelio-Development Packages`
5. **Read PR template**: `read_file` at `<repo-root>/.azuredevops/pull_request_template.md`
6. **Locate test-snapshot tooling**: Use `find_by_name` to search for `test-snapshot.sh` starting from the user's home directory (search common locations: workspace roots, Windsurf config, etc.)
   - If found → store the parent directory as `TEST_SNAPSHOT_DIR` for this session
   - If NOT found → proceed to **Step 0b**

### Step 0b: First-time test-snapshot setup (only if not found in Step 0)

The test-snapshot tool validates that code changes don't cause test regressions before committing.
It consists of two files:
- `test-snapshot.sh` — Runs `vitest` with coverage, compares against a saved baseline, blocks if coverage drops
- `compare-coverage.mjs` — Node.js script that compares two coverage JSON files and reports regressions

**The directory MUST be outside any git repository** (so it doesn't get committed or interfere with repos).

If the tool is not found:
1. Explain briefly in the chat what it does:
   > "The test-snapshot tool runs your tests and compares coverage against a baseline. It must live outside your repos. I'll help you set it up."
2. Propose locations using `ask_user_question`:
   - **Next to repos**: A `test-snapshots` folder alongside the repo directories (e.g., sibling of `amelio-performance-fe` inside `REPOs/`)
   - **Windsurf config**: `~/.codeium/windsurf/test-snapshots/`
   - *(User can also type a custom path)*
3. After the user chooses, create the directory and generate both scripts inside it **using the exact contents from Appendix A and Appendix B** at the bottom of this workflow. Make the shell script executable (`chmod +x`).
4. Store the path as `TEST_SNAPSHOT_DIR` for the session
5. Continue with the workflow — do not restart

### 1. Identify work items and files
- Determine which ADO work item(s) are linked to the changes
- List all modified files per bug/feature
- If multiple bugs: **one branch per bug, one PR per bug** (never group them — if one gets review comments, it blocks the others)

### 2. For each bug/feature, repeat steps 3-9

### 3. Create branch locally
```bash
git checkout main
git checkout -b <type>/#<task-number>-<short-description>
```
- Stash unrelated files: `git stash push -m "other-changes" -- <file1> <file2> ...`
- Verify only relevant files remain: `git status`

### 3.5. Run tests — MANDATORY (never skip)
**This step is NON-NEGOTIABLE. Always run tests before committing, every single time.**

Run the test snapshot script using paths detected in Step 0:
```bash
<TEST_SNAPSHOT_DIR>/test-snapshot.sh <repo-name> <repo-root>
```

- `<TEST_SNAPSHOT_DIR>` = directory found or created in Step 0/0b
- `<repo-name>` = repo name detected in Step 0 (e.g., `amelio-performance-fe`)
- `<repo-root>` = repo root detected in Step 0 (from `git rev-parse --show-toplevel`)

#### Exit code handling:

**Exit 0 — PASS**: All tests pass, no coverage regressions. Baseline updated automatically. Continue.

**Exit 1 — HARD FAIL** (tests failed OR total coverage dropped below 80%):
- **STOP immediately.** This CANNOT be bypassed under any circumstances.
- Fix the failing tests or restore total coverage above 80% before proceeding.

**Exit 4 — FIRM FAIL** (a file/metric dropped more than 5%, but all totals still ≥ 80%):
1. Report the regression details to the user with strong emphasis on fixing
2. **First attempt**: Cascade MUST try to fix the regression by adding or improving tests. Do NOT immediately offer the bypass option.
3. Rerun the test script after the fix attempt
4. **Only if the fix attempt fails or is truly not feasible**, use `ask_user_question`:
   - **"Let me try another approach to fix"** — Try a different fix strategy
   - **"I understand, but I need to bypass with justification"** — Accept with mandatory written justification
   - **"Stop — I'll handle this manually"** — Let the user take over
5. If the user bypasses:
   - Rerun the script with the `--accept-regression` flag
   - The user MUST provide a **written justification** explaining why the regression is acceptable
   - Store the regression details AND justification in memory for Step 7
   - The regression + justification MUST appear in the PR description (see Step 7)

**Exit 3 — SOFT FAIL** (minor regression ≤ 5%, all totals ≥ 80%):
1. Report the regression details to the user
2. **First attempt**: Cascade MUST try to fix the regression by adding or improving tests. Do NOT immediately offer the bypass option.
3. Rerun the test script after the fix attempt
4. **Only if the fix attempt fails or is truly not feasible**, use `ask_user_question`:
   - **"Let me try another approach to fix"** — Try a different fix strategy
   - **"Accept and continue"** — Accept the regression, note it in the PR
5. If the user accepts:
   - Rerun the script with the `--accept-regression` flag
   - Store the regression details in memory for Step 7
   - The regression MUST be documented in the PR description (see Step 7)

#### General rules:
- All tests MUST pass (0 failures)
- Total coverage MUST stay ≥ 80% (hard floor, no exceptions)
- No single file/metric can drop more than 5% without going through FIRM FAIL flow
- **Always try to fix regressions first** — the bypass is a last resort, not a shortcut
- The script auto-updates the baseline if no regressions
- Report test results summary in the chat (test count, pass/fail, coverage %)

### 4. Commit
- Use `--no-verify` to bypass pre-commit hooks that may auto-stage unrelated files
```bash
git add <relevant-files>
git commit --no-verify -m "<type>(#<task>): <description>" -m "- detail 1" -m "- detail 2"
```
- Verify: `git show --stat HEAD` must show ONLY the intended files

### 5. Push branch
- Push manually if authentication fails from CLI
- **Before interrupting the user**: always verify if the branch already exists on remote via ADO MCP `repo_get_branch_by_name`
- If branch exists on remote, continue immediately — do NOT ask the user to confirm

### 6. For Bug work items — Update the bug fields
Before creating the PR, update the bug work item with:
- **Cause of Bug**: Root cause analysis (technical explanation)
- **Resolution**: What was changed to fix it

To identify the **origin developer** (who introduced the bug):
- Use `git blame` on the affected file(s) around the problematic code
- Look for the last person before our changes who modified those lines
- Record their name in the work item if the field exists

### 7. Create PR as Draft
- Use the ADO MCP tool `mcp1_repo_create_pull_request` (NEVER use `az` CLI)
- Use the PR template already loaded in Step 0 from `<repo-root>/.azuredevops/pull_request_template.md`
  - This is the **SINGLE source of truth** — never use a cached or hardcoded template
  - Every repo has its own template; always use the one from the current repo
  - If the PR description does not follow the template structure, the PR is invalid
- Fill in ALL template sections — never delete fields, only add text and check relevant boxes
- Set `isDraft: true`
- Link the work item via `workItems` parameter
- Template sections to fill:
  - **What's This All About?**: Brief description of the fix/feature
  - **Related ticket**: #<task-number>
  - **Type of Magic**: Check relevant boxes
  - **How Did You Test This?**: Check relevant testing methods
  - **Screenshots**: Add if visual changes, otherwise comment `<!-- N/A -->`
  - **Pre-Flight Checklist**: Check all that apply
  - **Anything Else?**: Follow the template instructions ("Share any other thoughts, challenges, or victories here!"). Rules:
    - **Never name or blame anyone** (no "Origin developer: X" — that info goes in the ADO bug fields only)
    - **For bugs**: Optionally mention the root cause if it adds value beyond what's in the description
    - **For normal tasks**: Leave empty or share learnings, challenges, or non-obvious decisions. ~90% of the time this stays empty
    - This section is for added value only — not a repeat of the description
    - **Never expose internal process details** (no AI tool names, audit reports, or internal workflow steps)
    - **If a SOFT coverage regression was accepted in Step 3.5** (exit 3): Add a short note:
      ```
      ⚠️ Accepted minor coverage regression (≤ 5%):
      - `<file>`: <metric> dropped from <was>% to <now>% (<diff>%)
      ```
    - **If a FIRM coverage regression was accepted in Step 3.5** (exit 4): Add a detailed note with the user's justification:
      ```
      ⛔ Accepted significant coverage regression (> 5%):
      - `<file>`: <metric> dropped from <was>% to <now>% (<diff>%)
      Justification: <user's written justification explaining why this is acceptable>
      ```
      The justification is **mandatory** for FIRM regressions. Without it, the PR is invalid.
      This ensures reviewers are fully aware of the trade-off. Keep it factual and concise.

### 8. Link work items
- The `workItems` parameter on PR creation handles this
- Verify the link was created via `repo_get_pull_request_by_id` with `includeWorkItemRefs: true`

### 9. Return to main and restore stash
```bash
git checkout main
git stash pop
```
- Then repeat from step 3 for the next bug/feature

### 10. Share PR links in chat
- **Always** share the PR link in the chat immediately after creation
- Format: `PR #<id> (Draft) — <title>` with the ADO URL

### 11. If no bug/work item exists for the changes
- Create a new Bug work item as a child of the parent feature
- Fill in: Title (one line), Description (brief), IterationPath, AssignedTo
- Link it as child of the parent work item
- Then proceed with the normal flow (branch, commit, push, PR)

## After all PRs are created as drafts

### 12. User validation
- Present summary of all draft PRs with links
- Ask the user to confirm if everything looks correct
- **Never propose to publish the PR** — the user will publish it themselves when ready
- Do NOT offer a "publish" option in `ask_user_question` choices

### 13. Final Validation Checklist (MANDATORY)

**Before presenting the result to the user, verify EVERY item on this list.**
For each item, Cascade must actively verify (not just assume). If any item fails, fix it before proceeding.

#### For EACH PR created:
- [ ] **Template used**: Verify the PR description on remote (via `repo_get_pull_request_by_id`) matches the structure of `<repo-root>/.azuredevops/pull_request_template.md`. All sections must be present.
- [ ] **Work item linked**: Verify via `repo_get_pull_request_by_id` with `includeWorkItemRefs: true` that the work item is linked
- [ ] **Draft status**: Confirm the PR is set as Draft (`isDraft: true`)
- [ ] **Branch convention**: Branch name matches `<type>/#<task-number>-<short-description>`
- [ ] **Commit convention**: Commit message matches `<type>(#<task>): <description>`
- [ ] **Tests passed**: Test-snapshot step completed with 0 failures. Coverage either has 0 regressions OR a soft regression was accepted by the user (documented in "Anything Else?" section)
- [ ] **Clean commit**: Only relevant files in the commit (verified via `git show --stat`)
- [ ] **PR link shared**: PR URL was displayed in the chat

#### For Bug work items (additional checks):
- [ ] **Cause of Bug** filled (`Custom.Causeofbug`) — verify via `wit_get_work_item`
- [ ] **Resolution** filled (`Microsoft.VSTS.Common.Resolution`) — verify via `wit_get_work_item`
- [ ] **Origin Developer** identified via `git blame` and recorded in `Custom.OriginDeveloper`

#### For ALL work items:
- [ ] **State NOT changed**: Work item state must remain untouched (verify current state matches pre-workflow state)
- [ ] **Description NOT modified**: Unless explicitly asked by the user

**Every item must pass. If any fails, fix it immediately. Only then present the summary to the user.**

---

## Bug Work Item Fields Reference (ADO)
These are the correct field paths for the Bug type in this project:
- **Cause of bug**: `Custom.Causeofbug`
- **Resolution**: `Microsoft.VSTS.Common.Resolution`
- **Origin Developer**: `Custom.OriginDeveloper` (accepts display name, resolves to ADO identity)
- **Found In Environments**: `Custom.FoundInEnvironments`
- **Assigned To**: `System.AssignedTo`

## Important Rules

- **Never change work item status** — the user will change it when closing the PR
- **Never interrupt to ask if something is already done** — verify first via MCP tools or git commands
- **Always share PR links in chat** — immediately after PR creation
- **One branch per bug, one PR per bug** — keeps reviews independent
- **Draft first, publish after validation** — always create as draft
- **Template integrity** — never remove template fields, only fill them in. Always use the repo's own `.azuredevops/pull_request_template.md`
- **Commits must be clean** — verify `git show --stat HEAD` after every commit
- **English only** for branch names, commit messages, PR descriptions, and ALL generated files
- **Keep commit messages concise** — title + short bullet points, no essays
- **Fill bug fields but don't change state** — Cause of bug, Resolution, Origin Developer only
- **Use git blame for Origin Developer** — find the last person before us who modified the problematic code
- **ALWAYS run tests before committing** — use the test-snapshot script, never skip this step
- **Coverage thresholds (3 levels)** — (1) Total < 80% = HARD FAIL (no bypass), (2) File drop > 5% but totals ≥ 80% = FIRM FAIL (bypass with justification, after fix attempt), (3) Drop ≤ 5% and totals ≥ 80% = SOFT FAIL (bypass after fix attempt). Always try to fix first — bypass is last resort
- **Never propose to publish the PR** — the user publishes it themselves; only ask if the draft looks correct
- **Never expose internal process details** in PR descriptions (no audit reports, AI tool references, or internal workflow steps)

---

## Appendix A: `test-snapshot.sh`

When Step 0b needs to create this file, use the **exact** content below. Save as `<TEST_SNAPSHOT_DIR>/test-snapshot.sh` and run `chmod +x` on it.

```bash
#!/bin/bash

# test-snapshot.sh — Run tests with coverage and compare against baseline snapshot
#
# Usage:
#   ./test-snapshot.sh <repo-name> <repo-path> [--accept-regression]
#
# Arguments (first two required):
#   repo-name:            Name of the repo (e.g., amelio-performance-fe)
#   repo-path:            Absolute path to the repo root
#   --accept-regression:  Optional flag to accept soft regressions and update baseline
#
# Exit codes:
#   0 = PASS (no regressions, or regression accepted with --accept-regression)
#   1 = HARD FAIL (tests failed, or total coverage dropped below 80%)
#   3 = SOFT FAIL (minor regression ≤ 5%, try to fix first — rerun with --accept-regression)
#   4 = FIRM FAIL (file dropped >5% but totals ≥ 80% — strongly insist on fixing, bypass with justification)
#
# This script:
#   1. Runs vitest with coverage in the specified repo
#   2. Parses the JSON coverage report (coverage-summary.json)
#   3. Compares against the saved baseline snapshot
#   4. Reports regressions (FAIL) or improvements
#   5. Updates the baseline only if no regressions found (or if --accept-regression)
#   6. Saves a timestamped copy in history/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_NAME="${1:-}"
REPO_PATH="${2:-}"
ACCEPT_REGRESSION="${3:-}"

if [ -z "${REPO_NAME}" ] || [ -z "${REPO_PATH}" ]; then
    echo "❌ Usage: $0 <repo-name> <repo-path> [--accept-regression]"
    echo "   Both repo-name and repo-path are required."
    exit 1
fi

SNAPSHOT_DIR="${SCRIPT_DIR}/${REPO_NAME}"
BASELINE_FILE="${SNAPSHOT_DIR}/baseline.json"
CURRENT_FILE="${SNAPSHOT_DIR}/current.json"
MERGED_FILE="${SNAPSHOT_DIR}/merged.json"
HISTORY_DIR="${SNAPSHOT_DIR}/history"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "${SNAPSHOT_DIR}" "${HISTORY_DIR}"

echo ""
echo "══════════════════════════════════════════════"
echo "  🧪 TEST SNAPSHOT — ${REPO_NAME}"
echo "  $(date '+%Y-%m-%d %H:%M:%S')"
echo "══════════════════════════════════════════════"
echo ""

# Step 1: Run tests with coverage
echo "📦 Running tests in ${REPO_PATH}..."
echo ""

cd "${REPO_PATH}"

# Run the tests — capture output but also show it live
npx vitest run --coverage --coverage.reporter=json-summary 2>&1 | tee "${SNAPSHOT_DIR}/last-run-output.txt"
TEST_EXIT_CODE=${PIPESTATUS[0]}

if [ ${TEST_EXIT_CODE} -ne 0 ]; then
    echo ""
    echo "══════════════════════════════════════════════"
    echo "  ❌ TESTS FAILED (exit code ${TEST_EXIT_CODE})"
    echo "  See: ${SNAPSHOT_DIR}/last-run-output.txt"
    echo "══════════════════════════════════════════════"
    exit 1
fi

# Step 2: Locate coverage JSON
COVERAGE_JSON="${REPO_PATH}/coverage/coverage-summary.json"
if [ ! -f "${COVERAGE_JSON}" ]; then
    echo ""
    echo "❌ Coverage JSON not found at ${COVERAGE_JSON}"
    echo "   Make sure vitest is configured with reporter: ['json'] in coverage settings."
    exit 1
fi

# Step 3: Copy current coverage
cp "${COVERAGE_JSON}" "${CURRENT_FILE}"

# Step 4: Compare with baseline
echo ""
node "${SCRIPT_DIR}/compare-coverage.mjs" "${CURRENT_FILE}" "${BASELINE_FILE}" "${MERGED_FILE}"
COMPARE_EXIT_CODE=$?

save_baseline() {
    local SOURCE_FILE="$1"
    cp "${SOURCE_FILE}" "${BASELINE_FILE}"
    cp "${SOURCE_FILE}" "${HISTORY_DIR}/snapshot_${TIMESTAMP}.json"

    # Keep only last 20 history snapshots
    ls -t "${HISTORY_DIR}"/snapshot_*.json 2>/dev/null | tail -n +21 | xargs rm -f 2>/dev/null || true

    echo "📁 Baseline saved: ${BASELINE_FILE}"
    echo "📁 History saved:  ${HISTORY_DIR}/snapshot_${TIMESTAMP}.json"
}

if [ ${COMPARE_EXIT_CODE} -eq 0 ]; then
    # No regressions — update baseline with merged (best-of-both) values
    echo ""
    save_baseline "${MERGED_FILE}"
elif [ ${COMPARE_EXIT_CODE} -eq 1 ]; then
    # HARD FAIL — total coverage below 80%, cannot bypass
    echo ""
    echo "🛑 Baseline NOT updated. Total coverage dropped below 80%."
    echo "   This CANNOT be bypassed. Fix before proceeding."
    exit 1
elif [ ${COMPARE_EXIT_CODE} -eq 4 ]; then
    # FIRM FAIL — file dropped >5% but totals still >= 80%
    if [ "${ACCEPT_REGRESSION}" = "--accept-regression" ]; then
        echo ""
        echo "⛔ FIRM regression accepted by user. Updating baseline with current values..."
        echo "   A written justification is REQUIRED in the PR description."
        save_baseline "${CURRENT_FILE}"
    else
        echo ""
        echo "⛔ Baseline NOT updated. File regression exceeds 5% tolerance."
        echo "   STRONGLY RECOMMENDED: Fix regressions by adding tests."
        echo "   To bypass (justification required), rerun with: $0 ${REPO_NAME} ${REPO_PATH} --accept-regression"
        exit 4
    fi
elif [ ${COMPARE_EXIT_CODE} -eq 3 ]; then
    # SOFT FAIL — minor regression ≤ 5%, totals still >= 80%
    if [ "${ACCEPT_REGRESSION}" = "--accept-regression" ]; then
        echo ""
        echo "⚠️  Regression accepted by user. Updating baseline with current values..."
        save_baseline "${CURRENT_FILE}"
    else
        echo ""
        echo "⚠️  Baseline NOT updated due to minor regressions."
        echo "    Try to fix by adding tests first."
        echo "    To bypass, rerun with: $0 ${REPO_NAME} ${REPO_PATH} --accept-regression"
        exit 3
    fi
fi

echo ""
echo "Done."
```

---

## Appendix B: `compare-coverage.mjs`

When Step 0b needs to create this file, use the **exact** content below. Save as `<TEST_SNAPSHOT_DIR>/compare-coverage.mjs`.

```javascript
#!/usr/bin/env node

/**
 * compare-coverage.mjs
 *
 * Compares a current coverage-summary.json against a baseline.
 *
 * Rules:
 *   - REGRESSION: A file existed in baseline AND in current, but a metric (lines/statements/functions/branches) pct dropped
 *   - MISSING FILE: File was in baseline but not in current → keep old data in merged (no fail)
 *   - NEW FILE: File in current but not in baseline → add to merged (no fail)
 *   - IMPROVEMENT: File metric went up → take new (better) value
 *   - If no regressions: write merged as new baseline, exit 0
 *   - HARD FAIL (exit 1): Any total metric drops below HARD_FLOOR (80%) — absolute block, no bypass
 *   - FIRM FAIL (exit 4): Any file/metric drops by more than MAX_DROP (5%) but totals still ≥ 80%
 *     → Strongly insist on fixing first. Bypass possible only with written justification.
 *   - SOFT FAIL (exit 3): Regressions exist but all drops ≤ 5% and totals ≥ 80%
 *     → Attempt to fix first. Bypass possible if not feasible.
 *
 * Exit codes:
 *   0 = PASS (no regressions)
 *   1 = HARD FAIL (total below 80% — must fix, no bypass)
 *   2 = Usage error
 *   3 = SOFT FAIL (minor regression ≤ 5% — try to fix first, bypass if not feasible)
 *   4 = FIRM FAIL (file dropped >5% but totals still ≥ 80% — strongly insist on fixing, bypass with justification)
 *
 * Usage: node compare-coverage.mjs <current.json> <baseline.json> <merged-output.json>
 */

import { readFileSync, writeFileSync, existsSync } from 'fs';

const METRICS = ['lines', 'statements', 'functions', 'branches'];
const HARD_FLOOR = 80;
const MAX_DROP = 5;
const SEPARATOR = '══════════════════════════════════════════════';

const [currentPath, baselinePath, mergedPath] = process.argv.slice(2);

if (!currentPath || !baselinePath || !mergedPath) {
    console.error('Usage: node compare-coverage.mjs <current.json> <baseline.json> <merged-output.json>');
    process.exit(2);
}

const current = JSON.parse(readFileSync(currentPath, 'utf-8'));

if (!existsSync(baselinePath)) {
    console.log('📸 No baseline found. Creating initial baseline...');
    writeFileSync(mergedPath, JSON.stringify(current, null, 2));
    process.exit(0);
}

const baseline = JSON.parse(readFileSync(baselinePath, 'utf-8'));

const regressions = [];
const improvements = [];
const newFiles = [];
const missingFiles = [];
const merged = {};

// Check all baseline files
for (const filePath of Object.keys(baseline)) {
    if (filePath in current) {
        // File exists in both — compare metrics
        merged[filePath] = { ...current[filePath] };

        for (const metric of METRICS) {
            const baselinePct = baseline[filePath]?.[metric]?.pct ?? 0;
            const currentPct = current[filePath]?.[metric]?.pct ?? 0;

            if (currentPct < baselinePct) {
                regressions.push({
                    file: filePath,
                    metric,
                    was: baselinePct,
                    now: currentPct,
                    diff: (currentPct - baselinePct).toFixed(2),
                });
                // Keep the better (baseline) value in merged for this metric
                merged[filePath][metric] = { ...baseline[filePath][metric] };
            } else if (currentPct > baselinePct) {
                improvements.push({
                    file: filePath,
                    metric,
                    was: baselinePct,
                    now: currentPct,
                    diff: `+${(currentPct - baselinePct).toFixed(2)}`,
                });
            }
        }
    } else {
        // File missing in current run — keep old data
        missingFiles.push(filePath);
        merged[filePath] = { ...baseline[filePath] };
    }
}

// Check for new files in current that aren't in baseline
for (const filePath of Object.keys(current)) {
    if (!(filePath in baseline)) {
        newFiles.push(filePath);
        merged[filePath] = { ...current[filePath] };
    }
}

// Output report
console.log(`\n${SEPARATOR}`);
console.log('  COVERAGE COMPARISON REPORT');
console.log(`${SEPARATOR}\n`);

// Total summary
if (current.total && baseline.total) {
    console.log('📊 Global totals:');
    for (const metric of METRICS) {
        const bPct = baseline.total?.[metric]?.pct ?? 0;
        const cPct = current.total?.[metric]?.pct ?? 0;
        const diff = cPct - bPct;
        const arrow = diff > 0 ? '↑' : diff < 0 ? '↓' : '=';
        const color = diff > 0 ? '🟢' : diff < 0 ? '🔴' : '⚪';
        console.log(`   ${color} ${metric.padEnd(12)} ${bPct}% → ${cPct}% (${arrow} ${diff.toFixed(2)}%)`);
    }
    console.log('');
}

if (regressions.length > 0) {
    console.log(`🔴 REGRESSIONS FOUND: ${regressions.length}`);
    for (const reg of regressions) {
        console.log(`   ❌ ${reg.file}`);
        console.log(`      ${reg.metric}: ${reg.was}% → ${reg.now}% (${reg.diff}%)`);
    }
    console.log('');
}

if (improvements.length > 0) {
    console.log(`🟢 Improvements: ${improvements.length}`);
    for (const imp of improvements) {
        console.log(`   ✅ ${imp.file}`);
        console.log(`      ${imp.metric}: ${imp.was}% → ${imp.now}% (${imp.diff}%)`);
    }
    console.log('');
}

if (newFiles.length > 0) {
    console.log(`🆕 New files: ${newFiles.length}`);
    for (const file of newFiles) {
        console.log(`   📄 ${file}`);
    }
    console.log('');
}

if (missingFiles.length > 0) {
    console.log(`⚠️  Files in baseline but not in current run: ${missingFiles.length}`);
    for (const file of missingFiles) {
        console.log(`   📁 ${file} (kept from baseline)`);
    }
    console.log('');
}

// Write merged
writeFileSync(mergedPath, JSON.stringify(merged, null, 2));

if (regressions.length > 0) {
    // Check HARD FAIL: any total metric below HARD_FLOOR
    const hardFailReasons = [];
    if (current.total) {
        for (const metric of METRICS) {
            const currentPct = current.total?.[metric]?.pct ?? 0;
            if (currentPct < HARD_FLOOR) {
                hardFailReasons.push(`Total ${metric}: ${currentPct}% (minimum: ${HARD_FLOOR}%)`);
            }
        }
    }

    if (hardFailReasons.length > 0) {
        console.log(SEPARATOR);
        console.log(`  ❌ HARD FAIL — Total coverage below ${HARD_FLOOR}%`);
        for (const reason of hardFailReasons) {
            console.log(`     ${reason}`);
        }
        console.log('  This CANNOT be bypassed. Fix before proceeding.');
        console.log(SEPARATOR);
        process.exit(1);
    }

    // Check FIRM FAIL: any file/metric dropped more than MAX_DROP
    const firmFailReasons = [];
    for (const reg of regressions) {
        const drop = Math.abs(parseFloat(reg.diff));
        if (drop > MAX_DROP) {
            firmFailReasons.push(`${reg.file} — ${reg.metric}: ${reg.was}% → ${reg.now}% (dropped ${drop}%, max tolerance: ${MAX_DROP}%)`);
        }
    }

    if (firmFailReasons.length > 0) {
        console.log(SEPARATOR);
        console.log(`  ⛔ FIRM FAIL — File regression exceeds ${MAX_DROP}% tolerance`);
        for (const reason of firmFailReasons) {
            console.log(`     ${reason}`);
        }
        console.log('');
        console.log('  ⚠️  STRONGLY RECOMMENDED: Fix these regressions before proceeding.');
        console.log('  Add missing tests or restore coverage. Only bypass if truly not feasible.');
        console.log('  If bypassed, a written justification is REQUIRED in the PR description.');
        console.log(SEPARATOR);
        process.exit(4);
    }

    // SOFT FAIL: all drops within tolerance
    console.log(SEPARATOR);
    console.log('  ⚠️  SOFT FAIL — Minor regressions detected');
    console.log(`  All totals ≥ ${HARD_FLOOR}% and all drops ≤ ${MAX_DROP}%.`);
    console.log('  Try to fix by adding tests first. Bypass only if not feasible.');
    console.log(SEPARATOR);
    process.exit(3);
} else {
    console.log(SEPARATOR);
    console.log('  ✅ PASS — No regressions. Baseline updated.');
    console.log(SEPARATOR);
    process.exit(0);
}
```
