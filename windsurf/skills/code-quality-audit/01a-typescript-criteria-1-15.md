# 📘 29 TypeScript Coding Practices Standards

> **Source:** https://github.com/loopfive/code-practices + Amelio internal standards
> 
> **Status:** MANDATORY for all Amelio components

---

## ❌ 1. Invoking Component Functions Directly

### ❌ Avoid
```typescript
{EmailField()}
```

### ✅ Prefer
```typescript
<EmailField />
```

### 🤔 Why
- Prevents loss of rerender encapsulation
- Avoids hook errors
- Maintains proper React component lifecycle

---

## ❌ 2. Nesting Component Definitions

### ❌ Avoid
```typescript
function App() {
    const EmailField = () => {
        // Component defined inside
    };
    return <EmailField />;
}
```

### ✅ Prefer
```typescript
export const EmailField = () => {
    // Component exported separately
};

function App() {
    return <EmailField />;
}
```

### 🤔 Why
- Testability
- Performance (no re-creation on each render)
- Prevents closure state leakage

---

## ✅ 3. Use Template Literals to Combine Strings

### ❌ Avoid
```typescript
const myString = 'hello' + world;
className={'flex' + ' ' + variant}
```

### ✅ Prefer
```typescript
const myString = `hello ${world}`;
className={`flex ${variant}`}
```

### 🤔 Why
- Readability
- Maintainability

---

## ✅ 4. Use === Instead of ==

### ❌ Avoid
```typescript
if (num1 == num2) { ... }  // Type coercion
```

### ✅ Prefer
```typescript
if (num1 === num2) { ... }  // Strict equality
```

### 🤔 Why
- Prevents unexpected behaviors from type coercion
- More predictable

---

## ✅ 5. Use Meaningful Variable Names

### ❌ Avoid
```typescript
const a1 = getUserData();
const a2 = formatData(a1);
const a3 = sendData(a2);
```

### ✅ Prefer
```typescript
const userData = getUserData();
const formattedData = formatData(userData);
const response = sendData(formattedData);
```

### 🤔 Why
- Code readability
- Self-documenting code

---

## ✅ 6. Use Same Vocabulary for Same Type

### ❌ Avoid
```typescript
getUserInfo();
getUserDetails();
getUserData();
```

### ✅ Prefer
```typescript
getUser();  // Consistent everywhere
```

### 🤔 Why
- Removes ambiguity
- Adds clarity

---

## ✅ 7. Use Default Arguments Instead of Conditionals

### ❌ Avoid
```typescript
function Component({ count }: Props) {
    const finalCount = count !== undefined ? count : 10;
}
```

### ✅ Prefer
```typescript
function Component({ count = 10 }: Props) {
    // count already has the default value
}
```

### 🤔 Why
- Self-documenting
- Eliminates conditional logic

---

## ✅ 8. Function Arguments and Type Aliases

### ❌ Avoid
```typescript
function createUser(
    name: string,
    email: string,
    age: number,
    role: string
) { ... }
```

### ✅ Prefer
```typescript
type CreateUserParams = {
    name: string;
    email: string;
    age: number;
    role: string;
};

function createUser(params: CreateUserParams) { ... }
```

### 🤔 Why
- Clear properties
- Reduces cognitive load
- Easier to extend

---

## ✅ 9. Functions Should Do One Thing

### ❌ Avoid
```typescript
function processUserAndSendEmail(user: User) {
    // Validates the user
    // Formats the data
    // Saves to DB
    // Sends an email
    // Logs the action
}
```

### ✅ Prefer
```typescript
function validateUser(user: User) { ... }
function formatUserData(user: User) { ... }
function saveUser(user: User) { ... }
function sendWelcomeEmail(user: User) { ... }
function logUserCreation(user: User) { ... }
```

### 🤔 Why
- Easier to compose
- Easier to test
- Easier to read

---

## ✅ 10. Favor Functional Programming Over Imperative

### ❌ Avoid
```typescript
const results = [];
for (let i = 0; i < items.length; i++) {
    if (items[i].isActive) {
        results.push(items[i].name);
    }
}
```

### ✅ Prefer
```typescript
const results = items
    .filter(item => item.isActive)
    .map(item => item.name);
```

### 🤔 Why
- Use optimized array methods
- More declarative
- Easier to read

---

## ✅ 11. Encapsulate Conditionals

### ❌ Avoid
```typescript
if (subscription.isTrial || account.balance > 0) {
    activateService();
}
```

### ✅ Prefer
```typescript
const canActivateService = (sub: Subscription, acc: Account) => {
    return sub.isTrial || acc.balance > 0;
};

if (canActivateService(subscription, account)) {
    activateService();
}
```

### 🤔 Why
- Readability
- Maintainability
- Centralized logic

---

## ✅ 12. Avoid Negative Conditionals

### ❌ Avoid
```typescript
if (!isEmailNotUsed(email)) { ... }
```

### ✅ Prefer
```typescript
if (isEmailUsed(email)) { ... }
```

### 🤔 Why
- Less prone to errors
- Easier to understand

---

## ✅ 13. Avoid Type Checking

### ❌ Avoid
```typescript
function processValue(value: string | number) {
    if (typeof value === 'string') {
        // String processing
    } else {
        // Number processing
    }
}
```

### ✅ Prefer
```typescript
interface Value {
    process(): void;
}

class StringValue implements Value {
    process() { /* String logic */ }
}

class NumberValue implements Value {
    process() { /* Number logic */ }
}
```

### 🤔 Why
- Leverage TypeScript
- Easier refactoring
- More maintainable

---

## ✅ 14. Remove Dead Code

### ❌ Avoid
```typescript
function OldComponent() {
    // No longer used but kept "just in case"
}
```

### ✅ Prefer
```typescript
// Delete completely
// Git keeps the history
```

### 🤔 Why
- Version control saves history
- Reduces clutter

---

## ❌ 15. Don't Leave Commented Out Code

### ❌ Avoid
```typescript
function Component() {
    // const oldLogic = () => { ... };
    // return <OldComponent />;
    
    return <NewComponent />;
}
```

### ✅ Prefer
```typescript
function Component() {
    return <NewComponent />;
}
```

### 🤔 Why
- Version control exists for a reason
- Clutters the codebase

---
