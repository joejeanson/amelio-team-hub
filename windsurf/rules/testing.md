---
trigger: glob
globs: ["**/*.test.ts", "**/*.test.tsx", "**/__tests__/**"]
description: Testing standards, coverage requirements, and patterns.
---

# 🧪 Testing Standards

> **Scope**: All Frontend and Backend Code.

## 1. Coverage Requirements (CRITICAL)
- **100% MANDATORY**:
  - Statements
  - Branches
  - Functions
  - Lines
- **Definition**: A component with <100% coverage is **incomplete**.
- **Exceptions**: Must be explicitly justified and approved (rare).

## 2. Testing Structure (Frontend - Vitest/RTL)
- **Location**: `__tests__` folder or adjacent `Component.test.tsx`.
- **Standard Test Suite**:
  1. **Rendering**: Renders without crashing.
  2. **Props**: Handles all props (custom & default).
  3. **Variants**: Tests all visual variants (sizes, colors).
  4. **States**: Tests `disabled`, `loading`, `error` states.
  5. **Events**: Verifies callbacks are called with correct arguments.
  6. **Accessibility**: Verifies ARIA roles, labels, and keyboard navigation.
  7. **Edge Cases**: Handles `undefined`, empty arrays, long text.
- **`dataTestId`**: Use `dataTestId` prop for selecting elements in tests. Do not rely on unstable class names or DOM structure.

## 3. Best Practices
- **Arrange-Act-Assert**: Distinctly separate these phases in every test.
- **Behavior Driven**: Test what the user sees/does, not internal implementation details (e.g., check if a modal opens, not if internal state `isOpen` is true).
- **Mocks**: Mock external services and heavy dependencies. Keep mocks simple.
