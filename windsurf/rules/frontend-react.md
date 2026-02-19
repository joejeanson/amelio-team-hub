---
trigger: glob
globs: ["**/*.ts", "**/*.tsx"]
description: Frontend React and TypeScript coding standards, hooks patterns, and naming conventions.
---

# 📘 Frontend React & TypeScript Standards

> **Scope**: All React and TypeScript code.

## 1. Naming Conventions
- **Components**: `PascalCase` (e.g., `UserCard`). Match filename: `UserCard.tsx`.
- **Variables/Functions**: `camelCase` (e.g., `isLoading`, `handleClick`).
- **Types/Interfaces**: `PascalCase` (e.g., `UserProps`). **NO `I` prefix**.
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `MAX_RETRY_COUNT`).
- **Boolean Props**: Prefix with `is`, `has`, `can`, `should` (e.g., `isOpen`).
- **Event Handlers**: `handle` + Event (e.g., `handleClick`).
- **Props Callbacks**: `on` + Event (e.g., `onClick`).

## 2. TypeScript Best Practices
- **Strict Typing**: Avoid `any`, `object`, `Function`. Define precise interfaces.
- **No Force Casts**: Do NOT use `as any` or `!` unless absolutely necessary and documented.
- **Exports**: Group exports at the end of the file or use named exports consistently.
- **Imports**: Use aliases (`@/components`, `@/services`) instead of relative paths (`../../../`).

## 3. React Patterns
- **Functional Components**: Use arrow functions (`const Component = () => {}`).
- **Hooks Order (MANDATORY)**:
  1. `useState`
  2. `useRef`
  3. `useContext`
  4. `useReducer`
  5. `useCallback` / `useMemo`
  6. `useEffect` (ALWAYS last)
- **Functions before Effects**: Define functions (wrapped in `useCallback`) *before* the `useEffect` that depends on them.
- **Render Purity**: Never mutate state/refs during render.
- **Fragments**: Use `<>` instead of `<Fragment>` where possible.

## 4. Component Architecture
- **Single Responsibility**: Components should do ONE thing.
- **Extraction Guidelines**:
  - **Utils**: 3+ pure functions or >10 lines logic -> extract to `utils/`.
  - **Sub-components**: Repeated JSX or map iterations >30 lines -> extract to `components/`.
  - **Hooks**: Reusable state/ref logic >15 lines -> extract to `hooks/`.
- **Width Control**: Components must **never** set their own width (no `w-[px]` or `w-full` on the root element unless it's a layout container). The parent controls the width.
- **No Direct Invocation**: Use `<Component />`, never `Component()`.

## 5. API & Data Fetching
- **Services**: Use existing service layers. Do not make raw fetch/axios calls in components.
- **Cancellation**: Use cancellation tokens for rapid requests (search, autocomplete). Pattern: `TOKENS.REQUEST_NAME`.
- **Async/Await**: Prefer over `.then()`.
- **Multilingual**:
  - Use `BindMultiLingualTitles` (or equivalent) to get current language text.
  - Always handle fallback to English.

## 6. Performance
- **Optimization**: Do NOT use `useMemo` for simple math or string ops (<1ms). Measure first.
- **Stable Props**: Ensure objects/arrays passed to memoized children are stable.
