# 🧪 Testing Patterns - Amelio Standards

> **Objective:** CRITICAL: Achieve 100% everywhere for Stmts, Branch, Funcs and 100% of Lines

> **Why is it critical?:
> - To protect our code from regressions by other developers.
> - To guarantee code quality. Requiring 100% forces us to change our code to make it well-typed, and a component that cannot reach 100% is an incomplete component with weaknesses.

> **If objective not met:** I need solid explanations, and options to achieve it.
---

## 📋 Standard Test Structure

### Format Vitest
```typescript
import { Colors } from '@amelio/ui-library';
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { describe, it, expect, vi } from 'vitest';

import { Component } from './Component';
import type { ComponentProps } from './types';

describe('Component', () => {
    const defaultProps: ComponentProps = {
        // Default props for reuse
    };

    // ===== UNIT TESTS =====
    it('renders with default props', () => {
        render(<Component {...defaultProps} />);
        expect(screen.getByRole('button')).toBeInTheDocument();
    });

    // ===== PROPS TESTS =====
    it('applies custom className correctly', () => {
        render(<Component {...defaultProps} className="custom-class" />);
        expect(screen.getByRole('button')).toHaveClass('custom-class');
    });

    // ===== VARIANTS TESTS =====
    it('renders all variants correctly', () => {
        const { rerender } = render(<Component {...defaultProps} variant="primary" />);
        expect(screen.getByRole('button')).toHaveClass('variant-primary');
        
        rerender(<Component {...defaultProps} variant="secondary" />);
        expect(screen.getByRole('button')).toHaveClass('variant-secondary');
    });

    // ===== STATES TESTS =====
    it('handles disabled state', () => {
        render(<Component {...defaultProps} disabled={true} />);
        expect(screen.getByRole('button')).toBeDisabled();
    });

    // ===== EVENTS TESTS =====
    it('calls onClick when clicked', async () => {
        const handleClick = vi.fn();
        render(<Component {...defaultProps} onClick={handleClick} />);
        
        await userEvent.click(screen.getByRole('button'));
        expect(handleClick).toHaveBeenCalledTimes(1);
    });

    // ===== ACCESSIBILITY TESTS =====
    it('has correct ARIA attributes', () => {
        render(<Component {...defaultProps} ariaLabel="Test label" />);
        expect(screen.getByLabelText('Test label')).toBeInTheDocument();
    });
});
```

---

## 🎯 Mandatory Test Categories

### 1. Unit Tests (Basic rendering)
```typescript
it('renders without crashing', () => {
    render(<Component />);
});

it('renders with required props', () => {
    render(<Component label="Test" />);
    expect(screen.getByText('Test')).toBeInTheDocument();
});

it('renders children correctly', () => {
    render(<Component><span>Child</span></Component>);
    expect(screen.getByText('Child')).toBeInTheDocument();
});
```

### 2. Props Tests
```typescript
it('applies custom className', () => {
    render(<Component className="custom" />);
    expect(screen.getByRole('button')).toHaveClass('custom');
});

it('applies custom dataTestId', () => {
    render(<Component dataTestId="test-id" />);
    expect(screen.getByTestId('test-id')).toBeInTheDocument();
});

it('uses default values when props not provided', () => {
    render(<Component />);
    // Verify defaults
});
```

### 3. Variants & Sizes Tests
```typescript
it('renders all size variants', () => {
    const sizes = ['sm', 'md', 'lg'] as const;
    
    sizes.forEach(size => {
        const { container } = render(<Component size={size} />);
        // Size-specific verifications
    });
});

it('renders all color variants', () => {
    render(<Component color={Colors.PRIMARY} />);
    expect(screen.getByRole('button')).toHaveStyle({
        color: Colors.PRIMARY
    });
});
```

### 4. States Tests
```typescript
it('handles disabled state', () => {
    render(<Component disabled={true} />);
    const element = screen.getByRole('button');
    expect(element).toBeDisabled();
    expect(element).toHaveClass('opacity-50');
});

it('handles loading state', () => {
    render(<Component loading={true} />);
    expect(screen.getByRole('progressbar')).toBeInTheDocument();
});

it('handles error state', () => {
    render(<Component error={true} errorMessage="Error!" />);
    expect(screen.getByText('Error!')).toBeInTheDocument();
});
```

### 5. Events Tests
```typescript
it('calls onClick when clicked', async () => {
    const handleClick = vi.fn();
    render(<Component onClick={handleClick} />);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
});

it('calls onChange with correct value', async () => {
    const handleChange = vi.fn();
    render(<Input onChange={handleChange} />);
    
    await userEvent.type(screen.getByRole('textbox'), 'test');
    expect(handleChange).toHaveBeenCalled();
});

it('does not call onClick when disabled', async () => {
    const handleClick = vi.fn();
    render(<Component onClick={handleClick} disabled={true} />);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).not.toHaveBeenCalled();
});
```

### 6. Accessibility Tests
```typescript
it('has correct role', () => {
    render(<Component />);
    expect(screen.getByRole('button')).toBeInTheDocument();
});

it('applies aria-label correctly', () => {
    render(<Component ariaLabel="Close" />);
    expect(screen.getByLabelText('Close')).toBeInTheDocument();
});

it('has aria-disabled when disabled', () => {
    render(<Component disabled={true} />);
    expect(screen.getByRole('button')).toHaveAttribute('aria-disabled', 'true');
});

it('maintains logical reading order', () => {
    render(<Component />);
    // Verify element order
});
```

### 7. Edge Cases Tests
```typescript
it('handles undefined props gracefully', () => {
    render(<Component label={undefined} />);
    // Should not crash
});

it('handles very long text', () => {
    const longText = 'a'.repeat(1000);
    render(<Component label={longText} />);
    expect(screen.getByText(longText)).toBeInTheDocument();
});

it('handles empty array', () => {
    render(<Component items={[]} />);
    // Verify behavior with empty array
});
```

---

## 🎨 ColorType in Tests

```typescript
import { Colors } from '@amelio/ui-library';

describe('Component Colors', () => {
    it('applies custom color correctly', () => {
        render(<Component color={Colors.PRIMARY} />);
        
        const element = screen.getByRole('button');
        expect(element).toHaveStyle({ color: Colors.PRIMARY });
    });

    it('uses default color when not provided', () => {
        render(<Component />);
        
        const element = screen.getByRole('button');
        expect(element).toHaveStyle({ color: Colors.BASE });
    });

    it('applies different colors to different states', () => {
        render(
            <>
                <Component status="active" />
                <Component status="completed" />
                <Component status="upcoming" />
            </>
        );
        
        // Verify each color
    });
});
```

---

## 🔄 Tests with Rerender

```typescript
it('updates when props change', () => {
    const { rerender } = render(<Component value="Initial" />);
    expect(screen.getByText('Initial')).toBeInTheDocument();
    
    rerender(<Component value="Updated" />);
    expect(screen.getByText('Updated')).toBeInTheDocument();
    expect(screen.queryByText('Initial')).not.toBeInTheDocument();
});
```

---

## 🎭 Mock Functions

```typescript
import { vi } from 'vitest';

describe('Component with callbacks', () => {
    it('calls callback with correct parameters', async () => {
        const mockCallback = vi.fn();
        render(<Component onAction={mockCallback} />);
        
        await userEvent.click(screen.getByRole('button'));
        
        expect(mockCallback).toHaveBeenCalledTimes(1);
        expect(mockCallback).toHaveBeenCalledWith(
            expect.objectContaining({
                id: 'test',
                value: 'data'
            })
        );
    });
});
```

---

## 🧩 Sub-Component Tests

```typescript
// StepItem.test.tsx
describe('StepItem', () => {
    const defaultSizeConfig = {
        indicator: 'h-10 w-10',
        numberText: 'h4' as const,
        // ...
    };

    const defaultColors = {
        active: Colors.BASE,
        completed: Colors.BASE,
        upcoming: Colors.BASE_300,
    };

    const defaultProps = {
        step: { id: '1', label: 'Step 1' },
        index: 0,
        activeIndex: 0,
        sizeConfig: defaultSizeConfig,
        colors: defaultColors,
    };

    it('renders step label', () => {
        render(<StepItem {...defaultProps} />);
        expect(screen.getByText('Step 1')).toBeInTheDocument();
    });

    it('computes status correctly', () => {
        render(<StepItem {...defaultProps} index={0} activeIndex={1} />);
        // Verify that 'completed' status is applied
    });
});
```

---

## 📊 Coverage Goals

### **MANDATORY: 100% Coverage Required**

**Fundamental principle:** A component that does not reach 100% coverage is an **incomplete, fragile and unvalidated** component.

- **Statements:** 100% ✅ MANDATORY
- **Branches:** 100% ✅ MANDATORY
- **Functions:** 100% ✅ MANDATORY
- **Lines:** 100% ✅ MANDATORY

### Why 100% and not 80%?

**80% coverage = 20% untested code = 20% potential bugs**

1. **Complete validation:** 100% guarantees every line, branch and function has been executed and validated
2. **Total confidence:** No grey areas, no "maybe it works"
3. **Safe refactoring:** Modify code without fear of breaking something untested
4. **Professional quality:** A 100% tested component is a production-ready component
5. **Early detection:** Bugs are found during development, not in production

**⚠️ Code smell:** Coverage < 100% indicates an incomplete component or untested branches (edge cases, error handling, etc.)

### Check coverage
```bash
yarn test
# Report in coverage/index.html
```

---

## 🚫 Anti-Patterns

### ❌ Tests too coupled to implementation
```typescript
// ❌ BAD: tests internal implementation
it('calls internal function', () => {
    const component = new Component();
    expect(component._internalMethod).toHaveBeenCalled();
});

// ✅ GOOD: tests behavior
it('displays result after action', async () => {
    render(<Component />);
    await userEvent.click(screen.getByRole('button'));
    expect(screen.getByText('Result')).toBeInTheDocument();
});
```

### ❌ Tests that test nothing
```typescript
// ❌ BAD
it('component exists', () => {
    const component = Component;
    expect(component).toBeDefined();
});

// ✅ GOOD
it('renders with required props', () => {
    render(<Component label="Test" />);
    expect(screen.getByText('Test')).toBeInTheDocument();
});
```

### ❌ Duplicated tests
```typescript
// ❌ BAD: Two identical tests
it('applies size classes (sm, md, lg)', () => {
    // Test logic
});

it('icon container has correct size', () => {
    // EXACTLY same test logic!
});

// ✅ GOOD: A single comprehensive test
it('applies size classes for all variants', () => {
    // Test all sizes
});
```

---

## ✅ Best Practices

### 1. Arrange-Act-Assert
```typescript
it('example test', () => {
    // Arrange: Setup
    const handleClick = vi.fn();
    
    // Act: Execute
    render(<Component onClick={handleClick} />);
    await userEvent.click(screen.getByRole('button'));
    
    // Assert: Verify
    expect(handleClick).toHaveBeenCalled();
});
```

### 2. Descriptive Test Names
```typescript
// ✅ GOOD
it('displays error message when validation fails', () => {});
it('calls onSubmit with form data when form is valid', () => {});

// ❌ BAD
it('test 1', () => {});
it('works', () => {});
```

### 3. Test One Thing
```typescript
// ❌ BAD: Tests too many things
it('component works', () => {
    render(<Component />);
    expect(screen.getByRole('button')).toBeInTheDocument();
    expect(screen.getByText('Label')).toBeInTheDocument();
    await userEvent.click(screen.getByRole('button'));
    expect(mockFn).toHaveBeenCalled();
    // etc...
});

// ✅ GOOD: Separate tests
it('renders button', () => {
    render(<Component />);
    expect(screen.getByRole('button')).toBeInTheDocument();
});

it('renders label', () => {
    render(<Component />);
    expect(screen.getByText('Label')).toBeInTheDocument();
});

it('calls onClick when clicked', async () => {
    const mockFn = vi.fn();
    render(<Component onClick={mockFn} />);
    await userEvent.click(screen.getByRole('button'));
    expect(mockFn).toHaveBeenCalled();
});
```

---

## 🎯 Test Checklist

Before committing:

- [ ] **100% coverage MANDATORY** (Statements | Branches | Functions | Lines)
- [ ] Unit tests (basic rendering)
- [ ] Props tests (all props tested)
- [ ] Variants & Sizes tests
- [ ] States tests (disabled, loading, error)
- [ ] Events tests (onClick, onChange, etc.)
- [ ] Accessibility tests (ARIA, roles, keyboard)
- [ ] Edge cases tests (undefined, empty, long text)
- [ ] ColorType tests (if applicable)
- [ ] No duplicated tests
- [ ] Descriptive test names
- [ ] One test = one thing

---

## 📚 References

- [Vitest Documentation](https://vitest.dev/)
- [Testing Library](https://testing-library.com/)
- [User Event](https://testing-library.com/docs/user-event/intro)
- Conversation: "Stepper Scroll and Storybook Fixes" (100% coverage)
- Conversation: "UserCard Refactoring" (100% coverage)
- Conversation: "InfoBadge Component Review" (100% coverage)
