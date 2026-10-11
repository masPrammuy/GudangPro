# Task 1 Brief: Struktur Markup Workspace Tab & 6 View Containers di `dashboard.html`

## Objective
Update `dashboard.html` to establish the 6 modular workspace view containers and sidebar navigation IDs.

## Requirements & Constraints
- Modify `dashboard.html`:
  - Ensure all 6 sidebar navigation links have exact IDs:
    - `id="navOverview"` (Dashboard Utama)
    - `id="navInventory"` (Stok Kain & Baju)
    - `id="navInbound"` (Bahan Masuk)
    - `id="navOutbound"` (Kirim Baju)
    - `id="navRacks"` (Zona Rak Konveksi)
    - `id="navAudit"` (Audit Stok Pakaian)
  - Inside `<main class="app-main">`:
    - Wrap the overview components (hero banner, onboarding guide, KPI cards, zones panel preview, low-stock banner) inside `<div id="viewOverview" class="workspace-view active">...</div>`.
    - Wrap the inventory panel section (`#inventorySection`) inside `<div id="viewInventory" class="workspace-view" style="display:none;">...</div>`.
    - Create container `<div id="viewInbound" class="workspace-view" style="display:none;">...</div>`:
      - Header: "Penerimaan Bahan Baku (Inbound PO)" + subtitle
      - Form with `id="inboundForm"`:
        - Dropdown `id="inboundItemSelect"`
        - Input text `id="inboundSupplier"` (Pemasok / Vendor Tekstil)
        - Input text `id="inboundLot"` (No. Lot Kain / Kode Celup)
        - Input number `id="inboundQty"` (Jumlah Masuk)
        - Input date `id="inboundDate"` (Tanggal Masuk)
        - Textarea `id="inboundNotes"` (Catatan)
        - Button submit "Catat Bahan Masuk"
      - Table for history with `id="inboundTable"` and `id="inboundTableBody"`
    - Create container `<div id="viewOutbound" class="workspace-view" style="display:none;">...</div>`:
      - Header: "Surat Jalan & Pengiriman Baju Jadi (Outbound DO)" + subtitle
      - Form with `id="outboundForm"`:
        - Dropdown `id="outboundItemSelect"`
        - Element `id="outboundStockHint"` (menampilkan info stok saat ini)
        - Input text `id="outboundRecipient"` (Reseller / Pembeli)
        - Input text `id="outboundCourier"` (Ekspedisi / Kurir)
        - Input number `id="outboundQty"` (Jumlah Kirim)
        - Input date `id="outboundDate"` (Tanggal Terbit DO)
        - Button submit `id="btnSubmitOutbound"` "Terbitkan Surat Jalan (DO)"
      - Table for shipment logs with `id="outboundTable"` and `id="outboundTableBody"`
    - Create container `<div id="viewZones" class="workspace-view" style="display:none;">...</div>`:
      - Header: "Denah Interaktif & Telemetri 4 Zona Workshop" + subtitle
      - 4 Interactive zone cards with class `zone-card interactive` and `data-zone="A"`, `data-zone="B"`, `data-zone="C"`, `data-zone="D"`
      - Filtered items table with `id="zoneFilterTable"` and `id="zoneFilterTableBody"`, heading `id="currentZoneHeading"`
    - Create container `<div id="viewAudit" class="workspace-view" style="display:none;">...</div>`:
      - Header: "Stock Opname & Audit Fisik Pakaian" + subtitle
      - Audit card:
        - Dropdown `id="auditItemSelect"`
        - Display `id="auditSystemStock"` (Stok Tercatat Sistem)
        - Input `id="auditPhysicalCount"` (Hitungan Fisik Nyata)
        - Element `id="auditDiscrepancyBadge"` (Selisih)
        - Input `id="auditReason"` (Keterangan / Alasan Selisih)
        - Button `id="btnSyncAuditStock"` "Sinkronkan Stok Sistem"
      - Table for audit history with `id="auditTable"` and `id="auditTableBody"`
- Create test file `tests/test_dom_structure.py` and follow TDD:
  1. Write failing test
  2. Run test to verify failure (Red)
  3. Modify `dashboard.html`
  4. Run test to verify pass (Green)
  5. Commit changes: `git commit -m "feat(html): add 6 modular workspace view containers and form markups"`
- Write full report to `.superpowers/sdd/2026-09-22-full-apparel-dashboard/task-1-report.md`.
