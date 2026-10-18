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
      final oldUser = _users[index];
      final oldEmail = oldUser.email.trim().toLowerCase();
      final newEmail = updatedUser.email.trim().toLowerCase();

      if (oldEmail != newEmail && _passwords.containsKey(oldEmail)) {
        final pwd = _passwords.remove(oldEmail)!;
        _passwords[newEmail] = pwd;
      }

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
      return;
    }
    throw Exception('User tidak ditemukan');
  }

  Future<void> updatePassword(String email, String newPassword) async {
    _passwords[email.trim().toLowerCase()] = newPassword;
  }

  void dispose() {
    _usersStreamController.close();
  }
}
