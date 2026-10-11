# PRODUCT REQUIREMENTS DOCUMENT (PRD)
## GudangPro (Warehouse Management System)

| Parameter | Keterangan |
| :--- | :--- |
| **Nama Produk / Aplikasi** | **GudangPro (Warehouse Management System)** |
| **Domain Bisnis** | Manajemen Pergudangan & Rantai Pasok (Logistik / Supply Chain & Inventory) |
| **Status Dokumen** | v2.0 (Development Ready / Approved Specification) |
| **Live Demo (Vercel)** | [https://gudang-pro-flame.vercel.app/](https://gudang-pro-flame.vercel.app/) |
| **Fokus Industri** | Apparel, Konveksi & Manufaktur Pakaian |

---

## 1. Latar Belakang & Filosofi Produk

### 1.1 Belajar dari Eksplorasi Mibebi Kasir
Pengembangan GudangPro berangkat dari studi mendalam terhadap pola rancang bangun aplikasi bisnis (Point of Sale Mibebi Kasir). Pembelajaran utama dari proses tersebut adalah membedakan produk ke dalam **Dua Lapisan Nilai (Two-Layered Value)**:
1. **Lapisan 1 — Fitur Inti (Core Features):** Fungsi fundamental yang wajib ada agar sistem dapat diakui secara sah sebagai WMS.
2. **Lapisan 2 — Fitur Bernilai Tambah (Value-Added Features):** Fitur proaktif dan cerdas yang menyelesaikan masalah finansial atau operasional nyata serta menjadi pembeda (*competitive edge*).

### 1.2 Prinsip Perancangan
$$\text{Masalah Nyata Pengguna} \longrightarrow \text{Proses Bisnis Terstandar} \longrightarrow \text{Fitur Inti} \longrightarrow \text{Nilai Tambah Terukur} \longrightarrow \text{Dampak Bisnis}$$

---

## 2. Analisis Masalah Nyata di Domain Pergudangan

Teknologi bukan masalah bisnis utama. Fokus perancangan sistem berakar pada 3 masalah operasional nyata di lantai gudang:

1. **Selisih Stok Fisik vs Catatan (*Stock Discrepancy*)**
   - **Akar Masalah:** Keterlambatan input manual di kertas/spreadsheet menyebabkan selisih antara saldo komputer dan fisik di rak.
   - **Dampak Bisnis:** Penolakan pesanan mendadak, keterlambatan pengiriman (*fulfillment delay*), dan kerugian reputasi bisnis.

2. **Waktu Pengambilan Barang yang Lama (*High Retrieval Time*)**
   - **Akar Masalah:** Penataan barang tidak teratur dan urutan pengambilan (*picking list*) tidak memperhatikan denah lokasi rak.
   - **Dampak Bisnis:** Staf menghabiskan 40%–60% jam kerjanya hanya untuk mondar-mandir mencari lokasi barang.

3. **Penumpukan Barang Mati (*Dead Stock*) & Modal Macet**
   - **Akar Masalah:** Barang yang pertama kali datang tertimbun barang baru karena alur FIFO (First-In, First-Out) gagal ditegakkan secara sistemik.
   - **Dampak Bisnis:** Penurunan kualitas bahan baku, kedaluwarsa, dan modal kerja terkunci hingga puluhan juta rupiah.

---

## 3. Fondasi 5 Fitur Inti GudangPro (Lapisan 1: WMS Core)

Kelima fitur ini merupakan syarat mutlak agar sistem sah diklasifikasikan sebagai *Warehouse Management System*:

| No | Fitur Inti | Fungsi Utama | Alasan Wajib Ada (*Rationale*) |
| :---: | :--- | :--- | :--- |
| **1** | **Master Data SKU & Katalog Barang** | Mengelola daftar SKU, nama barang, satuan (Roll, Lusin, Pcs), barcode, dan kategori. | Fondasi sistem; tidak ada transaksi mutasi yang bisa diproses tanpa identitas barang yang sah. |
| **2** | **Pencatatan Barang Masuk (*Inbound Receiving*)** | Mencatat penerimaan stok dari pemasok (PO Supplier) beserta no batch/lot roll. | Pintu masuk penambahan saldo stok resmi yang dapat dipertanggungjawabkan. |
| **3** | **Pencatatan Pengeluaran Barang (*Outbound Dispatch*)** | Memvalidasi pengurangan stok untuk pesanan/surat jalan (Delivery Order). | Menjamin pemotongan fisik barang terverifikasi dan saldo berkurang real-time. |
| **4** | **Pemetaan Lokasi Rak & Zona (*Bin Location Mapping*)** | Menetapkan koordinat alamat penyimpanan presisi (Zona, Lorong, Rak, Level). | Menghilangkan kebingungan lokasi dan memandu staf langsung ke titik simpan. |
| **5** | **Kartu Stok & Jejak Audit (*Stock Ledger & Audit Trail*)** | Merekam kronologi kronologis seluruh mutasi (waktu, jenis mutasi, kuantitas, operator). | Instrumen utama investigasi dan rekonsiliasi saat audit berkala (*stock opname*). |

---

## 4. Tiga Fitur Bernilai Tambah Inovatif (Lapisan 2: Value-Added)

```
┌────────────────────────────────────────────────────────┐
│                 GudangPro WMS Platform                 │
└──────────────────────────┬─────────────────────────────┘
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
┌─────────────────────────┐ ┌─────────────────────────┐
│     LAPISAN 1: INTI     │ │  LAPISAN 2: NILAI TAMBAH│
│   (Core Transactions)   │ │      (Value-Added)      │
├─────────────────────────┤ ├─────────────────────────┤
│ • Master SKU            │ │ 1. Smart Reorder Point  │
│ • Inbound PO Receiving  │ │    & Auto Alert         │
│ • Outbound DO Dispatch  │═│ 2. Guided Batch Picking │
│ • Pemetaan Rak & Zona   │ │    Route (S-Shape)      │
│ • Kartu Stok & Audit    │ │ 3. Dead Stock Aging     │
└─────────────────────────┘ │    Analyzer             │
                            └─────────────────────────┘
```

### 4.1 Fitur 1: Smart Reorder Point (ROP) & Auto Stock-Out Alert
- **Cara Kerja:** Sistem secara dinamis mengevaluasi batas aman stok (*Safety Stock*) dan titik pemesanan ulang (*Reorder Point*) untuk setiap SKU. Begitu kuantitas menyentuh batas minimum, sistem otomatis memunculkan banner peringatan dan notifikasi toast.
- **Target Dampak:** Mencegah terjadinya kekosongan stok (*Zero Stock-Out*) dan potensi kehilangan penjualan hingga 90%.

### 4.2 Fitur 2: Guided S-Shape Batch Picking Route
- **Cara Kerja:** Sistem mengelompokkan pesanan kirim dan mengurutkan rute pengambilan barang menyusuri lorong gudang secara satu arah berkesinambungan (pola S-Shape), tanpa staf perlu berjalan bolak-balik.
- **Target Dampak:** Memangkas jarak tempuh staf dan mengurangi siklus waktu pengambilan (*picking cycle time*) sebesar 35% – 50%.

### 4.3 Fitur 3: Dead Stock Aging Analyzer & Slow-Moving Clearance Engine
- **Cara Kerja:** Melacak usia penyimpanan barang di rak (kuadran Fast-Moving <30 hari, Medium 30–60 hari, Slow-Moving 60–90 hari, dan Dead Stock >90 hari tanpa mutasi). Menghasilkan rekomendasi tindakan: promo diskon cuci gudang atau retur supplier.
- **Target Dampak:** Mempercepat perputaran modal kerja (*Inventory Turnover*) dan mengoptimalkan kapasitas tampung rak.

---

## 5. Prioritas Ruang Lingkup (MoSCoW Framework)

| Fitur | Kategori Prioritas | Pertimbangan Teknis & Bisnis |
| :--- | :---: | :--- |
| **5 Fitur Inti WMS + Smart Reorder Point Alert** | **MUST HAVE** | Wajib untuk fondasi operasional dan langsung menyelesaikan masalah kehabisan stok. |
| **Dead Stock Aging Analyzer & Slow-Moving Alert** | **SHOULD HAVE** | Menghubungkan mutasi barang dengan efisiensi finansial dan pembebasan modal kerja. |
| **Guided Batch Picking Route Optimizer** | **COULD HAVE** | Fitur lanjutan optimasi rute fisik lantai gudang untuk pengembangan tahap berikutnya. |
| **Sensor Timbangan IoT & GPS Fleet Tracking** | **WON'T HAVE (Out of Scope)** | Dibatasi secara sadar agar pengembangan terfokus pada kesempurnaan perangkat lunak web. |

---

## 6. Spesifikasi Arsitektur Sistem & Prototipe Web

### 6.1 Arsitektur Antarmuka (Seamless Tab Workspace)
Aplikasi mengusung pola **Single-Page Dynamic Tab Workspace** di `dashboard.html` dengan 6 modul kerja tanpa reload:
1. `#viewOverview`: Ringkasan metrik KPI, peringatan stok minimum, okupansi 4 zona rak, dan log transaksi mutasi.
2. `#viewInventory`: Katalog master data bahan baku kain, benang, dan pakaian jadi beserta multi-filter.
3. `#viewInbound`: Formulir penerimaan PO bahan kain masuk, no lot roll, dan mutasi otomatis penambahan stok.
4. `#viewOutbound`: Formulir pengeluaran Surat Jalan DO dengan validasi anti-*overselling* dan pemotongan stok otomatis.
5. `#viewZones`: Denah interaktif 4 zona workshop garmen (Kain Roll, Aksesoris, Pola WIP, Baju Jadi).
6. `#viewAudit`: Formulir stock opname fisik, kalkulasi selisih (*discrepancy badge*), dan sinkronisasi saldo instan.

### 6.2 Tech Stack
- **Frontend:** Semantic HTML5, Modern Responsive CSS3 (Industrial Slate Tone), Vanilla JavaScript ES6+ (Local-First Reactive State).
- **Backend / Auth:** Supabase Client (Database & Google Cloud OAuth 2.0 / Email-Password Auth).
- **Test Runner:** Python 3.13 Automated Test Suite (Verifikasi struktur DOM & logika transaksi state).
- **Deployment:** Vercel Hosting dengan integrasi auto-build.

---

## 7. Model Data Utama (State Schema)

```typescript
// Entitas Master Inventaris
interface ApparelItem {
  id: string;              // ID unik (contoh: "item-1")
  sku: string;             // Kode SKU (contoh: "FAB-CT30-BLK")
  name: string;            // Nama bahan / produk
  category: 'kain' | 'aksesoris' | 'cutting' | 'baju';
  stock: number;           // Kuantitas stok saat ini
  unit: string;            // Satuan (Roll, Lusin, Pcs, Cones)
  minStock: number;        // Ambang batas peringatan minimum
  rack: string;            // Nomor rak (contoh: "A-01", "D-02")
  zone: 'A' | 'B' | 'C' | 'D'; // Kode zona workshop
  updatedAt: string;       // Timestamp ISO pembaruan terakhir
}

// Log Transaksi Mutasi Inbound
interface InboundLog {
  id: string;              // Nomor Bukti Terima (contoh: "INB-2026-001")
  poNumber: string;        // Nomor PO Supplier
  supplier: string;        // Nama Pemasok Bahan
  lotNumber: string;       // Nomor Lot / Roll Bahan
  itemId: string;          // Relasi SKU
  itemName: string;        // Nama Bahan
  qty: number;             // Jumlah Masuk
  unit: string;            // Satuan
  date: string;            // Tanggal Terima
  operator: string;        // Nama Staf Gudang
}
```

---

## 8. Rumusan Value Proposition

> *"GudangPro tidak hanya membantu mencatat keluar-masuknya barang di gudang, tetapi juga secara aktif mencegah kerugian akibat kehabisan barang (**stock-out**) dan memangkas waktu pencarian barang melalui fitur peringatan dini ambang stok pintar (**Smart Reorder Point**) dan pemetaan lokasi rak penyimpanan presisi (**Bin Location Mapping**)."*
