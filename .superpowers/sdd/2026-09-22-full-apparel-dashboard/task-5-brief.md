# Task 5 Brief: Modul Pengiriman Baju Jadi (Outbound DO) & Validasi Anti Over-Shipping di `dashboard.js`

## Objective
Implement genuine Outbound Delivery Order (DO) issuance in `dashboard.js`: populate the item dropdown with finished garments & apparel, validate quantity against live inventory to strictly prevent over-shipping, show dynamic inline feedback, auto-generate DO numbers (`DO-GP-YYYY-XXX`), automatically deduct inventory stock, update item threshold status, record into `gp_apparel_outbound_logs`, render outbound logs table, update stats, and show toast feedback.

## Requirements & Constraints
- Modify `dashboard.js`:
  - `renderOutboundDropdown()`:
    - Populates `#outboundItemSelect` with apparel items (categories such as `Baju Jadi (Siap Kirim)` or all items with stock > 0, indicating current available stock in option label, e.g. `[BJU-OVR-BLK] Kaos Polos Oversize Katun (Stok: 6 Pcs)`).
    - When user changes item selection, update `#outboundStockHint` to display available stock and unit (e.g. `Tersedia: 6 Pcs`).
  - Real-time Over-Shipping Validation:
    - Listen to `input` event on `#outboundQty` and `change` event on `#outboundItemSelect`.
    - If `qty > currentItem.qty`:
      - Show warning message in `#outboundStockHint`: `"🚨 Stok tidak mencukupi! Tersedia hanya " + currentItem.qty + " " + currentItem.unit`.
      - Add class `is-invalid` or danger styling to `#outboundQty`.
      - Disable submit button `#btnSubmitOutbound` (`disabled = true`).
    - If `qty <= currentItem.qty` and `qty > 0`:
      - Clear error message in `#outboundStockHint`: `"Tersedia: " + currentItem.qty + " " + currentItem.unit`.
      - Enable submit button `#btnSubmitOutbound` (`disabled = false`).
  - `renderOutboundLogs()`:
    - Renders all entries from `outboundLogsList` into `#outboundTableBody`.
    - Columns: No. Surat Jalan (DO), Tanggal Terbit, SKU & Nama Baju, Reseller / Pembeli, Jumlah Kirim (-qty unit), Ekspedisi / Kurir, Status Badge (`Terkirim`).
    - If empty, render clean empty row: `<td colspan="7" style="text-align:center; color:var(--muted); padding:24px;">Belum ada riwayat pengiriman baju jadi.</td>`.
  - `handleOutboundSubmit(e)`:
    - Form `#outboundForm` submit event listener.
    - Validate inputs:
      - Selected item exists.
      - Qty is positive integer > 0.
      - Qty <= current item stock. If qty > stock, show toast error `"Stok tidak mencukupi untuk pengiriman!"` and abort.
      - Recipient is not empty.
      - Courier is not empty.
      - Date is provided (default today).
    - Auto-generate DO number: `DO-GP-` + current year + `-` + sequential number or 3 random digits (e.g. `DO-GP-2026-089`).
    - **Stock Mutation**: Find item in `inventoryList`:
      - `item.qty -= qty;`
      - Re-evaluate item status: `item.status = item.qty === 0 ? '🚨 Stok Habis' : (item.qty <= item.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');`
      - Save `inventoryList` to `localStorage` (`gp_apparel_inventory`).
    - Add new log object to `outboundLogsList` (unshift):
      - `id`: `'OUT-' + Date.now()`
      - `doNo`: generated DO number
      - `itemId`: item.id
      - `sku`: item.sku
      - `itemName`: item.name
      - `qty`: qty
      - `unit`: item.unit
      - `recipient`: recipient string
      - `courier`: courier string
      - `date`: date string
      - `status`: `'Terkirim'`
    - Save `outboundLogsList` to `localStorage` (`gp_apparel_outbound_logs`).
    - Re-render:
      - `renderOutboundLogs()`
      - `renderInventoryTable()`
      - `renderOutboundDropdown()`
      - Update Overview KPI stats (e.g. `statOutboundToday`, `statLowStock`, low-stock alert banner).
    - Reset form inputs (default date to today, clear hint).
    - Show success toast: `"Surat Jalan [No. DO] berhasil diterbitkan! Stok [Nama Baju] berkurang -[Qty] [Unit]"`.
    - If after deduction `item.qty <= item.minStock`, show additional low-stock alert toast if applicable.
- Create test file `tests/test_outbound_logic.py` and follow TDD:
  1. Write failing test:
     Verify functions `handleOutboundSubmit`, `renderOutboundLogs`, `renderOutboundDropdown`, pattern `DO-GP-`, and error string `"Stok tidak mencukupi"`.
  2. Run test to verify failure (Red)
  3. Implement minimal code in `dashboard.js`
  4. Run test to verify pass (Green)
  5. Commit: `git commit -m "feat(outbound): implement garment delivery order with over-shipping prevention"`
- Write full report to `.superpowers/sdd/2026-09-22-full-apparel-dashboard/task-5-report.md`.
