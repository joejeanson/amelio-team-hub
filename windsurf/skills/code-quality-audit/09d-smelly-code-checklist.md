# 🔍 Smelly Code Checklist & Reference

> Continuation of [Architecture Smells](./09c-smelly-code-architecture.md) | Series start: [Smelly Code Principles](./09a-smelly-code-principles.md)

---

## ✅ Validation Checklist

Before committing, verify:

### Code Quality
- [ ] **Import Order** - ⚠️ **NEVER reorganize manually** - Use `yarn eslint --fix` to apply team ESLint rules
- [ ] **Naming Consistency** - No inconsistent suffixes
- [ ] **No Magic Strings** - Extracted constants
- [ ] **No Hardcoded Values** - Constants for reused values
- [ ] **Max 3-4 Parameters** - Config object if more
- [ ] **No Nested Ternaries** - Maximum one ternary
- [ ] **Component Size** - Maximum ~200 lines
- [ ] **Self-Explanatory Code** - No comments explaining the code
- [ ] **No Dead Code** - No commented or unused code

### React Specific
- [ ] **Stable Hook Dependencies** - No unstable calculated dependencies
- [ ] **Pure Renders** - No side effects during render (except documented ref mutation)
- [ ] **No Inline Functions** - useCallback for functions in render (if >10 items)
- [ ] **useEffect Guards** - Guard mandatory for controlled state sync (avoids infinite loops)
- [ ] **100% Test Coverage** - MANDATORY for all components

### Architecture
- [ ] **No Premature Optimization** - Optimize only if measured necessary
- [ ] **No Over-Engineering** - Pattern 1 for simple components (<100 lines)
- [ ] **Parent Controls Width** - Component without width constraint (parent decides)
- [ ] **Extract Complex Logic** - Business logic/complex calculations in separate hooks/utils
- [ ] **Accessibility** - ARIA/keyboard if within ticket scope

---

## 🎯 General Principles

### 1. **YAGNI** (You Aren't Gonna Need It)
- Do not add code "just in case"
- Implement only what is needed now
- **Example:** Do not create Map for 5-10 items

### 2. **KISS** (Keep It Simple, Stupid)
- Favor simplicity
- Avoid over-engineering
- **Example:** 1 file for a simple component instead of 5 files

### 3. **DRY** (Don't Repeat Yourself)
- Extract duplications into functions/constants
- Single source of truth
- **Caution:** Do not DRY prematurely (wait for 3 occurrences)

### 4. **Single Responsibility**
- One function = one responsibility
- One component = one feature
- **Limit:** ~200 lines for UI components with JSX

### 5. **Consistency Over Perfection**
- Consistency with the existing codebase
- Do not break the API for cosmetic gains
- **Example:** Keep existing pattern even if not "perfect"

---

## � Anti-Over-Engineering: When NOT to Optimize

### ❌ Do NOT create types.ts if:
- Simple component (<100 lines)
- Only 2-3 interfaces
- No external reuse of types

### ❌ Do NOT create index.ts if:
- Component without sub-components
- Only 1-2 exports
- Direct import works fine

### ❌ Do NOT use useMemo/useCallback if:
- Simple calculation (<1ms)
- Few items (<10)
- No measured lag
- **Exception:** useEffect dependencies

### ❌ Do NOT extract to constant if:
- Used only once
- Value is obvious in context
- **Exception:** Translation magic strings

### ❌ Do NOT create custom hook if:
- Logic used only once
- Less than 10 lines
- No planned reuse

### ✅ Optimize ONLY if:
1. **Measured** - Profiler shows a problem
2. **Visible** - Lag perceptible by the user
3. **Justified** - Gain > Added complexity
4. **Documented** - Comment explaining why

**Golden rule:** "Make it work, make it right, make it fast" - In that order!

---

## 📊 Severity Levels

| Level           | Description                     | Action                    |
| --------------- | ------------------------------- | ------------------------- |
| 🔴 **CRITICAL**  | Must be fixed immediately       | Block the merge           |
| 🟠 **IMPORTANT** | Must be fixed before merge      | Request correction        |
| 🟡 **MODERATE**  | Should be fixed                 | Suggest improvement       |
| 🟢 **MINOR**     | Optional                        | Mention in code review    |

---

## 🔧 Detection Tools

### Automatic
- **ESLint** - Problematic pattern detection
- **TypeScript** - Type checking
- **Prettier** - Consistent formatting
- **SonarQube** - Code smell analysis

### Manual
- **Code Review** - Peer review
- **Pair Programming** - Real-time detection
- **Refactoring Sessions** - Regular cleanup

---

## 🎓 Additional Resources

### Books
- **Clean Code** - Robert C. Martin
- **Refactoring** - Martin Fowler
- **The Pragmatic Programmer** - Hunt & Thomas

### Articles
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [Google TypeScript Style Guide](https://google.github.io/styleguide/tsguide.html)
- [React Best Practices](https://react.dev/learn/thinking-in-react)

### Tools
- [ESLint](https://eslint.org/)
- [TypeScript](https://www.typescriptlang.org/)
- [SonarQube](https://www.sonarqube.org/)
- [Prettier](https://prettier.io/)

---

**Status:** ✅ Source of truth for code quality
