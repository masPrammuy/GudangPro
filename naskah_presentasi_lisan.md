# NASKAH PRESENTASI LISAN (SPOKEN SCRIPT)
**Tugas Eksplorasi Produk dan Perancangan Fitur Bernilai Tambah: GudangPro (WMS)**
*Estimasi Durasi: 5 – 7 Menit (Padat, Lugas, dan Terfokus pada Alur Slide)*

---

### 🎙️ SLIDE 1: JUDUL & LATAR BELAKANG IDE
*(Tampilkan Slide 01: Judul & Latar Belakang Ide)*

> **[Kata Pembuka & Salam]**  
> *"Selamat pagi/siang Bapak/Ibu Dosen Pembimbing dan Dosen Penguji.*  
> *Perkenalkan, nama saya [Nama Anda]. Hari ini saya akan mempresentasikan hasil pengerjaan **Tugas Eksplorasi Produk dan Perancangan Fitur Bernilai Tambah** yang menjadi batu pijakan sebelum penyusunan PRD dan proses vibe coding skripsi saya.*  
>  
> *Proyek yang saya kembangkan berjudul: **GudangPro**, yaitu Sistem Manajemen Pergudangan (Warehouse Management System) berbasis web. Prototipe awalnya saat ini sudah live dan dapat diakses publik melalui link `gudang-pro-flame.vercel.app`.*  
>  
> *Melalui tugas ini, saya belajar dari bedah produk **Mibebi Kasir** untuk memahami bagaimana mentransformasikan sebuah sistem: dari sekadar alat pencatat pasif menjadi mesin yang secara aktif meningkatkan efisiensi dan melindungi keuntungan bisnis. Mari kita masuk ke slide kedua."*

---

### 🎙️ SLIDE 2: FILOSOFI — FITUR INTI VS FITUR BERNILAI TAMBAH
*(Klik Next → Tampilkan Slide 02)*

> *"Bapak/Ibu Dosen sekalian, hal paling berharga yang saya pelajari dari eksplorasi ini adalah membedakan produk ke dalam **Dua Lapisan Nilai (Two-Layered Value)**:*  
>  
> *1. **Lapisan Pertama adalah Fitur Inti (Core).** Ini adalah fitur yang 'harus ada' agar sistem bisa berjalan. Di gudang, fitur intinya adalah mencatat barang masuk, barang keluar, dan mencatat master SKU. Namun, jika aplikasi saya hanya berhenti di sini, aplikasi ini hanyalah 'kalkulator digital' atau Google Spreadsheet yang dipindah ke web. Belum ada nilai jualnya.*  
>  
> *2. **Lapisan Kedua adalah Fitur Bernilai Tambah (Value-Added).** Inilah pembeda sebenarnya. Fitur ini proaktif, cerdas, dan langsung menyelesaikan masalah operasional atau finansial pemilik gudang—seperti mencegah kehabisan barang dan memandu staf agar tidak capek keliling lorong gudang.*  
>  
> *Prinsip yang saya pegang teguh dalam tugas ini adalah: **Cari masalah nyata manusia $\rightarrow$ Pahami proses bisnisnya $\rightarrow$ Tentukan fitur inti $\rightarrow$ Rancang nilai tambah $\rightarrow$ dan Buktikan dampaknya.**"*

---

### 🎙️ SLIDE 3: 3 MASALAH NYATA DI LANTAI GUDANG
*(Klik Next → Tampilkan Slide 03)*

> *"Sebelum memikirkan coding atau teknologi, saya membedah masalah riil di lantai gudang. Sebagaimana ditekankan dalam panduan tugas, **'Teknologi bukan masalah bisnis'**. Masalahnya bukan karena gudang 'belum pakai AI' atau 'belum pakai cloud', melainkan 3 kesakitan nyata berikut:*  
>  
> *1. **Stock Discrepancy (Selisih Stok):** Catatan di buku menyatakan barang masih ada 10 box, tapi saat dicari fisiknya kosong. Akibatnya order pelanggan dibatalkan dan toko rugi.*  
> *2. **Ambil Barang Lambat (High Retrieval Time):** Karena penataan rak acak, staf picker menghabiskan **50% jam kerjanya hanya untuk jalan kaki mondar-mandir** menyusuri lorong yang sama.*  
> *3. **Dead Stock (Modal Macet):** Barang baru menumpuk barang lama di rak. Akhirnya barang lama tertimbun berbulan-bulan, rusak, kadaluwarsa, dan modal puluhan juta rupiah terkunci mati di pojokan gudang.*  
>  
> *Ketiga masalah inilah yang menjadi target tembak dari GudangPro."*

---

### 🎙️ SLIDE 4: 5 FITUR INTI GUDANGPRO (FONDASI WMS)
*(Klik Next → Tampilkan Slide 04)*

> *"Untuk menjawab proses bisnis dasarnya, saya merumuskan **5 Fitur Inti** GudangPro:*  
> *1. **Master Data SKU:** Database tunggal identitas barang dan barcode.*  
> *2. **Pencatatan Inbound:** Pintu masuk resmi bertambahnya stok dari supplier.*  
> *3. **Pencatatan Outbound:** Verifikasi resmi keluarnya barang untuk pemenuhan pesanan.*  
> *4. **Pemetaan Lokasi Rak (Bin Mapping):** Alamat presisi penyimpanan per barang (misal: Zona A, Lorong 2, Rak 4).*  
> *5. **Kartu Stok (Audit Trail):** Rekam jejak kronologis siapa dan kapan yang memutasi barang.*  
>  
> *Sesuai rubrik tugas, ada pertanyaan uji: **'Jika salah satu fitur di atas dihilangkan, apakah GudangPro masih bisa disebut WMS?'**  
> Jawaban saya tegas: **TIDAK BISA.** Tanpa lokasi rak, sistem ini hanyalah kasir toko biasa. Tanpa kartu stok, sistem ini tidak bisa dipakai audit. Kelima fitur ini adalah tiket masuk non-negotiable agar aplikasi ini sah disebut Warehouse Management System."*

---

### 🎙️ SLIDE 5: 3 FITUR BERNILAI TAMBAH (THE GAME CHANGERS)
*(Klik Next → Tampilkan Slide 05)*

> *"Sekarang kita masuk ke inti inovasi skripsi saya, yaitu **3 Fitur Bernilai Tambah** yang orisinal dari karakteristik pergudangan:*  
>  
> *1. **Fitur Pertama: Smart Reorder Point (ROP) & Auto Stock-Out Alert.**  
> Sistem secara otomatis menghitung konsumsi harian dan lead time pengiriman supplier. Begitu stok menyentuh titik kritis, sistem proaktif mengirimkan peringatan ke WhatsApp/Email staf purchasing lengkap dengan rekomendasi kuantitas yang harus diorder.  
> **Dampaknya:** Mengeliminasi hingga **90% risiko kehabisan barang (*Zero Stock-Out*)**.*  
>  
> *2. **Fitur Kedua: S-Shape Batch Picking Route.**  
> Sistem menggabungkan 5 sampai 10 pesanan sekaligus, lalu memandu rute langkah kaki staf secara satu arah menyusuri rak dari lorong ke lorong tanpa perlu berbalik arah.  
> **Dampaknya:** Memangkas waktu pengambilan barang hingga **35 sampai 50%**, melipatgandakan kapasitas kirim gudang.*  
>  
> *3. **Fitur Ketiga: Dead Stock Aging Analyzer.**  
> Sistem melacak usia setiap batch barang. Jika ada barang mengendap lebih dari 90 hari tanpa keluar, sistem memberi rekomendasi aksi: retur ke supplier atau diskon cuci gudang B2B.  
> **Dampaknya:** **Mencairkan modal kerja yang macet** dan mengosongkan kapasitas rak untuk barang cepat laku."*

---

### 🎙️ SLIDE 6: VALUE PROPOSITION, SCOPE, & PENUTUP
*(Klik Next → Tampilkan Slide 06)*

> *"Sebagai kesimpulan, saya merumuskan **Value Proposition resmi GudangPro**:*  
> *'Aplikasi GudangPro tidak hanya membantu mencatat keluar-masuknya barang, tetapi juga membantu mencegah kerugian kehabisan stok dan memangkas waktu pencarian barang melalui fitur Smart Reorder Point dan Pemetaan Lokasi Rak Presisi.'*  
>  
> *Untuk menjaga agar skripsi ini selesai tepat waktu dan tidak mengalami feature creep, saya **mengunci ruang lingkup (Scope Guard)**:*  
> *• **In-Scope:** Fokus pada software web WMS cerdas, autentikasi multi-role, pencatatan transaksi real-time, lokasi rak, dan kalkulasi alert stok.*  
> *• **Out-of-Scope:** Saya dengan sengaja meniadakan sensor hardware timbangan fisik IoT dan robotik AGV karena berada di luar batas waktu skripsi.*  
>  
> *Dengan selesainya dokumen eksplorasi produk ini, saya siap menyusun Product Requirements Document (PRD) yang matang sebelum melangkah ke tahap vibe coding.*  
>  
> *Sekian presentasi dari saya. Terima kasih banyak atas waktu Bapak/Ibu Dosen, dan saya menyambut baik segala saran, masukan, ataupun pertanyaan. Terima kasih."*

---
*Naskah presentasi ini dirancang dengan durasi 5–7 menit, padat, lugas, dan terstruktur sesuai alur slide 1 s.d. 6.*
