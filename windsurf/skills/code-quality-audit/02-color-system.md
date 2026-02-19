# 🎨 Amelio Color System

[[_TOC_]]

> **Single Source of Truth:** `@amelio/ui-library/src/index.css`

---

## 🔸 Architecture

::: mermaid
graph TB
    subgraph Source
        A[index.css<br/>CSS Variables @theme]
    end
    
    subgraph Script
        B[yarn gen:colors<br/>generateColors.ts]
    end
    
    subgraph Generated
        C[Colors.ts<br/>TypeScript Constants]
        D[tailwind.config.js<br/>Tailwind Classes]
    end
    
    A --> B
    B --> C
    B --> D
    
    subgraph Usage
        E[Component Props<br/>Colors.PRIMARY]
        F[Tailwind Classes<br/>bg-primary]
    end
    
    C --> E
    D --> F
:::

### Key Files

| File | Purpose |
|:---|:---|
| src/index.css | Source of Truth - CSS variable definitions |
| src/constants/Colors.ts | TypeScript constants (auto-generated) |
| tailwind.config.js | Tailwind classes for IDE (auto-generated) |
| scripts/generateColors.ts | Synchronization script |

---

## 🎯 Two Distinct Usage Patterns

### 1. Component Props → `Colors.XXX`

When passing a color to a component via its props:

```typescript
import { Colors, Icon, Typography, type ColorType } from '@amelio/ui-library';

// In props
<Icon color={Colors.PRIMARY} />
<Typography color={Colors.BASE_300}>Text</Typography>
<Card borderColor={Colors.BASE_50} />
```

### 2. Tailwind Classes → `bg-xxx`, `text-xxx`

For CSS styling via utility classes:

```typescript
// Tailwind classes
<div className="bg-primary text-white">...</div>
<div className="bg-base-200 text-base-300">...</div>
<div className="border-secondary-700">...</div>
```

---

## ✅ Real-World Example: Stepper

<details>
<summary>Click to expand Stepper.tsx example</summary>

```typescript
// @/src/components/Stepper/Stepper.tsx
import { Colors, Heading, Card } from '@amelio/ui-library';

export const Stepper = ({ title }: StepperProps) => {
    // Internal props using Colors.XXX
    const titleColor = Colors.BASE;
    const completedConnectorColor = Colors.SECONDARY_700;
    const upcomingLabelColor = Colors.BASE_300;

    return (
        <Card borderColor={Colors.BASE_50}>  {/* ← Props: Colors.XXX */}
            <Heading color={titleColor}>
                {title}
            </Heading>
        </Card>
    );
};
```

</details>

<details>
<summary>Click to expand StepItem.tsx example</summary>

```typescript
// @/src/components/Stepper/StepItem.tsx
export const StepItem = () => {
    return (
        // Tailwind classes for styling
        <div className="bg-primary text-white">  {/* ← Classes: bg-xxx */}
            <Icon color={Colors.BASE_50} />       {/* ← Props: Colors.XXX */}
        </div>
    );
};
```

</details>

---

## 🔧 Adding a New Color

### Step 1: Edit `index.css`

```css
/* @amelio/ui-library/src/index.css */
@theme {
    /* Add the new color */
    --color-info: #3B82F6;
    --color-info-50: #EFF6FF;
    --color-info-800: #1E40AF;
}
```

### Step 2: Run the generation script

```bash
cd amelio-ui-library
yarn gen:colors
```

### Step 3: Verify the generated files

The script automatically updates:

- `src/constants/Colors.ts` → `Colors.INFO`, `Colors.INFO_50`, `Colors.INFO_800`
- `tailwind.config.js` → `bg-info`, `text-info-50`, etc.

---

## 📦 TypeScript Types

<details>
<summary>Click to expand Colors.ts structure</summary>

```typescript
// @amelio/ui-library/src/constants/Colors.ts (auto-generated)
export const Colors = {
    PRIMARY: '#10CFBD',
    PRIMARY_50: '#E0F9F7',
    // ...
} as const;

export type ColorKey = keyof typeof Colors;
export type ColorType = (typeof Colors)[ColorKey];
```

</details>

### Usage in Interfaces

```typescript
import type { ColorType } from '@amelio/ui-library';

interface ComponentProps {
    color?: ColorType;        // Only accepts values from Colors
    borderColor?: ColorType;
}
```

---

## 🔸 Common Mistakes to Avoid

| Incorrect | Correct |
|:---|:---|
| color="secondary" | color={Colors.SECONDARY} |
| color="#7B68EE" | color={Colors.SECONDARY} |
| color?: string | color?: ColorType |
| Edit Colors.ts manually | Edit index.css + yarn gen:colors |

---

## 🔸 Current Palette

| Category | Colors |
|:---|:---|
| Primary | PRIMARY, PRIMARY_50 to PRIMARY_900 |
| Secondary | SECONDARY, SECONDARY_50 to SECONDARY_900 |
| Base | BASE, BASE_50 to BASE_600 |
| Status | SUCCESS, ERROR, WARNING + _50, _800 variants |
| Other | WHITE, BLACK, PURPLE, PINK |

---

## 🔸 Quick Reference

```typescript
// Import
import { Colors, type ColorType } from '@amelio/ui-library';

// Component props
<Icon color={Colors.PRIMARY} />
<Typography color={Colors.BASE_300} />

// Tailwind classes
<div className="bg-primary-50 text-base border-secondary-700" />

// Type for interfaces
interface Props {
    color?: ColorType;
}
```

---

## 📚 Official References

<details>
<summary>1. CSS Variables as Single Source of Truth (MDN)</summary>

> *"By declaring a custom property on the `:root` pseudo-class and using it where needed throughout the document, a CSS author can reduce the need for repetition [...] which is very useful if you want to change the value across the entire project later."*

**Source:** [MDN - Using CSS custom properties](https://developer.mozilla.org/en-US/docs/Web/CSS/CSS_cascading_variables/Using_CSS_custom_properties#using_the_root_pseudo-class)

</details>

<details>
<summary>2. Tailwind @theme for Design Tokens</summary>

> *"Theme variables are special CSS variables defined using the `@theme` directive that influence which utility classes exist in your project. [...] Tailwind also generates regular CSS variables for your theme variables so you can reference your design tokens in arbitrary values or inline styles."*

**Source:** [Tailwind CSS - Theme Variables](https://tailwindcss.com/docs/theme#what-are-theme-variables)

</details>

<details>
<summary>3. Sharing Theme Across Projects</summary>

> *"Since theme variables are defined in CSS, sharing them across projects is just a matter of throwing them into their own CSS file that you can import in each project. You can put shared theme variables in their own package in monorepo setups or even publish them to NPM."*

**Source:** [Tailwind CSS - Sharing across projects](https://tailwindcss.com/docs/theme#sharing-across-projects)

</details>

<details>
<summary>4. TypeScript as const for Type-Safe Constants</summary>

> *"TypeScript 3.4 introduces a new construct for literal values called `const` assertions. [...] no literal types in that expression should be widened (e.g. no going from `"hello"` to `string`). This can even be used to enable enum-like patterns in plain JavaScript code."*

```typescript
export const Colors = {
    red: "RED",
    blue: "BLUE",
    green: "GREEN",
} as const;
```

**Source:** [TypeScript 3.4 - const assertions](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-4.html#const-assertions)

</details>
