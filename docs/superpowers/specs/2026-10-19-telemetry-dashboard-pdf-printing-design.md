# Spesifikasi Teknis Desain: Dashboard Telemetri Workshop Konveksi & Cetak Dokumen PDF Resmi (Surat Penerimaan PO & Surat Jalan DO)

---

- **Dokumen ID**: SPEC-2026-10-19-TELEMETRY-PDF
- **Tanggal Penyusunan**: 19 Oktober 2026
- **Status**: Disetujui (Approved)
- **Target Platform**: Flutter Mobile (Android, iOS) & Desktop/Web Emulator
- **Arsitektur**: Feature-First Clean Architecture + Riverpod (v2)
- **Pustaka Pihak Ketiga**: `pdf: ^3.11.1`, `printing: ^5.13.2`, `fl_chart: ^0.68.0`

---

## 1. Ringkasan Eksekutif & Tujuan Desain

Spesifikasi teknis ini mendefinisikan implementasi dua subsistem kunci pada aplikasi **GudangPro Apparel**:
1. **Dashboard Utama Telemetri Workshop (*Workshop Telemetry Dashboard*)**: Layar Beranda (*Home*) baru yang merefleksikan arsitektur visual dasbor konveksi modern sesuai acuan desain:
   - Baris panduan cepat operasional (3 langkah pemantauan).
   - 4 Kartu Metrik KPI (Total SKU Aktif, Kuantitas Masuk Hari Ini, Kuantitas Terkirim Hari Ini, Peringatan Stok Minimum).
   - Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian (Zona A: Gudang Kain Roll, Zona B: Aksesori & Benang, Zona C: Meja Potong & WIP, Zona D: Baju Jadi Siap Kirim) lengkap dengan persentase status, kapasitas terisi vs total, daftar material, dan progress bar.
   - Banner peringatan stok bahan/baju kritis dengan tombol navigasi instan *"Lihat di Tabel ↓"* ke katalog inventaris.
2. **Generator Dokumen PDF Resmi (*Official Logistics PDF Printing*)**:
   - Pembuatan berkas PDF resmi untuk **Surat Penerimaan Bahan Masuk (Purchase Order - PO)** berstandar legalitas pabrik garmen.
   - Pembuatan berkas PDF resmi untuk **Surat Jalan Pengiriman Barang (Delivery Order - DO)** untuk keperluan ekspedisi dan serah terima distributor.
   - Dialog pratinjau cetak (*native print preview*) menggunakan paket `printing` yang mendukung pencetakan nirkabel langsung ke printer Bluetooth/Wi-Fi serta fitur *Share / Save as PDF*.

---

## 2. Model Dokumen & Spesifikasi Generator PDF

### 2.1 Pustaka dan Layanan PDF (`core/services/pdf_invoice_service.dart`)
Sistem menggunakan paket `pdf/widgets.dart` dan `printing/printing.dart`. Layanan PDF merender dokumen terstandarisasi dengan spesifikasi:

#### Layout Surat Penerimaan Barang Masuk (PO):
- **Ukuran Kertas**: A4 Portrait.
- **Kop Surat Resmi**:
  - Judul Perusahaan: `GUDANGPRO APPAREL - LOGISTIK & WORKSHOP KONVEKSI`.
  - Alamat: `Sentra Industri Konveksi Tekstil, Blok C No. 12, Jawa Barat`.
  - Kontak: `Telp: (022) 8765-4321 • Email: warehouse@gudangpro.com`.
- **Judul Dokumen**: `SURAT PENERIMAAN BARANG / PURCHASE ORDER (PO)`.
- **Nomor Dokumen**: Sesuai input controller (misal: `PO-TX-2026-001`).
- **Metadata Transaksi**:
  - Tanggal & Jam Penerimaan: Format pelokalan Indonesia (misal: `19 Oktober 2026, 00:40 WIB`).
  - Nama Supplier / Vendor Tekstil.
  - Nomor Lot Celup / Batch Produksi Kain.
  - Petugas Penerima Gudang (Nama & NIK dari akun pengguna yang sedang login).
- **Tabel Rincian Material Masuk**:
  - Kolom: `No`, `Kode SKU`, `Deskripsi Material / Kain`, `Zona Rak`, `Kuantitas Masuk`, `Satuan`, `Status QC`.
  - Baris total kuantitas masuk.
- **Kolom Pengesahan Tanda Tangan 3 Pihak**:
  1. *Yang Menyerahkan* (Driver Vendor Tekstil)
  2. *Yang Menerima* (Petugas Gudang Inbound)
  3. *Mengetahui* (Quality Control / Kepala Gudang)

#### Layout Surat Jalan Pengiriman (Delivery Order - DO):
- **Ukuran Kertas**: A4 Portrait.
- **Kop Surat Resmi**: Identitas resmi GudangPro Apparel.
- **Judul Dokumen**: `SURAT JALAN PENGIRIMAN BARANG (DELIVERY ORDER)`.
- **Nomor Surat Jalan**: Sesuai input controller (misal: `DO-GP-2026-001`).
- **Metadata Transaksi**:
  - Tanggal & Waktu Pengiriman.
  - Nama Penerima / Pemesan / Toko / Distributor Busana.
  - Ekspedisi / Kurir / Nomor Plat Kendaraan.
  - Petugas Pengirim (Nama & NIK pengguna yang sedang login).
- **Tabel Rincian Barang Jadi Dikirim**:
  - Kolom: `No`, `Kode SKU`, `Nama Produk Pakaian Jadi`, `Zona Gudang (D)`, `Kuantitas Kirim`, `Satuan`, `Catatan Pengiriman`.
  - Baris total kuantitas pakaian jadi terkirim.
- **Kolom Pengesahan Tanda Tangan 3 Pihak**:
  1. *Yang Menyerahkan* (Petugas Gudang Outbound)
  2. *Kurir / Ekspedisi* (Driver Pengantar)
  3. *Yang Menerima* (Penerima / Toko Pemesan)

---

## 3. Spesifikasi Arsitektur Dashboard Telemetri Workshop

### 3.1 Komponen 1: Panduan Cepat Operasional (*Quick Steps Banner*)
Row interaktif atau kartu horizontal dengan 3 langkah:
1. `Cek Stok Kain & Baju Jadi`: Pantau stok roll kain, benang, kancing, dan baju siap kirim.
2. `Atur Batas Stok Minimum`: Menentukan ambang batas minimum untuk memicu peringatan restock.
3. `Peringatan Otomatis Realtime`: Banner peringatan kuning-merah langsung muncul otomatis saat stok kritis.

### 3.2 Komponen 2: 4 Kartu Metrik KPI (*Metric Stat Cards*)
- **Total Bahan & Baju (SKU)**: Menghitung total varian SKU aktif dari inventaris (misal: `8` atau `1.850`), dengan ikon grid kontainer (`Icons.grid_view_rounded`) dan label persentase aktif.
- **Bahan/Kain Masuk (Hari Ini)**: Kuantitas bahan masuk (`+142`), dengan ikon panah bawah hijau (`Icons.arrow_downward`), label `Batch Inbound terverifikasi`.
- **Baju Terkirim (Hari Ini)**: Kuantitas pengiriman pakaian jadi (`-85`), dengan ikon panah atas oranye (`Icons.arrow_upward`), label `Order Pengiriman kurir/kargo`.
- **Peringatan Stok Minimum**: Menghitung jumlah item dengan kuantitas $\le$ `min_stock` (`3`), ikon segitiga peringatan merah (`Icons.warning_amber_rounded`), label `Capai Batas Minimum Segera restock bahan`.

### 3.3 Komponen 3: Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian
Header: `Denah & Kapasitas 4 Zona Workshop Konveksi Pakaian` dengan teks pendukung `Realtime Workshop Telemetry • Sentra Konveksi`.

Tampilan 4 Kartu Zona dengan desain responsif:
1. **ZONA A (Gudang Kain Roll)**:
   - Tag: `75% Terpakai` (Kuning-Amber).
   - Deskripsi: `Katun Combed, Rayon, Fleece & Denim`.
   - Kapasitas: `Terisi: 450 / 600 Roll` (Progress Bar 75%, warna Biru Zona A `#3B82F6`).
2. **ZONA B (Aksesori & Benang)**:
   - Tag: `55% Stabil` (Hijau-Emerald).
   - Deskripsi: `Benang Jahit, Kancing, Resleting & Karet`.
   - Kapasitas: `Terisi: 330 / 600 Slot` (Progress Bar 55%, warna Ungu Zona B `#8B5CF6`).
3. **ZONA C (Meja Potong & WIP)**:
   - Tag: `88% Padat Jahit` (Merah-Rose).
   - Deskripsi: `Pola Cutting, Bordir & Antrean Jahit`.
   - Kapasitas: `Antrean: 440 / 500 Batch` (Progress Bar 88%, warna Amber Zona C `#F59E0B`).
4. **ZONA D (Baju Jadi Siap Kirim)**:
   - Tag: `40% Tersedia` (Cyan-Emerald).
   - Deskripsi: `Kaos, Kemeja, Hoodie Lolos QC & Polybag`.
   - Kapasitas: `Terisi: 400 / 1.000 Pcs` (Progress Bar 40%, warna Hijau Zona D `#10B981`).

### 3.4 Komponen 4: Banner Peringatan Kritis Ketinggian Stok Minimum
- Wadah kontainer berlatar amber transparan dengan garis tepi amber.
- Ikon segitiga peringatan di sisi kiri.
- Judul: `⚠️ Peringatan: Stok Bahan / Baju Mencapai Batas Minimum! [3 Item Kritis]`.
- Deskripsi: `Segera lakukan restock bahan kain/aksesoris atau jadwal ulang proses potong untuk item berikut agar jalur jahit tidak terhenti:`.
- Baris *chips* item kritis:
  - `⚠️ Benang Jahit Spun Polyester Putih Extra (40/2) (8 / Min: 20 Lusin)`
  - `⚠️ Kaos Polos Oversize Katun 24s Hitam Size L (Siap Kirim) (6 / Min: 30 Pcs)`
  - `🚨 Habis: Resleting Jaket YKK Metal Open End 60cm Hitam (0 / Min: 50 Pcs)`
- Tombol aksi `Lihat di Tabel ↓`: Mengalihkan indeks navigasi secara langsung ke tab katalog Stok Master garmen.

---

## 4. Penataan Rute Navigasi Adaptif pada `app.dart`

### 4.1 Rute Navigasi untuk **User (Operator Gudang)**: 6 Tab
1. 🏠 **Beranda**: `WorkshopTelemetryDashboardScreen` (Dashboard sesuai gambar).
2. 📦 **Stok**: `InventoryScreen` (Katalog garmen & filter zona).
3. 📥 **Bahan Masuk**: `InboundScreen` (Form PO + tombol Cetak Surat Masuk PDF).
4. 📤 **Kirim Baju**: `OutboundScreen` (Form DO + validasi anti-over-shipping + tombol Cetak Surat Jalan PDF).
5. 📋 **Opname**: `AuditScreen` (Audit fisik & selisih).
6. 👤 **Profil**: `ProfileScreen` (NIK, profil, logout).

### 4.2 Rute Navigasi untuk **Administrator**: 8 Tab
1. 🏠 **Beranda**: `WorkshopTelemetryDashboardScreen` (Dashboard sesuai gambar).
2. 📊 **Grafik Analitik**: `AdminDashboardScreen` (4 grafik interaktif `fl_chart`).
3. 📦 **Stok**: `InventoryScreen`.
4. 📥 **Bahan Masuk**: `InboundScreen` (+ Cetak PDF).
5. 📤 **Kirim Baju**: `OutboundScreen` (+ Cetak PDF).
6. 📋 **Opname**: `AuditScreen`.
7. 👥 **Pengguna**: `UserManagementScreen`.
8. 👤 **Profil**: `ProfileScreen`.

---

## 5. Rencana Pengujian Otomatis (TDD)

1. `test/unit/pdf_invoice_service_test.dart`:
   - Pengujian pembentukan dokumen PDF Surat Penerimaan Barang Masuk (PO) valid (memuat judul, kop, nomor PO, nama supplier, tabel rincian, tanda tangan).
   - Pengujian pembentukan dokumen PDF Surat Jalan Pengiriman (DO) valid (memuat nomor DO, penerima, ekspedisi, tabel barang, tanda tangan).
2. `test/widget/workshop_telemetry_dashboard_test.dart`:
   - Verifikasi render panduan cepat operasional (3 langkah).
   - Verifikasi render 4 kartu metrik KPI.
   - Verifikasi render 4 kartu denah & kapasitas zona workshop.
   - Verifikasi render banner peringatan kritis dan tombol *"Lihat di Tabel ↓"*.
3. `test/widget/transaction_screens_pdf_test.dart`:
   - Pengujian tombol *"Cetak Surat Masuk (PDF)"* pada `InboundScreen`.
   - Pengujian tombol *"Cetak Surat Jalan (PDF)"* pada `OutboundScreen`.
4. `test/widget_test.dart`:
   - Verifikasi bahwa tab pertama adalah Beranda (Dashboard Telemetri) untuk Admin dan User.
   - Verifikasi tombol *"Lihat di Tabel ↓"* mengalihkan tab secara presisi ke tab Stok Master.
5. `flutter test` & `flutter analyze`:
   - Seluruh pengujian lulus 100% dan analisis statis bersih (0 isu).
