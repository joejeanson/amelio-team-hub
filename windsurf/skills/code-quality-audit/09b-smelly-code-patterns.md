# 🔍 Smelly Code Patterns - Smells 10-16

> Continuation of [Smelly Code Principles](./09a-smelly-code-principles.md) | Next: [Architecture Smells](./09c-smelly-code-architecture.md)

---

### **SMELL #10: Unstable Dependencies in Hooks** ⚠️ IMPORTANT

**Problem:**
```typescript
// ❌ BAD - Unstable calculated dependency
const nextItem = options.find(opt => !rankedIds.includes(opt.id));

const handleAction = useCallback(
    () => {
        if (!nextItem) return;  // nextItem recalculated on every render
        doSomething(nextItem);
    },
    [nextItem, doSomething],  // nextItem changes on every render
);
```

**React Best Practice:** Dependencies should be stable or primitive

**Solution:**
```typescript
// ✅ GOOD - Use primitive dependencies
const handleAction = useCallback(
    () => {
        const currentNext = options.find(opt => !rankedIds.includes(opt.id));
        if (!currentNext) return;
        doSomething(currentNext);
    },
    [options, rankedIds, doSomething],  // Stable dependencies
);
```

**Justification:**
- Avoids unnecessary callback recreations
- Better performance
- Explicit and stable dependencies
- Recommended React pattern

---

### **SMELL #11: Side Effects During Render** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Mutation during render
{items.map((item, index) => {
    // Ref mutation during render
    handlersRef.current.set(index, {
        onClick: () => handleClick(item.id)
    });
    
    return <Item key={item.id} />;
})}
```

**React Official Docs:** Renders must be pure

**Solution Option 1 (Preferred):**
```typescript
// ✅ GOOD - Mutation in ref callback
{items.map((item, index) => {
    const handleClick = () => handleItemClick(item.id);
    
    return (
        <Item
            key={item.id}
            ref={(el) => {
                if (el) {
                    handlersRef.current.set(index, { onClick: handleClick });
                }
            }}
        />
    );
})}
```

**Solution Option 2 (If ref mutation needed for tests):**
```typescript
// ✅ ACCEPTABLE - Document the intention
{items.map((item, index) => {
    const handleClick = () => handleItemClick(item.id);
    
    // Intentional ref mutation for test imperative API
    handlersRef.current.set(index, { onClick: handleClick });
    
    return <Item key={item.id} />;
})}
```

**Justification:**
- Respects React render purity principle
- Avoids subtle bugs
- Better predictability
- **Exception:** Ref mutation acceptable if documented and needed for tests

---

### **SMELL #12: Missing Accessibility Attributes** ⚠️ MODERATE

**Problem:**
```typescript
// ❌ BAD - Interactive element without ARIA
<div
    onClick={handleClick}
    className="cursor-pointer"
>
    Click me
</div>
```

**WCAG 2.1 AA Standard:** Interactive elements need proper semantics

**Solution:**
```typescript
// ✅ GOOD - Appropriate semantics and ARIA
<button
    onClick={handleClick}
    type="button"
    aria-label="Click to perform action"
>
    Click me
</button>

// OR if div is necessary
<div
    role="button"
    tabIndex={0}
    onClick={handleClick}
    onKeyDown={(e) => {
        if (e.key === 'Enter' || e.key === ' ') {
            handleClick();
        }
    }}
    aria-label="Click to perform action"
    className="cursor-pointer"
>
    Click me
</div>
```

**Justification:**
- Accessibility for screen readers
- Keyboard support
- WCAG 2.1 AA compliance
- Better UX for everyone

**Note:** Apply only if within the ticket scope. Do not over-engineer.

---

### **SMELL #13: Premature Optimization** ⚠️ IMPORTANT

**Problem:**
```typescript
// ❌ BAD - Premature optimization
const optionsMap = useMemo(
    () => new Map(options.map(opt => [opt.id, opt])),
    [options]
);

// For only 5-10 items
const rankedItems = rankedIds.map(id => optionsMap.get(id));
```

**Donald Knuth:** "Premature optimization is the root of all evil"

**Solution:**
```typescript
// ✅ GOOD - Simple and clear for few items
const rankedItems = rankedIds
    .map(id => options.find(opt => opt.id === id))
    .filter(Boolean);
```

**When to optimize:**
- ✅ Measure first (profiler)
- ✅ Optimize if >100 items
- ✅ Optimize if visible lag
- ❌ Do not optimize "just in case"

**Justification:**
- YAGNI (You Aren't Gonna Need It)
- Simpler and more maintainable code
- Optimization based on real data
- Avoids over-engineering

---

### **SMELL #14: Over-Engineering Simple Components** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Over-engineering for a simple component
// Files created:
// - Component.tsx
// - types.ts (3 interfaces)
// - index.ts (barrel export)
// - hooks/useComponentLogic.ts
// - utils/componentHelpers.ts
// - constants.ts

// For a 50-line component with 2-3 props
```

**KISS Principle:** Keep It Simple, Stupid

**Solution:**
```typescript
// ✅ GOOD - Everything in one file for a simple component
// Component.tsx (50 lines)
export interface ComponentProps {
    title: string;
    onClick: () => void;
}

export const Component: React.FC<ComponentProps> = ({ title, onClick }) => {
    return <button onClick={onClick}>{title}</button>;
};
```

**Rules:**
- **Pattern 1 (Simple):** 1 .tsx file if <100 lines and 2-3 interfaces
- **Pattern 2 (Complex):** Separate if >100 lines OR sub-components OR 5+ interfaces
- **index.ts:** Only if parent component + sub-components

**Justification:**
- Avoids over-structuring
- Easier to navigate
- Fewer files to maintain
- Respects the YAGNI principle

---

### **SMELL #15: Incomplete Test Coverage** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Incomplete coverage
// Coverage Report:
// Statements: 85%
// Branches: 78%
// Functions: 90%
// Lines: 82%

// 15-22% untested code = potential bugs in production
```

**Fundamental principle:** A component < 100% coverage is **incomplete, fragile and unvalidated**

**Solution:**
```typescript
// ✅ GOOD - 100% Coverage MANDATORY
// Coverage Report:
// Statements: 100% ✅
// Branches: 100% ✅
// Functions: 100% ✅
// Lines: 100% ✅

// All paths tested = Total confidence
```

**Why 100% and not 80%?**

**80% coverage = 20% untested code = 20% potential bugs**

1. **Complete validation:** 100% guarantees every line, branch and function has been executed and validated
2. **Total confidence:** No grey areas, no "maybe it works"
3. **Safe refactoring:** Modify code without fear of breaking something untested
4. **Professional quality:** A 100% tested component is a production-ready component
5. **Early detection:** Bugs are found during development, not in production
6. **Robust code:** 100% coverage forces testing all edge cases and error handling

**What 100% coverage reveals:**
- ✅ All code paths are validated
- ✅ All edge cases are tested
- ✅ All error handling is covered
- ✅ All conditional branches are exercised
- ✅ The component is complete and robust

**What < 100% coverage hides:**
- ❌ Untested branches (missing if/else)
- ❌ Ignored edge cases (null, undefined, empty)
- ❌ Unvalidated error handling (untested try/catch)
- ❌ Forgotten utility functions
- ❌ Potential dead code

**Justification:**
- Incomplete component if < 100%
- Fragile code with untested zones
- Production bugs on uncovered code
- Risky refactoring without complete tests
- Loss of confidence in the code

**Note:** Some tools suggest 80% as "acceptable", but in a professional quality context, 100% is the only standard that guarantees robust and validated code.

---

### **SMELL #16: useEffect Without Guard on Controlled State** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Guaranteed infinite loop
const [localState, setLocalState] = useState(propValue);

useEffect(() => {
    setLocalState(propValue);  // No guard!
}, [propValue]);

const handleChange = (newValue) => {
    setLocalState(newValue);
    onPropChange(newValue);  // Parent updates propValue → infinite loop!
};
```

**React Official Docs:** "Maximum update depth exceeded" error

**Loop sequence:**
1. `propValue` changes (external prop)
2. `useEffect` triggers → `setLocalState(propValue)`
3. Handler calls `onPropChange(newValue)`
4. Parent updates `propValue` prop
5. Back to step 1 → **INFINITE LOOP** 🔄

**Solution for primitives:**
```typescript
// ✅ GOOD - Guard for primitives (string, number, boolean)
useEffect(() => {
    if (localState !== propValue) {
        setLocalState(propValue);
    }
}, [propValue, localState]);
```

**Solution for arrays:**
```typescript
// ✅ GOOD - Guard for arrays with shallow compare
useEffect(() => {
    const arraysAreDifferent = 
        localArray.length !== propArray.length ||
        localArray.some((item, i) => item !== propArray[i]);
    
    if (arraysAreDifferent) {
        setLocalArray(propArray);
    }
}, [propArray, localArray]);
```

**Solution for objects:**
```typescript
// ✅ GOOD - Guard for objects with shallow compare
useEffect(() => {
    const keys = Object.keys(propObject);
    const objectsAreDifferent = 
        Object.keys(localObject).length !== keys.length ||
        keys.some(key => localObject[key] !== propObject[key]);
    
    if (objectsAreDifferent) {
        setLocalObject(propObject);
    }
}, [propObject, localObject]);
```

**Justification:**
- Avoids infinite loops in controlled states
- Recommended React pattern for parent-child sync
- Performance: avoids unnecessary re-renders
- Critical: Can crash the entire application

**Typical use case:**
- Controlled components with local state (input, select, etc.)
- Bidirectional parent ↔ child sync
- Props that can change from outside AND inside

**Real example (RankingQuestionAnswer):**
```typescript
// ❌ BEFORE - Infinite loop
useEffect(() => {
    setLocalRankedIds(rankedOptionIds);
}, [rankedOptionIds]);

// ✅ AFTER - Guard added
useEffect(() => {
    const arraysAreDifferent =
        localRankedIds.length !== rankedOptionIds.length ||
        localRankedIds.some((id, index) => id !== rankedOptionIds[index]);

    if (arraysAreDifferent) {
        setLocalRankedIds(rankedOptionIds);
    }
}, [rankedOptionIds, localRankedIds]);
```

---
