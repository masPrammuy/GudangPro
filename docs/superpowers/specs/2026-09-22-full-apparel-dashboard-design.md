# Spesifikasi Desain: Dashboard Konveksi Pakaian Interaktif & Bebas AI-Codet

- **Tanggal Dokumen**: 2026-09-22
- **Status**: Disetujui Melalui Brainstorming Bertahap
- **Pendekatan Arsitektur**: Opsi 1 (Seamless Tab Workspace)
- **Target Aplikasi**: Sistem Manajemen Produksi & Pergudangan Garmen Pakaian (*GudangPro Apparel*)

---

## 1. Latar Belakang & Tujuan

Aplikasi web pergudangan sebelumnya telah ditransformasikan menjadi aplikasi bertema industri konveksi dan manufaktur pakaian (*GudangPro Apparel*). Pengguna meminta agar:
1. **Seluruh modul dan menu di dashboard dapat berjalan 100% secara fungsional** tanpa tombol atau tampilan bohongan (*zero dummy interactions*).
2. **Tampilan antarmuka tidak bernuansa 'AI-codet' / template generik**: Menghapus nuansa kaku, gradien neon ungu klise, dan elemen dekoratif palsu. Menggantinya dengan visual workshop garmen profesional yang rapi, berkontras tinggi, padat data, dan intuitif bagi operator konveksi.

---

## 2. Arsitektur Workspace (Seamless Tab Workspace)

Aplikasi mengadopsi arsitektur **Single-Page Dynamic Tab Workspace** pada `dashboard.html`. Pengguna dapat beralih modul kerja secara seketika melalui navigasi sidebar tanpa perlu me-reload halaman peramban.

### 2.1 Modul Tampilan (View Containers)
1. `#viewOverview`: Dashboard Utama (Ringkasan KPI, Peringatan Stok Minimum Interaktif, Visualisasi Kapasitas 4 Zona Workshop, dan Log Transaksi Terkini).
2. `#viewInventory`: Stok Kain & Baju (Tabel master inventaris garmen dengan multi-filter, search, modal tambah barang, dan aksi cepat penyesuaian stok).
3. `#viewInbound`: Bahan Masuk / Inbound PO (Formulir penerimaan kain roll & aksesoris, penambahan stok otomatis, dan tabel riwayat PO).
4. `#viewOutbound`: Kirim Baju / Outbound DO (Formulir penerbitan Surat Jalan DO, validasi stok riil anti over-shipping, pemotongan stok otomatis, dan tabel log DO).
5. `#viewZones`: Zona Rak Konveksi (Denah interaktif 4 zona produksi pakaian dengan filter dinamis inventaris per zona dan kalkulasi okupansi rak riil).
6. `#viewAudit`: Audit Stok / Stock Opname (Formulir audit hitung fisik, kalkulasi selisih otomatis, 1-click stock alignment, dan arsip riwayat opname).

### 2.2 Navigasi & Komponen Shell
- **Sidebar Navigasi**: Menu samping memiliki item navigasi dengan ID eksplisit: `navOverview`, `navInventory`, `navInbound`, `navOutbound`, `navRacks`, `navAudit`. State aktif (`.active`) berpindah sesuai modul yang dipilih.
- **Top Bar Reaktif**: Breadcrumb dan judul modul kerja di bagian atas berganti secara otomatis mengikuti modul yang aktif.
- **Quick Action**: Tombol aksi cepat di header menyesuaikan konteks (contoh: di view Inventory menampilkan "Tambah Barang", di Inbound menampilkan "Catat Bahan Masuk", di Outbound menampilkan "Buat Surat Jalan").

---

## 3. Struktur Data & Manajemen State (Reactive Local-First)

Data disimpan dan disinkronisasi melalui `localStorage` peramban web pengguna sehingga data transaksi tetap tersimpan saat halaman ditutup atau dimuat ulang.

### 3.1 Model Data Master Inventaris (`gp_apparel_inventory`)
Setiap entitas inventaris garmen memiliki struktur:
```typescript
interface ApparelItem {
  id: string;              // ID unik (contoh: "item-1")
  sku: string;             // Kode SKU garmen (contoh: "FAB-CT30-BLK")
  name: string;            // Nama bahan / pakaian (contoh: "Kain Katun Combed 30s Hitam")
  category: 'kain' | 'aksesoris' | 'cutting' | 'baju'; // Kategori garmen
  stock: number;           // Jumlah stok saat ini
  unit: string;            // Satuan fisik (Roll, Lusin, Pcs, Cones)
  minStock: number;        // Batas ambang peringatan minimum
  rack: string;            // Lokasi rak (contoh: "A-01", "B-03", "D-02")
  zone: 'A' | 'B' | 'C' | 'D'; // Kode zona workshop
  updatedAt: string;       // Timestamp ISO pembaruan terakhir
}
```

### 3.2 Model Data Penerimaan Bahan (`gp_apparel_inbound_logs`)
```typescript
interface InboundLog {
  id: string;              // ID log
  poNo: string;            // Nomor PO (contoh: "PO-TX-2026-004")
  itemId: string;          // Referensi ke ApparelItem
  sku: string;
  itemName: string;
  qty: number;             // Jumlah roll/pcs masuk
  unit: string;
  supplier: string;        // Nama vendor tekstil / aksesoris
  lotNumber: string;       // Nomor lot celup / pabrik
  date: string;            // Tanggal penerimaan (YYYY-MM-DD)
  notes?: string;          // Catatan operator
  status: 'QC Passed';
}
```

### 3.3 Model Data Surat Jalan Pengiriman (`gp_apparel_outbound_logs`)
```typescript
interface OutboundLog {
  id: string;              // ID log
  doNo: string;            // Nomor Surat Jalan DO (contoh: "DO-GP-2026-012")
  itemId: string;          // Referensi ke ApparelItem (baju jadi)
  sku: string;
  itemName: string;
  qty: number;             // Jumlah baju dikirim
  unit: string;
  recipient: string;       // Reseller / Customer / Marketplace
  courier: string;         // Ekspedisi pengiriman
  date: string;            // Tanggal terbit DO (YYYY-MM-DD)
  status: 'Terkirim' | 'Dalam Pengiriman';
}
```

### 3.4 Model Data Audit Stock Opname (`gp_apparel_audit_logs`)
```typescript
interface AuditLog {
  id: string;              // ID log audit
  date: string;            // Tanggal audit
  itemId: string;
  sku: string;
  itemName: string;
  systemStock: number;     // Stok tercatat di sistem sebelum audit
  physicalStock: number;   // Hitungan riil di rak
  discrepancy: number;     // Selisih (physicalStock - systemStock)
  reason: string;          // Keterangan selisih (misal: "Barang reject QC")
  auditor: string;         // Nama petugas opname
}
```

---

## 4. Mekanisme Interaksi Antar Modul

1. **Inbound Transaksi -> Inventaris**:
   - Operator mengisi formulir penerimaan bahan.
   - Saat disimpan: `ApparelItem.stock += qty`.
   - Entitas baru ditambahkan ke `gp_apparel_inbound_logs`.
   - Muncul notifikasi toast hijau sukses, formulir direset, tabel inventaris dan overview otomatis diperbarui.

2. **Outbound Transaksi -> Inventaris**:
   - Operator memilih baju jadi dan memasukkan jumlah kirim.
   - Validasi: Jika `qty > ApparelItem.stock`, tombol terbit terkunci dan pesan galat merah muncul seketika.
   - Saat valid dan disimpan: `ApparelItem.stock -= qty`.
   - Entitas baru ditambahkan ke `gp_apparel_outbound_logs`.
   - Jika sisa stok menyentuh atau berada di bawah `minStock`, status otomatis berubah menjadi `⚠️ Stok Minimum` atau `🚨 Stok Habis`.

3. **Zona Workshop -> Filter Inventaris**:
   - Kartu Zona A, B, C, dan D menampilkan total stok dan persentase kapasitas maksimum.
   - Mengklik salah satu kartu zona akan memfilter tabel daftar barang di bawahnya untuk menampilkan hanya item dari zona tersebut, serta memberikan highlight aktif pada kartu terpilih.

4. **Stock Opname -> Sinkronisasi Stok**:
   - Operator memilih item garmen, sistem menampilkan stok sistem.
   - Operator mengetik hitungan fisik nyata. Sistem menghitung selisih (`discrepancy`) secara langsung (*real-time*).
   - Mengklik tombol "Sinkronisasi Stok" akan mengoreksi `ApparelItem.stock = physicalStock`, mencatat riwayat audit, dan memicu notifikasi pembaruan.

---

## 5. Pedoman Desain Anti-AI-Codet (Human-Crafted Apparel UI)

- **Color Harmony**: Palet netral slate (`#0f172a`, `#334155`, `#64748b`, `#f8fafc`, `#ffffff`) dengan aksen operasional fungsional (Indigo `#4f46e5`, Emerald `#10b981`, Amber `#d97706`, Rose `#e11d48`).
- **Data Density**: Menggunakan spasi kompak, tabel dengan garis tipis `#e2e8f0`, perataan angka rata kanan untuk stok, dan tag kategori monokromatis/lembut.
- **Terminologi Konveksi Asli**: Menggunakan istilah industri nyata seperti *"No. PO Roll Kain"*, *"No. Surat Jalan (DO)"*, *"Vendor Tekstil"*, *"Gudang Aksesoris Jahit"*, *"Area Cutting & WIP"*, *"Stock Opname"*, *"Lusin"*, *"Roll"*, *"Pcs"*.
- **Zero Mock Buttons**: Tidak ada tombol tanpa fungsi. Setiap tombol di sidebar dan aksi tabel terhubung dengan handler interaktif.

---

## 6. Rencana Verifikasi & Uji Kualitas

1. **Struktur DOM**: Verifikasi seluruh container view dan elemen form melalui script Python validator.
2. **Headless Browser Test (MS Edge)**:
   - Pengujian peralihan ke 6 tampilan view.
   - Eksekusi transaksi Inbound (+20 Roll Kain) dan verifikasi stok bertambah.
   - Eksekusi validasi Outbound (penolakan jika stok minus) dan pengiriman sukses.
   - Eksekusi audit fisik stock opname dan verifikasi sinkronisasi.
   - Uji klik interaktif pada denah 4 zona rak.
   - Pengecekan console peramban untuk menjamin 0 uncaught errors.
