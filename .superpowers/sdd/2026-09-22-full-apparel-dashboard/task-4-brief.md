# Task 4 Brief: Modul Penerimaan Bahan Masuk (Inbound PO) & Mutasi Stok Otomatis di `dashboard.js`

## Objective
Implement genuine Inbound PO handling in `dashboard.js`: populate the item dropdown, validate input, generate PO numbers (`PO-TX-YYYY-XXX`), automatically increment inventory stock for the selected item, persist transaction to `gp_apparel_inbound_logs`, update the inbound log table, refresh stats, and show success toast feedback.

## Requirements & Constraints
- Modify `dashboard.js`:
  - `renderInboundDropdown()`:
    - Populates `#inboundItemSelect` with fabric & accessory items (`Kain & Bahan Baku`, `Aksesoris Jahit`, etc.).
    - Option label shows item SKU, name, current stock, and unit (e.g. `[KAN-CMB-01] Kain Katun Combed 30s Hitam (Stok: 45 Roll)`).
  - `renderInboundLogs()`:
    - Renders all entries from `inboundLogsList` into `#inboundTableBody`.
    - Columns: No. PO / Bukti Masuk, Tanggal, SKU & Nama Bahan, Pemasok / Vendor, Jumlah Masuk (+qty unit), No. Lot / Batch, Status Badge (`QC Lolos`).
    - If empty, render clean empty row: `<td colspan="7" style="text-align:center; color:var(--muted); padding:24px;">Belum ada riwayat penerimaan bahan.</td>`.
  - `handleInboundSubmit(e)`:
    - Form `#inboundForm` submit event listener.
    - Validate inputs:
      - Selected item exists.
      - Qty is a positive integer > 0.
      - Supplier name is not empty.
      - Date is provided (default to today if empty).
    - Auto-generate PO number if not manual: `PO-TX-` + current year + `-` + sequential number or 3 random digits (e.g. `PO-TX-2026-042`).
    - **Stock Mutation**: Find item in `inventoryList` matching `itemId` or `sku`:
      - `item.qty += qty;`
      - Re-evaluate item status: `item.status = item.qty === 0 ? '🚨 Stok Habis' : (item.qty <= item.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');`
      - Save `inventoryList` to `localStorage` (`gp_apparel_inventory`).
    - Add new log object to `inboundLogsList` (unshift):
      - `id`: `'INB-' + Date.now()`
      - `poNo`: generated PO number
      - `itemId`: item id
      - `sku`: item.sku
      - `itemName`: item.name
      - `qty`: qty
      - `unit`: item.unit
      - `supplier`: supplier string
      - `lotNumber`: lot string or '-'
      - `date`: date string
      - `notes`: notes string or '-'
      - `status`: `'QC Passed'`
    - Save `inboundLogsList` to `localStorage` (`gp_apparel_inbound_logs`).
    - Re-render:
      - `renderInboundLogs()`
      - `renderInventoryTable()`
      - `renderInboundDropdown()`
      - Update Overview KPI stats if relevant (e.g. `statInboundToday`).
    - Reset form inputs (default date to today).
    - Show success toast: `"Bahan masuk berhasil dicatat! Stok [Nama Bahan] bertambah +[Qty] [Unit]"`.
- Create test file `tests/test_inbound_logic.py` and follow TDD:
  1. Write failing test:
     Verify functions `handleInboundSubmit`, `renderInboundLogs`, `renderInboundDropdown`, and pattern `PO-TX-` exist and are wired.
  2. Run test to verify failure (Red)
  3. Implement minimal code in `dashboard.js`
  4. Run test to verify pass (Green)
  5. Commit: `git commit -m "feat(inbound): implement fabric receiving PO, auto stock increment and logging"`
- Write full report to `.superpowers/sdd/2026-09-22-full-apparel-dashboard/task-4-report.md`.
