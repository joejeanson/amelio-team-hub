---
name: code-quality-audit
description: Perform comprehensive code quality audit and refactoring based on Amelio's 31 TypeScript Criteria, 18 Clean Code principles, and 100% test coverage standards. Use when reviewing code quality, refactoring components, or ensuring compliance with Amelio coding standards.
---

# Code Quality Audit & Refactoring Skill

## Overview

This skill guides you through a comprehensive code quality audit based on Amelio's mandatory standards:
- **31 TypeScript Coding Criteria** (MANDATORY)
- **19 Clean Code Principles** (Smelly Code Detection)
- **100% Test Coverage** (MANDATORY)
- **React Hooks Order** (MANDATORY)
- **Accessibility Standards** (WCAG 2.1 AA)

## When to Use This Skill

- Code review and quality audit
- Refactoring existing components
- Pre-commit validation
- Post-development cleanup
- Ensuring compliance with Amelio standards

## Audit Process

### Phase 1: TypeScript Standards (29 Criteria)

Review the code against all 31 TypeScript Criteria:

1. ✅ **JSX Tags**: Use `<Component />` NOT `{Component()}`
2. ✅ **No Nested Components**: Components defined at module level
3. ✅ **Template Literals**: Use `` `hello ${world}` `` NOT `'hello' + world`
4. ✅ **Strict Equality**: Use `===` NOT `==`
5. ✅ **Meaningful Names**: No `a`, `b`, `x` variables
6. ✅ **Consistent Vocabulary**: Same terms for same concepts
7. ✅ **Default Arguments**: In function signatures
8. ✅ **Type Aliases + Object Destructuring**: For ALL functions with 2+ params (not just components)
9. ✅ **Single Responsibility**: One function = one task
10. ✅ **Functional Programming**: `.map()`, `.filter()`, `.reduce()`
11. ✅ **Encapsulate Conditionals**: Extract to named functions
12. ✅ **Positive Conditionals**: Avoid negative logic
13. ✅ **No Type Checking**: Use TypeScript types
14. ✅ **No Dead Code**: Remove unused code
15. ✅ **No Commented Code**: Delete or uncomment
16. ✅ **TODO Comments**: Only if necessary with context
17. ✅ **TypeScript Aliases**: Use `@/` paths
18. ✅ **Curly Braces**: Always use `{}` for conditionals
19. ✅ **Extract Types**: No inline type definitions
20. ✅ **Max One Ternary**: Per function/expression
21. ✅ **Constants Before Return**: Declare before useEffect/return
22. ✅ **Object Destructuring**: For props AND utility function parameters (2+ params)
23. ✅ **Group Exports**: At end of file
24. ✅ **3-Phase Quality Analysis**: Internal + Official + Community docs
25. ✅ **ColorType**: Use `Colors` constants from UI library
26. ✅ **useMemo**: Only for expensive calculations (>1ms)
27. ✅ **Tailwind CSS**: Prefer over inline styles (static values)
28. ✅ **dataTestId**: Always include prop for testing
29. ✅ **void in Types**: Use in interfaces, omit in implementations

**Reference**: See `01-typescript-29-criteria.md` for detailed examples.

### Phase 2: Clean Code Audit (19 Smells)

Detect and fix these code smells:

1. ⚠️ **Naming Inconsistency**: Consistent suffixes/prefixes
2. ⚠️ **Magic Strings**: Extract to constants
3. ⚠️ **Magic Numbers**: Extract to constants (repeated 2+ times)
4. ⚠️ **Inline Functions in Render**: Use useCallback (if >10 items)
5. ⚠️ **Long Parameter Lists**: **2+ params = use object destructuring** (applies to ALL functions)
6. ⚠️ **Nested Ternaries**: Max one ternary per expression
7. ⚠️ **Large Components**: Max ~200 lines, extract sub-components
8. ⚠️ **Comments Explaining Code**: Code should be self-explanatory
9. ⚠️ **Dead Code**: Remove unused code
10. ⚠️ **Unstable Hook Dependencies**: Use primitive dependencies
11. ⚠️ **Side Effects During Render**: Renders must be pure
12. ⚠️ **Missing Accessibility**: ARIA attributes, roles, keyboard support
13. ⚠️ **Premature Optimization**: Measure first, optimize later
14. ⚠️ **Over-Engineering**: Keep it simple (KISS principle)
15. ⚠️ **Incomplete Test Coverage**: 100% MANDATORY
16. ⚠️ **useEffect Without Guard**: Prevent infinite loops
17. ⚠️ **Component Width Constraints**: Parent controls width
18. ⚠️ **Complex Business Logic in Components**: Extract to utils/hooks
19. ⚠️ **Sub-Component SRP Violation**: Child receives pre-calculated data instead of raw data (child should handle its own calculations)

**⚠️ CRITICAL - Import Order:**
- **NEVER manually reorganize** import order
- **ALWAYS use** `yarn eslint --fix <file>` to apply the team's ESLint rules
- If ESLint changes nothing after `--fix`, the current order is already compliant
- Import rules are configured in `.eslintrc` and vary by project

**Reference**: See `09-smelly-code-19-principles.md` for detailed solutions.

### Phase 2.5: Architecture Decision Triggers (NEW)

Apply these architectural patterns when refactoring:

**Extract to Utils** when:
- 3+ utility functions (>10 lines each, pure, reusable)
- Example: `getResponseLabel`, `calculateBarHeightPercent`, `formatTooltipText`

**Extract Sub-Component** when:
- Repeated JSX in `.map()` (>30 lines per iteration)
- Example: `RankingBar` extracted from repeated bar rendering
- **⚠️ CRITICAL SRP**: When extracting, ALL related logic MUST migrate to child (child receives RAW data, handles its own calculations)

**Extract Custom Hook** when:
- Logic with refs/state (>15 lines, reusable)
- Example: `useScrollSync` for scroll synchronization

**Extract Constant** when:
- Value repeated 2+ times (magic numbers/strings)
- Example: `CHART_HEIGHT_PX = 300`

**Reference**: See `12-component-architecture-decisions.md` for detailed decision matrix.

### Phase 3: React Hooks Order (MANDATORY)

Verify hooks are declared in this exact order:

1. `useState`
2. `useRef`
3. `useContext`
4. `useReducer`
5. `useCallback` / `useMemo`
6. `useEffect`

**Critical Rule**: Functions defined with `useCallback` MUST be declared BEFORE `useEffect` that uses them.

**Reference**: See `06-hooks-react-patterns.md`.

### Phase 4: Test Coverage (100% MANDATORY)

Ensure complete test coverage:

- **Statements**: 100% ✅
- **Branches**: 100% ✅
- **Functions**: 100% ✅
- **Lines**: 100% ✅

**Why 100%?** Coverage < 100% = incomplete component with untested code paths.

Test categories required:
1. Unit tests (rendering)
2. Props tests (all props)
3. Variants & sizes tests
4. States tests (disabled, loading, error)
5. Events tests (onClick, onChange)
6. Accessibility tests (ARIA, roles, keyboard)
7. Edge cases (undefined, empty, long text)

**Reference**: See `03-testing-patterns.md`.

## Audit Checklist

### Before Starting
- [ ] Read the component code completely
- [ ] Identify the component's purpose and responsibilities
- [ ] Check existing tests and coverage report

### During Audit
- [ ] Verify all 31 TypeScript Criteria
- [ ] Detect and document all 18 code smells
- [ ] Validate React hooks order
- [ ] Check test coverage (must be 100%)
- [ ] Verify accessibility (WCAG 2.1 AA)
- [ ] Check ColorType usage (no hardcoded colors)
- [ ] Validate Tailwind CSS usage (static values)
- [ ] Ensure dataTestId props exist

### After Audit
- [ ] Create detailed list of violations
- [ ] Prioritize fixes (Critical → Important → Moderate)
- [ ] Provide code examples for each fix
- [ ] Verify all fixes maintain functionality
- [ ] Re-run tests to ensure 100% coverage
- [ ] Update documentation if needed

## Output Format

Provide audit results in this format:

```markdown
# Code Quality Audit Report

## Summary
- **File**: [file path]
- **Component**: [component name]
- **Total Violations**: [count]
- **Critical**: [count] | **Important**: [count] | **Moderate**: [count]

## TypeScript Criteria Violations

### ❌ Criterion #[number]: [name]
**Location**: Line [X]
**Current Code**:
```typescript
[problematic code]
```
**Issue**: [explanation]
**Fix**:
```typescript
[corrected code]
```

## Clean Code Smells Detected

### ⚠️ SMELL #[number]: [name]
**Severity**: [Critical/Important/Moderate]
**Location**: Line [X]
**Current Code**:
```typescript
[problematic code]
```
**Issue**: [explanation]
**Solution**:
```typescript
[corrected code]
```

## Test Coverage Issues

- **Current Coverage**: Statements [X]% | Branches [X]% | Functions [X]% | Lines [X]%
- **Missing Tests**: [list untested code paths]
- **Required Tests**: [list tests to add]

## Recommendations

1. [Priority 1 recommendation]
2. [Priority 2 recommendation]
3. [Priority 3 recommendation]

## Next Steps

- [ ] Fix critical violations first
- [ ] Address important issues
- [ ] Resolve moderate issues
- [ ] Achieve 100% test coverage
- [ ] Re-run audit to verify fixes
```

## Supporting Resources

All detailed documentation is available in this skill directory:

- `01-typescript-29-criteria.md` - Complete TypeScript standards with examples
- `09-smelly-code-19-principles.md` - Clean Code principles and solutions
- `03-testing-patterns.md` - Testing patterns and 100% coverage guide
- `06-hooks-react-patterns.md` - React hooks order and best practices
- `12-component-architecture-decisions.md` - When to extract utils/components/hooks (NEW)
- `02-color-system.md` - ColorType system documentation
- `README.md` - Quick reference and overview

## Best Practices

1. **Be Thorough**: Check every line against all criteria
2. **Provide Examples**: Show before/after code for each fix
3. **Prioritize**: Critical issues first, then important, then moderate
4. **Explain Why**: Always explain the reason behind each recommendation
5. **Reference Standards**: Cite specific criteria/smell numbers
6. **Test Everything**: Ensure 100% coverage after fixes
7. **Maintain Functionality**: Never break existing behavior

## Keywords for Invocation

Use this skill when you see requests like:
- "Review code quality"
- "Audit this component"
- "Check for code smells"
- "Refactor this code"
- "Ensure compliance with standards"
- "Validate TypeScript criteria"
- "Check test coverage"
- "Quality check before commit"

---

**Remember**: Quality is not optional. Every component must meet 100% of these standards before being considered production-ready.
