# 🔍 Smelly Code Principles - Clean Code Standards

> Detection and correction principles for **19 code smells** based on Clean Code, official documentation and community best practices

**Status:** ✅ MANDATORY for all components

---

## ⚠️ CRITICAL RULE: Import Order

**NEVER manually reorganize import order.**

### ✅ Correct Procedure
```bash
# If import order seems incorrect, run ESLint:
yarn eslint --fix <file.tsx>
```

### ❌ DO NOT
- Do not manually reorganize imports
- Do not apply a "theoretical" order (React → External → Internal)
- Do not modify order without going through ESLint

### 🎯 Why
- **ESLint applies the team rules** configured in `.eslintrc`
- Avoids conflicts between personal conventions and team rules
- Guarantees consistency across the entire project

### 📝 Note
If ESLint does not modify import order after `--fix`, it means **the current order is already compliant** with team rules.

---

## 📚 Reference Sources

1. **Clean Code** (Robert C. Martin / Uncle Bob)
2. **Refactoring** (Martin Fowler)
3. **Official React Documentation**
4. **Official TypeScript Documentation**
5. **Airbnb JavaScript Style Guide**
6. **Google TypeScript Style Guide**
7. **React Best Practices** (community)

---

## 🔴 Code Smells to Detect and Fix

### **SMELL #1: Naming Inconsistency** ⚠️ IMPORTANT

**Problem:**
```typescript
// ❌ BAD - Inconsistency in naming
interface ComponentProps {
    addItemHandler: (index: number) => void;  // Suffix "Handler"
    updateItem: (id: string) => void;         // No suffix
    deleteItem: (id: string) => void;         // No suffix
}
```

**Clean Code Principle:** Consistency is key

**Solution:**
```typescript
// ✅ GOOD - Consistency in naming
interface ComponentProps {
    addItem: (index: number) => void;      // Consistent
    updateItem: (id: string) => void;      // Consistent
    deleteItem: (id: string) => void;      // Consistent
}
```

**Justification:**
- Easier to understand
- Reduces cognitive load
- Uniform pattern across the entire application
- Better maintainability

---

### **SMELL #2: Magic Strings** ⚠️ IMPORTANT

**Problem:**
```typescript
// ❌ BAD - Repeated magic strings
<Text>{t('evaluation360.questionnaire.form.questions.ranking.title')}</Text>
<Text>{t('evaluation360.questionnaire.form.questions.ranking.description')}</Text>
```

**Clean Code Principle:** Avoid magic strings

**Solution:**
```typescript
// ✅ GOOD - Extracted constants
const TRANSLATION_KEYS = {
    TITLE: 'evaluation360.questionnaire.form.questions.ranking.title',
    DESCRIPTION: 'evaluation360.questionnaire.form.questions.ranking.description',
} as const;

<Text>{t(TRANSLATION_KEYS.TITLE)}</Text>
<Text>{t(TRANSLATION_KEYS.DESCRIPTION)}</Text>
```

**Justification:**
- Avoids typos
- Facilitates refactoring
- IDE autocomplete
- Single source of truth

---

### **SMELL #3: Hardcoded Values** ⚠️ MODERATE

**Problem:**
```typescript
// ❌ BAD - Hardcoded value
dataTestId={
    dataTestId
        ? `${dataTestId}-option-${index}`
        : `ranking-option-${index}`  // Hardcoded
}
```

**Clean Code Principle:** Extract constants

**Solution:**
```typescript
// ✅ GOOD - Extracted constant
const DEFAULT_TEST_ID_PREFIX = 'ranking-option';

dataTestId={
    dataTestId
        ? `${dataTestId}-option-${index}`
        : `${DEFAULT_TEST_ID_PREFIX}-${index}`
}
```

**Justification:**
- Easier to modify
- Avoids duplication
- Better maintainability
- Single source of truth

---

### **SMELL #4: Inline Function Creation in Render** ⚠️ PERFORMANCE

**Problem:**
```typescript
// ❌ BAD - Function recreated on every render
renderItem={(item, index) => (
    <Component
        onChange={(value) => updateItem(item.id, value)}  // New function
        onRemove={() => deleteItem(item.id)}              // New function
    />
)}
```

**React Best Practice:** Use useCallback for stable references

**Solution:**
```typescript
// ✅ GOOD - Memoized functions with useCallback
const handleChange = useCallback(
    (id: string) => (value: string) => {
        updateItem(id, value);
    },
    [updateItem],
);

const handleRemove = useCallback(
    (id: string) => () => {
        deleteItem(id);
    },
    [deleteItem],
);

renderItem={(item, index) => (
    <Component
        onChange={handleChange(item.id)}
        onRemove={handleRemove(item.id)}
    />
)}
```

**Justification:**
- Avoids unnecessary re-renders
- Better performance
- Recommended React pattern
- Justified optimization

---

### **SMELL #5: Long Parameter Lists** ⚠️ MODERATE

**Problem:**
```typescript
// ❌ BAD - Too many parameters
function createUser(
    firstName: string,
    lastName: string,
    email: string,
    phone: string,
    address: string,
    city: string,
    country: string,
) { }
```

**Clean Code Principle:** Limit parameters (max 3-4)

**Solution:**
```typescript
// ✅ GOOD - Configuration object
interface CreateUserParams {
    firstName: string;
    lastName: string;
    email: string;
    phone: string;
    address: string;
    city: string;
    country: string;
}

function createUser(params: CreateUserParams) { }
```

**Justification:**
- Easier to read
- Parameter order does not matter
- Easier to add new parameters
- Better documentation

---

### **SMELL #6: Nested Ternaries** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Nested ternaries
const status = isActive 
    ? isVerified 
        ? 'active-verified' 
        : 'active-unverified'
    : isVerified 
        ? 'inactive-verified' 
        : 'inactive-unverified';
```

**Clean Code Principle:** Maximum one ternary per expression

**Solution:**
```typescript
// ✅ GOOD - Function with clear conditions
const getStatus = (isActive: boolean, isVerified: boolean): string => {
    if (isActive && isVerified) return 'active-verified';
    if (isActive && !isVerified) return 'active-unverified';
    if (!isActive && isVerified) return 'inactive-verified';
    return 'inactive-unverified';
};

const status = getStatus(isActive, isVerified);
```

**Justification:**
- Much more readable
- Easier debugging
- Better maintainability
- Avoids errors

---

### **SMELL #7: Large Components** ⚠️ IMPORTANT

**Problem:**
```typescript
// ❌ BAD - Component > 200 lines
const UserDashboard = () => {
    // 50 lines of state
    // 100 lines of logic
    // 100 lines of JSX
    return <div>...</div>;
};
```

**Clean Code Principle:** Single Responsibility

**Solution:**
```typescript
// ✅ GOOD - Separated components
const UserDashboard = () => {
    return (
        <div>
            <UserHeader />
            <UserStats />
            <UserActivity />
            <UserSettings />
        </div>
    );
};
```

**Justification:**
- Better testability
- Reusability
- Easier to understand
- Better maintainability

---

### **SMELL #8: Comments Explaining Code** ⚠️ MODERATE

**Problem:**
```typescript
// ❌ BAD - Comment explaining obscure code
// Check if user is active and verified and not banned
if (u.s === 1 && u.v === true && !u.b) { }
```

**Clean Code Principle:** Code should be self-explanatory

**Solution:**
```typescript
// ✅ GOOD - Self-explanatory code
const isUserActive = user.status === UserStatus.ACTIVE;
const isUserVerified = user.isVerified === true;
const isUserNotBanned = !user.isBanned;

if (isUserActive && isUserVerified && isUserNotBanned) { }
```

**Justification:**
- Self-documenting code
- No need for comments
- Better readability
- Easier maintenance

---

### **SMELL #9: Dead Code** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Dead or commented code
const MyComponent = () => {
    // const oldFunction = () => { };  // Commented out
    
    const unusedVariable = 'test';  // Never used
    
    return <div>Content</div>;
};
```

**Clean Code Principle:** Remove dead code

**Solution:**
```typescript
// ✅ GOOD - No dead code
const MyComponent = () => {
    return <div>Content</div>;
};
```

**Justification:**
- Git keeps the history
- Reduces confusion
- Cleaner code
- Better maintainability

---
