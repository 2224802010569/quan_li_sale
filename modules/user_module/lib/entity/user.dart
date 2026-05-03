class User {
  final String id;
  final String username;
  final String email;
  final String password;
  final String phone;
  final String role;
  final String fullName;
  final String groupId;
  final String avatarUrl;
  final String avatarPath;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    required this.role,
    required this.fullName,
    required this.groupId,
    this.avatarUrl = '',
    this.avatarPath = '',
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? phone,
    String? role,
    String? fullName,
    String? groupId,
    String? avatarUrl,
    String? avatarPath,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      groupId: groupId ?? this.groupId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
