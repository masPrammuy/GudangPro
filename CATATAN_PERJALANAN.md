# CATATAN PERJALANAN PENGEMBANGAN SISTEM (ENGINEERING DEVLOG)
## Proyek: GudangPro — Warehouse Management System (WMS) Apparel & Konveksi

| Informasi | Detail |
| :--- | :--- |
| **Nama Mahasiswa** | [Nama Mahasiswa] |
| **NIM** | [NIM] |
| **Program Studi** | Informatika / Ilmu Komputer |
| **Judul Proyek / Skripsi** | *Pengembangan Prototipe Sistem Manajemen Pergudangan (GudangPro) Berbasis Web untuk Pengelolaan Stok Real-Time, Pemetaan Lokasi Rak, dan Optimasi Alur Barang Masuk-Keluar* |
| **Dosen Pembimbing** | [Nama Dosen Pembimbing] |
| **Status Saat Ini** | **Tahap 1 Selesai** (PRD Approved, Core Architecture Implemented, 11 Automated Tests Passed, Live Deployed) |
| **Tautan Live Demo** | [https://gudang-pro-flame.vercel.app/](https://gudang-pro-flame.vercel.app/) |
| **Repositori Kode** | [Tautan Repositori GitHub Anda] |

---

## 1. Ringkasan Eksekutif (Executive Summary)

Dokumen ini merekam rekam jejak (*devlog*) proses rekayasa perangkat lunak sistem **GudangPro** dari fase ideasi konseptual, evaluasi kebutuhan produk, perancangan arsitektur, hingga implementasi prototipe fungsional berbasis web yang teruji secara otomatis (*automated testing*) dan ter-*deploy* ke lingkungan *production* (Vercel).

Pengembangan tidak langsung melompat ke penulisan kode (*vibe coding* tanpa arah), melainkan mengikuti kaidah rekayasa perangkat lunak yang berdisiplin:
1. **Fase Analisis Domain Bisnis:** Melakukan dekonstruksi sistem aplikasi komersial (Mibebi Kasir) untuk membedakan secara tegas antara **Fitur Inti (*Core*)** dan **Fitur Bernilai Tambah (*Value-Added*)**.
2. **Fase Spesifikasi Kebutuhan:** Menyusun dokumen formal *Product Requirements Document* ([PRD.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/PRD.md)) dengan kerangka prioritas MoSCoW dan batasan ruang lingkup yang terukur.
3. **Fase Rekayasa Arsitektur & Antarmuka:** Mentransformasikan desain generik menjadi antarmuka profesional industri garmen (*anti AI-codet*) dengan arsitektur *Seamless Tab Workspace* 6 modul.
4. **Fase Implementasi & Quality Assurance:** Menerapkan siklus *Test-Driven Development* (TDD) dengan 11 unit test otomatis yang memvalidasi struktur DOM, mutasi saldo inventaris, dan navigasi state.

---

## 2. Kronologi Perjalanan Pengembangan (Milestones Timeline)

```
[14 September 2026]
   │  Milestone 1: Studi Eksplorasi Mibebi Kasir & Rumusan 2 Lapisan Nilai
   │  Milestone 2: Identifikasi 3 Masalah Gudang & 5 Fitur Inti WMS
   │  Milestone 3: Perancangan Slide Presentasi (10 Slide SVG) & Naskah Lisan
   ▼
[22 September 2026]
   │  Milestone 4: Formalisasi PRD v2.0 & Spesifikasi Teknis Sistem
   │  Milestone 5: Setup Autentikasi Multi-Metode (Supabase & Google Cloud OAuth)
   │  Milestone 6: Refactoring Arsitektur "Seamless Tab Workspace" 6 Modul
   │  Milestone 7: Styling CSS Industrial Slate & Eliminasi Dummy Interface
   │  Milestone 8: Implementasi Modul Transaksional Inbound & Low Stock Alert
   │  Milestone 9: Pengujian Otomatis (11 Unit Tests Passed) & Live Deployment Vercel
   ▼
[Status Saat Ini: Siap Evaluasi Bimbingan Dosen]
```

---

### Milestone 1 — Eksplorasi Produk & Domain Research (14 Sep 2026)
- **Aktivitas:** Menguji dan membedah alur sistem bisnis Mibebi Kasir (Point of Sale) dari sudut pandang pemilik usaha dan kasir.
- **Hasil Kunci:**
  - Merumuskan konsep **Two-Layered Value Product**: Memahami bahwa aplikasi bisnis tidak boleh hanya menjadi kalkulator pasif.
  - Membedah fitur-fitur pembeda seperti *Smart Upselling*, *Loyalty Points*, dan *Last Bite*.
  - Dokumen tersimpan: [dokumen_presentasi_gudangpro.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/dokumen_presentasi_gudangpro.md).

### Milestone 2 — Kontekstualisasi Domain ke GudangPro (14 Sep 2026)
- **Aktivitas:** Mentransfer prinsip bernilai tambah ke domain pergudangan tanpa menjiplak mentah-mentah model F&B.
- **Hasil Kunci:**
  - Mengidentifikasi 3 masalah utama lantai gudang:
    1. *Stock Discrepancy* (selisih data fisik vs sistem).
    2. *High Retrieval Time* (waktu jalan staf yang lama saat *picking*).
    3. *Dead Stock* (barang mati menumpuk mengunci modal kerja).
  - Merumuskan 5 Fitur Inti WMS: Master SKU, Inbound, Outbound, Pemetaan Rak (*Bin Mapping*), dan Kartu Stok (*Audit Trail*).
  - Merumuskan 3 Fitur Bernilai Tambah: *Smart Reorder Point*, *Guided S-Shape Batch Picking*, dan *Dead Stock Aging Analyzer*.
  - Menyiapkan aset visual presentasi lisan: 10 slide infografis format SVG di direktori `slides/` beserta modul web viewer di [presentation.html](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/presentation.html) dan naskah lisan di [naskah_presentasi_lisan.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/naskah_presentasi_lisan.md).

### Milestone 3 — Penyusunan PRD & Spesifikasi Teknis (22 Sep 2026)
- **Aktivitas:** Memformalkan dokumen persyaratan sistem ke dalam [PRD.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/PRD.md) dan spesifikasi desain di [docs/superpowers/specs/2026-09-22-full-apparel-dashboard-design.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/docs/superpowers/specs/2026-09-22-full-apparel-dashboard-design.md).
- **Hasil Kunci:**
  - Penentuan prioritas MoSCoW (*Must Have, Should Have, Could Have, Won't Have*).
  - Penetapan batasan ruang lingkup (*In-Scope* vs *Out-of-Scope* seperti peniadaan sensor IoT agar fokus skripsi tajam pada kehandalan software).
  - Perancangan struktur data TypeScript/JSON untuk entitas inventaris garmen, log transaksi penerimaan (inbound), dan pengeluaran (outbound).

### Milestone 4 — Setup Fondasi Arsitektur Web & Autentikasi (22 Sep 2026)
- **Aktivitas:** Membangun fondasi aplikasi web responsif dan modul keamanan akses pengguna.
- **Hasil Kunci:**
  - Implementasi login multi-metode di [index.html](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/index.html) dan [app.js](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/app.js):
    - *Quick Demo Login* (`admin@gudangpro.id`).
    - *Email / Password Authentication* terhubung ke backend Supabase.
    - *Google Cloud OAuth 2.0 Single Sign-On* via Supabase Client CDN.
  - Sesi pengguna persisten dengan pengalihan otomatis (*redirection*) ke dashboard operasional.

### Milestone 5 — Rekayasa Antarmuka "Seamless Tab Workspace" (22 Sep 2026)
- **Aktivitas:** Mengubah antarmuka lama yang sarat tombol dummy dan gradien generik (*AI-codet*) menjadi dashboard industrial yang fungsional dan padat data.
- **Commit Terkait:**
  - `8c67579 docs: add implementation plan for full apparel dashboard workspace`
  - `063e1d9 feat(html): add 6 modular workspace view containers and form markups`
  - `ddf1716 style: add workspace tabs, transaction forms and industrial apparel table styles`
  - `e12bea4 feat(js): implement tab workspace switcher and initialize transaction states`
- **Hasil Kunci:**
  - Arsitektur Single-Page dengan 6 kontainer view independen tanpa reload:
    1. `#viewOverview` (Dashboard KPI, Peringatan Stok Kritis, Okupansi Rak, Log Terkini).
    2. `#viewInventory` (Tabel Master Bahan & Pakaian, Pencarian, Filter Kategori).
    3. `#viewInbound` (Pencatatan Bahan Masuk dari Supplier).
    4. `#viewOutbound` (Penerbitan Surat Jalan DO Pengeluaran Baju Jadi).
    5. `#viewZones` (Denah Visual 4 Zona Gudang Konveksi).
    6. `#viewAudit` (Formulir Stock Opname Fisik & Rekonsiliasi Selisih).
  - Desain *Industrial Slate Theme* di [style.css](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/style.css): Palet warna netral kontras tinggi, tipografi Inter yang terbaca jelas di lingkungan gudang, dan penghapusan seluruh efek dekoratif tak bermakna.

### Milestone 6 — Implementasi Logika Transaksional & Peringatan Dini (22 Sep 2026)
- **Aktivitas:** Mengaktifkan mutasi data riil dan logika cerdas stok minimum.
- **Commit Terkait:**
  - `cbdf54a feat(inbound): implement fabric receiving PO, auto stock increment and logging`
- **Hasil Kunci:**
  - **Modul Inbound Fungsional:** Formulir input PO bahan kain roll/aksesoris jahit secara instan menambah saldo stok item terkait di memori lokal (`localStorage`), mencatat nomor bukti penerimaan otomatis, dan menambahkan baris ke tabel riwayat mutasi.
  - **Low Stock Alert System:** Evaluasi otomatis saat stok berada pada atau di bawah ambang batas minimum (`item.qty <= item.minStock`), memicu kemunculan banner peringatan di Overview serta notifikasi peringatan (*toast notification*).
  - **Manajemen Denah 4 Zona Garmen:** Visualisasi kapasitas dan kalkulasi persentase keterisian rak per zona (Zona A: Bahan Baku Kain Roll, Zona B: Aksesoris & Benang Jahit, Zona C: Pola Potong WIP, Zona D: Baju Jadi Siap Kirim).

---

## 3. Bukti Rekayasa Perangkat Lunak & Verifikasi Otomatis (Testing Rigor)

Pengembangan modul diverifikasi menggunakan pengujian unit otomatis berbasis Python (`unittest` runner) yang menguji integritas DOM dan logika state sebelum kode di-*commit*:

```text
Ran 11 tests in 0.007s
OK (All Tests Passed)
```

### Rincian Modul Pengujian:
1. **[tests/test_dom_structure.py](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/tests/test_dom_structure.py):**
   - Memvalidasi keberadaan seluruh 6 kontainer view (`viewOverview` s/d `viewAudit`).
   - Memvalidasi elemen interaktif form input (`inboundForm`, `outboundForm`, `auditItemSelect`, `btnSyncAuditStock`).
   - Memvalidasi ID navigasi sidebar.
2. **[tests/test_css_styles.py](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/tests/test_css_styles.py):**
   - Memvalidasi rule CSS workspace container (`.workspace-view.active`), tata letak grid form, dan styling industrial.
3. **[tests/test_tab_switcher.py](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/tests/test_tab_switcher.py):**
   - Menguji logika perpindahan tab navigasi tanpa reload dan sinkronisasi breadcrumb top bar.
4. **[tests/test_inbound_logic.py](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/tests/test_inbound_logic.py):**
   - Menguji mutasi penambahan saldo stok saat transaksi PO bahan kain masuk berhasil disimpan.

---

## 4. Tantangan Teknis Utama & Solusi Rekayasa

| No | Tantangan Teknis (*Problem Encountered*) | Akar Masalah | Solusi Rekayasa (*Engineered Solution*) |
| :-: | :--- | :--- | :--- |
| **1** | **Antarmuka terkesan "Template AI generik" (*AI-codet*)** | Banyak tombol palsu/dummy, warna gradien ungu tidak fungsional, dan visual membingungkan operator gudang. | Menghapus seluruh elemen dekoratif; mengganti sistem palet menjadi *Industrial Slate Palette* (slate-900/slate-800) dan memastikan setiap tombol memiliki fungsi riil (*zero dummy buttons*). |
| **2** | **Kebutuhan perpindahan menu cepat tanpa kehilangan state data** | Jika menggunakan multi-page HTML biasa, setiap perpindahan menu me-reload halaman dan memicu latensi. | Mengadopsi arsitektur *Seamless Dynamic Tab Workspace*: seluruh 6 modul dimuat dalam satu halaman terstruktur dan di-*switch* secara instan via manipulasi kelas DOM CSS. |
| **3** | **Risiko inkonsistensi saldo stok akibat keterlambatan input** | Stok di rak bertambah secara fisik tetapi belum tercatat di sistem saat PO tiba. | Mengimplementasikan validasi form Inbound terikat langsung ke model inventaris reaktif lokal, mencatat nomor lot/roll kain secara otomatis, dan memperbarui tabel riwayat secara instan. |
| **4** | **Pencegahan kondisi kehabisan stok (*Stock-Out*)** | Operator sering tidak menyadari bahwa bahan baku telah kritis sebelum ludes. | Membangun *Low Stock Alert System*: sistem mengevaluasi ambang batas (`minStock`) pada setiap mutasi dan memicu visual badge merah/oranye serta notifikasi sistem. |

---

## 5. Rencana Langkah Lanjutan (Next Development Roadmap)

Untuk menyelesaikan keseluruhan target penelitian sebelum sidang skripsi/evaluasi akhir, langkah lanjutan yang telah dijadwalkan mencakup:

- [ ] **Milestone Lanjutan 1 (Outbound Dispatch Fulfillment):** Mengaktifkan modul Surat Jalan DO pengeluaran pakaian jadi siap kirim dengan validasi anti-*overselling* (jumlah keluar tidak boleh melampaui stok fisik).
- [ ] **Milestone Lanjutan 2 (Stock Opname & Discrepancy Reconciliation):** Mengaktifkan fitur audit hitung fisik barang di rak vs saldo sistem dengan kalkulasi selisih otomatis (*1-Click Reconciliation*).
- [ ] **Milestone Lanjutan 3 (Cloud Data Syncing):** Menghubungkan seluruh mutasi lokal ke tabel PostgreSQL Supabase secara *real-time* via Supabase Realtime Channel.
- [ ] **Milestone Lanjutan 4 (Pengujian UAT Pengguna):** Melakukan uji coba operasional pengguna (*User Acceptance Testing*) terhadap operator konveksi/gudang untuk mengukur efisiensi waktu input dan kemudahan navigasi.

---

*Dokumen catatan perjalanan ini disusun secara sistematis sebagai pertanggungjawaban progres rekayasa perangkat lunak kepada Dosen Pembimbing.*
