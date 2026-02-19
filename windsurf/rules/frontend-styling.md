---
trigger: glob
globs: ["**/*.css", "**/*.tsx", "tailwind.config.js"]
description: Frontend styling standards, color system, and Tailwind usage.
---

# 🎨 Frontend Styling Standards

## 1. Tailwind vs. Inline Styles
- **STATIC values** (colors, padding, margin, fixed dimensions) -> **Tailwind CSS** (Mandatory).
  - Example: `className="p-4 bg-primary text-white"`
- **DYNAMIC values** (calculated heights, user-defined colors, progress bars) -> **Inline Styles** (Allowed).
  - Example: `style={{ width: `${progress}%` }}`

## 2. Color System
- **Source of Truth**: `@amelio/ui-library` (`src/index.css`).
- **Usage**:
  - **In Props**: Use `Colors` constants.
    ```typescript
    import { Colors } from '@amelio/ui-library';
    <Icon color={Colors.PRIMARY} />
    ```
  - **In Classes**: Use Tailwind classes.
    ```typescript
    <div className="bg-primary text-base-300" />
    ```
- **Prohibited**:
  - Hardcoded hex codes (e.g., `#F02F42`).
  - String literals for colors (e.g., `color="red"`).

## 3. Layout & Responsiveness
- **Fluidity**: Components should generally fill their parent (unless specific UI elements like buttons).
- **Mobile First**: Use Tailwind prefixes (`md:`, `lg:`) for responsive overrides.
- **Spacing**: Use the spacing scale (`p-4` = 1rem), avoid arbitrary values (`p-[13px]`) unless strictly required by design.

## 4. Maintenance
- **Adding Colors**:
  1. Edit `@amelio/ui-library/src/index.css` (add CSS variable).
  2. Run `yarn gen:colors` in `amelio-ui-library`.
  3. Commit generated `Colors.ts` and `tailwind.config.js`.
