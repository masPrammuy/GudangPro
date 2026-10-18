# Spesifikasi Teknis Desain: Role-Based Access Control (RBAC), Manajemen Pengguna, Dashboard Grafik Analitik, dan Manajemen Profil

---

- **Dokumen ID**: SPEC-2026-10-18-RBAC-CHARTS
- **Tanggal Penyusunan**: 18 Oktober 2026
- **Status**: Disetujui (Approved)
- **Target Platform**: Flutter Mobile (Android, iOS) & Web Emulator
- **Arsitektur**: Feature-First Clean Architecture + Riverpod (v2)

---

## 1. Ringkasan Eksekutif & Tujuan Sistem

Fitur ini memperluas kapabilitas aplikasi manajemen pergudangan garmen **GudangPro Apparel** dengan memperkenalkan sistem kendali akses berbasis peran (*Role-Based Access Control* - RBAC) yang membedakan hak akses dan antarmuka kerja antara **Administrator** dan **User (Operator Gudang)**.

Tujuan utama spesifikasi ini meliputi:
1. **Pemisahan Peran & Keamanan Sesi**: Menyediakan modul autentikasi dengan dua peran baku (`UserRole.admin` dan `UserRole.user`), dilengkapi identitas Nomor Induk Karyawan (NIK).
2. **Manajemen Akun Terpusat**: Memberikan wewenang kepada Administrator untuk mendaftarkan akun baru, mengelola status aktif/nonaktif, serta mengedit data profil seluruh pengguna.
3. **Penyuntingan Profil Terkontrol**: Pengguna biasa (*User*) memiliki wewenang untuk memperbarui profil pribadinya sendiri (nama, nomor telepon, dan kata sandi), sementara data krusial seperti NIK, Email, dan Role hanya dapat diubah oleh Administrator.
4. **Visualisasi Data Eksekutif (Analytics Dashboard)**: Menghadirkan 4 (empat) komponen grafik visual interaktif berbasis `fl_chart` untuk memberikan wawasan data komprehensif bagi Administrator mengenai pergerakan stok, volume transaksi, dan akurasi opname.
5. **Prinsip Zero-Freeze Offline Resilience**: Sistem tetap beroperasi secara mandiri dan interaktif tanpa ketergantungan koneksi internet melalui penyediaan akun *seed* bawaan, sembari tetap kompatibel dengan sinkronisasi Supabase Auth.

---

## 2. Model Domain & Spesifikasi Data

### 2.1 Model `UserModel` & Enumerasi `UserRole`
Model domain pengguna didefinisikan pada `mobile/lib/features/auth/data/user_model.dart`:

```dart
enum UserRole {
  admin,
  user;

  String get displayName => this == UserRole.admin ? 'Administrator' : 'Operator Gudang';
}

class UserModel {
  final String id;
  final String nik;            // Nomor Induk Karyawan (misal: ADM-001, STF-042)
  final String name;           // Nama Lengkap Pengguna
  final String email;          // Alamat Email Resmi
  final String phone;          // Nomor Telepon / WhatsApp
  final UserRole role;         // Hak Akses (admin / user)
  final bool isActive;         // Status Akun (true = Aktif, false = Nonaktif)
  final String avatarUrl;      // URL / Path Foto Profil
  final DateTime createdAt;    // Waktu Perekaman Akun

  const UserModel({
    required this.id,
    required this.nik,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.isActive = true,
    this.avatarUrl = '',
    required this.createdAt,
  });

  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;

  UserModel copyWith({
    String? nik,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    bool? isActive,
    String? avatarUrl,
  }) {
    return UserModel(
      id: id,
      nik: nik ?? this.nik,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      nik: json['nik'] as String? ?? '',
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String? ?? '',
      role: (json['role'] as String) == 'admin' ? UserRole.admin : UserRole.user,
      isActive: json['is_active'] as bool? ?? true,
      avatarUrl: json['avatar_url'] as String? ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nik': nik,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role == UserRole.admin ? 'admin' : 'user',
      'is_active': isActive,
      'avatar_url': avatarUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
```

### 2.2 Akun Bawaan Default (*Seed Accounts*)
Untuk menjamin aplikasi dapat langsung digunakan tanpa setup rumit, sistem menyediakan akun default:
1. **Administrator**:
   - ID: `user-adm-001`
   - NIK: `ADM-001`
   - Nama: `Pramudya Administrator`
   - Email: `admin@gudangpro.com`
   - Password: `admin123`
   - Role: `UserRole.admin`
   - Status: `isActive = true`
2. **Operator Gudang (User)**:
   - ID: `user-stf-042`
   - NIK: `STF-042`
   - Nama: `Budi Santoso (Staff Gudang)`
   - Email: `operator@gudangpro.com`
   - Password: `user123`
   - Role: `UserRole.user`
   - Status: `isActive = true`

---

## 3. Matriks Hak Akses & Peraturan Keamanan (*Permissions Matrix*)

### 3.1 Matriks Penyuntingan Profil

| Bidang Data (*Field*) | Akses oleh User (Operator) | Akses oleh Admin (Profil Sendiri) | Akses oleh Admin (Profil User Lain) |
| :--- | :---: | :---: | :---: |
| **Foto Profil / Avatar** | ✅ Dapat diubah | ✅ Dapat diubah | ✅ Dapat diubah |
| **Nama Lengkap** | ✅ Dapat diubah | ✅ Dapat diubah | ✅ Dapat diubah |
| **Nomor Telepon / WhatsApp** | ✅ Dapat diubah | ✅ Dapat diubah | ✅ Dapat diubah |
| **Kata Sandi (Password)** | ✅ Dapat ganti kata sandi | ✅ Dapat ganti kata sandi | ✅ Dapat me-reset password |
| **NIK (Nomor Induk Karyawan)** | 🔒 Terkunci (Read-Only) | 🔒 Terkunci (Read-Only) | ✅ **Dapat diubah oleh Admin** |
| **Email Akun** | 🔒 Terkunci (Read-Only) | 🔒 Terkunci (Read-Only) | ✅ **Dapat diubah oleh Admin** |
| **Role (Hak Akses)** | 🔒 Terkunci (`User`) | 🔒 Terkunci (`Admin`) | ✅ **Dapat diubah (`Admin` $\leftrightarrow$ `User`)** |
| **Status Akun (Aktif/Nonaktif)** | 🔒 Terkunci (`Aktif`) | 🔒 Terkunci (Pencegahan *Self-Lockout*) | ✅ **Dapat mengaktifkan / menonaktifkan** |

### 3.2 Penyekatan Rute Navigasi (*Navigation Guards*)
- Apabila sesi `currentUser == null`, router menampilkan `LoginScreen`.
- Apabila akun yang sedang login memiliki `isActive == false`, sistem secara otomatis memutus sesi (*force logout*) dan menampilkan pesan galat: *"Akun Anda telah dinonaktifkan oleh Administrator. Hubungi kepala gudang."*
- Menu **Dashboard Grafik** dan **Manajemen Pengguna** secara eksklusif hanya dapat diakses oleh akun dengan `role == UserRole.admin`. Pengguna dengan peran `user` tidak akan melihat tab maupun tombol navigasi tersebut.

---

## 4. Arsitektur Antarmuka Pengguna Adaptif

### 4.1 Struktur Tab untuk Role **User (Operator Gudang)**
1. **Stok Master**: Katalog 4 zona garmen dengan pencarian dan filter chip.
2. **Bahan Masuk**: Form penerimaan PO kain dan aksesoris.
3. **Kirim Baju**: Form penerbitan DO pengiriman dengan proteksi *anti-over-shipping*.
4. **Opname Fisik**: Audit stok fisik dan kalkulasi selisih.
5. **Profil Saya**: Informasi akun pengguna (NIK, nama, kontak) dan tombol ubah profil.

### 4.2 Struktur Tab untuk Role **Administrator**
1. **Dashboard Grafik**: 4 grafik visual analitik performa pergudangan.
2. **Stok Master**: Monitoring katalog stok dan pengawasan ambang minimum.
3. **Transaksi Gudang**: Pengawasan terintegrasi modul Penerimaan PO dan Pengiriman DO.
4. **Opname Fisik**: Rekonsiliasi fisik vs sistem dan evaluasi selisih.
5. **Manajemen User**: Manajemen daftar akun, pembuatan user baru, dan pengeditan profil semua staf.
6. **Profil Admin**: Informasi akun admin, pengaturan sistem, dan tombol logout.

---

## 5. Spesifikasi 4 Komponen Grafik Analitik (*fl_chart*)

Pada modul `mobile/lib/features/dashboard/presentation/widgets/`:

1. **`ZoneDistributionChart` (Donut / Pie Chart)**:
   - Menghitung akumulasi kuantitas stok berdasarkan 4 zona workshop konveksi.
   - Menggunakan palet warna tema industrial:
     - Zona A (Kain Tekstil): `#3B82F6` (Biru)
     - Zona B (Aksesoris Jahit): `#8B5CF6` (Ungu)
     - Zona C (Pola Potong): `#F59E0B` (Amber)
     - Zona D (Baju Jadi & Packing): `#10B981` (Hijau)
   - Dilengkapi kartu ringkasan total stok dan persentase kontribusi per zona.
2. **`InboundOutboundChart` (Grouped Bar Chart)**:
   - Menampilkan perbandingan volume barang masuk (Inbound PO) vs barang keluar (Outbound DO).
   - Batang Inbound diwarnai `#10B981` (Emerald), sedangkan Outbound diwarnai `#6366F1` (Indigo).
3. **`StockHealthChart` (Distribution / Status Bar Chart)**:
   - Visualisasi perbandingan rasio:
     - `Tersedia`: Jumlah item dengan stok aman.
     - `⚠️ Stok Minimum!`: Jumlah item yang mendekati batas minimum.
     - `🚨 Stok Habis`: Jumlah item dengan stok 0.
4. **`AuditAccuracyGauge` (Accuracy & Discrepancy Card)**:
   - Menghitung rasio akurasi fisik:
     $$\text{Akurasi} = \left( 1 - \frac{\sum |\Delta_{\text{stock}}|}{\sum Q_{\text{system}}} \right) \times 100\%$$
   - Menampilkan selisih bersih (*net discrepancy*) barang surplus vs defisit.

---

## 6. Strategi State Management & Lapisan Repositori

### 6.1 `AuthRepository` (`features/auth/data/auth_repository.dart`)
- Mempertahankan daftar akun `List<UserModel> _users` dalam memori lokal dengan 2 akun *seed* default.
- Metode publik:
  - `Future<UserModel?> login(String email, String password)`
  - `Future<void> logout()`
  - `Future<List<UserModel>> getAllUsers()`
  - `Future<UserModel> createUser(UserModel newUser, String initialPassword)`
  - `Future<UserModel> updateUserProfile(UserModel updatedUser)`
  - `Future<void> toggleUserActiveStatus(String userId, bool isActive)`
  - `Future<void> changePassword(String userId, String oldPassword, String newPassword)`

### 6.2 Provider Riverpod (`features/auth/providers/auth_providers.dart`)
- `authRepositoryProvider`: Repositori autentikasi singleton.
- `currentUserProvider`: Menyimpan objek `UserModel?` yang sedang aktif.
- `userListProvider`: Stream/State notifier yang menyajikan daftar akun termutakhir kepada Admin.

---

## 7. Rencana Pengujian Otomatis (TDD)

Sesuai metodologi *Test-Driven Development*, seluruh komponen diuji secara komprehensif:

1. `test/unit/user_model_test.dart`:
   - Validasi parsing JSON `UserModel`.
   - Validasi getter `isAdmin`, `isUser`, dan keberadaan field `nik`.
2. `test/unit/auth_repository_test.dart`:
   - Validasi login berhasil dengan kredensial default admin & user.
   - Validasi penolakan login untuk akun nonaktif atau kata sandi keliru.
   - Validasi penambahan user baru dengan NIK unik oleh Admin.
   - Validasi bahwa Admin dapat mengubah profil user lain dan user biasa hanya dapat mengubah profilnya sendiri.
3. `test/widget/login_screen_test.dart`:
   - Render form login dan tombol aksi *Quick Fill*.
   - Transisi ke layar utama setelah autentikasi berhasil.
4. `test/widget/user_management_screen_test.dart`:
   - Admin dapat melihat daftar pengguna, memfilter role, membuka dialog tambah user, dan membuka dialog edit profil.
5. `test/widget/profile_screen_test.dart`:
   - Tampilan profil membaca data NIK secara akurat.
   - Form penyuntingan profil mematuhi pembatasan hak akses (*read-only fields* untuk User biasa).
6. `test/widget/admin_dashboard_screen_test.dart`:
   - Memverifikasi render 4 komponen grafik visual `fl_chart`.
7. `flutter test` & `flutter analyze`:
   - Memastikan seluruh pengujian otomatis lulus 100% dan analisis statis kode bersih (*0 issues*).
