# 📘 TypeScript Criteria 25-29

> Continuation of [Criteria 16-24](./01b-typescript-criteria-16-24.md) | Next: [Criteria 30-32](./01d-typescript-criteria-30-32.md)

---

## ✅ 25. Use Color Constants from UI Library

### ❌ Avoid
```typescript
// Hard-coded hex colors
const gradient = 'linear-gradient(to right, #F02F42, #F8863F, #F7D23E)';
<Icon color="#10CFBD" />
<div style={{ background: '#7B68EE' }} />
```

### ✅ Prefer
```typescript
import { Colors } from '@amelio/ui-library';

// Use Colors constants - single source of truth
const gradient = `linear-gradient(to right, ${Colors.CHART_RED}, ${Colors.CHART_ORANGE}, ${Colors.CHART_YELLOW})`;
<Icon color={Colors.PRIMARY} />
<div style={{ background: Colors.SECONDARY }} />
```

### 🤔 Why
- **Single source of truth**: All colors defined in `@amelio/ui-library/src/index.css`
- **Type safety**: `ColorType` ensures only valid colors are used
- **Consistency**: Same colors across all components
- **Maintainability**: Update colors in one place, changes propagate everywhere
- **Design system**: Enforces adherence to Figma design tokens

### 📖 Reference
See [02-color-system.md](./02-color-system.md) for complete color system documentation.

---

## ✅ 26. Use useMemo Only for Expensive Calculations

### ❌ Avoid
```typescript
// useMemo for simple, fast calculations (<0.01ms)
const maxValue = useMemo(() => {
    return maxYValue || Math.max(...yValues, ...values.map((v) => v.value));
}, [maxYValue, yValues, values]);

// useMemo for simple loops
const scaleValues = useMemo(() => {
    const values: number[] = [];
    for (let i = minValue; i <= maxValue; i++) {
        values.push(i);
    }
    return values;
}, [minValue, maxValue]);
```

### ✅ Prefer
```typescript
// Direct calculation for fast operations
const maxValue = maxYValue || Math.max(...yValues, ...values.map((v) => v.value));

// Simple loop without useMemo
const scaleValues: number[] = [];
for (let i = minValue; i <= maxValue; i++) {
    scaleValues.push(i);
}
```

### 🤔 Why
- useMemo has a cost (dependency comparison, cache management)
- For fast calculations (<1ms), cost of useMemo > benefit
- "You should only rely on useMemo as a performance optimization" - React docs
- "useMemo won't make the first render faster" - React docs

### When to use useMemo:
1. ✅ **Truly expensive** calculations (>1ms, measurable with `console.time`)
2. ✅ Value passed to a component wrapped in `memo`
3. ✅ Value used as a dependency in another Hook (useEffect, useMemo, useCallback)

### When NOT to use useMemo:
- ❌ Simple calculations: `Math.max()`, `Math.min()`, `.map()` on small arrays
- ❌ Simple loops (few iterations)
- ❌ String operations: `.split()`, `.join()`, template literals
- ❌ Object property access
- ❌ "Premature optimization"

### 📏 How to measure:
```typescript
console.time('calculation');
const result = expensiveCalculation();
console.timeEnd('calculation');
// If < 1ms, useMemo probably not needed
```

### 🎯 Rule of thumb:
**"Measure first, optimize later"**
- Write simple code first (without useMemo)
- Profile with React DevTools if performance is problematic
- Add useMemo only if measurement proves the benefit

---

## ✅ 27. Prefer Tailwind CSS Over Inline Styles

### 🎯 MAIN RULE (READ FIRST)
**"If it's STATIC (fixed value in code) → Use TAILWIND"**  
**"If it's DYNAMIC (props, state, calculation) → Use INLINE STYLES"**

---

### ❌ FORBIDDEN - Inline styles for static values
```typescript
// ❌ BAD - Fixed values in inline styles
<div style={{ height: '300px' }}>
<div style={{ overflow: 'auto', maxWidth: '100%', paddingBottom: '10px' }}>
<div style={{ width: '64px' }}>

// ❌ BAD - Static gradient in inline style
<div style={{ 
    background: 'linear-gradient(to bottom, rgba(126, 64, 251, 0.15) 0%, rgba(255, 207, 206, 0.3) 100%)'
}}>
```

### ✅ MANDATORY - Tailwind for static values
```typescript
// ✅ GOOD - Fixed values in Tailwind
<div className={'h-[300px]'}>
<div className={'max-w-full overflow-auto pb-2.5'}>
<div className={'w-16'}>

// ✅ GOOD - Static gradient in Tailwind
<div className={'bg-gradient-to-b from-[rgba(126,64,251,0.15)] to-[rgba(255,207,206,0.3)]'}>
```

### ✅ ALLOWED EXCEPTION - Inline styles for dynamic values
```typescript
// ✅ GOOD - Calculated/props/state values in inline styles
<div style={{ minWidth: `${containerMinWidth}px` }}>           // Variable
<div style={{ height: `${percentage}%` }}>                     // Calculation
<div style={{ backgroundColor: dynamicColor }}>                // Prop
<div style={{ transform: `translateX(${position}px)` }}>       // State
```

---

### 🔍 HOW TO IDENTIFY STATIC VS DYNAMIC?

#### ✅ STATIC = Tailwind MANDATORY
- Value written directly in code (hardcoded)
- No `${}`, no variables, no props
- Gradient with fixed colors
- Fixed dimensions (300px, 100%, etc.)
- Fixed colors (#fff, rgba(0,0,0,0.5), etc.)

**STATIC Examples:**
```typescript
// ✅ All in Tailwind
<div className={'h-[300px]'}>                                  // Fixed height
<div className={'bg-[#10CFBD]'}>                               // Fixed color
<div className={'bg-gradient-to-r from-purple-500 to-pink-500'}> // Fixed gradient
<div className={'w-full max-w-4xl'}>                           // Fixed width
```

#### ✅ DYNAMIC = Inline styles ALLOWED
- Uses `${}` with variable/prop/state
- Calculated or conditional value
- Changes based on user interaction

**DYNAMIC Examples:**
```typescript
// ✅ All in inline styles
<div style={{ width: `${width}px` }}>                          // Variable
<div style={{ backgroundColor: isActive ? '#fff' : '#000' }}>  // Conditional
<div style={{ transform: `rotate(${angle}deg)` }}>             // Calculation
<div style={{ opacity: loading ? 0.5 : 1 }}>                   // State
```

---

### 🤔 Why Tailwind First?
- **Consistency**: Unified design system
- **Performance**: Optimized and purged classes in production
- **Maintainability**: Easier to scan and modify
- **Type safety**: Classes validated at build time
- **Responsive design**: Modifiers (`md:`, `lg:`) only work with classes
- **Developer experience**: Better autocomplete and IntelliSense

---

### 📋 CHECKLIST BEFORE CHOOSING

**Ask yourself this question:**
> "Can this value change based on a prop, state, or calculation?"

- **NO** → The value is STATIC → **Use Tailwind** ✅
- **YES** → The value is DYNAMIC → **Use inline styles** ✅

**Decision examples:**

| Code | Static or Dynamic? | Solution |
|------|-------------------|----------|
| `height: '300px'` | STATIC (fixed value) | ✅ `className={'h-[300px]'}` |
| `height: ${height}px` | DYNAMIC (variable) | ✅ `style={{ height: \`${height}px\` }}` |
| `background: 'linear-gradient(...)'` | STATIC (fixed gradient) | ✅ `className={'bg-gradient-to-b from-[...] to-[...]'}` |
| `background: gradientFromProp` | DYNAMIC (prop) | ✅ `style={{ background: gradientFromProp }}` |
| `width: '100%'` | STATIC (fixed value) | ✅ `className={'w-full'}` |
| `width: ${percent}%` | DYNAMIC (calculation) | ✅ `style={{ width: \`${percent}%\` }}` |

---

### ⚠️ SPECIAL CASE: Gradients

**Gradient with FIXED colors → Tailwind MANDATORY**
```typescript
// ✅ GOOD - Static gradient
<div className={'bg-gradient-to-b from-purple-500 to-pink-500'}>
<div className={'bg-gradient-to-r from-[rgba(126,64,251,0.15)] to-[rgba(255,207,206,0.3)]'}>
```

**Gradient with DYNAMIC colors → Inline styles ALLOWED**
```typescript
// ✅ GOOD - Dynamic gradient
<div style={{ background: `linear-gradient(to bottom, ${startColor}, ${endColor})` }}>
<div style={{ background: gradientFromProps }}>
```

---

## ✅ 28. Always Include dataTestId for Component Testing

### ❌ Avoid
```typescript
// Component without dataTestId
export interface ButtonProps {
    label: string;
    onClick: () => void;
    disabled?: boolean;
}

export const Button = ({ label, onClick, disabled }: ButtonProps) => {
    return (
        <button onClick={onClick} disabled={disabled}>
            {label}
        </button>
    );
};
```

### ✅ Prefer
```typescript
// Component with dataTestId prop
export interface ButtonProps {
    label: string;
    onClick: () => void;
    disabled?: boolean;
    /** Test ID for querying the button in tests */
    dataTestId?: string;
}

export const Button = ({ label, onClick, disabled, dataTestId }: ButtonProps) => {
    return (
        <button 
            onClick={onClick} 
            disabled={disabled}
            data-testid={dataTestId}
        >
            {label}
        </button>
    );
};
```

### 🎯 Pattern with Suffix Propagation
```typescript
// Parent component propagates dataTestId to children with suffixes
export const List = ({ items, dataTestId }: ListProps) => {
    return (
        <ul data-testid={dataTestId}>
            {items.map((item, index) => (
                <ListItem
                    key={item.id}
                    item={item}
                    dataTestId={dataTestId ? `${dataTestId}-item-${index}` : undefined}
                />
            ))}
        </ul>
    );
};
```

### 🤔 Why
- **Test resilience**: Tests won't break from CSS or JS changes
- **Clear intent**: Makes it obvious which elements are used in tests
- **Stable selectors**: Independent of styling or behavior changes
- **Team standard**: Consistent with amelio-ui-library components
- **Best practice**: Recommended by Testing Library and Cypress documentation

### 📖 When to use dataTestId:
1. ✅ All reusable components (buttons, inputs, modals, etc.)
2. ✅ Interactive elements (clickable, focusable)
3. ✅ Elements queried in unit tests
4. ✅ Complex components with multiple child elements
5. ✅ Lists and repeated elements (with index suffix)

### 📖 Naming Convention:
- **Simple components**: `dataTestId="submit-button"`
- **With suffixes**: `dataTestId="user-list-item-0"`
- **Nested elements**: `dataTestId="modal-close-button"`
- **Kebab-case**: Always use lowercase with hyphens

### 📖 Testing Usage:
```typescript
// Vitest + Testing Library
import { render, screen } from '@testing-library/react';

it('renders button with dataTestId', () => {
    render(<Button label="Submit" dataTestId="submit-btn" />);
    expect(screen.getByTestId('submit-btn')).toBeInTheDocument();
});

// Cypress (if used in future)
cy.get('[data-testid="submit-btn"]').click();
```

### 🎯 Rule of thumb:
**"Every interactive component should accept an optional dataTestId prop and pass it to data-testid attribute."**

### 📚 References (dataTestId):
- [Testing Library - ByTestId](https://testing-library.com/docs/queries/bytestid/)
- [Cypress Best Practices](https://docs.cypress.io/guides/references/best-practices)
- [Amelio UI Library Examples](../../Amelio_FullStack/amelio-ui-library/src/components/)

---

## ✅ 29. Use `void` for Callback Types, Not Function Implementations

### ❌ Avoid
```typescript
// ❌ Redundant void in function implementation (TypeScript infers it)
const handleClick = (): void => {
    console.log('clicked');
};

function processData(): void {
    // Do something
    return;
}

// ❌ Missing void in interface/type definition
interface Props {
    onClick: () => {};  // Wrong - this is an empty object type, not "no return"
    onSave: Function;   // Too generic
}
```

### ✅ Prefer
```typescript
// ✅ void in interface/type definitions (REQUIRED)
interface Props {
    onClick: () => void;
    onSave: (data: FormData) => void;
    onChange: (value: string) => void;
}

// ✅ No void in function implementations (TypeScript infers it)
const handleClick = () => {
    console.log('clicked');
};

function processData() {
    // Do something
    return;
}

// ✅ But if you want to be explicit in implementations, it's acceptable
const handleSave = (): void => {
    saveData();
};
```

### 🤔 Why

**In Interfaces/Types (REQUIRED):**
- `void` explicitly states "this callback returns nothing useful"
- Without `void`, TypeScript may infer wrong types (e.g., `{}` is an empty object, not "no return")
- Provides clear contract for consumers of the interface

**In Function Implementations (OPTIONAL/REDUNDANT):**
- TypeScript automatically infers `void` when function has no return statement
- Adding `: void` is redundant noise according to community best practices
- ESLint rule `explicit-function-return-type` has `allowTypedFunctionExpressions: true` by default
- Reduces visual clutter in code

### 📏 Rule of thumb

```typescript
// ✅ ALWAYS use void in types/interfaces
type Callback = () => void;
interface Props {
    onEvent: () => void;
}

// ✅ OMIT void in implementations (let TypeScript infer)
const callback = () => {
    doSomething();
};

// ⚠️ OPTIONAL: Explicit void in implementations (acceptable but redundant)
const callback = (): void => {
    doSomething();
};
```

### � Special case: `void` allows return values to be ignored

```typescript
// This is why void is powerful in callback types
type Callback = () => void;

// ✅ This works - void ignores the return value
const myCallback: Callback = () => {
    return 42;  // OK - void ignores this
};

// vs. undefined would be strict
type StrictCallback = () => undefined;
const strictCallback: StrictCallback = () => {
    return 42;  // ❌ ERROR - expects undefined
};
```

### 🎯 Summary

| Context | Use `void`? | Reason |
|---------|-------------|--------|
| Interface/Type callback | ✅ **REQUIRED** | Explicit contract, prevents wrong types |
| Function implementation | ❌ **OMIT** (or ⚠️ optional) | TypeScript infers it, reduces noise |
| Explicit documentation | ⚠️ **OPTIONAL** | Acceptable if team prefers explicit types |

### 📚 References (void):
- [TypeScript Handbook - void](https://www.typescriptlang.org/docs/handbook/2/functions.html#void)
- [typescript-eslint - explicit-function-return-type](https://typescript-eslint.io/rules/explicit-function-return-type/)
- Community consensus: Explicit in types, inferred in implementations

---

