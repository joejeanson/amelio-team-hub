# ⚛️ Hooks React - Patterns & Best Practices

> **Standards for using React hooks in Amelio projects**

---

## 📋 Hook Order (MANDATORY)

### Rule 18: Hook Organization

Hooks must ALWAYS be defined in this order:

```typescript
export const Component = ({ prop1, prop2 }: Props) => {
    // 1. useState
    const [state, setState] = useState<string>('');
    const [count, setCount] = useState<number>(0);

    // 2. useRef
    const inputRef = useRef<HTMLInputElement>(null);
    const previousValue = useRef<string>('');

    // 3. useContext
    const theme = useContext(ThemeContext);

    // 4. useReducer
    const [state, dispatch] = useReducer(reducer, initialState);

    // 5. useCallback / useMemo
    const handleClick = useCallback(() => {
        // Logic
    }, [dependencies]);

    const computedValue = useMemo(() => {
        return expensiveCalculation();
    }, [dependencies]);

    // 6. useEffect (AFTER all other hooks)
    useEffect(() => {
        // Side effects
    }, [dependencies]);

    // 7. Custom hooks
    const { data, loading } = useCustomHook();

    return (/* JSX */);
};
```

---

## 🎯 Critical Rule: Functions Before useEffect

### ❌ WRONG (Violation Rule #21)
```typescript
export const Component = ({ value }: Props) => {
    // ❌ useEffect uses processValue BEFORE its definition
    useEffect(() => {
        processValue(value);  // Function not yet defined!
    }, [value]);

    // Function defined AFTER
    const processValue = (val: string) => {
        // Logic
    };

    return <div>{value}</div>;
};
```

### ✅ CORRECT
```typescript
export const Component = ({ value }: Props) => {
    // ✅ Function defined BEFORE useEffect
    const processValue = useCallback((val: string) => {
        // Logic
    }, []);

    // useEffect uses the function defined above
    useEffect(() => {
        processValue(value);
    }, [value, processValue]);

    return <div>{value}</div>;
};
```

---

## 🪝 Custom Hooks

### Custom Hook Structure
```typescript
/**
 * Custom hook for auto-scrolling elements.
 * 
 * @param currentIndex - Index of the current element
 * @param elementRefs - Ref array of elements
 * @param scrollOffset - Offset for scroll calculation (default: 1)
 * 
 * @example
 * ```tsx
 * const stepRefs = useRef<(HTMLDivElement | null)[]>([]);
 * useAutoScroll(activeIndex, stepRefs);
 * ```
 */
export const useAutoScroll = <T extends HTMLElement>(
    currentIndex: number,
    elementRefs: RefObject<(T | null)[]>,
    scrollOffset: number = 1,
) => {
    const previousIndexRef = useRef<number>(-1);

    useEffect(() => {
        const elements = elementRefs.current;
        if (!elements) return;

        const direction = currentIndex - previousIndexRef.current;
        
        let targetIndex = currentIndex;
        if (direction > 0) {
            targetIndex = currentIndex + scrollOffset;
        } else if (direction < 0) {
            targetIndex = currentIndex - scrollOffset;
        }

        const targetElement = elements[targetIndex] || elements[currentIndex];

        if (targetElement && typeof targetElement.scrollIntoView === 'function') {
            targetElement.scrollIntoView({
                behavior: 'smooth',
                block: 'nearest',
                inline: 'nearest',
            });
        }

        previousIndexRef.current = currentIndex;
    }, [currentIndex, elementRefs, scrollOffset]);
};
```

### Custom Hook Organization

```
src/hooks/
├── index.ts                 # Centralized export
├── navigation/
│   ├── index.ts
│   ├── useAutoScroll.ts
│   └── useAutoScroll.test.ts
└── utils/
    ├── useAmelioTranslations.ts
    └── useNavigate.ts
```

---

## 📦 useRef vs MutableRefObject

### ✅ CORRECT: RefObject (Moderne)
```typescript
import { useRef, type RefObject } from 'react';

export const useAutoScroll = <T extends HTMLElement>(
    elementRefs: RefObject<(T | null)[]>,  // ✅ RefObject
) => {
    // Implementation
};
```

### ❌ DEPRECATED: MutableRefObject
```typescript
import { useRef, type MutableRefObject } from 'react';

export const useAutoScroll = (
    elementRefs: MutableRefObject<(HTMLDivElement | null)[]>,  // ❌ Deprecated
) => {
    // Implementation
};
```

---

## 🎣 useState Best Practices

### Explicit Typing
```typescript
// ✅ GOOD: Explicit type
const [items, setItems] = useState<Item[]>([]);
const [count, setCount] = useState<number>(0);
const [user, setUser] = useState<User | null>(null);

// ⚠️ OK: Inferred type if clear
const [isOpen, setIsOpen] = useState(false);  // boolean inferred
const [name, setName] = useState('');         // string inferred
```

### Functional Updates
```typescript
// ✅ GOOD: Uses the previous value
setCount(prev => prev + 1);
setItems(prev => [...prev, newItem]);

// ❌ BAD: Can cause bugs
setCount(count + 1);  // Uses the closure value
```

### State Objects
```typescript
// ✅ GOOD: Immutable update
setState(prev => ({
    ...prev,
    field: newValue,
}));

// ❌ BAD: Mutation directe
state.field = newValue;
setState(state);
```

---

## 🔄 useEffect Best Practices

### Complete Dependencies
```typescript
// ✅ GOOD: All dependencies listed
useEffect(() => {
    processData(value, config);
}, [value, config, processData]);

// ❌ BAD: Missing dependencies
useEffect(() => {
    processData(value, config);
}, []); // ESLint warning!
```

### Cleanup Functions
```typescript
// ✅ GOOD: Cleanup for event listeners
useEffect(() => {
    const handleKeyDown = (event: KeyboardEvent) => {
        // Logic
    };
    
    document.addEventListener('keydown', handleKeyDown);
    
    return () => {
        document.removeEventListener('keydown', handleKeyDown);
    };
}, [dependencies]);
```

### Conditional Effects
```typescript
// ✅ GOOD: Condition inside
useEffect(() => {
    if (condition) {
        doSomething();
    }
}, [condition]);

// ❌ BAD: Condition outside
if (condition) {  // ❌ Violation of hook rules!
    useEffect(() => {
        doSomething();
    }, []);
}
```

---

## 🎯 useCallback Best Practices

### When to use useCallback
- ✅ Callback passed to child components
- ✅ Callback used in useEffect dependencies
- ✅ Computationally expensive callback

### When NOT to use
- ❌ Simple local event handlers
- ❌ Premature over-optimization

### Example
```typescript
export const Component = ({ onAction }: Props) => {
    const [value, setValue] = useState('');

    // ✅ GOOD: Passed to a child component
    const handleSubmit = useCallback(() => {
        onAction(value);
    }, [value, onAction]);

    // ❌ BAD: Simple handler local
    const handleClick = useCallback(() => {
        console.log('clicked');
    }, []);  // Unnecessary here

    return (
        <>
            <input onChange={e => setValue(e.target.value)} />
            <ChildComponent onSubmit={handleSubmit} />
        </>
    );
};
```

---

## 🧠 useMemo Best Practices

### When to use useMemo
- ✅ Expensive calculations
- ✅ Complex data transformations
- ✅ Objects/arrays recreated on every render

### Example
```typescript
export const Component = ({ items }: Props) => {
    // ✅ GOOD: Expensive calculation
    const sortedItems = useMemo(() => {
        return items
            .slice()
            .sort((a, b) => a.value - b.value);
    }, [items]);

    // ❌ BAD: Simple calculation
    const count = useMemo(() => items.length, [items]);  // Unnecessary!

    return (/* JSX */);
};
```

---

## 📊 useRef Patterns

### For DOM Elements
```typescript
export const Component = () => {
    const inputRef = useRef<HTMLInputElement>(null);

    const focusInput = () => {
        inputRef.current?.focus();
    };

    return <input ref={inputRef} />;
};
```

### For Previous Values
```typescript
export const Component = ({ value }: Props) => {
    const previousValueRef = useRef<string>(value);

    useEffect(() => {
        if (previousValueRef.current !== value) {
            // Value changed
        }
        previousValueRef.current = value;
    }, [value]);
};
```

### For Array of Refs
```typescript
export const Component = ({ items }: Props) => {
    const itemRefs = useRef<(HTMLDivElement | null)[]>([]);

    return (
        <>
            {items.map((item, index) => (
                <div
                    key={item.id}
                    ref={el => { itemRefs.current[index] = el; }}
                >
                    {item.label}
                </div>
            ))}
        </>
    );
};
```

---

## 🚫 Anti-Patterns

### ❌ Conditional Hooks
```typescript
// ❌ BAD: Conditional hooks
if (condition) {
    useState('');  // REACT ERROR!
}

// ✅ GOOD: Condition in the hook
const [value, setValue] = useState(condition ? 'A' : 'B');
```

### ❌ Hooks in Loops
```typescript
// ❌ BAD: Hooks in a loop
items.forEach(item => {
    const [state, setState] = useState();  // REACT ERROR!
});

// ✅ GOOD: Separate component
items.map(item => <ItemComponent key={item.id} item={item} />);
```

### ❌ Infinite Loop
```typescript
// ❌ BAD: Infinite loop
useEffect(() => {
    setState(value);  // Causes a re-render
}, [value]);  // Which updates value, which causes a re-render...

// ✅ GOOD: Condition to stop the loop
useEffect(() => {
    if (needsUpdate) {
        setState(value);
    }
}, [value, needsUpdate]);
```

---

## 🎯 Hook Checklist

Before committing:

- [ ] Hooks in correct order (useState → useRef → useCallback → useEffect)
- [ ] Functions defined BEFORE useEffect
- [ ] Complete dependencies in all hooks
- [ ] Cleanup functions for event listeners
- [ ] No conditional hooks
- [ ] No hooks in loops
- [ ] useCallback for callbacks passed to children
- [ ] useMemo for expensive calculations only
- [ ] RefObject instead of MutableRefObject
- [ ] Custom hooks documented with JSDoc

---

## 📚 Real Examples

### useAutoScroll (Custom Hook)
```typescript
// Conversation: "Refactor useAutoScroll Hook"
// Generic hook for auto-scroll
export const useAutoScroll = <T extends HTMLElement>(
    currentIndex: number,
    elementRefs: RefObject<(T | null)[]>,
    scrollOffset: number = 1,
) => {
    // Implementation with useEffect and useRef
};

// Usage
const stepRefs = useRef<(HTMLDivElement | null)[]>([]);
useAutoScroll(activeIndex, stepRefs);
```

### EditorToolbar (Functions Before useEffect)
```typescript
// Conversation: "RichText Editor Code Review"
export const EditorToolbar = ({ disabled, toolbarOptions }: Props) => {
    const editor = useSlate();
    
    // ✅ Functions defined BEFORE useEffect
    const toggleMark = useCallback((format: string) => {
        // Logic
    }, [editor]);

    // useEffect AFTER
    useEffect(() => {
        const handleKeyDown = (event: KeyboardEvent) => {
            toggleMark(/* ... */);
        };
        // ...
    }, [editor, toggleMark]);
};
```

---

## 📚 References

- [React Hooks Documentation](https://react.dev/reference/react)
- [Rules of Hooks](https://react.dev/warnings/invalid-hook-call-warning)
- Conversation: "Refactor useAutoScroll Hook"
- Conversation: "RichText Editor Code Review"
- Rule #21 loopfive: Constants before return
- User Rule #18: React hook organization
