# Task 5 Report: Modul Pengiriman Baju Jadi (Outbound DO) & Validasi Anti Over-Shipping di `dashboard.js`

**Status:** DONE  
**Commit:** `8d1849a`  
**Test Suite:** `tests/test_outbound_logic.py` (7 tests passing, 18/18 total tests in suite passing)  

---

## 1. Executive Summary

Task 5 successfully implemented the complete Outbound Delivery Order (DO) module with real-time anti over-shipping protection in `dashboard.js`. The module empowers garment warehouse personnel to generate delivery orders for finished apparel to resellers, distributors, and buyers while strictly preventing overselling or over-shipping. Key functionalities include:
1. **Dropdown Population (`renderOutboundDropdown`)**: Populates `#outboundItemSelect` with finished garments (`Baju Jadi (Siap Kirim)` or in-stock apparel) showing live stock quantities (e.g. `[BJU-OVR-BLK] Kaos Polos Oversize Katun (Stok: 6 Pcs)`).
2. **Real-time Anti Over-Shipping Validation (`validateOutboundStock`)**: Listens to input on `#outboundQty` and change on `#outboundItemSelect`. When requested quantity exceeds available stock, displays dynamic warning `"🚨 Stok tidak mencukupi! Tersedia hanya X Unit"`, applies `.is-invalid` danger styling to the input, and disables the submit button (`disabled = true`). When quantity is valid, clears error, restores available stock hint, and enables the submit button.
3. **Outbound Log Table Rendering (`renderOutboundLogs`)**: Renders all 7 columns (`NO. DO`, `TANGGAL`, `SKU & NAMA PAKAIAN`, `PENERIMA / RESELLER`, `EKSPEDISI`, `JUMLAH` with negative quantity `-X Unit`, `STATUS` badge `Terkirim`), plus a clean empty state row spanning 7 columns when logs are empty.
4. **Delivery Order Generation & Stock Deduction (`handleOutboundSubmit`)**: Enforces input validation (including fail-safe over-shipping check), auto-generates Delivery Order numbers (`DO-GP-YYYY-XXX`), automatically deducts stock (`item.qty -= qty`), recalculates stock threshold statuses (`🚨 Stok Habis`, `⚠️ Stok Minimum!`, or `Tersedia`), unshifts new log to `outboundLogsList`, and persists both to `localStorage` (`gp_apparel_inventory` and `gp_apparel_outbound_logs`).
5. **Reactivity & Feedback**: Refreshes inventory table, outbound logs, dropdowns, and KPI stats (including `#statOutboundToday`), resets the form with default date to today, shows success toast (`"Surat Jalan [No. DO] berhasil diterbitkan! Stok [Nama Baju] berkurang -[Qty] [Unit]"`), and emits additional low-stock warning toasts if threshold is reached.

---

## 2. TDD Cycle Execution

### Step 1: Red (Failing Test)
Created `tests/test_outbound_logic.py` with 7 unit test methods:
- `test_functions_defined`: Verified `renderOutboundDropdown`, `renderOutboundLogs`, and `handleOutboundSubmit` declarations.
- `test_outbound_dropdown_and_stock_hint`: Verified `#outboundItemSelect` population, stock hint element reference, and option label formatting with SKU and available stock.
- `test_realtime_over_shipping_validation`: Verified comparison `qty > currentItem.qty`, warning text `"🚨 Stok tidak mencukupi!"`, `is-invalid` class application, and `disabled = true` on submit button.
- `test_outbound_logs_table_rendering`: Verified `#outboundTableBody` rendering, 7-column layout, and empty state row (`Belum ada riwayat pengiriman baju jadi.`).
- `test_do_number_generation_and_mutation`: Verified `DO-GP-` DO number prefix, inventory stock deduction (`item.qty -= qty`), and submit-level error message `"Stok tidak mencukupi untuk pengiriman!"`.
- `test_outbound_storage_and_kpi_persistence`: Verified persistence to `localStorage` key `gp_apparel_outbound_logs`, call to `saveInventory()`, and dynamic calculation of `statOutboundToday`.
- `test_outbound_event_listener_and_reactivity`: Verified form submit listener wiring, switchView reactivity for `viewOutbound`, and success toast message.

**Red Verification Command:**
```bash
python tests/test_outbound_logic.py
```
**Result:** FAILED (failures=7) — Confirmed all tests accurately caught missing outbound functions and validation logic.

### Step 2: Green (Minimal Implementation)
Modified `dashboard.js` to implement:
- `validateOutboundStock()`: Live stock checker updating `#outboundStockHint`, toggling `.is-invalid` danger styling, and enabling/disabling `#btnSubmitOutbound`.
- `renderOutboundDropdown()`: Filters finished garments, populates options with formatted SKU & stock, and re-validates stock hint.
- `renderOutboundLogs()`: Populates `#outboundTableBody` with 7 structured columns, formatting negative quantities with warning color and rendering empty state when empty.
- `handleOutboundSubmit(e)`: Form submit handler with complete validation, DO generation (`DO-GP-YYYY-XXX`), stock deduction (`item.qty -= qty`), status re-evaluation, logging to `outboundLogsList`, storage saving, UI re-renders, form reset, and toast notification.
- Updated `initStorage()` and `switchView()` to synchronize outbound dropdowns, tables, and default DO dates upon startup and tab switching.
- Updated `updateStats()` to dynamically calculate `statOutboundToday` from today's outbound logs.
- Wired form listener on `#outboundForm` and realtime validation listeners on `#outboundItemSelect` ('change') and `#outboundQty` ('input') in `bindEvents()`.

**Green Verification Command:**
```bash
python tests/test_outbound_logic.py
python -m unittest discover tests
```
**Result:** 
- `tests/test_outbound_logic.py`: 7/7 tests OK (0.003s).
- Full test suite (`discover tests`): 18/18 tests OK (0.016s).

### Step 3: Git Commit
Committed using exact required command:
`git add tests/test_outbound_logic.py dashboard.js; git commit -m "feat(outbound): implement garment delivery order with over-shipping prevention"`  
**Commit Hash:** `8d1849a`

---

## 3. Verification & Evidence

- **Unit Tests:**
  ```text
  Ran 18 tests in 0.016s
  OK
  ```
- **Git Commit Log:**
  ```text
  8d1849a feat(outbound): implement garment delivery order with over-shipping prevention
  ```
- **Code Quality & Compliance:**
  - Zero external npm packages required; pure vanilla JavaScript with full backwards compatibility.
  - HTML escaping (`escapeHtml`) across all user-supplied log fields (DO number, SKU, apparel name, recipient, courier).
  - Robust two-tier validation: instant interactive UX feedback via real-time DOM events + non-bypassable submit-level guard.
