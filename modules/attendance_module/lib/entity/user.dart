class User {
  final String id;
  final String name;
  final String employeeCode;
  final String currentRoute;
  final bool isEnoughWorkingDays;
  final String lastUpdated;
  final String role; // Role can be 'Manager' or 'Sale'
  final String? groupId; // group_id can be nullable if not assigned

  User({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.currentRoute,
    required this.isEnoughWorkingDays,
    required this.lastUpdated,
    required this.role,
    this.groupId,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    bool isEnough = false;
    // We might have isEnoughWorkingDays stored in 'data' map previously, 
    // but the new requirement says we calculate it dynamically in useCase.
    // We still keep the parsing from map if it exists just in case.
    if (map['data'] != null && map['data'] is Map) {
      isEnough = map['data']['isEnoughWorkingDays'] == true;
    } else if (map['isEnoughWorkingDays'] != null) {
      isEnough = map['isEnoughWorkingDays'] == true;
    }

    return User(
      id: map['id']?.toString() ?? '',
      name: map['full_name'] ?? map['name'] ?? 'Không rõ',
      employeeCode: map['employee_code']?.toString() ?? '',
      currentRoute: map['current_route'] ?? '',
      isEnoughWorkingDays: isEnough,
      lastUpdated: map['last_updated']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Sale', // Default to Sale
      groupId: map['group_id']?.toString(),
    );
  }

  // Create a copyWith method to allow updating isEnoughWorkingDays
  User copyWith({
    String? id,
    String? name,
    String? employeeCode,
    String? currentRoute,
    bool? isEnoughWorkingDays,
    String? lastUpdated,
    String? role,
    String? groupId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeCode: employeeCode ?? this.employeeCode,
      currentRoute: currentRoute ?? this.currentRoute,
      isEnoughWorkingDays: isEnoughWorkingDays ?? this.isEnoughWorkingDays,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      role: role ?? this.role,
      groupId: groupId ?? this.groupId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
