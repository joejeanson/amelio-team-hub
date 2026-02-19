# 📘 TypeScript Criteria 16-24

> Continuation of [Criteria 1-15](./01a-typescript-criteria-1-15.md) | Next: [Criteria 25-29](./01c-typescript-criteria-25-29.md)

---

## ✅ 16. TODO Comments

### ❌ Avoid
```typescript
// Ensure dueDate is indexed
function getActiveSubscriptions() { ... }
```

### ✅ Prefer
```typescript
// TODO: Ensure dueDate is indexed
function getActiveSubscriptions() { ... }
```

### 🤔 Why
- IDE support
- Easy tracking
- ⚠️ NOT an excuse for bad code!

---

## ✅ 17. Imports - TypeScript Aliases

### ❌ Avoid
```typescript
import { UserService } from '../../../services/UserService';
```

### ✅ Prefer
```typescript
import { UserService } from '@services/UserService';
// Or
import { UserService } from '@/services/UserService';
```

### 🤔 Why
- Avoids long relative paths
- Easier refactoring

---

## ✅ 18. Always Use Curly Braces for Conditionals

### ❌ Avoid
```typescript
if (true) doSomething();

if (isValid)
    return result;
else
    return null;
```

### ✅ Prefer
```typescript
if (true) {
    doSomething();
}

if (isValid) {
    return result;
} else {
    return null;
}
```

### 🤔 Why
- Prevents errors
- Maintains consistency
- Explicit structure

---

## ✅ 19. Extract Inline Type Definitions

### ❌ Avoid
```typescript
function createUser({
    name,
    email,
    role,
}: {
    name: string;
    email: string;
    role: 'admin' | 'user';
}) { ... }
```

### ✅ Prefer
```typescript
type CreateUserParams = {
    name: string;
    email: string;
    role: 'admin' | 'user';
};

function createUser(params: CreateUserParams) { ... }
```

### 🤔 Why
- Reusability
- Cleaner signatures
- Easier to extend

---

## ✅ 20. Limit to One Ternary Operator Per Function

### ❌ Avoid
```typescript
const value = condition1
    ? condition2
        ? result1
        : result2
    : condition3
        ? result3
        : result4;
```

### ✅ Prefer (Guard Clauses with Early Returns)
```typescript
const getValue = (): string => {
    if (condition1 && condition2) {
        return result1;
    }
    
    if (condition1) {
        return result2;
    }
    
    if (condition3) {
        return result3;
    }
    
    return result4;
};

const value = getValue();
```

### 💡 Alternative (for if/else if/else chains)
```typescript
// Instead of:
let borderClasses = '';
if (hasCustomBorder) {
    borderClasses = '';
} else if (shouldShowLegend) {
    borderClasses = 'border-transparent';
} else {
    borderClasses = 'border-none';
}

// Prefer function with guard clauses:
const getBorderClasses = (): string => {
    if (hasCustomBorder) {
        return '';
    }
    
    if (shouldShowLegend) {
        return 'border-transparent';
    }
    
    return 'border-none';
};

const borderClasses = getBorderClasses();
```

### 🤔 Why
- **Readability**: Each condition is clearly separated
- **Easier debugging**: Can set breakpoints on each return
- **Less error-prone**: No nested logic to track
- **Guard clauses**: Exit early when conditions are met
- **Avoids if/else chains**: Cleaner than cascading if/else if/else

---

## ✅ 21. Constants and Functions Declared Before Return

### ❌ Avoid
```typescript
export const Component = ({ value }: Props) => {
    useEffect(() => {
        processValue(value); // ❌ Used before being defined
    }, [value]);

    const processValue = (val: string) => {
        // Function defined AFTER useEffect
    };

    return <div>{value}</div>;
};
```

### ✅ Prefer
```typescript
export const Component = ({ value }: Props) => {
    // ✅ Function defined BEFORE useEffect
    const processValue = (val: string) => {
        // Logic
    };

    useEffect(() => {
        processValue(value);
    }, [value, processValue]);

    return <div>{value}</div>;
};
```

### 🤔 Why
- Immediate visibility
- Reduces cognitive load
- Better organization

---

## ✅ 22. Object Destructuring for Function Parameters

### ❌ Avoid
```typescript
function Component(
    props: ComponentProps
) {
    return <div>{props.title}</div>;
}
```

### ✅ Prefer
```typescript
function Component({
    title,
    description,
    onClick,
}: ComponentProps) {
    return <div>{title}</div>;
}
```

### 🤔 Why
- Self-documenting
- Order-independent
- Safer refactoring

---

## ✅ 23. Group Exports at End of File

### ❌ Avoid
```typescript
export const Component = () => {
    return <div>Component</div>;
};

export const Helper = () => {
    return <span>Helper</span>;
};
```

### ✅ Prefer
```typescript
const Component = () => {
    return <div>Component</div>;
};

const Helper = () => {
    return <span>Helper</span>;
};

export { Component, Helper };
```

### 🤔 Why
- Clear visibility of public API
- Easier to manage exports
- Better organization
- Consistent with module pattern

### 📖 Exception: index.ts Files

**Do NOT create index.ts files for simple components.**

#### ❌ Avoid (Unnecessary index.ts)
```typescript
// src/components/Button/index.ts - UNNECESSARY (simple component)
export { Button } from './Button';
export type { ButtonProps } from './Button';

// src/components/RankingQuestionAnswer/index.ts - UNNECESSARY (simple component)
export { RankingQuestionAnswer } from './RankingQuestionAnswer';
export type { RankingQuestionAnswerProps, RankingQuestionOption } from './RankingQuestionAnswer';
```

#### ✅ Prefer (Direct import)
```typescript
// Import directly from the component file
import { Button } from '@/components/Button/Button';
import { RankingQuestionAnswer } from '@/components/RankingQuestionAnswer/RankingQuestionAnswer';
```

#### ✅ When to create index.ts
Create an index.ts file ONLY when you have a **COMPLEX component with sub-components**:

```typescript
// src/components/AnswerOptionsList/index.ts - JUSTIFIED (parent component + sub-components)
export { AnswerOptionsList } from './AnswerOptionsList';
export { AnswerOption } from './AnswerOption';
export { AnswerOptionGroup } from './AnswerOptionGroup';
export type { AnswerOptionsListProps, AnswerOptionConfig, AnswerOptionProps } from './types';
```

### 🎯 Rule of thumb for index.ts:
- **Simple component** (1 .tsx file): ❌ NO index.ts - import directly from component file
- **Complex component** (parent + sub-components): ✅ YES index.ts - create barrel export for convenience
- **Number of exports is NOT the criterion** - it's the architectural complexity that matters

---

## ✅ 24. Code Quality Analysis and Optimization (3 Phases)

Before accepting any code modification, perform a thorough 3-phase analysis to ensure quality, optimization, and best practices.

### Phase 1: Internal Documentation
- Verify compliance with our project documentation
- Ensure consistency with our established team conventions
- Validate alignment with our existing architecture

### Phase 2: Official Documentation
- Consult the official documentation of the language used (TypeScript, JavaScript, etc.)
- Check the official docs of each imported library (React, Jotai, etc.)
- Apply patterns recommended by official maintainers
- Use the most modern and recommended APIs and syntaxes

### Phase 3: Community Best Practices
- Identify and eliminate dead or unused code
- Detect and fix any "code smell" (duplication, excessive complexity, etc.)
- Apply modern development practices (concise, clear, and performant syntax)
- Optimize intelligently without sacrificing readability
- Favor recent approaches that are shorter and more expressive

### 🤔 Why
- Guarantees code quality at all levels
- Eliminates dead code and code smells
- Ensures the use of modern best practices
- Maintains consistency with internal and official documentation

## 🎯 Quick Validation Checklist

```typescript
// Before committing, verify:
✅ 1. No direct component invocation
✅ 2. No nested components
✅ 3. Template literals for strings
✅ 4. === instead of ==
✅ 5. Meaningful variable names
✅ 6. Consistent vocabulary
✅ 7. Default arguments
✅ 8. Type aliases
✅ 9. One responsibility per function
✅ 10. Functional programming
✅ 11. Encapsulated conditionals
✅ 12. Positive conditionals
✅ 13. No manual type checking
✅ 14. No dead code
✅ 15. No commented code
✅ 16. TODO if necessary
✅ 17. TypeScript aliases
✅ 18. Curly braces everywhere
✅ 19. Extracted types
✅ 20. Max one ternary
✅ 21. Constants at top
✅ 22. Object destructuring
✅ 23. Exports grouped at end of file
✅ 24. Quality analysis 3 phases (internal + official + community)
✅ 25. Use Colors constants from UI library (no hard-coded hex colors)
✅ 26. Use useMemo only for expensive calculations (>1ms)
✅ 27. Prefer Tailwind CSS over inline styles
✅ 28. Always include dataTestId prop for component testing
```

---

