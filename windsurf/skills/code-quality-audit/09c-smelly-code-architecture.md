# 🔍 Smelly Code Architecture - Smells 17-19

> Continuation of [Smelly Code Patterns](./09b-smelly-code-patterns.md) | Next: [Checklist & Reference](./09d-smelly-code-checklist.md)

---

### **SMELL #17: Component Width Constraints** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Component imposes its own width
export const MyComponent = ({ title }: Props) => {
    return (
        <div className={'w-[600px] max-w-2xl'}>  // Fixed width!
            <h1>{title}</h1>
        </div>
    );
};

// ❌ BAD - Width in inline styles
export const MyCard = ({ children }: Props) => {
    return (
        <div style={{ width: '400px', maxWidth: '100%' }}>  // Fixed width!
            {children}
        </div>
    );
};
```

**Fundamental Amelio principle:** The **parent ALWAYS controls the width** of child components

**Solution:**
```typescript
// ✅ GOOD - Full width component, parent controls
export const MyComponent = ({ title, className = '' }: Props) => {
    return (
        <div className={`space-y-4 ${className}`}>  // No width constraint
            <h1>{title}</h1>
        </div>
    );
};

// Usage - Parent decides the width
<div className={'w-[600px]'}>
    <MyComponent title="Hello" />
</div>

// OR
<div className={'max-w-2xl mx-auto'}>
    <MyComponent title="Hello" />
</div>
```

**Pattern Amelio UI Library:**
```typescript
// All UI Library components follow this pattern
export const Button = ({ children, className = '' }: Props) => {
    const baseClasses = 'inline-flex items-center justify-center ...';
    return (
        <button className={`${baseClasses} ${className}`}>  // No width
            {children}
        </button>
    );
};

export const Card = ({ children, className = '' }: Props) => {
    return (
        <div className={`border rounded-lg p-6 ${className}`}>  // No width
            {children}
        </div>
    );
};
```

**Justification:**
- **Maximum reusability:** Component usable in any context
- **Flexibility:** Parent decides based on its layout (sidebar, modal, full width page)
- **Responsive design:** Parent manages breakpoints (`w-full md:w-1/2 lg:w-1/3`)
- **Composition:** Allows nesting without width conflicts
- **Amelio standard:** All UI Library components follow this principle

**RARE exceptions (must be documented):**
```typescript
// ✅ ACCEPTABLE - Minimum width for UX (dropdowns, modals)
export const Dropdown = ({ children }: Props) => {
    return (
        <div className={'min-w-48'}>  // min-width OK, not fixed width
            {children}
        </div>
    );
};

// ✅ ACCEPTABLE - Components with intrinsic constraints
export const Icon = ({ name, size = 'md' }: Props) => {
    const sizeClasses = {
        sm: 'w-4 h-4',   // Icon = fixed dimensions OK
        md: 'w-6 h-6',
        lg: 'w-8 h-8',
    };
    return <svg className={sizeClasses[size]} />;
};
```

**Storybook:**
```typescript
// ✅ GOOD - Wrapper for demo only
export const Default: Story = {
    render: (args) => (
        <div className={'max-w-2xl'}>  // Wrapper Storybook
            <MyComponent {...args} />   // Component without width
        </div>
    ),
};

// ❌ BAD - Width in the component itself
export const MyComponent = () => {
    return <div className={'max-w-2xl'}>...</div>;  // No!
};
```

**Checklist before PR:**
- ❌ No `w-[value]` in the component (except Icon/Avatar)
- ❌ No `max-w-*` in the component (except documented exceptions)
- ❌ No `min-w-*` in the component (except dropdowns/modals)
- ❌ No `width:` in inline styles
- ✅ `className` prop accepted and applied
- ✅ Component adapts to parent width
- ✅ Storybook uses wrappers for demo

**Real example (RankingQuestionAnswer):**
```typescript
// ✅ CORRECT - No width constraint
return (
    <div className={`space-y-4 ${className}`}>  // Parent controls
        {titleComponent && <Text>{titleComponent}</Text>}
        {/* ... */}
    </div>
);

// Usage in a page
<div className={'max-w-4xl mx-auto'}>  // Page decides
    <RankingQuestionAnswer {...props} />
</div>
```

---

### **SMELL #18: Complex Business Logic in Components** ⚠️ IMPORTANT

**Problem:**
```typescript
// ❌ BAD - Complex business logic in the component (254 lines)
const RankingQuestionResult = ({ options }: Props) => {
    // 60+ lines of complex mathematical calculations
    const maxCount = useMemo(() => {
        return Math.max(...options.map((option) => option.count), 0);
    }, [options]);

    const percentages = useMemo(() => {
        return options.map((option) =>
            maxCount > 0 ? Math.round((option.count / maxCount) * 100) : 0,
        );
    }, [options, maxCount]);

    const yAxisConfig = useMemo(() => {
        const hasNoData = percentages.length === 0;
        if (hasNoData) {
            return { yValues: DEFAULT_Y_AXIS_VALUES, maxYValue: MAX_PERCENTAGE };
        }
        
        const validPercentages = percentages.filter((p) => p >= 0);
        const minPercentage = Math.min(...validPercentages);
        const maxPercentage = Math.max(...validPercentages);
        
        const minYValue = calculateAxisTicks(minPercentage, MIN_PERCENTAGE, true, 15);
        const maxYValue = calculateAxisTicks(maxPercentage, MAX_PERCENTAGE, false, 15);
        const yValues = generateYAxisValues(minYValue, maxYValue);
        
        return { yValues, maxYValue };
    }, [percentages]);

    const barValues = useMemo(() => {
        // 20+ lines of complex transformation and sorting
        const sortedIndices = percentages
            .map((percentage, index) => ({ percentage, index }))
            .sort((a, b) => a.percentage - b.percentage)
            .map((item) => item.index);
            
        return sortedIndices.map((originalIndex, displayIndex) => {
            // Complex mapping logic
        });
    }, [options, percentages]);

    // 100+ lines of JSX
    return <div>...</div>;
};
```

**Clean Code Principle:** Separation of Concerns - Separate business logic from presentation

**Solution - Extract into a Custom Hook:**
```typescript
// ✅ GOOD - Logic extracted into hooks/useRankingChartData.ts
export const useRankingChartData = (options: RankingOptionAnswer[]) => {
    const maxCount = useMemo(() => {
        return Math.max(...options.map((option) => option.count), 0);
    }, [options]);

    const percentages = useMemo(() => {
        return options.map((option) =>
            maxCount > 0 ? Math.round((option.count / maxCount) * 100) : 0,
        );
    }, [options, maxCount]);

    const yAxisConfig = useMemo(() => {
        // All Y-axis calculation logic
    }, [percentages]);

    const barValues = useMemo(() => {
        // All transformation logic
    }, [options, percentages]);

    return { barValues, yAxisConfig, hasNoOptions: options.length === 0 };
};

// Simplified component (149 lines - 41% reduction)
const RankingQuestionResult = ({ options }: Props) => {
    const { t } = useAmelioTranslations();
    const { barValues, yAxisConfig, hasNoOptions } = useRankingChartData(options);

    if (hasNoOptions) {
        return <EmptyState />;
    }

    return <ChartPresentation barValues={barValues} yAxisConfig={yAxisConfig} />;
};
```

**Solution - Extract Utility Functions:**
```typescript
// ✅ GOOD - Pure functions in utils/chartCalculations.ts
/**
 * Calculate axis tick values with padding
 */
export const calculateAxisTicks = (
    value: number,
    range: number,
    isMin: boolean,
    defaultExtraTicks: number = 15,
): number => {
    if (isMin) {
        return value - defaultExtraTicks <= range ? range : value - defaultExtraTicks;
    }
    return value + defaultExtraTicks >= range ? range : value + defaultExtraTicks;
};

/**
 * Generate Y-axis values with equal spacing
 */
export const generateYAxisValues = (minValue: number, maxValue: number): number[] => {
    const TICK_COUNT = 7;
    const range = maxValue - minValue;
    const step = range / (TICK_COUNT - 1);
    const values: number[] = [];

    for (let i = 0; i < TICK_COUNT; i++) {
        values.push(Math.round(minValue + step * i));
    }

    return values;
};
```

**When to extract logic:**

1. **Complex mathematical calculations** (>20 lines)
   - Calculation algorithms
   - Data transformations
   - Statistical aggregations

2. **Reusable business logic**
   - Can be used elsewhere in the application
   - Independently testable
   - Not coupled to rendering

3. **Component >200 lines with logic**
   - Logic + JSX mixed together
   - Multiple useMemo/useCallback
   - Difficult to understand at a glance

**Recommended structure:**
```
ComponentName/
├── ComponentName.tsx (presentation only)
├── ComponentName.test.tsx
├── hooks/
│   └── useComponentData.ts (business logic)
└── utils/
    └── calculations.ts (pure functions)
```

**Benefits:**
- ✅ **Separation of concerns** - Logic vs Presentation
- ✅ **Testability** - Hook and utils independently testable
- ✅ **Reusability** - Hook usable elsewhere if needed
- ✅ **Maintainability** - Simpler code to understand
- ✅ **Readability** - Component focused on rendering

**Justification:**
- Shorter and focused component (<150 lines)
- Isolated and testable business logic
- Reusable utility functions
- Respects the Single Responsibility principle
- Facilitates future modifications

**Real example (RankingQuestionResult):**

**Before:** 254 lines (logic + presentation mixed)
**After:** 149 lines component + 108 lines hook + 38 lines utils = **41% reduction**

---

### **SMELL #19: Sub-Component SRP Violation** ⚠️ CRITICAL

**Problem:**
```typescript
// ❌ BAD - Parent calculates data for the child
{barValues.map((barValue, index) => {
    // Parent does ALL the calculations
    const responseLabel = getResponseLabel(...);   // ❌ Should be in child
    const tooltipText = formatTooltipText(...);    // ❌ Should be in child
    const barHeightPercent = calculateBarHeight(...); // ❌ Should be in child
    
    return (
        <RankingBar
            barHeightPercent={barHeightPercent}  // Pre-calculated data
            tooltipText={tooltipText}            // Pre-calculated data
        />
    );
})}
```

**Single Responsibility Principle:** Each component is responsible for ITS OWN data transformations

**Solution:**
```typescript
// ✅ GOOD - Child receives RAW data and calculates itself
// components/RankingBar.tsx
export const RankingBar = ({ 
    barValue,        // Raw data
    originalOption,  // Raw data
    maxYValue,       // Config
    index, 
    dataTestId 
}: RankingBarProps) => {
    const { t } = useAmelioTranslations();
    
    // ✅ Child calculates ITS OWN data (SRP)
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
            {/* Rendering with calculated data */}
        </div>
    );
};

// Parent passes ONLY raw data
{barValues.map((barValue, index) => {
    const originalOption = options.find((opt) => opt.label === barValue.label);
    if (!originalOption) return null;
    
    return (
        <RankingBar
            key={index}
            barValue={barValue}           // ✅ Raw data
            originalOption={originalOption} // ✅ Raw data
            maxYValue={yAxisConfig.maxYValue}
            index={index}
            dataTestId={dataTestId}
        />
    );
})}
```

**Justification:**
- **SRP Respected**: Child has ONE single reason to change
- **Testability**: Test the child with raw mock data
- **Reusability**: Self-sufficient child, usable anywhere
- **Maintainability**: Need to change a calculation? Modify only the child
- **Clean Parent**: The parent only does orchestration

**Golden rule:**
> "Parent = raw data + orchestration"
> "Child = calculations + transformations + rendering"

---
