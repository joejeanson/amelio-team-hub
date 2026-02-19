# 📘 TypeScript Criteria 30-32 & References

> Continuation of [Criteria 25-29](./01c-typescript-criteria-25-29.md) | Series start: [Criteria 1-15](./01a-typescript-criteria-1-15.md)

---

## ✅ 30. Destructure Props in Function Signature (Including Nested Objects)

### ❌ Avoid
```typescript
const Component = (props: ComponentProps) => {
    const { title, description, onClick } = props;
    return <div onClick={onClick}>{title}</div>;
};
```

### ✅ Prefer
```typescript
const Component = ({ title, description, onClick }: ComponentProps) => {
    return <div onClick={onClick}>{title}</div>;
};
```

### ⚠️ Also Applies to Nested Object Props

When receiving an object prop (like `config`), destructure it **in the signature**, not in the body.

#### ❌ Avoid (Nested destructuring in body)
```typescript
const PriorityContainer = ({
    config,
    isOver,
    disabled,
}: PriorityContainerProps) => {
    const { id, number, label, markerColor = Colors.PRIMARY } = config;  // ← WRONG: in body
    return <div>{label}</div>;
};
```

#### ✅ Prefer (Nested destructuring in signature)
```typescript
const PriorityContainer = ({
    config: { id, number, label, markerColor = Colors.PRIMARY },  // ← CORRECT: in signature
    isOver,
    disabled,
}: PriorityContainerProps) => {
    return <div>{label}</div>;
};
```

### 🤔 Why
- Props are immediately visible in signature
- Less code
- Standard React pattern
- Better IDE support
- **Applies to ALL levels of destructuring, not just top-level props**

---

## ✅ 31. Extract Render Functions to Separate Components

### ❌ Avoid
```typescript
const ParentComponent = () => {
    const renderItem = (item: Item, metadata: Metadata) => (
        <div className={'complex-styling'}>
            <span>{item.title}</span>
            <button onClick={() => handleClick(item.id)}>Action</button>
        </div>
    );

    return <List renderItem={renderItem} />;
};
```

### ✅ Prefer
```typescript
// components/ItemComponent/ItemComponent.tsx
const ItemComponent = ({ item, onAction }: ItemComponentProps) => (
    <div className={'complex-styling'}>
        <span>{item.title}</span>
        <button onClick={() => onAction(item.id)}>Action</button>
    </div>
);

// ParentComponent.tsx
const ParentComponent = () => {
    return <List renderItem={(item, meta) => <ItemComponent item={item} onAction={handleClick} />} />;
};
```

### 🤔 Why
- Single Responsibility Principle
- Testable in isolation
- Reusable across components
- Each component in its own folder with tests

---

## ⚠️ 32. No Integration in UI Tasks

### ❌ Avoid (in UI task)
```typescript
// PriorityBoard.tsx - UI component with API integration
const PriorityBoard = ({ userId }: Props) => {
    const [data, setData] = useState([]);
    
    useEffect(() => {
        fetchPriorities(userId).then(setData);  // ❌ Integration in UI task
    }, [userId]);

    return <Board data={data} />;
};
```

### ✅ Prefer
```typescript
// [UI] Task: Pure UI component
const PriorityBoard = ({ priorities, onChange }: Props) => {
    return <Board data={priorities} onChange={onChange} />;
};

// [Integration] Task: Container with data fetching
const PriorityBoardContainer = ({ userId }: Props) => {
    const { data } = usePriorities(userId);
    return <PriorityBoard priorities={data} onChange={handleChange} />;
};
```

### 🤔 Why
- Clear separation of concerns
- UI components are pure and testable
- Integration tested separately
- Matches task types: [UI] vs [Integration]

---

## 📚 References

- [loopfive/code-practices](https://github.com/loopfive/code-practices)
- [Clean Code TypeScript](https://github.com/labs42io/clean-code-typescript)
- [Airbnb JavaScript Style Guide](https://github.com/airbnb/javascript)
- [TypeScript Handbook - Functions](https://www.typescriptlang.org/docs/handbook/2/functions.html)
- [typescript-eslint Rules](https://typescript-eslint.io/rules/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)
- [Testing Library Documentation](https://testing-library.com/docs/)
- [Cypress Best Practices](https://docs.cypress.io/guides/references/best-practices)
