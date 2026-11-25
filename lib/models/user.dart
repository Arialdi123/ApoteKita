enum UserRole {
  user,
  apoteker,
  pegawai,
  admin,
}

extension UserRoleExtension on UserRole {
  String get label {
    switch (this) {
      case UserRole.user:
        return 'Pengguna';
      case UserRole.apoteker:
        return 'Apoteker';
      case UserRole.pegawai:
        return 'Pegawai';
      case UserRole.admin:
        return 'Admin';
    }
  }

  String get subtitle {
    switch (this) {
      case UserRole.user:
        return 'Pelanggan ApoteKita';
      case UserRole.apoteker:
        return 'Tenaga Kefarmasian & Konsultasi';
      case UserRole.pegawai:
        return 'Staf Operasional & Kasir Apotek';
      case UserRole.admin:
        return 'Administrator Sistem ApoteKita';
    }
  }

  static UserRole fromString(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'admin':
        return UserRole.admin;
      case 'apoteker':
        return UserRole.apoteker;
      case 'pegawai':
        return UserRole.pegawai;
      default:
        return UserRole.user;
    }
  }
}

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? photoUrl;
  final UserRole role;
  final List<String> allergies;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.photoUrl,
    this.role = UserRole.user,
    this.allergies = const [],
  });

  /// Factory untuk membuat User dari Map (Firestore / lokal)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      photoUrl: map['photoUrl'],
      role: UserRoleExtension.fromString(map['role']?.toString()),
      allergies: map['allergies'] is List
          ? List<String>.from(map['allergies'])
          : const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'role': role.name,
      'allergies': allergies,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    UserRole? role,
    List<String>? allergies,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      allergies: allergies ?? this.allergies,
    );
  }
}
