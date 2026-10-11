# Task 6 Brief: Denah Interaktif Zona Workshop & Stock Opname Audit Fisik di `dashboard.js`

## Objective
Implement genuine interactive rack zone telemetry & filtering, and the Stock Opname audit physical counting & 1-click sync tool in `dashboard.js`.

## Requirements & Constraints
- Modify `dashboard.js`:
  - **Part A: Zona Workshop Interaktif (`#viewZones`)**:
    - `initZoneInteractions()`:
      - Listen to click events on each `.zone-card.interactive` (or `.zone-card[data-zone]`):
        - Zones: `A` (Gudang Kain Roll), `B` (Aksesoris & Benang), `C` (Cutting & Meja Potong), `D` (Baju Jadi Siap Kirim).
        - Toggle `.selected` / `.active` state on clicked zone card and remove from siblings.
        - Call `filterByZone(zoneKey)`.
    - `filterByZone(zoneKey)`:
      - Filter `inventoryList` for items stored in that zone:
        - Match rack/location string starting with or containing "A" or category "Kain", etc. (e.g. `item.location.toUpperCase().includes('A')` or `item.category.includes('Kain')`).
      - Render filtered items in `#zoneFilterTableBody`:
        - Columns: SKU, Nama Bahan / Baju, Kategori, Lokasi Rak, Stok Saat Ini, Status Badge.
        - If empty, render clean empty row indicating no items in this zone.
      - Update `#currentZoneHeading` / `#currentZoneName` text to indicate active zone name (e.g. `"Daftar Inventaris: ZONA A (Gudang Kain Roll)"`).
    - `updateZoneTelemetry()`:
      - Dynamically calculate total quantities for each of the 4 zones from `inventoryList` and update the capacity bars and occupancy percentages in `.zone-card` elements on both `#viewOverview` and `#viewZones`.
  - **Part B: Stock Opname & Audit Fisik (`#viewAudit`)**:
    - `renderAuditDropdown()`:
      - Populates `#auditItemSelect` with all items from `inventoryList`.
      - Shows SKU, name, and current system stock in option label.
    - When user selects an item in `#auditItemSelect`:
      - Retrieve the item.
      - Set `#auditSystemStock` text to `item.qty + " " + item.unit`.
      - Store current system stock in data attribute or variable.
      - Reset `#auditPhysicalCount` and trigger `calculateAuditDiscrepancy()`.
    - `calculateAuditDiscrepancy()`:
      - Listen to `input` event on `#auditPhysicalCount`.
      - If input is empty: `#auditDiscrepancyBadge` displays `"Masukkan hitungan fisik"`, disable `#btnSyncAuditStock`.
      - If input is a valid number:
        - `physicalVal = parseInt(countInput.value, 10);`
        - `diff = physicalVal - currentItem.qty;`
        - If `diff === 0`:
          - Badge class: `discrepancy-pill match` -> `"✓ Sesuai (Selisih: 0 " + item.unit + ")"`
        - If `diff > 0`:
          - Badge class: `discrepancy-pill surplus` -> `"+ " + diff + " " + item.unit + " (Surplus Fisik)"`
        - If `diff < 0`:
          - Badge class: `discrepancy-pill deficit` -> `"" + diff + " " + item.unit + " (Kurang / Defisit)"`
        - Enable `#btnSyncAuditStock` (`disabled = false`).
    - `syncAuditStock()`:
      - Button `#btnSyncAuditStock` click handler.
      - Validate: item selected, valid physical count >= 0.
      - If there is a discrepancy (`diff !== 0`), ensure reason `#auditReason` is noted or default to `"Penyesuaian hasil audit fisik garmen"`.
      - **Stock Mutation**: Update item stock:
        - `var oldStock = item.qty;`
        - `item.qty = physicalVal;`
        - Re-evaluate status: `item.status = item.qty === 0 ? '🚨 Stok Habis' : (item.qty <= item.minStock ? '⚠️ Stok Minimum!' : 'Tersedia');`
        - Save `inventoryList` to `localStorage` (`gp_apparel_inventory`).
      - Add new audit log to `auditLogsList` (unshift):
        - `id`: `'AUD-' + Date.now()`
        - `date`: new Date().toISOString().split('T')[0]
        - `itemId`: item.id
        - `sku`: item.sku
        - `itemName`: item.name
        - `systemStock`: oldStock
        - `physicalStock`: physicalVal
        - `discrepancy`: diff
        - `reason`: reason text
        - `auditor`: user.name || 'Staff Konveksi'
      - Save `auditLogsList` to `localStorage` (`gp_apparel_audit_logs`).
      - Re-render:
        - `renderAuditLogs()`
        - `renderInventoryTable()`
        - `renderInboundDropdown()`
        - `renderOutboundDropdown()`
        - `renderAuditDropdown()`
        - `updateZoneTelemetry()`
      - Show success toast: `"Audit berhasil! Stok [Nama Item] disinkronkan menjadi [PhysicalVal] [Unit] (Selisih: [Diff])"`.
      - Reset count input and reason.
    - `renderAuditLogs()`:
      - Renders all entries from `auditLogsList` into `#auditTableBody`.
      - Columns: Tanggal Audit, SKU & Nama Bahan, Auditor, Stok Sistem, Hitungan Fisik, Selisih (berwarna hijau/merah/biru), Catatan / Alasan.
      - If empty, render clean empty row: `<td colspan="7" style="text-align:center; color:var(--muted); padding:24px;">Belum ada riwayat stock opname.</td>`.
- Create test file `tests/test_zones_and_audit.py` and follow TDD:
  1. Write failing test:
     Verify functions `initZoneInteractions`, `filterByZone`, `calculateAuditDiscrepancy`, `syncAuditStock`, `renderAuditLogs`, and `updateZoneTelemetry`.
  2. Run test to verify failure (Red)
  3. Implement minimal code in `dashboard.js`
  4. Run test to verify pass (Green)
  5. Commit: `git commit -m "feat(zones-audit): implement interactive zone filtering and stock opname audit tool"`
- Write full report to `.superpowers/sdd/2026-09-22-full-apparel-dashboard/task-6-report.md`.
