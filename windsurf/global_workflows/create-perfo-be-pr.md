---
description: Create pull requests for Performance Backend repo (amelio-performance-backend) on Azure DevOps
---

# Create Performance Backend PR Workflow

**Scope**: `amelio-performance-backend` (.NET 8 / C# / MongoDB)
**Not covered**: `amelio-performance-fe` or `amelio-ui-library` — see `/create-perfo-fe-pr` workflow

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

### PR Template (MANDATORY)
The repo has a PR template at `<repo-root>/.azuredevops/pull_request_template.md`.
This is the **single source of truth** — always read it fresh from the repo before creating a PR.

Never use a cached, hardcoded, or memorized template. Always `read_file` the template from disk.

---

## Workflow Steps

### Step 0: Detect environment (auto — runs silently at every invocation)

Do NOT ask the user for anything here. Detect everything automatically.

1. **Detect repo root**: Run `git rev-parse --show-toplevel` from the current working directory
2. **Detect repo name**: Extract from the directory name (should be `amelio-performance-backend`)
3. **Validate scope**: Confirm repo is `amelio-performance-backend`. If the repo is `amelio-performance-fe` or `amelio-ui-library`, inform the user to use `/create-perfo-fe-pr` instead and stop.
4. **Map to ADO project**: `amelio-performance-backend` → `Amelio-Performance Management`
5. **Read PR template**: `read_file` at `<repo-root>/.azuredevops/pull_request_template.md`

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

Run the .NET test suite from the repo root:
```bash
dotnet test --verbosity normal
```

<!-- TODO: This step can be enhanced with a test-snapshot tool similar to the FE workflow.
     A .NET-compatible version would use Coverlet for coverage and compare against a baseline.
     If you want to implement this, adapt the vitest-based scripts from /create-perfo-fe-pr
     to work with `dotnet test --collect:"XPlat Code Coverage"` and Coverlet JSON output. -->

Rules:
- All tests MUST pass (0 failures)
- If tests fail: **STOP and fix before proceeding**
- Report test results summary in the chat (test count, pass/fail)

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
  - **Anything Else?**: Follow the template instructions. Rules:
    - **Never name or blame anyone** (no "Origin developer: X" — that info goes in the ADO bug fields only)
    - **For bugs**: Optionally mention the root cause if it adds value beyond what's in the description
    - **For normal tasks**: Leave empty or share learnings, challenges, or non-obvious decisions. ~90% of the time this stays empty
    - This section is for added value only — not a repeat of the description
    - **Never expose internal process details** (no AI tool names, audit reports, or internal workflow steps)

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
- [ ] **Tests passed**: `dotnet test` completed with 0 failures
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
- **ALWAYS run tests before committing** — never skip this step
- **Never propose to publish the PR** — the user publishes it themselves; only ask if the draft looks correct
- **Never expose internal process details** in PR descriptions (no audit reports, AI tool references, or internal workflow steps)
