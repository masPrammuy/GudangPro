# NASKAH PRESENTASI PROYEK GUDANGPRO & RENCANA KERJA KEDEPAN (ROADMAP)
**Proyek:** GudangPro — Warehouse Management System (WMS) Apparel & Konveksi  
**Target Audiens:** Dosen Pembimbing / Dosen Penguji / Tim Evaluator Akademik  
**Estimasi Durasi Presentasi:** 7 – 10 Menit  
**Tautan Live Demo:** [https://gudang-pro-flame.vercel.app/](https://gudang-pro-flame.vercel.app/)  

---

## DAFTAR ISI
1. [Panduan Ringkas & Strategi Presentasi (Quick Cheat Sheet)](#1-panduan-ringkas--strategi-presentasi-quick-cheat-sheet)
2. [Teks / Naskah Lengkap Presentasi Lisan (Verbatim Spoken Script)](#2-teks--naskah-lengkap-presentasi-lisan-verbatim-spoken-script)
   - [Slide 1: Pembuka & Identitas Proyek](#bagian-1-pembuka--identitas-proyek-slide-1)
   - [Slide 2: Akar Masalah Riil di Lantai Gudang Konveksi](#bagian-2-akar-masalah-riil-di-lantai-gudang-konveksi-slide-2)
   - [Slide 3: Filosofi Produk — 2 Lapisan Nilai (Belajar dari Mibebi Kasir)](#bagian-3-filosofi-produk--2-lapisan-nilai-belajar-dari-mibebi-kasir-slide-3)
   - [Slide 4: 5 Fitur Inti WMS & Batasan Ruang Lingkup (Scope Guard)](#bagian-4-5-fitur-inti-wms--batasan-ruang-lingkup-scope-guard-slide-4)
   - [Slide 5: Desain Antarmuka Industrial Slate Workspace](#bagian-5-desain-antarmuka-industrial-slate-workspace-slide-5)
   - [Slide 6: Live Demo & Capaian Fungsional yang Sudah Selesai](#bagian-6-live-demo--capaian-fungsional-yang-sudah-selesai-slide-6)
   - [Slide 7: Disiplin Rekayasa Perangkat Lunak (Automated Testing Rigor)](#bagian-7-disiplin-rekayasa-perangkat-lunak-automated-testing-rigor-slide-7)
   - [Slide 8: Rencana Kerja Masa Depan (Development Roadmap)](#bagian-8-rencana-kerja-masa-depan-development-roadmap-slide-8)
   - [Slide 9: Penutup & Ucapan Terima Kasih](#bagian-9-penutup--ucapan-terima-kasih-slide-9)
3. [Rencana Kerja Masa Depan (Comprehensive Development Roadmap)](#3-rencana-kerja-masa-depan-comprehensive-development-roadmap)
4. [Antisipasi Tanya Jawab Dosen / Evaluator (Q&A Defense Guide)](#4-antisipasi-tanya-jawab-dosen--evaluator-qa-defense-guide)

---

## 1. PANDUAN RINGKAS & STRATEGI PRESENTASI (QUICK CHEAT SHEET)

| Menit Ke- | Bagian / Topik | Poin Kunci yang Ditekankan | Tindakan / Visual |
| :---: | :--- | :--- | :--- |
| **00:00 - 01:00** | **Pembukaan** | Salam, judul proyek, latar belakang domain apparel, dan status live app di Vercel. | Tampilkan Slide Judul / Buka tab browser Vercel. |
| **01:00 - 02:30** | **Masalah Bisnis & Filosofi** | 3 masalah nyata (selisih stok, waktu ambil lama, dead stock) + Konsep *Two-Layered Value* (Core vs Value-Added). | Tekankan: *"Teknologi bukan masalah bisnis, tapi solusi proses."* |
| **02:30 - 04:00** | **Fitur Inti & Scope Guard** | 5 Fitur Inti WMS (Uji eksistensi WMS) & penegasan batasan scope (tidak pakai sensor hardware/IoT agar fokus software tajam). | Tampilkan arsitektur tabel/kategori garmen. |
| **04:00 - 06:30** | **Live Demo Sistem Riil** | Transisi antarmuka *Seamless Tab Workspace* tanpa reload, Inbound PO (auto stock increment), Outbound DO (proteksi anti-overselling), dan visual 4 zona. | Buka langsung `gudang-pro-flame.vercel.app`, klik tab Inbound & Outbound. |
| **06:30 - 07:30** | **Engineering Rigor (Testing)** | 18 Automated Tests lulus (DOM, Tab Switcher, Logic Inbound & Outbound), bukan sekadar prototipe kosmetik. | Tampilkan bukti eksekusi test `python -m unittest`. |
| **07:30 - 09:00** | **Roadmap Kedepan** | 4 fase terukur: Audit Stock Opname, Cloud PostgreSQL Realtime Supabase, Value-Added Engine (ROP & S-Shape), dan UAT Pengguna. | Tampilkan tabel roadmap bertahap. |
| **09:00 - 10:00** | **Penutup & Q&A** | Ringkasan *value proposition*, terima kasih, dan buka sesi diskusi. | Tampilkan slide kontak/penutup. |

---

## 2. TEKS / NASKAH LENGKAP PRESENTASI LISAN (VERBATIM SPOKEN SCRIPT)

### BAGIAN 1: PEMBUKA & IDENTITAS PROYEK (SLIDE 1)
*(Tampilkan Slide 01 atau Halaman Utama Web)*

> **[KATA SAMBUTAN]**  
> *"Selamat pagi/siang kepada Bapak/Ibu Dosen Pembimbing dan Dosen Penguji sekalian.*  
> 
> *Perkenalkan, nama saya **[Nama Anda]**, mahasiswa Program Studi **[Teknik Informatika / Ilmu Komputer]**. Pada kesempatan hari ini, saya akan mempresentasikan progres pengembangan sistem yang telah saya selesaikan, yang berjudul:*  
> 
> ***'GudangPro: Sistem Manajemen Pergudangan (Warehouse Management System) Berbasis Web untuk Pengelolaan Stok Real-Time, Pemetaan Lokasi Rak, dan Optimasi Alur Barang Masuk-Keluar pada Industri Konveksi & Apparel.'***  
> 
> *Sistem yang saya bangun ini bukan sekadar konsep rancangan di atas kertas, melainkan prototipe fungsional yang telah lolos serangkaian pengujian otomatis dan saat ini sudah live dapat diakses publik melalui domain: `gudang-pro-flame.vercel.app`.*  
> 
> *Izinkan saya memaparkan latar belakang masalah, landasan filosofi produk, implementasi rekayasa yang telah dicapai, serta rencana peta jalan pengembangan ke depannya."*

---

### BAGIAN 2: AKAR MASALAH RIIL DI LANTAI GUDANG KONVEKSI (SLIDE 2)
*(Pindah ke Slide 02 / Bagian Masalah)*

> *"Bapak dan Ibu Dosen sekalian, proyek ini tidak saya mulai dari premis 'ingin membuat website', melainkan berakar dari observasi mendalam terhadap kesakitan nyata di lantai gudang industri konveksi dan pakaian jadi.*  
> 
> *Prinsip utama rekayasa perangkat lunak yang saya pegang adalah: **'Teknologi bukan masalah bisnis.'** Masalah gudang konveksi bukanlah karena mereka 'belum memakai AI' atau 'belum memakai Cloud', melainkan karena adanya 3 kesakitan operasional riil:*  
> 
> 1. *Pertama, **Stock Discrepancy (Selisih Data Stok):** Data di buku atau spreadsheet mencatat kain masih ada 10 roll, tetapi ketika operator potong hendak mengambil bahan, fisik di rak ternyata kosong karena mutasi tidak tercatat secara real-time. Dampaknya, proses potong terhenti dan pesanan pelanggan tertunda.*  
> 2. *Kedua, **High Retrieval Time (Waktu Pencarian Barang yang Lama):** Penataan barang konveksi—mulai dari benang, kancing, resleting, hingga kain roll—sering kali acak. Petugas menghabiskan lebih dari 40% jam kerjanya hanya untuk berjalan bolak-balik menyusuri lorong yang sama mencari letak bahan.*  
> 3. *Ketiga, **Dead Stock (Modal Kerja Mengendap):** Bahan kain roll atau pakaian jadi musiman tertumpuk oleh stok baru. Bahan lama tertimbun berbulan-bulan di sudut gudang tanpa terdeteksi, berdebu, rusak, dan mengunci modal kerja puluhan hingga ratusan juta rupiah.*  
> 
> *Ketiga masalah inilah yang menjadi sasaran tembak utama dari perancangan GudangPro."*

---

### BAGIAN 3: FILOSOFI PRODUK — 2 LAPISAN NILAI (BELAJAR DARI MIBEBI KASIR) (SLIDE 3)
*(Pindah ke Slide 03 / Filosofi Desain)*

> *"Sebelum menulis kode, saya melakukan studi bedah sistem terhadap produk kasir komersial (Mibebi Kasir) untuk mengekstraksi filosofi perancangan aplikasi bisnis. Dari studi tersebut, saya merumuskan prinsip **Dua Lapisan Nilai (Two-Layered Value)**:*  
> 
> * **Lapisan Pertama adalah Fitur Inti (Core Features):** Ini adalah fungsi wajib agar aplikasi sah disebut sistem. Jika hanya berhenti di sini, aplikasi hanyalah 'kalkulator digital' pasif yang memindahkan catatan kertas ke layar monitor.*  
> * **Lapisan Kedua adalah Fitur Bernilai Tambah (Value-Added Features):** Inilah mesin pembeda yang aktif melindungi profit bisnis, mengoptimasi alur kerja manusia, dan mencegah kerugian secara otomatis sebelum terjadi.*  
> 
> *Rantai berpikir yang saya terapkan dalam penelitian ini adalah:*  
> **Masalah Nyata Pengguna $\rightarrow$ Pahami Alur Proses Bisnis $\rightarrow$ Bangun Fitur Inti yang Kokoh $\rightarrow$ Rancang Nilai Tambah Cerdas $\rightarrow$ dan Buktikan Dampaknya Secara Terukur.**"*

---

### BAGIAN 4: 5 FITUR INTI WMS & BATASAN RUANG LINGKUP (SCOPE GUARD) (SLIDE 4)
*(Pindah ke Slide 04 / Core Features & Scope)*

> *"Untuk menjawab alur bisnis gudang, saya menetapkan **5 Fitur Inti WMS** sebagai fondasi sistem:*  
> 1. *Master Data SKU: Kode unik identitas bahan kain, aksesoris, WIP, dan pakaian jadi.*  
> 2. *Pencatatan Inbound: Pintu masuk verifikasi penerimaan barang dari supplier atau hasil produksi.*  
> 3. *Pencatatan Outbound: Validasi pengeluaran barang untuk pengiriman ke distributor/pelanggan.*  
> 4. *Pemetaan Lokasi Rak (Bin Mapping): Alamat presisi penyimpanan berbasis zona di gudang.*  
> 5. *Kartu Stok & Audit Trail: Rekam jejak kronologis mutasi untuk audit data.*  
> 
> *Saya menguji rancangan ini dengan pertanyaan kritis: **'Jika salah satu dari 5 fitur ini dihilangkan, apakah GudangPro masih bisa disebut WMS?'**  
> Jawabannya tegas: **TIDAK BISA.** Tanpa lokasi rak, sistem ini hanyalah kasir toko kelontong. Tanpa verifikasi inbound-outbound, sistem ini tidak memiliki akuntabilitas logistik.*  
> 
> *Selain itu, untuk mencegah *feature creep* dan memastikan penelitian selesai tepat waktu, saya menerapkan **Scope Guard (Batasan Ruang Lingkup)** yang tegas:*  
> * **In-Scope:** Fokus pada kehandalan software web WMS, integritas data stok real-time, validasi bisnis transaksional, dan visualisasi pemetaan zona rak.*  
> * **Out-of-Scope:** Saya secara sengaja tidak memasukkan sensor timbangan IoT fisik atau integrasi robotik AGV, agar evaluasi skripsi berfokus tajam pada arsitektur perangkat lunak dan kebenaran logika bisnis."*

---

### BAGIAN 5: DESAIN ANTARMUKA INDUSTRIAL SLATE WORKSPACE (SLIDE 5)
*(Pindah ke Slide 05 / Tampilan Desain)*

> *"Salah satu diferensiasi penting yang telah saya selesaikan adalah penolakan terhadap desain generik 'template AI' (*AI-codet*) yang sering kali dihiasi gradien warna-warni tidak berguna dan tombol-tombol dummy palsu.*  
> 
> *Antarmuka GudangPro saya rancang dengan standar **Industrial Slate Workspace** berdensitas data tinggi:*  
> * Menggunakan palet slate gelap berkontras tinggi yang nyaman di mata operator gudang di bawah pencahayaan lampu gudang.*  
> * **Zero Dummy Buttons:** Setiap elemen, badge, tombol, dan tabel yang tampil di layar memiliki fungsi nyata dan terhubung ke state data sistem.*  
> * Mengadopsi arsitektur **Single-Page Seamless Workspace 6 Modul**: modul berpindah secara instan tanpa reload halaman, sehingga operator tidak mengalami jeda waktu (*latency*) saat berpindah dari mencatat barang masuk ke melihat denah rak."*

---

### BAGIAN 6: LIVE DEMO & CAPAIAN FUNGSIONAL YANG SUDAH SELESAI (SLIDE 6)
*(Beralih ke Browser: Buka `https://gudang-pro-flame.vercel.app/` atau localhost dashboard)*

> *"Sekarang, izinkan saya mendemonstrasikan secara langsung apa yang telah berhasil saya bangun dan berfungsi secara penuh di sistem GudangPro:*  
> 
> **[1. Autentikasi Multi-Metode]**  
> *Sistem dilengkapi keamanan login ganda: Quick Demo login untuk pengujian cepat, login Email/Password terenkripsi, serta integrasi Google Cloud OAuth 2.0 Single Sign-On.*  
> 
> **[2. Modul 1: Overview & Low Stock Alert]** *(Klik Tab Overview)*  
> *Di halaman utama, supervisor langsung disajikan metrik real-time: total 8 SKU aktif, total stok fisik, okupansi kapasitas per zona, serta **Sistem Peringatan Dini Stok Kritis (Low Stock Alert)**. Begitu saldo suatu bahan berada di bawah ambang batas minimum, banner peringatan merah dan oranye langsung muncul secara reaktif.*  
> 
> **[3. Modul 2: Master Inventory Apparel]** *(Klik Tab Inventory)*  
> *Menyimpan master data bahan spesifik industri garmen: mulai dari Kain Katun Combed 30s Roll, Benang Jahit Spun, Kancing Kemeja, Pola Potong WIP di Meja Cutting, hingga Baju Jadi Siap Kirim lengkap dengan lokasi rak dan status ketersediaannya. Dilengkapi fitur pencarian instan dan filter kategori.*  
> 
> **[4. Modul 3: Inbound Goods Receiving (Bahan Masuk)]** *(Klik Tab Inbound)*  
> *Modul ini merekam penerimaan bahan dari supplier. Saat formulir PO diisi dan disimpan, sistem secara otomatis: (1) menambah saldo stok fisik pada item terkait, (2) mencatat nomor bukti penerimaan resmi beserta nomor LOT kain roll untuk penelusuran kualitas QC, dan (3) memperbarui tabel riwayat mutasi penerimaan.*  
> 
> **[5. Modul 4: Outbound Dispatch (Pengeluaran Baju Jadi)]** *(Klik Tab Outbound)*  
> *Modul ini menerbitkan Surat Jalan (Delivery Order) untuk pengiriman pesanan baju jadi ke distributor atau distro.  
> Yang terpenting di sini, saya telah mengimplementasikan **Proteksi Anti-Over-Shipping / Anti-Overselling**: jika operator mencoba mengeluarkan jumlah barang yang melebihi saldo fisik yang tersedia di rak, sistem akan menolak transaksi dan memunculkan peringatan validasi. Jika valid, stok berkurang seketika dan riwayat surat jalan tercatat rapi.*  
> 
> **[6. Modul 5: Denah 4 Zona Gudang Konveksi]** *(Klik Tab Zones)*  
> *Menampilkan pemetaan visual alur barang di lantai konveksi: Zona A untuk Bahan Baku Kain Roll, Zona B untuk Aksesoris & Benang, Zona C untuk Pola Potong WIP, dan Zona D untuk Pakaian Jadi Siap Kirim, lengkap dengan persentase keterisian rak."*

---

### BAGIAN 7: DISIPLIN REKAYASA PERANGKAT LUNAK (AUTOMATED TESTING RIGOR) (SLIDE 7)
*(Kembali ke Presentasi / Tampilkan Terminal Test)*

> *"Sebagai mahasiswa Informatika, tolok ukur keberhasilan proyek ini bukan hanya antarmukanya tampil di layar, melainkan kehandalan arsitektur dan kualitas kode.*  
> 
> *Pengembangan GudangPro menerapkan disiplin **Test-Driven Development (TDD)** dengan rangkaian pengujian unit otomatis menggunakan runner Python `unittest`.*  
> 
> *Saat ini, sebanyak **18 skenario pengujian unit otomatis telah dibuat dan 100% dinyatakan LULUS (ALL TESTS PASSED)**, mencakup:*  
> 1. *Validasi Integritas Struktur DOM untuk seluruh 6 modul kontainer view.*  
> 2. *Pengujian Spesifikasi Tata Letak & Styling CSS Industrial Workspace.*  
> 3. *Pengujian Logika Perpindahan Tab Navigation tanpa page-reload.*  
> 4. *Pengujian Fungsional Mutasi Transaksi Inbound (penambahan stok kain & pembentukan log).*  
> 5. *Pengujian Logika Proteksi Outbound (pencegahan pengeluaran minus/over-shipping dan pengurangan saldo stok).*  
> 
> *Hal ini membuktikan bahwa sistem dibangun di atas fondasi logika yang terverifikasi dan minim celah bug."*

---

### BAGIAN 8: RENCANA KERJA MASA DEPAN (DEVELOPMENT ROADMAP) (SLIDE 8)
*(Tampilkan Slide Roadmap)*

> *"Bapak dan Ibu Dosen, setelah capaian Tahap 1 ini berhasil diselesaikan dengan baik, saya telah menyusun rencana kerja lanjutan yang terstruktur ke dalam 4 milestone utama menuju penyelesaian skripsi:*  
> 
> * **Milestone Lanjutan 1 (Penyempurnaan Stock Opname & Filter Zona Interaktif):**  
>   Mengaktifkan modul Audit Fisik di `#viewAudit` dengan fitur rekonsiliasi selisih 1-klik (*1-Click Discrepancy Reconciliation*), serta integrasi interaktif pada Denah 4 Zona agar ketika kartu zona diklik, sistem langsung menyaring daftar barang di rak zona tersebut.  
> 
> * **Milestone Lanjutan 2 (Cloud Persistence & Real-time WebSocket Multi-User):**  
>   Menghubungkan penyimpanan lokal saat ini ke database relasional PostgreSQL di Supabase secara penuh dengan *Supabase Realtime Channel*. Dengan begitu, ketika operator Inbound menginput kain di pintu masuk gudang, layar monitor supervisor di ruang kantor akan ter-update seketika tanpa perlu menekan refresh.  
> 
> * **Milestone Lanjutan 3 (Implementasi Engine Fitur Bernilai Tambah):**  
>   Membangun kalkulator *Smart Reorder Point (ROP)* otomatis berbasis rata-rata konsumsi harian dan lead time supplier, serta merancang algoritma rute langkah kaki *Guided S-Shape Batch Picking* untuk memangkas waktu ambil barang hingga 35-50%.  
> 
> * **Milestone Lanjutan 4 (Pengujian UAT Pengguna & Evaluasi Skripsi):**  
>   Melakukan *User Acceptance Testing (UAT)* langsung kepada pemilik usaha konveksi atau operator gudang menggunakan kuesioner *System Usability Scale (SUS)* guna mengukur tingkat efisiensi dan kepuasan pengguna sebelum sidang skripsi."*

---

### BAGIAN 9: PENUTUP & UCAPAN TERIMA KASIH (SLIDE 9)
*(Tampilkan Slide Penutup)*

> *"Sebagai rangkuman akhir, *Value Proposition* dari GudangPro adalah:*  
> *'GudangPro hadir bukan hanya sekadar untuk mencatat barang masuk dan keluar, melainkan mentransformasikan operasional gudang konveksi menjadi ekosistem yang presisi—mencegah kerugian selisih stok, mengeliminasi risiko kehabisan bahan kritis, dan mempercepat alur logistik dari bahan baku hingga baju jadi.'*  
> 
> *Demikian presentasi progres proyek GudangPro yang dapat saya sampaikan. Terima kasih banyak atas perhatian dan arahan Bapak/Ibu Dosen Pembimbing dan Penguji. Saya dengan senang hati menyambut masukan, pertanyaan, dan saran demi penyempurnaan sistem ini.*  
> 
> *Wassalamu'alaikum Warahmatullahi Wabarakatuh / Selamat pagi/siang."*

---

## 3. RENCANA KERJA MASA DEPAN (COMPREHENSIVE DEVELOPMENT ROADMAP)

Rencana kerja ini disusun secara sistematis menggunakan prinsip rekayasa perangkat lunak bertahap (*Iterative & Incremental Delivery*):

```
┌────────────────────────────────────────────────────────────────────────┐
│                      GUDANGPRO DEVELOPMENT ROADMAP                     │
└────────────────────────────────────────────────────────────────────────┘
  Tahap 1 (SELESAI):
  [x] PRD & Spesifikasi Arsitektur 6 Workspace Modul
  [x] Industrial Slate UI Theme (Anti AI-Codet, 0 Dummy Buttons)
  [x] Transaksi Inbound (Auto Stock Increment + LOT Tracking)
  [x] Transaksi Outbound (Surat Jalan DO + Proteksi Anti-Overselling)
  [x] 18 Automated Unit Tests Passed & Vercel Live Deployment
  ──────────────────────────────────────────────────────────────────────
  Tahap 2 (FASE LANJUTAN KEDEPAN):
  
  [Fase 1: 1 - 2 Minggu Kedepan] ────► Stock Opname & Interaktivitas Zona
  [Fase 2: 2 - 3 Minggu Kedepan] ────► Supabase Cloud Realtime & RBAC Multi-User
  [Fase 3: 3 - 4 Minggu Kedepan] ────► Value-Added Engine (Smart ROP & S-Shape)
  [Fase 4: 2 Minggu Menuju Sidang] ──► Pengujian UAT (SUS Score) & Laporan Skripsi
```

### Rincian Rencana Per Fase:

### 🎯 FASE 1: PENYELESAIAN CORE OPERASIONAL & AUDIT FISIK (Estimasi: 1 – 2 Minggu)
* **Objektif:** Menuntaskan seluruh fitur operasional dasar di level browser sebelum migrasi database cloud.
* **Tugas Kerja:**
  1. **Modul Stock Opname & Rekonsiliasi Selisih (`#viewAudit`):**
     - Mengaktifkan dropdown pemilihan SKU barang untuk audit fisik rak.
     - Perhitungan varians otomatis: $\text{Selisih} = \text{Stok Fisik Dihitung} - \text{Stok Sistem}$.
     - Tombol *1-Click Reconcile*: memperbarui saldo sistem sesuai hasil hitung fisik dengan mencatat alasan koreksi audit pada log mutasi.
  2. **Interaktivitas Denah 4 Zona Gudang (`#viewZones`):**
     - Menghubungkan kartu zona (Zona A, B, C, D) dengan event click handler.
     - Ketika kartu zona diklik, tabel inventaris di bawahnya otomatis memfilter dan menampilkan daftar barang serta tingkat kapasitas rak pada zona yang bersangkutan.
  3. **Penambahan Automated Unit Test:**
     - Mengaktifkan dan meluluskan pengujian pada `tests/test_zones_and_audit.py` sehingga total automated test bertambah menjadi 27 test lulus.

### 🌐 FASE 2: CLOUD PERSISTENCE & REAL-TIME WEBSOCKET (Estimasi: 2 – 3 Minggu)
* **Objektif:** Mengubah penyimpanan lokal (*localStorage/mock state*) menjadi arsitektur multi-user tersinkronisasi via database cloud.
* **Tugas Kerja:**
  1. **Migrasi Skema PostgreSQL Supabase:**
     - Menjalankan skrip DDL `supabase-setup.sql` untuk membuat tabel relasional: `inventory_items`, `inbound_transactions`, `outbound_transactions`, dan `stock_audit_logs`.
     - Mengonfigurasi *Foreign Key Integrity* dan *Trigger* database untuk konsistensi saldo inventaris.
  2. **Supabase Realtime Channel Integration:**
     - Memanfaatkan protokol WebSocket Supabase (`postgres_changes`).
     - Menguji sinkronisasi multi-perangkat: ketika Operator Inbound menginput penerimaan barang di perangkat tablet gudang, dashboard PC Supervisor otomatis memperbarui grafik KPI tanpa refresh halaman.
  3. **Role-Based Access Control (RBAC):**
     - Memisahkan otorisasi menu berdasarkan peran:
       - *Supervisor/Admin:* Akses penuh ke seluruh 6 modul dan konfigurasi.
       - *Operator Inbound:* Hanya dapat mengakses Inbound & Master Stok.
       - *Operator Outbound:* Hanya dapat mengakses Outbound & Surat Jalan.
       - *Auditor Gudang:* Dibatasi pada modul Stock Opname Audit.

### ⚡ FASE 3: IMPLEMENTASI ENGINE FITUR BERNILAI TAMBAH (Estimasi: 3 – 4 Minggu)
* **Objektif:** Mewujudkan inovasi pembeda (*The Game Changers*) yang telah dirancang pada dokumen PRD.
* **Tugas Kerja:**
  1. **Smart Reorder Point (ROP) & Auto Alert Engine:**
     - Mengimplementasikan formula kalkulasi logistik:  
       $$\text{Reorder Point (ROP)} = (\text{Rata-rata Penggunaan Harian} \times \text{Lead Time Supplier}) + \text{Safety Stock}$$
     - Integrasi pengiriman peringatan dini otomatis ke saluran eksternal (Webhook Notifikasi WhatsApp / Email) saat saldo stok mendekati titik kritis ROP.
  2. **Guided S-Shape Batch Picking Route Generator:**
     - Algoritma pengelompokan pesanan (*Order Batching*): menggabungkan beberapa Surat Jalan DO menjadi satu daftar ambil sekaligus.
     - Algoritma pengurutan rute lorong satu arah (*S-Shape Heuristic*): menyusun urutan pengambilan dari Zona A $\rightarrow$ Zona B $\rightarrow$ Zona D tanpa membiarkan staf *picker* berputar balik di lorong yang sama.
  3. **Dead Stock Aging Analyzer:**
     - Visualisasi analitik usia stok berdasarkan tanggal masuk (*First-In*): kategori umur 0–30 hari (Lancar), 31–60 hari (Perhatian), 61–90 hari (Lambat), dan >90 hari (*Dead Stock*).
     - Tombol rekomendasi aksi otomatis: Cetak Daftar Cuci Gudang atau Ajukan Retur Bahan ke Supplier.

### 📊 FASE 4: EVALUASI ILMIAH, UAT PENGGUNA, & SIDANG SKRIPSI (Estimasi: 2 Minggu Menuju Sidang)
* **Objektif:** Mengumpulkan data empiris dampak sistem untuk keperluan penulisan Bab 4 dan Bab 5 laporan skripsi.
* **Tugas Kerja:**
  1. **User Acceptance Testing (UAT):**
     - Melakukan uji coba langsung kepada 3–5 staf operasional konveksi/gudang garmen skala UMKM.
     - Mengukur parameter: Waktu rata-rata input transaksi, persentase keberhasilan pencegahan selisih stok, dan skor kepuasan antarmuka menggunakan kuesioner terstandar *System Usability Scale (SUS)* dengan target skor $\ge 75$ (Kategori *Good/Excellent*).
  2. **Penyusunan Dokumentasi Akademik:**
     - Melengkapi Bab 3 (Metodologi Penelitian & Desain Arsitektur).
     - Menulis Bab 4 (Hasil Implementasi, Analisis Data Pengujian Otomatis, dan Pembahasan UAT).
     - Menyusun Bab 5 (Kesimpulan, Kontribusi Penelitian, dan Saran Pengembangan Lanjutan).

---

## 4. ANTISIPASI TANYA JAWAB DOSEN / EVALUATOR (Q&A DEFENSE GUIDE)

Berikut adalah panduan argumentasi untuk menjawab pertanyaan kritis yang paling sering dilontarkan dosen pembimbing atau dosen penguji:

---

### ❓ Pertanyaan 1:
> *"Apa perbedaan mendasar antara aplikasi GudangPro Anda dengan aplikasi Kasir (Point of Sale) biasa? Bukankah sama-sama mencatat barang masuk dan barang keluar?"*

#### 💡 Rekomendasi Jawaban:
> *"Terima kasih atas pertanyaannya, Bapak/Ibu Dosen. Perbedaannya sangat mendasar pada **model bisnis dan unit manajemen entitasnya**:*  
> 1. *Aplikasi Kasir berorientasi pada **transaksi finansial (harga jual, pembayaran, dan struk belanja)**, dan umumnya tidak memedulikan di mana lokasi fisik barang tersebut diletakkan di dalam ruangan.*  
> 2. *Sedangkan GudangPro sebagai WMS berorientasi pada **manajemen fisik & lokasi (Spatial & Movement Management)**. Sistem kami mencatat alamat presisi rak (*Bin Location Mapping* per zona konveksi), mengelola alur bahan baku roll hingga baju jadi, nomor LOT produksi, serta mengendalikan rute pergerakan barang agar staf gudang tidak berjalan bolak-balik. Selain itu, WMS memiliki mekanisme rekonsiliasi audit fisik (*Stock Opname*) yang tidak ada pada kasir standar."*

---

### ❓ Pertanyaan 2:
> *"Mengapa Anda tidak mengintegrasikan sensor hardware seperti timbangan digital IoT atau RFID scanner untuk membaca barang masuk secara otomatis?"*

#### 💡 Rekomendasi Jawaban:
> *"Keputusan tersebut merupakan bentuk penerapan **Scope Guard (Pembatasan Ruang Lingkup)** yang disengaja dalam metodologi rekayasa perangkat lunak saya, Bapak/Ibu.*  
> *Sering kali proyek mahasiswa terhambat karena mencoba menggabungkan hardware dan software sekaligus, sehingga ketika alat sensor mengalami gangguan kalibrasi listrik atau konektivitas fisik, fokus penelitian perangkat lunak menjadi bias.*  
> *Oleh karena itu, batasan skripsi ini dikunci secara tegas pada **kehandalan arsitektur software, integritas logika transaksi, pencegahan over-shipping, dan algoritma alur pergudangan**. Namun demikian, arsitektur data GudangPro sudah siap menerima input data dari barcode scanner standar (HID Keyboard Emulation) melalui field SKU yang reaktif."*

---

### ❓ Pertanyaan 3:
> *"Bagaimana sistem Anda menjamin data stok tidak bernilai minus jika ada pesanan keluar dalam jumlah besar?"*

#### 💡 Rekomendasi Jawaban:
> *"Sistem kami menerapkan **Proteksi Logika Transaksional Anti-Over-Shipping / Anti-Overselling** yang telah diuji dengan automated testing.*  
> *Pada modul Outbound Dispatch, sebelum data surat jalan disimpan ke sistem, algoritma memvalidasi: apakah `kuantitas keluar > saldo stok fisik saat ini`.*  
> *Jika kuantitas yang diminta melampaui stok fisik di rak, form akan mengunci eksekusi, menolak transaksi, dan memunculkan notifikasi kesalahan validasi kepada operator beserta informasi sisa stok yang tersedia. Validasi ini juga diperkuat dengan pengujian otomatis pada berkas pengujian `tests/test_outbound_logic.py` yang memastikan saldo stok tidak akan pernah berada di bawah angka 0."*

---

### ❓ Pertanyaan 4:
> *"Saat ini aplikasi masih menggunakan memori lokal peramban (localStorage). Bagaimana kesiapan sistem ini jika nantinya diakses oleh banyak operator sekaligus?"*

#### 💡 Rekomendasi Jawaban:
> *"Saat ini implementasi localStorage digunakan sebagai fondasi pengujian prototipe mandiri (self-contained testing) pada Tahap 1 untuk memastikan seluruh DOM, state management, dan alur form teruji bebas error tanpa dependensi jaringan eksternal.*  
> *Namun, sebagaimana tertuang pada **Milestone Lanjutan 2 Roadmap**, struktur modul ini telah disiapkan untuk langsung disambungkan ke backend PostgreSQL Supabase. Kami bahkan telah menyiapkan skrip struktur tabel relasional `supabase-setup.sql` dan modul integrasi `supabase-client.js`. Pada fase berikutnya, sinkronisasi antar-operator akan diakomodasi melalui protokol Supabase Realtime WebSocket."*

---

### ❓ Pertanyaan 5:
> *"Apa metodologi pengujian yang Anda gunakan untuk membuktikan bahwa aplikasi ini bebas dari kesalahan fatal?"*

#### 💡 Rekomendasi Jawaban:
> *"Kami menerapkan pendekatan **Test-Driven Development (TDD)** dengan pengujian unit otomatis berbasis Python `unittest` runner.*  
> *Kami tidak hanya menguji secara manual dengan mengklik tombol, melainkan membuat 18 kasus uji terprogram yang memverifikasi integritas DOM, ketersediaan komponen form, transisi navigasi tab, penambahan stok pada Inbound, hingga penolakan pesanan minus pada Outbound. Bukti pengujian ini terdokumentasi rapi di repositori dan dapat dijalankan kembali kapan pun dalam waktu kurang dari 0.1 detik untuk menjamin tidak adanya efek regresi (*regression testing*)."*
