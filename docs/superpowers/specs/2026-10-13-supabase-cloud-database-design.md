# Desain Arsitektur Sub-Project 1: Supabase Cloud Database Backend (GudangPro Apparel)

**Tanggal:** 2026-10-13  
**Status:** Draf Tinjauan  
**Target Komponen:** Skema Database PostgreSQL, Triggers Anti-Overshipping, Realtime Event Stream, & Row Level Security (RLS)  
**Terkait:** Migrasi Ekosistem GudangPro Apparel (Web Dashboard & Flutter Mobile App)

---

## 1. Latar Belakang & Tujuan

Aplikasi GudangPro Apparel saat ini telah memiliki 6 modul operasional frontend yang bekerja penuh di browser dengan *client-side state* dan `localStorage`. Untuk mendukung operasional multi-perangkat (Web Admin, Tablet Workshop Cutting, dan Smartphone Staff Lapangan) serta persiapan migrasi penuh ke **Flutter**, diperlukan repositori data cloud terpusat dengan integritas data tingkat database (*database-level integrity*).

Sub-Project 1 ini berfokus pada perancangan dan implementasi fondasi backend **Supabase PostgreSQL** yang akan menjadi sumber kebenaran tunggal (*single source of truth*) bagi Web Dashboard maupun aplikasi Flutter.

---

## 2. Arsitektur Relasi & Entitas Data

Skema database terdiri dari 5 entitas utama yang saling berelasi dengan proteksi integritas referensial:

```
+-------------------------------------------------------------+
|                        auth.users                           |
+-------------------------------------------------------------+
                              | 1:1
                              v
+-------------------------------------------------------------+
|                      public.profiles                        |
|  - id (UUID PK -> auth.users)                               |
|  - full_name (TEXT)                                         |
|  - role (owner | supervisor | inbound_staff | ...)          |
|  - phone_number, avatar_url, timestamps                     |
+-------------------------------------------------------------+
       |                           |                      |
       | 1:N                       | 1:N                  | 1:N
       v                           v                      v
+---------------------+   +---------------------+   +---------------------+
| inbound_transactions|   |outbound_transactions|   |    stock_audits     |
| - po_number (UNIQUE)|   | - do_number (UNIQUE)|   | - system_stock      |
| - item_id (FK)      |   | - item_id (FK)      |   | - physical_stock    |
| - qty (> 0)         |   | - qty (> 0)         |   | - discrepancy       |
| - received_by (FK)  |   | - dispatched_by (FK)|   | - audited_by (FK)   |
+---------------------+   +---------------------+   +---------------------+
       |                           |                      |
       +-------------> [FK] <------+                      |
                       |                                  |
                       v                                  v
+-------------------------------------------------------------+
|                   public.inventory_items                    |
|  - id (UUID PK)                                             |
|  - sku (TEXT UNIQUE)                                        |
|  - name, category, unit, location                           |
|  - zone ('A' | 'B' | 'C' | 'D')                             |
|  - qty (INTEGER >= 0)                                       |
|  - min_stock (INTEGER >= 0)                                 |
|  - status ('Tersedia' | '⚠️ Stok Minimum!' | '🚨 Stok Habis')|
+-------------------------------------------------------------+
```

### 2.1 Definisi Tabel

1. **`profiles`**
   - Menghubungkan akun otentikasi Supabase (`auth.users`) dengan data staf garment.
   - Kolom `role`: `owner`, `supervisor`, `inbound_staff`, `cutting_operator`, `outbound_staff`.
2. **`inventory_items`**
   - Master data bahan baku (roll kain), aksesoris garment (benang, kancing, resleting), pola cutting WIP, baju jadi, dan packaging.
   - Validasi `CHECK (qty >= 0)` memastikan kuantitas stok tidak pernah bernilai negatif.
   - Zona fisik: Zona A (Kain Utama), Zona B (Aksesoris Jahit), Zona C (Meja Potong & Pola), Zona D (Baju Jadi & Packing).
3. **`inbound_transactions`**
   - Log penerimaan bahan masuk dengan nomor Purchase Order (`PO-TX-YYYY-XXX`).
   - Mencatat supplier, nomor lot kain, status QC (`QC Passed`), dan staf penerima.
4. **`outbound_transactions`**
   - Log pengiriman surat jalan / Delivery Order (`DO-GP-YYYY-XXX`).
   - Mencatat penerima / buyer, ekspedisi/kurir, status pengiriman (`Terkirim`), dan staf pengirim.
5. **`stock_audits`**
   - Log audit fisik berkala (stock opname).
   - Mencatat stok sistem vs stok fisik aktual, deviasi/selisih (*discrepancy*), serta alasan penyesuaian.

---

## 3. Logika Mutasi Otomatis & Proteksi Database Triggers

Untuk mencegah anomali stok, mutasi tidak dikelola secara manual oleh klien melainkan dieksekusi secara atomik oleh PostgreSQL Triggers:

### 3.1 Trigger Inbound (`trg_inbound_stock_increment`)
- **Event:** `AFTER INSERT ON public.inbound_transactions`
- **Fungsi:** `fn_handle_inbound_stock()`
- **Tindakan:**
  - Menambah `inventory_items.qty` sebesar `NEW.qty`.
  - Memperbarui `status`:
    - Jika `qty == 0` -> `'🚨 Stok Habis'`
    - Jika `qty <= min_stock` -> `'⚠️ Stok Minimum!'`
    - Jika `qty > min_stock` -> `'Tersedia'`
  - Memperbarui `updated_at = NOW()`.

### 3.2 Trigger Outbound Anti Over-Shipping (`trg_outbound_stock_deduct`)
- **Event:** `BEFORE INSERT ON public.outbound_transactions`
- **Fungsi:** `fn_handle_outbound_stock()`
- **Tindakan:**
  - Mengunci baris item terkait dengan `SELECT ... FOR UPDATE` guna mencegah *race condition* ketika dua staf mengajukan DO serentak.
  - Memeriksa apakah `current_qty < NEW.qty`.
  - Jika stok kurang, trigger langsung melempar `RAISE EXCEPTION` dengan pesan spesifik (*"Stok tidak mencukupi untuk item... Tersedia hanya X pcs, diminta Y pcs"*), membatalkan seluruh transaksi INSERT.
  - Jika stok cukup, memotong `inventory_items.qty` sebesar `NEW.qty` dan memperbarui status peringatan secara otomatis.

### 3.3 Trigger Stock Opname (`trg_audit_stock_sync`)
- **Event:** `AFTER INSERT ON public.stock_audits`
- **Fungsi:** `fn_handle_audit_stock_sync()`
- **Tindakan:**
  - Menyelaraskan master stok: `inventory_items.qty = NEW.physical_stock`.
  - Menghitung ulang status peringatan stok dan memperbarui `updated_at`.

---

## 4. Supabase Realtime Stream

Tabel berikut didaftarkan ke publikasi realtime Supabase (`supabase_realtime`):
- `public.inventory_items`
- `public.inbound_transactions`
- `public.outbound_transactions`
- `public.stock_audits`

**Dampak:** Setiap mutasi stok di gudang (misal staf inbound memindai roll kain masuk atau staf outbound menerbitkan DO) akan memicu event websocket broadcast ke seluruh klien (Web Dashboard dan Flutter app) tanpa perlu tombol refresh manual.

---

## 5. Keamanan & Hak Akses (Row Level Security / RLS)

Sistem menerapkan RBAC (*Role-Based Access Control*) berbasis RLS:

| Modul / Tabel | Owner | Supervisor | Inbound Staff | Cutting Operator | Outbound Staff |
| :--- | :---: | :---: | :---: | :---: | :---: |
| **profiles** | R/W Penuh | R/W Penuh | Read Profil Tim | Read Profil Tim | Read Profil Tim |
| **inventory_items** | R/W Penuh | R/W Penuh | Read Master | Read Master | Read Master |
| **inbound_transactions** | Read & Buat PO | Read & Buat PO | Read & Buat PO | Read Saja | Read Saja |
| **outbound_transactions**| Read & Buat DO | Read & Buat DO | Read Saja | Read Saja | Read & Buat DO |
| **stock_audits** | Read & Opname | Read & Opname | Read Saja | Read Saja | Read Saja |

Helper Function `public.get_current_user_role()` mengekstrak role dari tabel `profiles` berdasarkan `auth.uid()` secara aman (`SECURITY DEFINER`).

---

## 6. Integrasi Frontend & Strategi Offline-First (Local Fallback)

1. **Klien Web (`supabase-client.js`)**:
   - Berisi inisialisasi koneksi SDK Supabase (`createClient`).
   - Dilengkapi detektor koneksi: jika kredensial Supabase (`SUPABASE_URL` dan `SUPABASE_ANON_KEY`) belum dikonfigurasi atau jaringan terputus, sistem secara mulus (*graceful fallback*) beralih ke engine `localStorage` yang sudah teruji.
2. **Kesiapan Migrasi Flutter**:
   - Struktur data model Dart akan mencerminkan struktur kolom tabel di atas secara 1-ke-1 (`ItemModel`, `InboundModel`, `OutboundModel`, `AuditModel`).

---

## 7. Verifikasi & Pengujian

1. **Pengujian Skema SQL**:
   - Uji parsing sintaks DDL, relasi foreign key, dan fungsi trigger menggunakan test runner Python/Postgres validator.
2. **Pengujian Fungsional Trigger**:
   - Verifikasi penambahan stok saat PO inbound dibuat.
   - Verifikasi pelemparan eksepsi saat pengiriman melebihi stok yang ada (*anti over-shipping*).
   - Verifikasi rekonsiliasi stok saat audit fisik selesai.
3. **Pengujian Non-Regresi Web**:
   - Menjalankan 7 test suite yang ada (`test_dom_structure.py`, `test_tab_switcher.py`, `test_inbound_logic.py`, `test_outbound_logic.py`, `test_zones_and_audit.py`, `test_e2e_browser.py`) untuk memastikan kompatibilitas penuh.
