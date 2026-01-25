---
description: Spec-driven feature development workflow
requires: [astro-mcp, astro-docs]
---

# /feature

Structured workflow for implementing new features with best practices, documentation consultation, and verification.

## Syntax

```
/feature "description"
/feature --continue
/feature --verify
```

## Options

| Option | Description |
|--------|-------------|
| `"description"` | Start new feature with description |
| `--continue` | Resume in-progress feature |
| `--verify` | Run verification checks only |

## The 7-Phase Workflow

```
┌─────────────────────────────────────────────────────────────┐
│                    FEATURE WORKFLOW                          │
├─────────────────────────────────────────────────────────────┤
│ 1. CLARIFY    │ Understand requirements fully               │
│ 2. CONSULT    │ Query docs for best practices               │
│ 3. ANALYZE    │ Check existing code and patterns            │
│ 4. PLAN       │ Design implementation approach              │
│ 5. EXECUTE    │ Build the feature                           │
│ 6. VERIFY     │ Run checks and tests                        │
│ 7. SHIP       │ Commit with detailed message                │
└─────────────────────────────────────────────────────────────┘
```

## Phase Details

### Phase 1: CLARIFY

**Goal**: Fully understand what needs to be built.

```
FEATURE: "Add dark mode toggle"
════════════════════════════════════════════════════════════════

Phase 1: CLARIFY

Understanding requirements...

Questions:
1. Should dark mode persist across sessions? (localStorage)
2. Should it respect system preference initially?
3. Where should the toggle be placed? (header, footer, settings)
4. Should it animate the transition?

Please answer these questions or type 'defaults' to use
recommended settings.
```

**Output after clarification**:
```
Requirements confirmed:
✓ Persist preference in localStorage
✓ Respect system preference on first visit
✓ Toggle in header, next to navigation
✓ Smooth transition animation (150ms)

Proceeding to Phase 2...
```

### Phase 2: CONSULT

**Goal**: Query documentation for current best practices.

```
Phase 2: CONSULT

Querying astro-docs for best practices...

Relevant documentation found:

1. "CSS Variables for Theming"
   - Recommended: Use CSS custom properties
   - Avoid: Tailwind dark: classes alone (causes flash)

2. "View Transitions with Theme"
   - Use ViewTransitions API for smooth theme switch
   - data-theme attribute pattern

3. "Client-side State"
   - Use client:load for immediate interaction
   - localStorage for persistence

Best practice approach identified.
Proceeding to Phase 3...
```

### Phase 3: ANALYZE

**Goal**: Understand existing code and patterns.

```
Phase 3: ANALYZE

Querying astro-mcp for project state...

Existing patterns found:
  Layout: src/layouts/Base.astro
  Header: src/components/Header.astro
  Styles: src/styles/global.css (Tailwind)

Current theme handling: None detected

Related files to modify:
  1. src/layouts/Base.astro - Add theme script
  2. src/components/Header.astro - Add toggle button
  3. src/styles/global.css - Add CSS variables
  4. NEW: src/components/ThemeToggle.astro

No conflicts with existing code.
Proceeding to Phase 4...
```

### Phase 4: PLAN

**Goal**: Design the implementation approach.

```
Phase 4: PLAN

Implementation Plan:
════════════════════════════════════════════════════════════════

1. Create CSS variables in global.css
   - Define --color-bg, --color-text, etc.
   - Set values for light and dark themes
   - Use [data-theme="dark"] selector

2. Create ThemeToggle.astro component
   - Sun/moon icon toggle
   - client:load for immediate interactivity
   - Dispatch custom event on change

3. Update Base.astro layout
   - Add inline script to prevent flash
   - Set initial data-theme from localStorage/system
   - Listen for theme change events

4. Add toggle to Header.astro
   - Import ThemeToggle component
   - Position in header nav

Files to create: 1
Files to modify: 3
Estimated changes: ~100 lines

Proceed with implementation? (yes/modify/cancel)
```

### Phase 5: EXECUTE

**Goal**: Build the feature following the plan.

```
Phase 5: EXECUTE

Implementing feature...

[1/4] Creating src/styles/theme.css
      ✓ CSS variables defined
      ✓ Light theme values
      ✓ Dark theme values

[2/4] Creating src/components/ThemeToggle.astro
      ✓ Toggle component created
      ✓ Icon switching logic
      ✓ localStorage integration

[3/4] Updating src/layouts/Base.astro
      ✓ Flash prevention script added
      ✓ Theme initialization
      ✓ Event listener added

[4/4] Updating src/components/Header.astro
      ✓ ThemeToggle imported
      ✓ Positioned in navigation

Implementation complete.
Proceeding to Phase 6...
```

### Phase 6: VERIFY

**Goal**: Ensure the feature works and doesn't break anything.

```
Phase 6: VERIFY

Running verification checks...

Astro Check:
  ✓ No TypeScript errors
  ✓ No build warnings
  ✓ All routes still valid

Feature Verification:
  ✓ Toggle component renders
  ✓ Theme changes on click
  ✓ Preference persists in localStorage
  ✓ Respects system preference initially
  ✓ No flash on page load
  ✓ Smooth transition animation

Code Quality:
  ✓ No unused imports
  ✓ Consistent code style
  ✓ Proper TypeScript types

All checks passed!
Proceeding to Phase 7...
```

### Phase 7: SHIP

**Goal**: Commit with a detailed, descriptive message.

```
Phase 7: SHIP

Preparing commit...

Files changed:
  A src/styles/theme.css
  A src/components/ThemeToggle.astro
  M src/layouts/Base.astro
  M src/components/Header.astro

Commit message:
────────────────────────────────────────────────────────────────
feat: Add dark mode toggle with system preference support

- Add CSS custom properties for theming (theme.css)
- Create ThemeToggle component with sun/moon icons
- Implement flash prevention with inline script
- Respect system color-scheme preference on first visit
- Persist user preference in localStorage
- Add smooth 150ms transition animation

Consulted: Astro docs on CSS Variables, View Transitions
────────────────────────────────────────────────────────────────

Commit changes? (yes/edit/cancel)
```

## Feature State Persistence

Features can be paused and resumed:

```
/feature --continue

FEATURE: "Add dark mode toggle" (in progress)
════════════════════════════════════════════════════════════════

Status: Phase 5 (EXECUTE) - 2/4 files completed

Resuming implementation...

[3/4] Updating src/layouts/Base.astro
      ...
```

State stored in `.cleo-web/feature-state.json`.

## Integration with Other Commands

### With /astro-check

Automatically runs `/astro-check` during VERIFY phase:
- Ensures no Astro-specific issues introduced
- Validates configuration changes

### With /task

Creates task if feature requires follow-up:
```
Created task: "Add dark mode to remaining pages"
  Priority: low
  Labels: [feature, follow-up]
```

### With /session

Feature progress tracked in session:
```
Session Summary:
  Features completed: 1
  - Dark mode toggle (7 phases)
```

## Error Handling

### Build Failure During Verify

```
VERIFY FAILED

Astro build error:

  src/components/ThemeToggle.astro:15:3
  Cannot find name 'toggleTheme'

Options:
  1. Fix the issue and run /feature --verify
  2. Roll back changes with /feature --abort
  3. Get help with the error
```

### MCP Unavailable

```
WARNING: astro-docs MCP not available

Phase 2 (CONSULT) will be skipped.
Best practices will be based on general knowledge.

Continue anyway? (yes/cancel)
```

## Best Practices

### Feature Descriptions

**Good**:
- "Add dark mode toggle with system preference support"
- "Implement blog post search with fuzzy matching"
- "Add RSS feed for blog collection"

**Too Vague**:
- "Add dark mode" (missing details)
- "Fix styling" (not a feature)
- "Make it better" (undefined)

### When to Use /feature

Use for:
- New user-facing features
- Significant refactors
- Features requiring doc consultation

Don't use for:
- Bug fixes (just fix them)
- Typo corrections
- Simple config changes

## Related Commands

- `/astro-check` - Validation used in VERIFY phase
- `/task add` - Create follow-up tasks
- `/session status` - See feature in session context
