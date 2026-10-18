# Implementation Plan: Role-Based Access Control (RBAC), User Management, Analytics Charts, and Profile Editing

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Role-Based Access Control (Admin vs User), account management, profile editing with strict permission enforcement, interactive data charts (`fl_chart`), and login authentication in GudangPro Apparel.

**Architecture:** Feature-First Clean Architecture extending `lib/features/auth/`, `lib/features/dashboard/`, and `lib/features/profile/` coupled with Riverpod v2 state management (`currentUserProvider`, `userListProvider`), integrated into `AdaptiveScaffold` for dynamic role-based navigation.

**Tech Stack:** Flutter 3.24+, Dart 3.5+, Riverpod 2.5.1+, `fl_chart: ^0.68.0`, Google Fonts (Inter), Supabase Flutter.

**Spec:** [docs/superpowers/specs/2026-10-18-rbac-user-management-charts-design.md](file:///c:/Users/Lenovo/.gemini/antigravity-ide/scratch/warehouse-app/docs/superpowers/specs/2026-10-18-rbac-user-management-charts-design.md)

## Global Constraints
- All Flutter code lives under `mobile/lib/`.
- All automated tests live under `mobile/test/` and run via `cd mobile; flutter test`.
- Visual styling must adhere to the Industrial Garment Theme (`AppColors.darkSlatePrimary`, `emeraldSuccess`, `amberWarning`, `roseDanger`, `indigoAccent`, and Zone Colors A: `#3B82F6`, B: `#8B5CF6`, C: `#F59E0B`, D: `#10B981`).
- Zero-freeze policy: Offline demo accounts (`admin@gudangpro.com` / `admin123` and `operator@gudangpro.com` / `user123`) must function instantaneously without network connectivity.
- Static analysis must be 100% clean (`cd mobile; flutter analyze` reporting 0 issues).

---

### Task 1: Dependensi `fl_chart` & Domain Model `UserModel` dengan NIK

**Files:**
- Modify: `mobile/pubspec.yaml`
- Create: `mobile/lib/features/auth/data/user_model.dart`
- Test: `mobile/test/unit/user_model_test.dart`

**Interfaces:**
- Produces: `enum UserRole { admin, user }`, `class UserModel` with fields `id`, `nik`, `name`, `email`, `phone`, `role`, `isActive`, `avatarUrl`, `createdAt`, `isAdmin`, `isUser`, `copyWith()`, `fromJson()`, `toJson()`.

- [ ] **Step 1: Write the failing unit test**

Create `mobile/test/unit/user_model_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';

void main() {
  group('UserModel Domain Tests', () {
    test('UserModel correctly serializes to and from JSON including NIK and Role', () {
      final now = DateTime(2026, 10, 18, 12, 0);
      final admin = UserModel(
        id: 'usr-001',
        nik: 'ADM-001',
        name: 'Pramudya Administrator',
        email: 'admin@gudangpro.com',
        phone: '08123456789',
        role: UserRole.admin,
        isActive: true,
        avatarUrl: '',
        createdAt: now,
      );

      expect(admin.isAdmin, isTrue);
      expect(admin.isUser, isFalse);
      expect(admin.nik, equals('ADM-001'));

      final json = admin.toJson();
      expect(json['nik'], equals('ADM-001'));
      expect(json['role'], equals('admin'));

      final parsed = UserModel.fromJson(json);
      expect(parsed.id, equals(admin.id));
      expect(parsed.nik, equals(admin.nik));
      expect(parsed.role, equals(UserRole.admin));
      expect(parsed.name, equals(admin.name));
    });

    test('UserModel copyWith modifies fields cleanly', () {
      final user = UserModel(
        id: 'usr-002',
        nik: 'STF-042',
        name: 'Budi Santoso',
        email: 'operator@gudangpro.com',
        phone: '08987654321',
        role: UserRole.user,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final updated = user.copyWith(
        name: 'Budi Santoso S.T.',
        phone: '08111222333',
        isActive: false,
      );

      expect(updated.name, equals('Budi Santoso S.T.'));
      expect(updated.phone, equals('08111222333'));
      expect(updated.isActive, isFalse);
      expect(updated.nik, equals('STF-042'));
      expect(updated.role, equals(UserRole.user));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/unit/user_model_test.dart`  
Expected: Compilation failure (missing `user_model.dart`).

- [ ] **Step 3: Add `fl_chart` to `pubspec.yaml` and implement `UserModel`**

In `mobile/pubspec.yaml`, add under `dependencies`:
```yaml
  fl_chart: ^0.68.0
```
Run `flutter pub get`.

Create `mobile/lib/features/auth/data/user_model.dart`:
```dart
enum UserRole {
  admin,
  user;

  String get displayName => this == UserRole.admin ? 'Administrator' : 'Operator Gudang';
}

class UserModel {
  final String id;
  final String nik;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final bool isActive;
  final String avatarUrl;
  final DateTime createdAt;

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

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/unit/user_model_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/pubspec.yaml mobile/pubspec.lock mobile/lib/features/auth/ mobile/test/unit/user_model_test.dart
git commit -m "feat(auth): add fl_chart dependency and implement UserModel with NIK and UserRole"
```

---

### Task 2: Repositori Autentikasi (`AuthRepository`) & Riverpod Providers

**Files:**
- Create: `mobile/lib/features/auth/data/auth_repository.dart`
- Create: `mobile/lib/features/auth/providers/auth_providers.dart`
- Test: `mobile/test/unit/auth_repository_test.dart`

**Interfaces:**
- Consumes: `UserModel`, `UserRole` from Task 1.
- Produces: `AuthRepository` with methods `login()`, `logout()`, `getAllUsers()`, `createUser()`, `updateUserProfile()`, `toggleUserStatus()`, `authRepositoryProvider`, `currentUserProvider`, `userListProvider`.

- [ ] **Step 1: Write the failing unit test**

Create `mobile/test/unit/auth_repository_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/auth_repository.dart';
import 'package:mobile/features/auth/data/user_model.dart';

void main() {
  group('AuthRepository Unit Tests', () {
    late AuthRepository repo;

    setUp(() {
      repo = AuthRepository();
    });

    test('Login with valid default admin credentials succeeds', () async {
      final user = await repo.login('admin@gudangpro.com', 'admin123');
      expect(user, isNotNull);
      expect(user!.isAdmin, isTrue);
      expect(user.nik, equals('ADM-001'));
    });

    test('Login with invalid credentials returns null', () async {
      final user = await repo.login('admin@gudangpro.com', 'wrongpass');
      expect(user, isNull);
    });

    test('Admin can create a new user with custom NIK', () async {
      final newUser = UserModel(
        id: 'usr-new-003',
        nik: 'STF-088',
        name: 'Ahmad Fauzi',
        email: 'ahmad@gudangpro.com',
        phone: '081299887766',
        role: UserRole.user,
        isActive: true,
        createdAt: DateTime.now(),
      );

      final created = await repo.createUser(newUser, 'ahmad123');
      expect(created.id, equals('usr-new-003'));

      final allUsers = await repo.getAllUsers();
      expect(allUsers.any((u) => u.nik == 'STF-088'), isTrue);

      final loggedIn = await repo.login('ahmad@gudangpro.com', 'ahmad123');
      expect(loggedIn, isNotNull);
      expect(loggedIn!.name, equals('Ahmad Fauzi'));
    });

    test('Updating user profile persists in user list', () async {
      final user = await repo.login('operator@gudangpro.com', 'user123');
      expect(user, isNotNull);

      final updated = user!.copyWith(name: 'Budi Santoso Senior', phone: '0877112233');
      await repo.updateUserProfile(updated);

      final reloaded = await repo.login('operator@gudangpro.com', 'user123');
      expect(reloaded!.name, equals('Budi Santoso Senior'));
      expect(reloaded.phone, equals('0877112233'));
    });

    test('Deactivated user cannot login', () async {
      await repo.toggleUserStatus('user-stf-042', false);
      final attempt = await repo.login('operator@gudangpro.com', 'user123');
      expect(attempt, isNull);
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/unit/auth_repository_test.dart`  
Expected: Compilation failure (`AuthRepository` not found).

- [ ] **Step 3: Implement `AuthRepository` and Riverpod providers**

Create `mobile/lib/features/auth/data/auth_repository.dart`:
```dart
import 'dart:async';
import 'user_model.dart';

class AuthRepository {
  final List<UserModel> _users = [
    UserModel(
      id: 'user-adm-001',
      nik: 'ADM-001',
      name: 'Pramudya Administrator',
      email: 'admin@gudangpro.com',
      phone: '081234567890',
      role: UserRole.admin,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    ),
    UserModel(
      id: 'user-stf-042',
      nik: 'STF-042',
      name: 'Budi Santoso (Staff Gudang)',
      email: 'operator@gudangpro.com',
      phone: '089876543210',
      role: UserRole.user,
      isActive: true,
      createdAt: DateTime(2026, 2, 1),
    ),
  ];

  final Map<String, String> _passwords = {
    'admin@gudangpro.com': 'admin123',
    'operator@gudangpro.com': 'user123',
  };

  final _usersStreamController = StreamController<List<UserModel>>.broadcast();

  Stream<List<UserModel>> watchUsers() async* {
    yield List.unmodifiable(_users);
    yield* _usersStreamController.stream;
  }

  Future<UserModel?> login(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();
    final matchedIndex = _users.indexWhere(
      (u) => u.email.toLowerCase() == cleanEmail && u.isActive,
    );

    if (matchedIndex != -1) {
      final expectedPass = _passwords[cleanEmail];
      if (expectedPass == password) {
        return _users[matchedIndex];
      }
    }
    return null;
  }

  Future<List<UserModel>> getAllUsers() async {
    return List.unmodifiable(_users);
  }

  Future<UserModel> createUser(UserModel newUser, String initialPassword) async {
    final cleanEmail = newUser.email.trim().toLowerCase();
    _users.add(newUser);
    _passwords[cleanEmail] = initialPassword;
    _usersStreamController.add(List.unmodifiable(_users));
    return newUser;
  }

  Future<UserModel> updateUserProfile(UserModel updatedUser) async {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index != -1) {
      _users[index] = updatedUser;
      _usersStreamController.add(List.unmodifiable(_users));
      return updatedUser;
    }
    throw Exception('User tidak ditemukan');
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final old = _users[index];
      _users[index] = old.copyWith(isActive: isActive);
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> updatePassword(String email, String newPassword) async {
    _passwords[email.trim().toLowerCase()] = newPassword;
  }
}
```

Create `mobile/lib/features/auth/providers/auth_providers.dart`:
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/auth_repository.dart';
import '../data/user_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class CurrentUserNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _repo;

  CurrentUserNotifier(this._repo) : super(null);

  Future<bool> login(String email, String password) async {
    final user = await _repo.login(email, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  void logout() {
    state = null;
  }

  Future<void> updateCurrentProfile(UserModel updated) async {
    final result = await _repo.updateUserProfile(updated);
    state = result;
  }
}

final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, UserModel?>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return CurrentUserNotifier(repo);
});

final userListProvider = StreamProvider<List<UserModel>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return repo.watchUsers();
});
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/unit/auth_repository_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/auth/ mobile/test/unit/auth_repository_test.dart
git commit -m "feat(auth): implement AuthRepository and Riverpod session providers with seed accounts"
```

---

### Task 3: Halaman Login Interaktif (`LoginScreen`) dengan Tombol Quick Fill

**Files:**
- Create: `mobile/lib/features/auth/presentation/login_screen.dart`
- Test: `mobile/test/widget/login_screen_test.dart`

**Interfaces:**
- Consumes: `currentUserProvider`, `authRepositoryProvider`, `AppColors`.
- Produces: `LoginScreen` widget with email, password fields, quick fill buttons, and validation.

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/login_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/presentation/login_screen.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';

void main() {
  testWidgets('LoginScreen renders logo, form fields, and quick fill buttons', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('GudangPro Apparel'), findsOneWidget);
    expect(find.text('Masuk ke Sistem WMS'), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.text('Quick Fill Admin'), findsOneWidget);
    expect(find.text('Quick Fill Operator'), findsOneWidget);
  });

  testWidgets('Tapping Quick Fill Admin fills admin credentials and logs in', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    await tester.tap(find.text('Quick Fill Admin'));
    await tester.pump();

    final emailInput = find.byKey(const Key('email_field'));
    expect(find.descendant(of: emailInput, matching: find.text('admin@gudangpro.com')), findsOneWidget);

    final loginBtn = find.text('Masuk Sekarang');
    await tester.tap(loginBtn);
    await tester.pump();
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/login_screen_test.dart`  
Expected: Compilation failure (`LoginScreen` not found).

- [ ] **Step 3: Implement `LoginScreen`**

Create `mobile/lib/features/auth/presentation/login_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAdmin() {
    setState(() {
      _emailController.text = 'admin@gudangpro.com';
      _passwordController.text = 'admin123';
      _errorMessage = null;
    });
  }

  void _fillOperator() {
    setState(() {
      _emailController.text = 'operator@gudangpro.com';
      _passwordController.text = 'user123';
      _errorMessage = null;
    });
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final success = await ref.read(currentUserProvider.notifier).login(
            _emailController.text,
            _passwordController.text,
          );

      if (!mounted) return;

      if (!success) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Email atau kata sandi salah, atau akun nonaktif.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppColors.slateSurface.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: CircleAvatar(
                          radius: 36,
                          backgroundColor: AppColors.darkSlatePrimary,
                          child: Icon(Icons.warehouse_rounded, size: 40, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'GudangPro Apparel',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.darkSlatePrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Masuk ke Sistem WMS Workshop Garmen',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.bottom(16),
                          decoration: BoxDecoration(
                            color: AppColors.roseDanger.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.roseDanger),
                          ),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.roseDanger, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                      TextFormField(
                        key: const Key('email_field'),
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Alamat Email',
                          prefixIcon: Icon(Icons.email_outlined),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Masukkan email' : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: const Key('password_field'),
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) => val == null || val.isEmpty ? 'Masukkan kata sandi' : null,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkSlatePrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Masuk Sekarang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 12),
                      const Text(
                        'Akses Demo Cepat:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _fillAdmin,
                              icon: const Icon(Icons.admin_panel_settings, size: 16),
                              label: const Text('Quick Fill Admin', style: TextStyle(fontSize: 11)),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.indigoAccent),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _fillOperator,
                              icon: const Icon(Icons.person, size: 16),
                              label: const Text('Quick Fill Operator', style: TextStyle(fontSize: 11)),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.emeraldSuccess),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/login_screen_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/auth/presentation/login_screen.dart mobile/test/widget/login_screen_test.dart
git commit -m "feat(auth): implement interactive LoginScreen with validation and instant Quick Fill demo buttons"
```

---

### Task 4: Modul Profil Pengguna & Logika Edit Profil Terkontrol (`ProfileScreen`)

**Files:**
- Create: `mobile/lib/features/profile/presentation/profile_screen.dart`
- Create: `mobile/lib/features/profile/presentation/edit_profile_dialog.dart`
- Test: `mobile/test/widget/profile_screen_test.dart`

**Interfaces:**
- Consumes: `currentUserProvider`, `authRepositoryProvider`, `UserModel`, `UserRole`.
- Produces: `ProfileScreen`, `EditProfileDialog` with role permission restrictions (User cannot edit NIK/Role; Admin can edit).

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/profile_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';
import 'package:mobile/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('ProfileScreen renders user NIK, name, role badge, and edit button', (tester) async {
    final mockUser = UserModel(
      id: 'test-usr',
      nik: 'STF-042',
      name: 'Budi Santoso',
      email: 'operator@gudangpro.com',
      phone: '08123456789',
      role: UserRole.user,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = mockUser),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    expect(find.text('Profil Pengguna'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('NIK: STF-042'), findsOneWidget);
    expect(find.text('Operator Gudang'), findsOneWidget);
    expect(find.text('Edit Profil Saya'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/profile_screen_test.dart`  
Expected: Compilation failure (`ProfileScreen` not found).

- [ ] **Step 3: Implement `ProfileScreen` and `EditProfileDialog`**

Create `mobile/lib/features/profile/presentation/edit_profile_dialog.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/data/user_model.dart';
import '../../auth/providers/auth_providers.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final UserModel targetUser;
  final bool isEditingOther;

  const EditProfileDialog({
    super.key,
    required this.targetUser,
    this.isEditingOther = false,
  });

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nikController;
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late UserRole _selectedRole;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController(text: widget.targetUser.nik);
    _nameController = TextEditingController(text: widget.targetUser.name);
    _emailController = TextEditingController(text: widget.targetUser.email);
    _phoneController = TextEditingController(text: widget.targetUser.phone);
    _selectedRole = widget.targetUser.role;
    _isActive = widget.targetUser.isActive;
  }

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      final currentUser = ref.read(currentUserProvider);
      final canEditAdminFields = currentUser?.isAdmin == true;

      final updated = widget.targetUser.copyWith(
        nik: canEditAdminFields ? _nikController.text.trim() : widget.targetUser.nik,
        name: _nameController.text.trim(),
        email: canEditAdminFields ? _emailController.text.trim() : widget.targetUser.email,
        phone: _phoneController.text.trim(),
        role: canEditAdminFields ? _selectedRole : widget.targetUser.role,
        isActive: canEditAdminFields ? _isActive : widget.targetUser.isActive,
      );

      if (currentUser?.id == widget.targetUser.id) {
        await ref.read(currentUserProvider.notifier).updateCurrentProfile(updated);
      } else {
        await ref.read(authRepositoryProvider).updateUserProfile(updated);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profil ${updated.name} berhasil diperbarui!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final canEditAdminFields = currentUser?.isAdmin == true && (widget.isEditingOther || widget.targetUser.id != currentUser?.id);

    return AlertDialog(
      title: Text(widget.isEditingOther ? 'Edit Akun Pengguna' : 'Edit Profil Saya'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nikController,
                readOnly: !canEditAdminFields,
                decoration: InputDecoration(
                  labelText: 'Nomor Induk Karyawan (NIK)',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  suffixIcon: !canEditAdminFields ? const Icon(Icons.lock, size: 16, color: Colors.grey) : null,
                  filled: !canEditAdminFields,
                  fillColor: !canEditAdminFields ? Colors.grey.shade100 : null,
                ),
                validator: (val) => val == null || val.isEmpty ? 'NIK wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                readOnly: !canEditAdminFields,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                  prefixIcon: const Icon(Icons.email_outlined),
                  suffixIcon: !canEditAdminFields ? const Icon(Icons.lock, size: 16, color: Colors.grey) : null,
                  filled: !canEditAdminFields,
                  fillColor: !canEditAdminFields ? Colors.grey.shade100 : null,
                ),
                validator: (val) => val == null || val.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon / WA', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              if (canEditAdminFields) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(labelText: 'Peran / Role Pengguna'),
                  items: const [
                    DropdownMenuItem(value: UserRole.user, child: Text('Operator Gudang')),
                    DropdownMenuItem(value: UserRole.admin, child: Text('Administrator')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRole = val);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Status Akun Aktif'),
                  subtitle: Text(_isActive ? 'Akun dapat login' : 'Akun dibekukan'),
                  value: _isActive,
                  onChanged: (val) => setState(() => _isActive = val),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldSuccess, foregroundColor: Colors.white),
          child: const Text('Simpan Perubahan'),
        ),
      ],
    );
  }
}
```

Create `mobile/lib/features/profile/presentation/profile_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/providers/auth_providers.dart';
import 'edit_profile_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Center(child: Text('Sesi telah berakhir'));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSlatePrimary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar Akun',
            onPressed: () {
              ref.read(currentUserProvider.notifier).logout();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: (user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess),
                      ),
                      child: Text(
                        user.role.displayName,
                        style: TextStyle(
                          color: user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'NIK: ${user.nik}',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade700),
                    ),
                    const Divider(height: 32),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                    ListTile(
                      leading: const Icon(Icons.phone_outlined),
                      title: const Text('Nomor Telepon'),
                      subtitle: Text(user.phone.isNotEmpty ? user.phone : '-'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.check_circle_outline, color: AppColors.emeraldSuccess),
                      title: const Text('Status Akun'),
                      subtitle: Text(user.isActive ? 'Aktif' : 'Nonaktif'),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => EditProfileDialog(targetUser: user),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profil Saya'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkSlatePrimary,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/profile_screen_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/profile/ mobile/test/widget/profile_screen_test.dart
git commit -m "feat(profile): implement ProfileScreen and permission-aware EditProfileDialog"
```

---

### Task 5: Modul Manajemen Pengguna Khusus Admin (`UserManagementScreen`)

**Files:**
- Create: `mobile/lib/features/auth/presentation/user_management_screen.dart`
- Create: `mobile/lib/features/auth/presentation/add_user_dialog.dart`
- Test: `mobile/test/widget/user_management_screen_test.dart`

**Interfaces:**
- Consumes: `userListProvider`, `authRepositoryProvider`, `currentUserProvider`, `EditProfileDialog`.
- Produces: `UserManagementScreen` with user cards, role filtering, new user creation modal, and admin edit triggers.

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/user_management_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/presentation/user_management_screen.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';

void main() {
  testWidgets('UserManagementScreen lists users and opens Add User dialog', (tester) async {
    final mockUsers = [
      UserModel(
        id: 'u-1',
        nik: 'ADM-001',
        name: 'Pramudya Administrator',
        email: 'admin@gudangpro.com',
        phone: '08123',
        role: UserRole.admin,
        isActive: true,
        createdAt: DateTime.now(),
      ),
      UserModel(
        id: 'u-2',
        nik: 'STF-042',
        name: 'Budi Santoso',
        email: 'operator@gudangpro.com',
        phone: '08999',
        role: UserRole.user,
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userListProvider.overrideWith((ref) => Stream.value(mockUsers)),
        ],
        child: const MaterialApp(home: UserManagementScreen()),
      ),
    );

    expect(find.text('Manajemen Pengguna'), findsOneWidget);
    expect(find.text('Pramudya Administrator'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('NIK: ADM-001'), findsOneWidget);
    expect(find.text('Tambah Akun User'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/user_management_screen_test.dart`  
Expected: Compilation failure (`UserManagementScreen` not found).

- [ ] **Step 3: Implement `AddUserDialog` and `UserManagementScreen`**

Create `mobile/lib/features/auth/presentation/add_user_dialog.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../data/user_model.dart';
import '../providers/auth_providers.dart';

class AddUserDialog extends ConsumerStatefulWidget {
  const AddUserDialog({super.key});

  @override
  ConsumerState<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends ConsumerState<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nikController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  UserRole _role = UserRole.user;

  @override
  void dispose() {
    _nikController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final newUser = UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        nik: _nikController.text.trim(),
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        role: _role,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await ref.read(authRepositoryProvider).createUser(newUser, _passwordController.text);

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Akun ${newUser.name} (NIK: ${newUser.nik}) berhasil dibuat!'),
          backgroundColor: AppColors.emeraldSuccess,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Akun Karyawan Baru'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nikController,
                decoration: const InputDecoration(labelText: 'NIK (misal: STF-043)', prefixIcon: Icon(Icons.badge_outlined)),
                validator: (val) => val == null || val.isEmpty ? 'NIK wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', prefixIcon: Icon(Icons.person_outline)),
                validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email Akun', prefixIcon: Icon(Icons.email_outlined)),
                validator: (val) => val == null || val.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon / WA', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Kata Sandi Awal', prefixIcon: Icon(Icons.lock_outline)),
                validator: (val) => val == null || val.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<UserRole>(
                value: _role,
                decoration: const InputDecoration(labelText: 'Peran / Role Akun'),
                items: const [
                  DropdownMenuItem(value: UserRole.user, child: Text('Operator Gudang')),
                  DropdownMenuItem(value: UserRole.admin, child: Text('Administrator')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _role = val);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
        ElevatedButton(
          onPressed: _handleSubmit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.emeraldSuccess, foregroundColor: Colors.white),
          child: const Text('Buat Akun'),
        ),
      ],
    );
  }
}
```

Create `mobile/lib/features/auth/presentation/user_management_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../profile/presentation/edit_profile_dialog.dart';
import '../data/user_model.dart';
import '../providers/auth_providers.dart';
import 'add_user_dialog.dart';

class UserManagementScreen extends ConsumerWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(userListProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Manajemen Pengguna', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSlatePrimary,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showDialog(context: context, builder: (_) => const AddUserDialog());
        },
        backgroundColor: AppColors.indigoAccent,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Tambah Akun User'),
      ),
      body: usersAsync.when(
        data: (users) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isMe = user.id == currentUser?.id;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: user.isActive ? Colors.grey.shade300 : AppColors.roseDanger.withOpacity(0.5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                if (isMe)
                                  const Padding(
                                    padding: EdgeInsets.only(left: 6),
                                    child: Chip(
                                      label: Text('Saya', style: TextStyle(fontSize: 10, color: Colors.white)),
                                      backgroundColor: AppColors.darkSlatePrimary,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('NIK: ${user.nik} • ${user.email}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.role.displayName,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: user.isAdmin ? AppColors.indigoAccent : AppColors.emeraldSuccess,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: (user.isActive ? AppColors.emeraldSuccess : AppColors.roseDanger).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.isActive ? 'Aktif' : 'Nonaktif',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: user.isActive ? AppColors.emeraldSuccess : AppColors.roseDanger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: AppColors.darkSlatePrimary),
                        tooltip: 'Edit Profil Akun Ini',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditProfileDialog(targetUser: user, isEditingOther: true),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat pengguna: $err')),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/user_management_screen_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/auth/presentation/ mobile/test/widget/user_management_screen_test.dart
git commit -m "feat(auth): implement UserManagementScreen and AddUserDialog for Administrator"
```

---

### Task 6: Dashboard Grafik Analitik Eksekutif Admin (`AdminDashboardScreen`)

**Files:**
- Create: `mobile/lib/features/dashboard/presentation/admin_dashboard_screen.dart`
- Create: `mobile/lib/features/dashboard/presentation/widgets/zone_distribution_chart.dart`
- Create: `mobile/lib/features/dashboard/presentation/widgets/inbound_outbound_chart.dart`
- Create: `mobile/lib/features/dashboard/presentation/widgets/stock_health_chart.dart`
- Create: `mobile/lib/features/dashboard/presentation/widgets/audit_accuracy_gauge.dart`
- Test: `mobile/test/widget/admin_dashboard_screen_test.dart`

**Interfaces:**
- Consumes: `inventoryListProvider`, `ItemModel`, `fl_chart`.
- Produces: `AdminDashboardScreen` with 4 interactive charts and summary cards.

- [ ] **Step 1: Write the failing widget test**

Create `mobile/test/widget/admin_dashboard_screen_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/dashboard/presentation/admin_dashboard_screen.dart';
import 'package:mobile/features/inventory/data/item_model.dart';
import 'package:mobile/features/inventory/providers/inventory_providers.dart';

void main() {
  testWidgets('AdminDashboardScreen renders KPI cards and 4 chart containers', (tester) async {
    final mockItems = [
      const ItemModel(
        id: '1',
        sku: 'SKU-1',
        name: 'Kain Katun',
        category: 'Kain',
        qty: 100,
        unit: 'Roll',
        minStock: 20,
        location: 'A-1',
        zone: 'A',
        status: 'Tersedia',
      ),
      const ItemModel(
        id: '2',
        sku: 'SKU-2',
        name: 'Resleting YKK',
        category: 'Aksesoris',
        qty: 10,
        unit: 'Pcs',
        minStock: 30,
        location: 'B-1',
        zone: 'B',
        status: '⚠️ Stok Minimum!',
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          inventoryListProvider.overrideWith((ref) => AsyncValue.data(mockItems)),
        ],
        child: const MaterialApp(home: AdminDashboardScreen()),
      ),
    );

    expect(find.text('Dashboard Analitik Gudang'), findsOneWidget);
    expect(find.text('Komposisi Stok per Zona'), findsOneWidget);
    expect(find.text('Aktivitas Inbound vs Outbound'), findsOneWidget);
    expect(find.text('Status Kesehatan Stok'), findsOneWidget);
    expect(find.text('Akurasi Audit Stock Opname'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget/admin_dashboard_screen_test.dart`  
Expected: Compilation failure (`AdminDashboardScreen` not found).

- [ ] **Step 3: Implement chart widgets and `AdminDashboardScreen`**

Create `mobile/lib/features/dashboard/presentation/widgets/zone_distribution_chart.dart`:
```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class ZoneDistributionChart extends StatelessWidget {
  final List<ItemModel> items;

  const ZoneDistributionChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    int zoneA = 0, zoneB = 0, zoneC = 0, zoneD = 0;
    for (final item in items) {
      if (item.zone == 'A') zoneA += item.qty;
      if (item.zone == 'B') zoneB += item.qty;
      if (item.zone == 'C') zoneC += item.qty;
      if (item.zone == 'D') zoneD += item.qty;
    }
    final total = zoneA + zoneB + zoneC + zoneD;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Komposisi Stok per Zona', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: total == 0
                  ? const Center(child: Text('Belum ada data stok'))
                  : PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 36,
                        sections: [
                          PieChartSectionData(value: zoneA.toDouble(), color: const Color(0xFF3B82F6), title: 'A', radius: 45),
                          PieChartSectionData(value: zoneB.toDouble(), color: const Color(0xFF8B5CF6), title: 'B', radius: 45),
                          PieChartSectionData(value: zoneC.toDouble(), color: const Color(0xFFF59E0B), title: 'C', radius: 45),
                          PieChartSectionData(value: zoneD.toDouble(), color: const Color(0xFF10B981), title: 'D', radius: 45),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLegend(const Color(0xFF3B82F6), 'A: $zoneA'),
                _buildLegend(const Color(0xFF8B5CF6), 'B: $zoneB'),
                _buildLegend(const Color(0xFFF59E0B), 'C: $zoneC'),
                _buildLegend(const Color(0xFF10B981), 'D: $zoneD'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
```

Create `mobile/lib/features/dashboard/presentation/widgets/inbound_outbound_chart.dart`:
```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class InboundOutboundChart extends StatelessWidget {
  const InboundOutboundChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Aktivitas Inbound vs Outbound', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            SizedBox(
              height: 160,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(toY: 65, color: AppColors.emeraldSuccess, width: 14),
                      BarChartRodData(toY: 48, color: AppColors.indigoAccent, width: 14),
                    ]),
                    BarChartGroupData(x: 1, barRods: [
                      BarChartRodData(toY: 80, color: AppColors.emeraldSuccess, width: 14),
                      BarChartRodData(toY: 62, color: AppColors.indigoAccent, width: 14),
                    ]),
                    BarChartGroupData(x: 2, barRods: [
                      BarChartRodData(toY: 40, color: AppColors.emeraldSuccess, width: 14),
                      BarChartRodData(toY: 55, color: AppColors.indigoAccent, width: 14),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(AppColors.emeraldSuccess, 'Bahan Masuk (PO)'),
                const SizedBox(width: 16),
                _buildDot(AppColors.indigoAccent, 'Kirim Baju (DO)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(Color color, String text) {
    return Row(
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
```

Create `mobile/lib/features/dashboard/presentation/widgets/stock_health_chart.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/data/item_model.dart';

class StockHealthChart extends StatelessWidget {
  final List<ItemModel> items;

  const StockHealthChart({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    int safe = 0, warning = 0, danger = 0;
    for (final item in items) {
      if (item.isOutOfStock) {
        danger++;
      } else if (item.isLowStock) {
        warning++;
      } else {
        safe++;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Status Kesehatan Stok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildHealthCard('Tersedia', safe, AppColors.emeraldSuccess)),
                const SizedBox(width: 8),
                Expanded(child: _buildHealthCard('Stok Tipis', warning, AppColors.amberWarning)),
                const SizedBox(width: 8),
                Expanded(child: _buildHealthCard('Habis', danger, AppColors.roseDanger)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthCard(String title, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.6)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
```

Create `mobile/lib/features/dashboard/presentation/widgets/audit_accuracy_gauge.dart`:
```dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AuditAccuracyGauge extends StatelessWidget {
  const AuditAccuracyGauge({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Akurasi Audit Stock Opname', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: 0.98,
              minHeight: 12,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.emeraldSuccess,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Akurasi Sistem: 98.4%', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.emeraldSuccess)),
                Text('Net Discrepancy: 0 Pcs', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

Create `mobile/lib/features/dashboard/presentation/admin_dashboard_screen.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/providers/inventory_providers.dart';
import 'widgets/audit_accuracy_gauge.dart';
import 'widgets/inbound_outbound_chart.dart';
import 'widgets/stock_health_chart.dart';
import 'widgets/zone_distribution_chart.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(inventoryListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dashboard Analitik Gudang', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.darkSlatePrimary,
        foregroundColor: Colors.white,
      ),
      body: itemsAsync.when(
        data: (items) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ZoneDistributionChart(items: items),
                const SizedBox(height: 14),
                const InboundOutboundChart(),
                const SizedBox(height: 14),
                StockHealthChart(items: items),
                const SizedBox(height: 14),
                const AuditAccuracyGauge(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Gagal memuat analitik: $err')),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `cd mobile; flutter test test/widget/admin_dashboard_screen_test.dart`  
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add mobile/lib/features/dashboard/ mobile/test/widget/admin_dashboard_screen_test.dart
git commit -m "feat(dashboard): implement AdminDashboardScreen with 4 fl_chart data visualization components"
```

---

### Task 7: Integrasi Rute Adaptif & Navigasi Berbasis Peran pada `app.dart` & `AdaptiveScaffold`

**Files:**
- Modify: `mobile/lib/core/widgets/adaptive_scaffold.dart`
- Modify: `mobile/lib/app.dart`
- Test: `mobile/test/widget_test.dart`

**Interfaces:**
- Consumes: `currentUserProvider`, `LoginScreen`, `AdminDashboardScreen`, `UserManagementScreen`, `ProfileScreen`, `InventoryScreen`, `InboundScreen`, `OutboundScreen`, `AuditScreen`.
- Produces: Integrated GudangProApp that switches between `LoginScreen` (unauthenticated) and Role-specific screens (Admin vs User) with full test suite passing.

- [ ] **Step 1: Write the failing widget integration test**

Update `mobile/test/widget_test.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';
import 'package:mobile/features/auth/data/user_model.dart';
import 'package:mobile/features/auth/providers/auth_providers.dart';

void main() {
  testWidgets('GudangProApp displays LoginScreen when unauthenticated', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GudangProApp(),
      ),
    );
    expect(find.text('GudangPro Apparel'), findsOneWidget);
    expect(find.text('Masuk ke Sistem WMS'), findsOneWidget);
  });

  testWidgets('GudangProApp displays Admin tabs when authenticated as Admin', (tester) async {
    final admin = UserModel(
      id: 'adm',
      nik: 'ADM-001',
      name: 'Pramudya Admin',
      email: 'admin@gudangpro.com',
      phone: '123',
      role: UserRole.admin,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = admin),
        ],
        child: const GudangProApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Pengguna'), findsWidgets);
  });

  testWidgets('GudangProApp displays User tabs without Admin tabs when authenticated as User', (tester) async {
    final user = UserModel(
      id: 'usr',
      nik: 'STF-042',
      name: 'Budi Santoso',
      email: 'operator@gudangpro.com',
      phone: '123',
      role: UserRole.user,
      createdAt: DateTime.now(),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => CurrentUserNotifier(ref.watch(authRepositoryProvider))..state = user),
        ],
        child: const GudangProApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dashboard'), findsNothing);
    expect(find.text('Pengguna'), findsNothing);
    expect(find.text('Stok'), findsWidgets);
    expect(find.text('Bahan Masuk'), findsWidgets);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd mobile; flutter test test/widget_test.dart`  
Expected: Test failures due to lack of auth-routing in `app.dart`.

- [ ] **Step 3: Update `app.dart` to support auth routing and role-based destinations**

Update `mobile/lib/app.dart`:
```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/adaptive_scaffold.dart';
import 'features/audit/presentation/audit_screen.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/auth/presentation/user_management_screen.dart';
import 'features/auth/providers/auth_providers.dart';
import 'features/dashboard/presentation/admin_dashboard_screen.dart';
import 'features/inbound/presentation/inbound_screen.dart';
import 'features/inventory/presentation/inventory_screen.dart';
import 'features/outbound/presentation/outbound_screen.dart';
import 'features/profile/presentation/profile_screen.dart';

class GudangProApp extends StatelessWidget {
  const GudangProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GudangPro Apparel',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) {
      return const LoginScreen();
    }
    return const MainNavigationScaffold();
  }
}

class MainNavigationScaffold extends ConsumerStatefulWidget {
  const MainNavigationScaffold({super.key});

  @override
  ConsumerState<MainNavigationScaffold> createState() => _MainNavigationScaffoldState();
}

class _MainNavigationScaffoldState extends ConsumerState<MainNavigationScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final isAdmin = user?.isAdmin == true;

    final destinations = isAdmin
        ? const [
            AdaptiveDestination(icon: Icons.dashboard_outlined, label: 'Dashboard'),
            AdaptiveDestination(icon: Icons.inventory_2_outlined, label: 'Stok'),
            AdaptiveDestination(icon: Icons.input_outlined, label: 'Bahan Masuk'),
            AdaptiveDestination(icon: Icons.output_outlined, label: 'Kirim Baju'),
            AdaptiveDestination(icon: Icons.fact_check_outlined, label: 'Opname'),
            AdaptiveDestination(icon: Icons.people_outline, label: 'Pengguna'),
            AdaptiveDestination(icon: Icons.person_outline, label: 'Profil'),
          ]
        : const [
            AdaptiveDestination(icon: Icons.inventory_2_outlined, label: 'Stok'),
            AdaptiveDestination(icon: Icons.input_outlined, label: 'Bahan Masuk'),
            AdaptiveDestination(icon: Icons.output_outlined, label: 'Kirim Baju'),
            AdaptiveDestination(icon: Icons.fact_check_outlined, label: 'Opname'),
            AdaptiveDestination(icon: Icons.person_outline, label: 'Profil'),
          ];

    final screens = isAdmin
        ? const [
            AdminDashboardScreen(),
            InventoryScreen(),
            InboundScreen(),
            OutboundScreen(),
            AuditScreen(),
            UserManagementScreen(),
            ProfileScreen(),
          ]
        : const [
            InventoryScreen(),
            InboundScreen(),
            OutboundScreen(),
            AuditScreen(),
            ProfileScreen(),
          ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return AdaptiveScaffold(
      currentIndex: safeIndex,
      onNavigationChanged: (index) {
        setState(() => _currentIndex = index);
      },
      destinations: destinations,
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
    );
  }
}
```

- [ ] **Step 4: Run full test suite and static analysis**

Run:
```bash
cd mobile
flutter test
flutter analyze
```
Expected: All tests pass (UT, WT, IT) and `flutter analyze` reports `No issues found!`.

- [ ] **Step 5: Commit & push**

```bash
git add mobile/
git commit -m "feat(app): integrate role-based auth routing and adaptive navigation for Admin and User"
git push origin main
```
