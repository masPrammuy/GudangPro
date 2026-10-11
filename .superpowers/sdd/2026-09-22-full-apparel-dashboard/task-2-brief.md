# Task 2 Brief: Penggayaan CSS untuk Workspace Tabs, Form Transaksi & Tabel Manufaktur di `style.css`

## Objective
Add clean, bespoke CSS styling for the 6 modular workspace views, transaction cards, dual-column input forms, status badges, discrepancy pills, and interactive rack cards in `style.css`.

## Requirements & Constraints
- Modify `style.css`:
  - Add styles for `.workspace-view`:
    - Display transitions, smooth display management, proper padding and card spacing.
  - Add styles for `.transaction-card`:
    - Card container for transaction workflows (inbound and outbound) with clean borders (`var(--border)`), subtle shadow, and light background (`#ffffff`).
  - Add styles for `.form-grid-2`:
    - Clean 2-column responsive layout for transaction forms (`display: grid; grid-template-columns: 1fr 1fr; gap: 14px;`).
  - Add styles for `.discrepancy-pill`:
    - Visual badge for audit stock opname calculation (`.discrepancy-pill.match`, `.discrepancy-pill.surplus`, `.discrepancy-pill.deficit`).
  - Add styles for `.zone-card.interactive`:
    - Cursor pointer, subtle hover elevation, `.zone-card.interactive.selected` / `.active` state with border highlight and active badge indication.
  - Add styles for `.stock-status-alert` & `.stock-preview-badge`:
    - Alert indicator when outbound quantity exceeds available stock or item is below threshold.
  - Maintain the clean, industrial apparel aesthetic: slate `#0f172a`, off-white `#f8fafc`, borders `#e2e8f0`, indigo `#4f46e5`, emerald `#10b981`, amber `#f59e0b`, rose `#ef4444`. No flashy AI-neon gradients or tacky decorative bubbles.
  - Ensure all CSS curly braces `{` and `}` are strictly balanced.
- Create test file `tests/test_css_styles.py` and follow TDD:
  1. Write failing test:
     Verify presence of `.workspace-view`, `.transaction-card`, `.discrepancy-pill`, `.zone-card.interactive`, `.stock-status-alert` and that braces are balanced.
  2. Run test to verify failure (Red)
  3. Write minimal CSS in `style.css` to pass
  4. Run test to verify pass (Green)
  5. Commit: `git commit -m "style: add workspace tabs, transaction forms and industrial apparel table styles"`
- Write full report to `.superpowers/sdd/2026-09-22-full-apparel-dashboard/task-2-report.md`.
