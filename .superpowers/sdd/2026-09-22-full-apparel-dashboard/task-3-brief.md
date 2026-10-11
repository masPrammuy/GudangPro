# Task 3 Brief: State Management & Tab Workspace Switcher di `dashboard.js`

## Objective
Implement clean, reactive tab switching logic (`switchView`), persistent state initializers for all 4 storage keys in `localStorage`, and replace all old dummy sidebar click handlers in `dashboard.js`.

## Requirements & Constraints
- Modify `dashboard.js`:
  - Storage initializers:
    - Ensure `gp_apparel_inventory` exists (or fallback to `DEFAULT_INVENTORY`).
    - Ensure `gp_apparel_inbound_logs` exists as an array (seed with 2-3 realistic sample PO records if empty, e.g. "PO-TX-2026-001", "PT Surya Tekstil Bandung", Katun Combed 30s, 50 Roll, QC Passed).
    - Ensure `gp_apparel_outbound_logs` exists as an array (seed with 2-3 realistic sample DO records if empty, e.g. "DO-GP-2026-001", "Distro Urban Cloth Jakarta", Kaos Oversize L, 24 Pcs, Terkirim).
    - Ensure `gp_apparel_audit_logs` exists as an array (seed with 1-2 realistic audit opname records if empty).
  - Implement `switchView(viewId)`:
    - Target view elements: `#viewOverview`, `#viewInventory`, `#viewInbound`, `#viewOutbound`, `#viewZones`, `#viewAudit`.
    - Set `display: none;` on all views and remove class `.active`.
    - Set `display: block;` (or add `.active`) on target view element.
    - Update sidebar nav items `.active` class according to view:
      - `navOverview` -> `#viewOverview`
      - `navInventory` -> `#viewInventory`
      - `navInbound` -> `#viewInbound`
      - `navOutbound` -> `#viewOutbound`
      - `navRacks` -> `#viewZones`
      - `navAudit` -> `#viewAudit`
    - Update topbar warehouse selector or breadcrumb / page title dynamically to reflect the current active module.
    - If `viewId === 'viewInventory'`, trigger `renderInventoryTable(getCurrentKeyword(), getCurrentCat())`.
  - Remove all old dummy click handlers:
    - Eliminate:
      ```javascript
      if (navInbound) navInbound.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Bahan Baku Masuk...', 'info'); };
      if (navOutbound) navOutbound.onclick = function (e) { e.preventDefault(); showToast('Membuka modul Pengiriman Baju...', 'info'); };
      if (navRacks) navRacks.onclick = function (e) { e.preventDefault(); showToast('Membuka denah rak...', 'info'); };
      if (navAudit) navAudit.onclick = function (e) { e.preventDefault(); showToast('Membuka audit...', 'info'); };
      ```
    - Replace with genuine event listeners calling `switchView('viewInbound')`, `switchView('viewOutbound')`, `switchView('viewZones')`, `switchView('viewAudit')`, `switchView('viewOverview')`, `switchView('viewInventory')`.
  - Also hook header quick actions (e.g. if on overview, button "Lihat di Tabel" in low stock banner switches to `viewInventory`).
- Create test file `tests/test_tab_switcher.py` and follow TDD:
  1. Write failing test:
     Verify `switchView` function is defined, all 4 localStorage keys are managed, and no old dummy toast click handlers exist.
  2. Run test to verify failure (Red)
  3. Implement minimal code in `dashboard.js`
  4. Run test to verify pass (Green)
  5. Commit: `git commit -m "feat(js): implement tab workspace switcher and initialize transaction states"`
- Write full report to `.superpowers/sdd/2026-09-22-full-apparel-dashboard/task-3-report.md`.
