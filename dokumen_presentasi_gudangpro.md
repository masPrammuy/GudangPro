# MATERI PRESENTASI TUGAS EKSPLORASI PRODUK
### Perancangan Fitur Inti & Fitur Bernilai Tambah pada GudangPro (WMS)

| Parameter | Keterangan |
| :--- | :--- |
| **Nama Proyek / Aplikasi** | **GudangPro (Warehouse Management System)** |
| **Domain Bisnis** | Manajemen Pergudangan & Rantai Pasok Logistik |
| **Status Prototipe** | Live Deployment: [https://gudang-pro-flame.vercel.app/](https://gudang-pro-flame.vercel.app/) |
| **Tujuan Presentasi** | Presentasi Evaluasi Rancangan Produk Sebelum Penyusunan PRD |

---

### BAGIAN 1. Latar Belakang & Filosofi Produk (Belajar dari Mibebi Kasir)

* **Tujuan Utama:** Mempelajari pola rancang bangun aplikasi bisnis dari Mibebi Kasir, bukan untuk meniru fiturnya secara mentah, melainkan memahami bagaimana membedakan fungsi dasar dengan fitur bernilai tambah.
* **Dua Lapisan Nilai Produk:**
  * **Lapisan 1 — Fitur Inti (Core):** Fungsi wajib agar aplikasi dapat berjalan sebagai sistem.
  * **Lapisan 2 — Fitur Bernilai Tambah (Value-Added):** Solusi proaktif yang menyelesaikan masalah finansial/operasional dan menjadi pembeda produk.
* **Prinsip Berpikir:** Masalah nyata pengguna $\rightarrow$ Pahami proses bisnis $\rightarrow$ Tentukan fitur inti $\rightarrow$ Rancang nilai tambah $\rightarrow$ Buktikan dampaknya.

> **Poin Penting untuk Disampaikan:**  
> Proyek ini tidak dimulai dari sekadar "ingin membuat aplikasi web", melainkan berakar dari identifikasi masalah nyata di operasional gudang.

---

### BAGIAN 2. Tiga Masalah Nyata di Operasional Pergudangan

* **1. Selisih Data Stok (*Stock Discrepancy*):**  
  Data di komputer menyatakan barang masih ada, namun fisik di rak ternyata kosong karena keterlambatan input manual. Dampaknya: pembatalan pesanan pelanggan dan kerugian toko.
* **2. Waktu Pengambilan Barang Lama (*High Retrieval Time*):**  
  Lokasi barang tidak terorganisir dan urutan picking acak. Petugas menghabiskan banyak jam kerja hanya untuk berjalan mondar-mandir di lorong yang sama.
* **3. Penumpukan Barang Mati (*Dead Stock*):**  
  Barang lama tertimbun barang baru di rak tanpa terdeteksi. Barang mengalami kerusakan, kedaluwarsa, dan mengunci modal kerja usaha puluhan juta rupiah.

> **Poin Penting untuk Disampaikan:**  
> *“Teknologi bukan masalah bisnis.”* Fokus tugas ini bukan karena gudang belum memakai AI atau Cloud, melainkan mengatasi selisih stok, inefisiensi rute jalan staf, dan modal kerja yang macet.

---

### BAGIAN 3. Lima Fitur Inti GudangPro (Fondasi WMS)

* **1. Master Data SKU & Barang:** Pencatatan identitas resmi barang, kategori, satuan, dan kode barcode.
* **2. Pencatatan Barang Masuk (*Inbound*):** Verifikasi penerimaan stok dari supplier ke gudang.
* **3. Pencatatan Barang Keluar (*Outbound*):** Validasi pengeluaran barang untuk pemenuhan order pelanggan.
* **4. Pemetaan Lokasi Rak (*Bin Location Mapping*):** Alamat presisi penyimpanan per barang (Zona, Lorong, Rak, Level).
* **5. Kartu Stok & Riwayat Mutasi (*Audit Trail*):** Rekam jejak kronologis siapa dan kapan barang dipindahkan secara real-time.

> **Poin Penting untuk Disampaikan:**  
> **Uji Eksistensi WMS:** Jika salah satu dari 5 fitur ini dihilangkan, GudangPro tidak lagi dapat disebut sebagai Warehouse Management System (WMS).

---

### BAGIAN 4. Tiga Fitur Bernilai Tambah (Inovasi Pembeda)

* **Fitur 1 — Smart Reorder Point (ROP) & Auto Alert:**  
  Sistem otomatis mengalkulasi ambang batas minimum stok berdasarkan rata-rata konsumsi harian dan lead time supplier. Sistem langsung mengirimkan notifikasi sebelum barang benar-benar habis.
* **Fitur 2 — Guided S-Shape Batch Picking:**  
  Sistem menggabungkan beberapa pesanan sekaligus dan mengurutkan rute jalan kaki staf secara satu arah menyusuri lorong (metode S-Shape) tanpa perlu berjalan bolak-balik.
* **Fitur 3 — Dead Stock Aging Analyzer:**  
  Sistem melacak usia penyimpanan barang di rak (30, 60, >90 hari) dan memberikan rekomendasi otomatis untuk diskon cuci gudang atau retur ke supplier.

#### Matriks Target Dampak Nyata:

| Fitur Bernilai Tambah | Cara Kerja Singkat | Target Dampak Nyata |
| :--- | :--- | :--- |
| **Smart Reorder Point** | Hitung ambang batas $\rightarrow$ Kirim peringatan otomatis | Mencegah kehabisan stok (*Zero Stock-Out*) |
| **Guided Batch Picking** | Gabung pesanan $\rightarrow$ Rute ambil satu arah (*S-Shape*) | Memangkas waktu jalan staf 35% – 50% |
| **Dead Stock Analyzer** | Lacak umur barang $\rightarrow$ Rekomendasi cuci gudang | Mencairkan modal kerja macet & melegakan kapasitas rak |

---

### BAGIAN 5. Prioritas Implementasi & Batasan Ruang Lingkup (Scope)

* **Prioritas Fitur (MoSCoW):**
  * **Must Have:** 5 Fitur Inti WMS + *Smart Reorder Point Alert*.
  * **Should Have:** *Guided S-Shape Batch Picking*.
  * **Could Have:** *Dead Stock Aging Analyzer*.
* **In-Scope (Fokus Skripsi):**  
  Aplikasi web responsif, autentikasi multi-role (Admin & Operator Gudang), pencatatan transaksi barang real-time, lokasi rak, dan kalkulasi peringatan stok.
* **Out-of-Scope (Sengaja Dibatasi):**  
  Sensor timbangan fisik IoT dan integrasi pelacakan GPS armada truk.

> **Poin Penting untuk Disampaikan:**  
> Penentuan *Out-of-Scope* bukan kelemahan sistem, melainkan strategi manajemen proyek yang realistis agar skripsi selesai tepat waktu dan teruji kualitasnya.

---

### BAGIAN 6. Rumusan Value Proposition & Penutup

* **Rumusan Value Proposition GudangPro:**  
  > *"GudangPro tidak hanya membantu mencatat keluar-masuknya barang di gudang, tetapi juga membantu mencegah kehabisan stok dan mempercepat pengambilan barang melalui fitur Smart Reorder Point dan Pemetaan Rak yang Terorganisir."*
* **Langkah Selanjutnya:**  
  Rancangan produk ini telah tuntas dan siap menjadi fondasi penyusunan **Product Requirements Document (PRD)** sebelum memasuki tahap *vibe coding* dan evaluasi pengujian.
