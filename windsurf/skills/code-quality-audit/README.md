# 📐 Standards Généraux - Documentation

**Standards universels applicables à tous les projets Amelio**

---

## 📚 Fichiers de Documentation

### **TypeScript & Types**
- [`01-typescript-29-criteria.md`](./01-typescript-29-criteria.md) - **29 critères TypeScript MANDATORY**
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section TypeScript)

- [`02-color-system.md`](./02-color-system.md) - Système ColorType
  - 🏷️ **Windsurf:** Rule `.windsurf/rules/color-system.md`

- [`05-type-architecture.md`](./05-type-architecture.md) - Organisation types TypeScript
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section Types)

### **Testing**
- [`03-testing-patterns.md`](./03-testing-patterns.md) - **Patterns tests + 100% coverage MANDATORY**
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section Testing)

### **Code Review**
- [`04-code-review-protocol.md`](./04-code-review-protocol.md) - Protocole code review
  - 🏷️ **Windsurf:** Workflow `/code-review`

- [`08-code-review-phrases.md`](./08-code-review-phrases.md) - **Phrases constructives (CRITIQUE)**
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section Code Review)

### **React & Hooks**
- [`06-hooks-react-patterns.md`](./06-hooks-react-patterns.md) - **Ordre hooks MANDATORY**
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section Hooks)

### **Documentation**
- [`07-comments-documentation.md`](./07-comments-documentation.md) - Standards commentaires
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section Comments)
 
- [`11-component-guidelines.md`](./11-component-guidelines.md) - Guide de développement (Storybook-first, workflow, best practices)

### **Clean Code**
- [`09-smelly-code-17-principles.md`](./09-smelly-code-17-principles.md) - **17 principes Clean Code**
  - 🏷️ **Windsurf:** Rule `global_rules.md` (section Clean Code)

### **Testing Avancé**
- [`10-motion-react-testing.md`](./10-motion-react-testing.md) - Testing Framer Motion
  - 🏷️ **Windsurf:** Memory (patterns spécifiques)

---

## 🌊 Intégration Windsurf

### **Rules à Créer**

**`global_rules.md`** (GLOBAL - Tous workspaces)
```markdown
<amelio_global_standards>
# Amelio - Standards Globaux

## Language & Communication
- Code comments: ENGLISH ONLY
- Documentation: French
- Commit messages: English
- Code review feedback: English

## TypeScript Standards (29 Criteria)
1. Use JSX tags: <Component /> NOT {Component()}
2. No nested component definitions
3. Template literals: `hello ${world}` NOT 'hello' + world
4. Strict equality: === NOT ==
5. Meaningful variable names (not a, b, x)
... (voir 01-typescript-29-criteria.md pour liste complète)

## React Hooks Order (MANDATORY)
1. useState
2. useRef
3. useContext
4. useReducer
5. useCallback / useMemo
6. useEffect

**Rule:** Functions defined with useCallback BEFORE useEffect that uses them

## Testing Standards
- 100% coverage MANDATORY (Statements | Branches | Functions | Lines)
- Coverage < 100% = incomplete component
- Test: rendering, props, variants, states, events, edge cases, accessibility

## Clean Code Principles (17 Smells)
1. Import order: React → External → Internal → Relative
2. Naming consistency (no Handler suffix)
3. No magic strings (extract constants)
4. No hardcoded values
5. No inline functions in render (use useCallback if >10 items)
... (voir 09-smelly-code-17-principles.md pour liste complète)

## Code Review Approach
- Use constructive phrases (not directives)
- Suggest improvements with "Consider...", "What do you think about..."
- Reference specific files and line numbers
- Provide code examples when suggesting changes
- Focus on: correctness, readability, maintainability, performance
</amelio_global_standards>
```

**`.windsurf/rules/color-system.md`** (Workspace)
```markdown
<color_system>
# ColorType System

## Usage
- ALWAYS use ColorType for colors
- Import: import { Colors } from '@amelio/ui-library'
- Usage: color={Colors.Primary}, color={Colors.Success}

## Available Colors
- Primary, Secondary, Tertiary
- Success, Warning, Danger, Info
- Gray (50-900 shades)
- White, Black

## Never Do
- ❌ color="primary" (string)
- ❌ color="#3B82F6" (hex)
- ❌ className="text-blue-500" (for dynamic colors)

## Always Do
- ✅ color={Colors.Primary}
- ✅ color={Colors.Success}
</color_system>
```

---

## 🎯 Quick Start

### **Pour Tous Développeurs**
1. Lire [`01-typescript-29-criteria.md`](./01-typescript-29-criteria.md) - 29 critères MANDATORY
2. Consulter [`03-testing-patterns.md`](./03-testing-patterns.md) - 100% coverage MANDATORY
3. Référer [`09-smelly-code-17-principles.md`](./09-smelly-code-17-principles.md) - 17 principes Clean Code

### **Pour Code Reviews**
1. Suivre [`04-code-review-protocol.md`](./04-code-review-protocol.md) - Protocole
2. Utiliser [`08-code-review-phrases.md`](./08-code-review-phrases.md) - Phrases constructives ⭐

---

## 📊 Standards Clés

### **29 Critères TypeScript (MANDATORY)**
- JSX tags: `<Component />` NOT `{Component()}`
- No nested components
- Template literals
- Strict equality `===`
- Meaningful names
- ... (voir fichier complet)

### **Ordre Hooks React (MANDATORY)**
1. useState
2. useRef
3. useContext
4. useReducer
5. useCallback / useMemo
6. useEffect

**Règle:** useCallback AVANT useEffect qui l'utilise

### **17 Principes Clean Code**
1. Import order correct
2. No magic strings
3. No hardcoded values
4. Component size <200 lines
5. 100% test coverage
... (voir fichier complet)

### **100% Coverage (MANDATORY)**
- Statements: 100%
- Branches: 100%
- Functions: 100%
- Lines: 100%

**Principe:** Coverage < 100% = composant incomplet

---

## 🔗 Liens Utiles

- **Guide Windsurf:** [`../WINDSURF-INTEGRATION-GUIDE.md`](../WINDSURF-INTEGRATION-GUIDE.md)
- **UI Library:** [`../1-UI-Library/README.md`](../1-UI-Library/README.md)
- **Performance FE:** [`../2-Performance-FE/README.md`](../2-Performance-FE/README.md)

---

**Dernière mise à jour:** Janvier 2026  
**Maintenu par:** Équipe Amelio Dev
