# Desain Arsitektur Migrasi Flutter: GudangPro Apparel Mobile

**Tanggal:** 2026-10-17  
**Status:** Disetujui (Approved)  
**Target Komponen:** Aplikasi Mobile Cross-Platform Flutter (`mobile/`), Riverpod State Management, Supabase Realtime SDK, Adaptive Smartphone/Tablet Layout, & TDD Suites  
**Terkait:** Ekosistem GudangPro Apparel (Web Dashboard & Supabase Cloud PostgreSQL)

---

## 1. Latar Belakang & Ruang Lingkup

Aplikasi GudangPro Apparel berbasis web telah memiliki skema database PostgreSQL Supabase dengan database triggers (*anti-overshipping*, *auto-increment inbound*, dan *audit sync*). Untuk mendukung operasional lapangan konveksi (staf penerimaan bahan, operator meja cutting, staf gudang packing, dan supervisor lapangan), sistem dimigrasikan ke platform mobile **Flutter** (Android & iOS).

### Ruang Lingkup Fase Ini:
- Inisialisasi proyek Flutter di folder monorepo `mobile/`.
- Pengaturan dependensi modern: `flutter_riverpod`, `supabase_flutter`, `google_fonts`, `intl`.
- Arsitektur *Feature-First Clean Architecture*.
- Tampilan responsif adaptif untuk **Smartphone Android (< 600dp)** dan **Tablet Meja Cutting (≥ 600dp)**.
- Integrasi penuh dengan database Supabase Cloud (REST & Realtime WebSocket stream).
- Validasi transaksi operasional (Inbound PO, Outbound DO dengan pencegahan *over-shipping*, Stock Opname).
- Pengujian otomatis berbasis TDD (*Unit Tests & Widget Tests*).
- *(Catatan: Integrasi scanner barcode kamera fisik dan printer thermal bluetooth 58mm/80mm akan ditambahkan pada sub-fase berikutnya sesuai kesepakatan scoping)*.

---

## 2. Struktur Proyek & Organisasi Kode (`mobile/`)

```
mobile/
├── pubspec.yaml                       # Konfigurasi dependensi Flutter
├── test/
│   ├── unit/
│   │   ├── item_model_test.dart       # Pengujian serialisasi & getter stok
│   │   ├── inbound_model_test.dart    # Pengujian model PO bahan masuk
│   │   ├── outbound_model_test.dart   # Pengujian model DO & validasi over-shipping
│   │   └── audit_model_test.dart      # Pengujian model opname fisik
│   └── widget/
│       ├── adaptive_layout_test.dart  # Pengujian breakpoint HP (<600dp) vs Tablet (>=600dp)
│       └── status_badge_test.dart     # Pengujian rendering badge status garmen
└── lib/
    ├── main.dart                      # Entrypoint: Inisialisasi Supabase & ProviderScope
    ├── app.dart                       # MaterialApp & routing utama
    ├── core/
    │   ├── constants/
    │   │   ├── app_colors.dart        # Slate, Emerald, Amber, Rose, Indigo
    │   │   └── app_constants.dart     # Breakpoints (600dp), Supabase default config
    │   ├── theme/
    │   │   └── app_theme.dart         # Tema industrial garmen (clean, non-AI)
    │   ├── utils/
    │   │   └── formatters.dart        # Format tanggal & kuantitas Indonesia
    │   └── widgets/
    │       ├── adaptive_scaffold.dart # Navigasi dinamis: BottomNav (HP) vs NavRail (Tablet)
    │       ├── status_badge.dart      # Badge Tersedia, Stok Minimum, Stok Habis
    │       └── connection_pill.dart   # Indikator status koneksi Supabase Realtime
    └── features/
        ├── inventory/
        │   ├── data/
        │   │   ├── item_model.dart
        │   │   └── inventory_repository.dart # Watch stream realtime & fetch
        │   ├── presentation/
        │   │   ├── inventory_screen.dart     # Grid / List view adaptif
        │   │   ├── widgets/item_card.dart
        │   │   └── widgets/zone_filter_bar.dart
        │   └── providers/
        │       └── inventory_providers.dart  # StreamProvider untuk live inventory
        ├── inbound/
        │   ├── data/
        │   │   ├── inbound_model.dart
        │   │   └── inbound_repository.dart   # Insert PO to Supabase
        │   ├── presentation/
        │   │   ├── inbound_screen.dart       # Form penerimaan kain & log
        │   │   └── widgets/inbound_form.dart
        │   └── providers/
        │       └── inbound_providers.dart
        ├── outbound/
        │   ├── data/
        │   │   ├── outbound_model.dart
        │   │   └── outbound_repository.dart  # Insert DO with anti-overshipping
        │   ├── presentation/
        │   │   ├── outbound_screen.dart      # Form surat jalan baju & log
        │   │   └── widgets/outbound_form.dart
        │   └── providers/
        │       └── outbound_providers.dart
        └── audit/
            ├── data/
            │   ├── audit_model.dart
            │   └── audit_repository.dart     # Insert opname sync
            ├── presentation/
            │   ├── audit_screen.dart         # Form hitung fisik & discrepancy
            │   └── widgets/discrepancy_card.dart
            └── providers/
                └── audit_providers.dart
```

---

## 3. Spesifikasi Model Data & Entitas

Model data Dart memetakan kolom dari tabel Supabase PostgreSQL secara presisi:

### 3.1 `ItemModel` (Tabel `inventory_items`)
- `id`: `String` (UUID)
- `sku`: `String` (misal: `'KAN-CMB-01'`, `'BJU-OVR-BLK'`)
- `name`: `String`
- `category`: `String` (`'Kain & Bahan Baku'`, `'Aksesoris Jahit'`, `'Pola & Hasil Cutting'`, `'Baju Jadi (Siap Kirim)'`, `'Packaging & Hangtag'`)
- `qty`: `int` (>= 0)
- `unit`: `String` (`'Roll'`, `'Lusin'`, `'Pcs'`, `'Meter'`, `'Kg'`, `'Pack'`, `'Cones'`)
- `minStock`: `int`
- `location`: `String`
- `zone`: `String` (`'A'`, `'B'`, `'C'`, `'D'`)
- `status`: `String` (`'Tersedia'`, `'⚠️ Stok Minimum!'`, `'🚨 Stok Habis'`)
- `updatedAt`: `DateTime`

### 3.2 `InboundModel` (Tabel `inbound_transactions`)
- `id`: `String?`
- `poNumber`: `String` (`'PO-TX-YYYY-XXX'`)
- `itemId`: `String`
- `qty`: `int` (> 0)
- `supplier`: `String`
- `lotNumber`: `String`
- `notes`: `String`
- `status`: `String` (`'QC Passed'`)
- `receivedAt`: `DateTime`

### 3.3 `OutboundModel` (Tabel `outbound_transactions`)
- `id`: `String?`
- `doNumber`: `String` (`'DO-GP-YYYY-XXX'`)
- `itemId`: `String`
- `qty`: `int` (> 0)
- `recipient`: `String`
- `courier`: `String`
- `notes`: `String`
- `status`: `String` (`'Terkirim'`)
- `dispatchedAt`: `DateTime`

### 3.4 `AuditModel` (Tabel `stock_audits`)
- `id`: `String?`
- `itemId`: `String`
- `systemStock`: `int`
- `physicalStock`: `int`
- `discrepancy`: `int` (kalkulasi: `physicalStock - systemStock`)
- `reason`: `String`
- `auditedAt`: `DateTime`

---

## 4. Aliran Data & Supabase Realtime Stream

1. **Aliran Live Stream Inventaris**:
   - `InventoryRepository.watchInventory()` menginisialisasi listener:
     ```dart
     supabase.from('inventory_items').stream(primaryKey: ['id']).order('created_at', ascending: true);
     ```
   - Stream dipetakan ke `List<ItemModel>` dan disajikan melalui `inventoryListStreamProvider`.
   - UI bereaksi instan saat ada perubahan baris (INSERT/UPDATE/DELETE) tanpa polling.

2. **Aliran Mutasi Transaksi & Proteksi Database**:
   - **Inbound**: `InboundRepository.submitInbound(model)` -> trigger PostgreSQL `trg_inbound_stock_increment` menambah `qty` dan memperbarui `status`.
   - **Outbound**: `OutboundRepository.submitOutbound(model)` -> trigger PostgreSQL `trg_outbound_stock_deduct` mengunci baris dengan `FOR UPDATE`. Jika `qty` melebihi stok, melempar PostgreSQL Exception yang ditangkap oleh Flutter dan ditampilkan sebagai pesan galat dialog/snackBar.
   - **Stock Opname**: `AuditRepository.submitAudit(model)` -> trigger PostgreSQL `trg_audit_stock_sync` memperbarui master stok fisik.

---

## 5. Antarmuka Pengguna Adaptif (Adaptive UI)

- **Breakpoint Layar**:
  - `width < 600dp`: Smartphone mode -> Menampilkan `BottomNavigationBar` (4 tab: Stok, Masuk, Keluar, Opname).
  - `width >= 600dp`: Tablet / Meja Cutting mode -> Menampilkan `NavigationRail` vertikal di sisi kiri dan tata letak *Master-Detail Split View* (dua panel berdampingan).
- **Desain Industrial & Kontras Tinggi**:
  - Tipografi tegas, angka kuantitas tebal.
  - Kartu barang dilengkapi indikator visual zona:
    - Zona A (Kain): Border biru-slate
    - Zona B (Aksesoris): Border abu netral
    - Zona C (Cutting & WIP): Border indigo
    - Zona D (Baju Jadi & Packing): Border emerald

---

## 6. Strategi Pengujian (Test-Driven Development)

1. **Unit Testing (`flutter test test/unit/`)**:
   - Serialisasi / deserialisasi JSON keempat model data.
   - Validasi logika over-shipping dan kalkulasi selisih opname.
   - Verifikasi status badge berdasarkan `qty` dan `minStock`.
2. **Widget Testing (`flutter test test/widget/`)**:
   - Uji adaptivitas `AdaptiveScaffold`: verifikasi kemunculan `BottomNavigationBar` pada ukuran layar HP (400x800) dan `NavigationRail` pada layar Tablet (800x1280).
   - Uji komponen form dan validasi tombol submit.
