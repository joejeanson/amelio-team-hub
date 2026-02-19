# Windsurf Skills - Meilleures Pratiques

> **Source**: Documentation officielle [agentskills.io](https://agentskills.io/specification) et [Claude Platform](https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices)

---

## 📏 Limites Officielles

| Élément | Limite | Notes |
|---------|--------|-------|
| **SKILL.md body** | < 500 lignes | < 5000 tokens recommandés |
| **name** | 1-64 caractères | lowercase, chiffres, tirets uniquement |
| **description** | 1-1024 caractères | Doit inclure QUAND utiliser le skill |
| **Metadata (~100 tokens)** | Chargé au démarrage | Seuls name + description |
| **References** | 1 niveau de profondeur | Pas de références imbriquées |

---

## 🏗️ Structure Recommandée

```
skill-name/
├── SKILL.md              # Instructions principales (< 500 lignes)
├── references/           # Documentations détaillées (chargées à la demande)
│   ├── api-reference.md
│   └── examples.md
├── scripts/              # Scripts exécutables (pas chargés, exécutés)
│   └── validate.sh
└── assets/               # Templates, configs
    └── template.yaml
```

---

## ✅ Principes Fondamentaux

### 1. Concis avant tout
```markdown
# ❌ Trop verbeux (~150 tokens)
## Extract PDF text
PDF (Portable Document Format) files are a common file format 
that contains text, images, and other content. To extract text 
from a PDF, you'll need to use a library. There are many libraries...

# ✅ Concis (~50 tokens)
## Extract PDF text
Use pdfplumber for text extraction:
```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
```

### 2. Claude est intelligent par défaut
- Ne pas expliquer ce que Claude sait déjà
- Fournir uniquement le contexte spécifique au projet
- Éviter les définitions génériques

### 3. Progressive Disclosure
1. **Startup**: Seuls `name` + `description` sont chargés
2. **Activation**: SKILL.md complet chargé quand pertinent
3. **Exécution**: Fichiers références chargés à la demande

---

## 📝 Format du Frontmatter

```yaml
---
name: skill-name              # Required: lowercase, hyphens
description: |                # Required: QUOI + QUAND
  Does X, Y, Z. Use when working with A or when user mentions B.
---
```

### Naming Conventions
| ✅ Bon | ❌ Mauvais |
|--------|-----------|
| `processing-pdfs` | `PDF-Processing` (uppercase) |
| `code-review` | `-code-review` (tiret début) |
| `deploy-staging` | `deploy--staging` (double tiret) |
| `bug-fix-workflow` | `helper`, `utils` (vague) |

### Description Efficace
```yaml
# ✅ Spécifique avec triggers
description: Fix bugs in Amelio projects. Use when user provides 
  Bug task HTML report or mentions "BUG", "fix", "debug".

# ❌ Trop vague
description: Helps with bugs.
```

---

## 🎯 Degrés de Liberté

| Niveau | Quand utiliser | Exemple |
|--------|---------------|---------|
| **Haute liberté** | Multiples approches valides | Code review guidelines |
| **Moyenne** | Pattern préféré, variation OK | Templates avec paramètres |
| **Basse** | Opérations fragiles | Scripts de migration DB |

---

## 📦 Organisation des Références

### Pattern 1: Guide + Références
```markdown
# SKILL.md
## Quick start
[Instructions courtes ici]

## Advanced
- **Form filling**: See [references/forms.md](references/forms.md)
- **API reference**: See [references/api.md](references/api.md)
```

### Pattern 2: Organisation par Domaine
```
skill/
├── SKILL.md (navigation)
└── references/
    ├── frontend.md
    ├── backend.md
    └── testing.md
```

### ⚠️ Éviter: Références Imbriquées
```markdown
# ❌ Trop profond - Claude peut lire partiellement
SKILL.md → advanced.md → details.md → actual-info.md

# ✅ Un seul niveau
SKILL.md → reference.md (contenu complet)
```

---

## 🔧 Optimisation d'un Skill Existant

### Checklist de Réduction

1. **Supprimer les explications génériques**
   - Claude sait ce qu'est un PDF, une API, React, etc.

2. **Condenser les exemples**
   - 1 exemple concis > 5 exemples détaillés

3. **Extraire vers références**
   - Contenu spécialisé → fichiers séparés
   - Garder uniquement le "when to use" dans SKILL.md

4. **Utiliser des tableaux**
   - Plus dense que les listes

5. **Supprimer les répétitions**
   - Une seule mention suffit

### Avant/Après Exemple

```markdown
# ❌ Avant (verbose)
## When to Use This Skill
This skill should be used when you are working on a bug task.
Bug tasks are different from user stories because they require
investigation first. You should use this skill whenever...

# ✅ Après (concis)
## When to Use
- Bug task HTML report provided
- Task title contains "BUG"
- Fixing existing defect (not new feature)
```

---

## 📊 Métriques de Qualité

| Métrique | Cible | Action si dépassée |
|----------|-------|-------------------|
| SKILL.md lignes | < 500 | Extraire vers references/ |
| Tokens estimés | < 5000 | Condenser ou diviser |
| Niveau références | 1 | Aplatir la structure |
| Exemples par concept | 1-2 | Supprimer les redondants |

---

## 🚫 Anti-Patterns

1. **Over-explaining**: Expliquer ce que Claude sait
2. **Too many options**: > 3 alternatives confuses
3. **Windows paths**: Utiliser `/` pas `\`
4. **Nested references**: Références dans les références
5. **Time-sensitive info**: Dates, versions qui changent
6. **Inconsistent terminology**: Varier les termes pour le même concept

---

## ✨ Template Minimal

```markdown
---
name: my-skill
description: Does X and Y. Use when working with Z or user mentions A, B.
---

# My Skill

## When to Use
- Condition 1
- Condition 2

## Quick Start
[Minimal instructions]

## Workflow
1. Step 1
2. Step 2
3. Step 3

## References
- **Details**: See [references/details.md](references/details.md)
- **Examples**: See [references/examples.md](references/examples.md)
```

---

*Généré depuis la documentation officielle Windsurf et agentskills.io*
