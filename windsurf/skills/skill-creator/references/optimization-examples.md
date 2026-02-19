# Exemples d'Optimisation de Skills

## Exemple 1: Réduire les Explications Génériques

### ❌ Avant (40 tokens)
```markdown
## Understanding Bug Tasks
Bug tasks are work items that represent defects in the software.
They are different from User Stories because they fix existing 
problems rather than adding new features. When working on a bug,
you need to first reproduce it, then investigate the root cause.
```

### ✅ Après (10 tokens)
```markdown
## Bug Tasks
Fix existing defects. Workflow: reproduce → investigate → fix → validate.
```

---

## Exemple 2: Condenser les Listes

### ❌ Avant (verbose liste)
```markdown
## When to Use This Skill
- You should use this skill when you receive a bug task
- This skill is also useful when you need to fix a defect
- If the user provides an HTML report for a bug, use this skill
- When the task title contains the word BUG, this is the right skill
- For any debugging or fixing work, consider using this skill
```

### ✅ Après (concis)
```markdown
## When to Use
- Bug task HTML report provided
- Task title contains "BUG"
- Fixing defect (not new feature)
```

---

## Exemple 3: Tableaux vs Paragraphes

### ❌ Avant (paragraphes)
```markdown
## File Locations
The SKILL.md file should be placed in the skill folder. For workspace
skills, put it in .windsurf/skills/skill-name/. For global skills,
put it in ~/.codeium/windsurf/skills/skill-name/. Supporting files
like references go in subdirectories.
```

### ✅ Après (tableau)
```markdown
## Locations
| Scope | Path |
|-------|------|
| Workspace | `.windsurf/skills/<name>/` |
| Global | `~/.codeium/windsurf/skills/<name>/` |
```

---

## Exemple 4: Extraire vers Références

### ❌ Avant (tout dans SKILL.md)
```markdown
# My Skill

## API Reference
### Method 1: createUser()
Parameters: name (string), email (string), role (string)
Returns: User object with id, createdAt, updatedAt
Example:
```javascript
const user = await createUser({
  name: "John",
  email: "john@example.com",
  role: "admin"
});
```

### Method 2: updateUser()
[... 200 more lines of API docs ...]
```

### ✅ Après (extrait)
```markdown
# My Skill (SKILL.md)

## API
See [references/api.md](references/api.md) for complete reference.

Quick example:
```javascript
const user = await createUser({ name, email, role });
```
```

---

## Exemple 5: Supprimer les Répétitions

### ❌ Avant (répétitif)
```markdown
## Important Rules
1. Always validate input before processing
2. Make sure to validate all input data
3. Input validation is critical

## Workflow
1. Validate input (this is very important)
2. Process data
3. Remember to validate input at each step
```

### ✅ Après (une seule mention)
```markdown
## Rules
- Validate input before processing

## Workflow
1. Validate input
2. Process data
3. Output results
```

---

## Exemple 6: Code Inline vs Bloc

### ❌ Avant (blocs inutiles)
```markdown
To run the command, type:
```bash
npm install
```
Then run:
```bash
npm start
```
```

### ✅ Après (inline)
```markdown
Run `npm install` then `npm start`.
```

---

## Métriques d'Optimisation Réussie

| Métrique | Avant | Après | Réduction |
|----------|-------|-------|-----------|
| Lignes SKILL.md | 678 | 120 | -82% |
| Tokens estimés | 8500 | 1500 | -82% |
| Exemples par concept | 5 | 1 | -80% |
| Références imbriquées | 3 niveaux | 1 niveau | -67% |

---

## Checklist Post-Optimisation

- [ ] SKILL.md < 500 lignes
- [ ] Aucune explication que Claude connaît déjà
- [ ] 1-2 exemples max par concept
- [ ] Tableaux utilisés pour données structurées
- [ ] Contenu détaillé extrait vers references/
- [ ] Pas de contenu répété
