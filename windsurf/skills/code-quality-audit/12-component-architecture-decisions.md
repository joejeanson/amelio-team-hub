# Component Architecture - Decision Triggers

## Overview

This document defines **when** and **how** to extract code into separate files (utils, components, hooks) based on Amelio's architectural standards.

**Source**: Code review feedback and audit sessions  
**Status**: MANDATORY for all components

---

## 🎯 Decision Matrix

### 1. When to Extract Helper Functions to Utils

#### ✅ CREATE utils/ file when:

- **3+ utility functions** in the same component
- Each function is **>10 lines**
- Functions are **pure** (no side effects, no hooks)
- Functions are **reusable** across components
- Functions perform **calculations** or **formatting**

#### ❌ DO NOT create utils/ file when:

- Only 1-2 small functions (<5 lines each)
- Functions use hooks (useState, useEffect, etc.)
- Functions are specific to one component only
- Logic is tightly coupled to component state

#### 📝 Example from RankingQuestionResult

**BEFORE** (functions in component):
```typescript
// RankingQuestionResult.tsx
const getResponseLabel = (count: number, singular: string, plural: string) => {
    return count === 1 ? singular : plural;
};

const calculateBarHeightPercent = (value: number, maxYValue: number) => {
    return maxYValue > 0 ? (value / maxYValue) * 100 : 0;
};

const formatTooltipText = (percentage: number, count: number, label: string) => {
    return `${percentage}% (${count} ${label})`;
};
```

**AFTER** (extracted to utils):
```typescript
// utils/chartCalculations.ts
export const getResponseLabel = (count: number, singularLabel: string, pluralLabel: string): string => {
    const isSingular = count === 1;
    return isSingular ? singularLabel : pluralLabel;
};

export const calculateBarHeightPercent = (value: number, maxYValue: number): number => {
    const hasValidMaxValue = maxYValue > 0;
    if (!hasValidMaxValue) return 0;
    return (value / maxYValue) * 100;
};

export const formatTooltipText = (percentage: number, count: number, responseLabel: string): string => {
    return `${percentage}% (${count} ${responseLabel})`;
};
```

**Benefits**:
- ✅ Testable in isolation (100% coverage)
- ✅ Reusable across components
- ✅ Follows Single Responsibility Principle
- ✅ Component stays focused on rendering

---

### 2. When to Extract a Sub-Component

#### ✅ CREATE components/ subfolder when:

- **Repeated JSX** in `.map()` (>30 lines per iteration)
- **Complex rendering logic** with multiple conditionals
- **Reusable UI pattern** across the component
- **Tooltip/Modal/Popover** with dedicated logic
- **Independent state management** possible

#### ❌ DO NOT create sub-component when:

- JSX is <15 lines
- Logic is tightly coupled to parent state
- Only used once in the entire app
- No clear separation of concerns

#### ⚠️ CRITICAL: Single Responsibility Principle (SRP) for Sub-Components

**When extracting a sub-component, ALL related logic MUST be migrated to the child.**

The parent should pass **raw data**, the child should handle **calculations and transformations**.

**WHY?**
- Each component has ONE reason to change
- Better testability (test child in isolation)
- Better reusability (child is self-contained)
- Cleaner parent component (orchestration only)

#### 📝 Example from RankingQuestionResult

**BEFORE** (inline rendering):
```typescript
{barValues.map((barValue, index) => (
    <div className={'flex flex-col items-center'}>
        <div className={'relative flex h-[300px] w-16 items-end'}>
            <Tooltip delayDuration={200}>
                <TooltipTrigger asChild>
                    <div
                        className={'min-h-[3px] w-full cursor-pointer'}
                        style={{ height: `${barHeightPercent}%` }}
                        data-testid={`${dataTestId}-bar-hover-${index}`}
                    />
                </TooltipTrigger>
                <TooltipContent>
                    <span>{tooltipText}</span>
                </TooltipContent>
            </Tooltip>
        </div>
    </div>
))}
```

**AFTER** (extracted component - ❌ INCOMPLETE):
```typescript
// ❌ WRONG: Parent still calculates data for child
// components/RankingBar.tsx
export const RankingBar = ({ barHeightPercent, tooltipText, index, dataTestId }: RankingBarProps) => {
    return (
        <div className={'flex flex-col items-center'}>
            {/* Just rendering pre-calculated data */}
        </div>
    );
};

// ❌ WRONG: Parent calculates everything
{barValues.map((barValue, index) => {
    const responseLabel = getResponseLabel(...);   // ❌ Should be in child
    const tooltipText = formatTooltipText(...);    // ❌ Should be in child
    const barHeightPercent = calculateBarHeight(...); // ❌ Should be in child
    
    return <RankingBar barHeightPercent={barHeightPercent} tooltipText={tooltipText} />;
})}
```

**AFTER** (extracted component - ✅ CORRECT with SRP):
```typescript
// ✅ CORRECT: Child is AUTONOMOUS - handles its own calculations
// components/RankingBar.tsx
export interface RankingBarProps {
    barValue: BarChartValue;           // Raw data
    originalOption: RankingOptionAnswer; // Raw data
    maxYValue: number;                 // Config
    index: number;
    dataTestId: string;
}

export const RankingBar = ({ 
    barValue, 
    originalOption, 
    maxYValue, 
    index, 
    dataTestId 
}: RankingBarProps) => {
    const { t } = useAmelioTranslations();
    
    // ✅ Child calculates its OWN data (SRP)
    const responseLabel = getResponseLabel({
        count: originalOption.count,
        singularLabel: t('common.response'),
        pluralLabel: t('common.responses'),
    });
    
    const tooltipText = formatTooltipText({
        percentage: barValue.value,
        count: originalOption.count,
        responseLabel,
    });
    
    const barHeightPercent = calculateBarHeightPercent({
        value: barValue.value,
        maxYValue,
    });
    
    return (
        <div className={'flex flex-col items-center'}>
            <Tooltip delayDuration={200}>
                <TooltipTrigger asChild>
                    <div
                        style={{ height: `${barHeightPercent}%` }}
                        data-testid={`${dataTestId}-bar-hover-${index}`}
                    />
                </TooltipTrigger>
                <TooltipContent>
                    <span>{tooltipText}</span>
                </TooltipContent>
            </Tooltip>
        </div>
    );
};

// ✅ CORRECT: Parent passes RAW DATA only
{barValues.map((barValue, index) => {
    const originalOption = options.find((opt) => opt.label === barValue.label);
    if (!originalOption) return null;
    
    return (
        <RankingBar
            key={index}
            barValue={barValue}           // Raw data
            originalOption={originalOption} // Raw data
            maxYValue={yAxisConfig.maxYValue}
            index={index}
            dataTestId={dataTestId}
        />
    );
})}
```

**Benefits**:
- ✅ **SRP Respected**: Child has ONE reason to change (bar rendering + its calculations)
- ✅ **Testable in isolation**: Can test child with mock raw data
- ✅ **Reusable**: Child is self-contained, usable anywhere
- ✅ **Cleaner parent**: Only orchestration, no business logic
- ✅ **Better maintainability**: Change calculation? Edit child only

---

### 3. When to Extract a Custom Hook

#### ✅ CREATE hooks/ file when:

- **Logic with refs/state** (>15 lines)
- **Side effects** (useEffect) not directly related to rendering
- **Reusable stateful logic** across components
- **Complex event handlers** with multiple refs
- **Synchronization logic** between elements

#### ❌ DO NOT create custom hook when:

- Logic is <10 lines
- Only used once in the entire app
- Tightly coupled to specific component structure
- No state or refs involved (use utils instead)

#### 📝 Example from RankingQuestionResult

**BEFORE** (inline logic):
```typescript
const RankingQuestionResult = ({ options }: Props) => {
    const chartContainerRef = useRef<HTMLDivElement>(null);
    const tooltipOverlayRef = useRef<HTMLDivElement>(null);

    const handleTooltipScroll = () => {
        if (chartContainerRef.current && tooltipOverlayRef.current) {
            const barChartScrollContainer = chartContainerRef.current.querySelector('.overflow-x-auto');
            if (barChartScrollContainer) {
                barChartScrollContainer.scrollLeft = tooltipOverlayRef.current.scrollLeft;
            }
        }
    };

    return (
        <div ref={chartContainerRef}>
            <BarChart />
            <div ref={tooltipOverlayRef} onScroll={handleTooltipScroll}>
                {/* content */}
            </div>
        </div>
    );
};
```

**AFTER** (extracted hook):
```typescript
// hooks/useScrollSync.ts
export const useScrollSync = () => {
    const chartContainerRef = useRef<HTMLDivElement>(null);
    const tooltipOverlayRef = useRef<HTMLDivElement>(null);

    const handleTooltipScroll = () => {
        if (!chartContainerRef.current || !tooltipOverlayRef.current) return;
        
        const barChartScrollContainer = chartContainerRef.current.querySelector('.overflow-x-auto');
        if (barChartScrollContainer) {
            barChartScrollContainer.scrollLeft = tooltipOverlayRef.current.scrollLeft;
        }
    };

    return { chartContainerRef, tooltipOverlayRef, handleTooltipScroll };
};

// Component
const RankingQuestionResult = ({ options }: Props) => {
    const { chartContainerRef, tooltipOverlayRef, handleTooltipScroll } = useScrollSync();

    return (
        <div ref={chartContainerRef}>
            <BarChart />
            <div ref={tooltipOverlayRef} onScroll={handleTooltipScroll}>
                {/* content */}
            </div>
        </div>
    );
};
```

**Benefits**:
- ✅ Testable in isolation (100% coverage)
- ✅ Reusable across components
- ✅ Follows React hooks best practices
- ✅ Component stays focused on rendering

---

### 4. When to Extract Magic Numbers/Strings

#### ✅ CREATE constant when:

- **Value repeated 2+ times** in the same file
- **Value repeated across files** (use shared constants file)
- **Hardcoded dimensions** (width, height, padding)
- **Configuration values** (delays, limits, thresholds)

#### ❌ DO NOT create constant when:

- Value used only once
- Value is dynamic (calculated from props/state)
- Value is self-explanatory in context

#### 📝 Example from RankingQuestionResult

**BEFORE** (magic number):
```typescript
<div className={'relative flex h-[300px] w-16 items-end'}>
    {/* ... */}
</div>

<div className={'relative flex h-[300px] flex-col'}>
    {/* ... */}
</div>
```

**AFTER** (extracted constant):
```typescript
const CHART_HEIGHT_PX = 300;

<div className={'relative flex w-16 items-end'} style={{ height: `${CHART_HEIGHT_PX}px` }}>
    {/* ... */}
</div>

<div className={'relative flex flex-col'} style={{ height: `${CHART_HEIGHT_PX}px` }}>
    {/* ... */}
</div>
```

**Benefits**:
- ✅ Single source of truth
- ✅ Easy to update globally
- ✅ Self-documenting code
- ✅ Avoids inconsistencies

---

## 📁 Folder Structure Guidelines

### Recommended Structure

```
ComponentName/
├── ComponentName.tsx          # Main component
├── ComponentName.test.tsx     # Main component tests
├── components/                # Sub-components (if needed)
│   ├── SubComponent.tsx
│   └── SubComponent.test.tsx
├── hooks/                     # Custom hooks (if needed)
│   ├── useCustomHook.ts
│   └── useCustomHook.test.ts
└── utils/                     # Utility functions (if needed)
    ├── helpers.ts
    └── helpers.test.ts
```

### When to Create Subfolders

- **components/**: 2+ sub-components
- **hooks/**: 2+ custom hooks
- **utils/**: 3+ utility functions OR 1 file with 5+ functions

### When NOT to Create Subfolders

- Only 1 sub-component → Keep in same file or parent folder
- Only 1 small hook → Keep inline in component
- Only 1-2 small utils → Keep inline in component

---

## ✅ Validation Checklist

Before extracting code, ask yourself:

### For Utils Functions:
- [ ] Is it pure (no hooks, no side effects)?
- [ ] Is it >10 lines?
- [ ] Is it used 2+ times OR reusable?
- [ ] Can it be tested in isolation?

### For Sub-Components:
- [ ] Is the JSX >30 lines?
- [ ] Is it repeated in `.map()`?
- [ ] Can it have its own props interface?
- [ ] Can it be tested in isolation?

### For Custom Hooks:
- [ ] Does it use refs or state?
- [ ] Is it >15 lines?
- [ ] Is the logic reusable?
- [ ] Can it be tested in isolation?

### For Constants:
- [ ] Is the value repeated 2+ times?
- [ ] Is it a magic number/string?
- [ ] Would extraction improve readability?

---

## 🚫 Anti-Patterns to Avoid

### ❌ Over-Engineering

```typescript
// BAD: Creating utils for trivial logic
export const addOne = (n: number) => n + 1;
export const isTrue = (value: boolean) => value === true;
```

### ❌ Premature Extraction

```typescript
// BAD: Extracting before knowing if it's reusable
// Wait until you have 2+ use cases
```

### ❌ Tight Coupling

```typescript
// BAD: Hook depends on specific component structure
export const useSpecificComponentLogic = (parentState: ComplexState) => {
    // Logic too coupled to parent
};
```

### ❌ Incomplete Extraction

```typescript
// BAD: Extracting component but keeping logic in parent
const SubComponent = ({ onClick }: Props) => <button onClick={onClick}>Click</button>;

// Parent still has all the logic
const handleClick = () => { /* complex logic */ };
```

---

## 📚 Related Standards

- **29 TypeScript Criteria**: See `01-typescript-29-criteria.md`
- **Testing Patterns**: See `03-testing-patterns.md`
- **Clean Code Principles**: See `09-smelly-code-19-principles.md`
- **Component Guidelines**: See `11-component-guidelines.md`

---

## 🎯 Summary

| Scenario | Trigger | Action | Location |
|----------|---------|--------|----------|
| **3+ utility functions** | >10 lines each, pure | Extract to utils | `utils/helpers.ts` |
| **Repeated JSX in .map()** | >30 lines per iteration | Extract component | `components/SubComponent.tsx` |
| **Logic with refs/state** | >15 lines, reusable | Extract hook | `hooks/useCustomHook.ts` |
| **Repeated value** | 2+ occurrences | Extract constant | Top of component file |
| **Import disorder** | Any file | Fix order | External → @/ → Type → Relative |

**Remember**: Extract when it improves **testability**, **reusability**, and **maintainability**. Don't extract for the sake of extracting.
