enum UserRole {
  user,
  admin;

  factory UserRole.fromString(String? value) {
    if (value == null) return UserRole.user;
    switch (value.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  String toJson() => name;
}

class UserModel {
  final String idUser;
  final String? namaLengkap;
  final String? email;
  final String? fotoProfile;
  final UserRole role;
  final bool statusAkun;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.idUser,
    this.namaLengkap,
    this.email,
    this.fotoProfile,
    required this.role,
    required this.statusAkun,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      idUser: json['id_user'] as String,
      namaLengkap: json['nama_lengkap'] as String?,
      email: json['email'] as String?,
      fotoProfile: json['foto_profile'] as String?,
      role: UserRole.fromString(json['role'] as String?),
      statusAkun: json['status_akun'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_user': idUser,
      'nama_lengkap': namaLengkap,
      'email': email,
      'foto_profile': fotoProfile,
      'role': role.toJson(),
      'status_akun': statusAkun,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? idUser,
    String? namaLengkap,
    String? email,
    String? fotoProfile,
    UserRole? role,
    bool? statusAkun,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      idUser: idUser ?? this.idUser,
      namaLengkap: namaLengkap ?? this.namaLengkap,
      email: email ?? this.email,
      fotoProfile: fotoProfile ?? this.fotoProfile,
      role: role ?? this.role,
      statusAkun: statusAkun ?? this.statusAkun,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
