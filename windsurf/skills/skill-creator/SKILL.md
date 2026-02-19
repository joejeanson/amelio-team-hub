---
name: skill-creator
description: Create and optimize Windsurf skills. Use when creating new skills, optimizing existing skills that are too long, or when user mentions "skill", "SKILL.md", or asks about skill best practices.
---

# Skill Creator & Optimizer

## When to Use
- Creating a new Windsurf skill
- Optimizing an existing skill (too verbose, > 500 lines)
- User asks about skill structure or best practices
- User provides a skill to review/improve

## Quick Reference (Official Limits)

| Limit | Value | Action | Source |
|-------|-------|--------|--------|
| SKILL.md | **< 500 lines** | Extract to references/ | [Claude Best Practices](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices) |
| Tokens | < 5000 | Condense content | [AgentSkills Spec](https://agentskills.io/specification) |
| name | 1-64 chars, lowercase | Fix casing/format | Official spec |
| description | 1-1024 chars | Add "when to use" | Official spec |
| References | **1 level deep only** | No nested refs | Claude Best Practices |

## Mode 1: Create New Skill

### Step 1: Gather Requirements
Ask user:
1. What does this skill do?
2. When should it be triggered?
3. What files/resources are needed?

### Step 2: Create Structure
```
skill-name/
├── SKILL.md           # < 500 lines
├── references/        # Detailed docs
└── assets/            # Templates
```

### Step 3: Write SKILL.md
```yaml
---
name: skill-name
description: Does X. Use when Y or user mentions Z.
---
```

Body structure:
1. **When to Use** (bullets, 3-5 items)
2. **Quick Start** (minimal instructions)
3. **Workflow** (numbered steps)
4. **References** (links to detailed files)

## Mode 2: Optimize Existing Skill

### Step 1: Analyze Current State
```bash
wc -l SKILL.md  # Target: < 500
```

### Step 2: Apply Optimizations

| Issue | Solution |
|-------|----------|
| > 500 lines | Extract to references/ |
| Generic explanations | Delete (Claude knows) |
| Multiple examples | Keep 1 best example |
| Long paragraphs | Convert to tables/bullets |
| Repeated content | Remove duplicates |

### Step 3: Restructure

**Before** (verbose):
```markdown
## When to Use This Skill
This skill should be used when you are working on...
Bug tasks are different from user stories because...
```

**After** (concise):
```markdown
## When to Use
- Bug task HTML provided
- Title contains "BUG"
```

### Step 4: Extract References
Move to `references/` folder:
- Detailed examples
- API references
- Domain-specific guides
- Long code snippets

Keep in SKILL.md:
- When to use (triggers)
- Quick start (minimal)
- Workflow (high-level steps)
- Links to references

## Validation Checklist

- [ ] SKILL.md < 500 lines
- [ ] name: lowercase, hyphens only
- [ ] description: includes "Use when..."
- [ ] No generic explanations
- [ ] References: 1 level deep only
- [ ] Each concept: 1-2 examples max

## Best Practices Reference

See [SKILL-BEST-PRACTICES.md](SKILL-BEST-PRACTICES.md) for complete documentation on:
- Token limits and progressive disclosure
- Naming conventions
- Description writing
- Anti-patterns to avoid
- Optimization techniques

## Common Patterns

### Pattern: Workflow Skill
```markdown
## Workflow
1. Analyze requirements
2. Implement changes
3. Validate results
4. Document findings
```

### Pattern: Reference Skill
```markdown
## Quick Reference
| Topic | Link |
|-------|------|
| Frontend | [references/frontend.md] |
| Backend | [references/backend.md] |
```

### Pattern: Conditional Skill
```markdown
## Workflow
**If new feature**: Follow [references/new-feature.md]
**If bug fix**: Follow [references/bug-fix.md]
```
