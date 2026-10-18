enum UserRole {
  admin,
  user;

  String get displayName =>
      this == UserRole.admin ? 'Administrator' : 'Operator Gudang';
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
    String? id,
    String? nik,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    bool? isActive,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      nik: nik ?? this.nik,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['created_at'] ?? json['createdAt'];
    final DateTime parsedCreatedAt;
    if (rawCreatedAt is DateTime) {
      parsedCreatedAt = rawCreatedAt;
    } else if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
      parsedCreatedAt = DateTime.parse(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    final roleStr = json['role'] as String? ?? 'user';
    final role = roleStr.toLowerCase() == 'admin' ? UserRole.admin : UserRole.user;

    return UserModel(
      id: (json['id'] as String?) ?? '',
      nik: (json['nik'] as String?) ?? '',
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      role: role,
      isActive: (json['is_active'] ?? json['isActive']) as bool? ?? true,
      avatarUrl: (json['avatar_url'] ?? json['avatarUrl']) as String? ?? '',
      createdAt: parsedCreatedAt,
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
