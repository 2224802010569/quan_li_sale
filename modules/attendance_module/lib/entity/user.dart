class User {
  final String id;
  final String name;
  final String employeeCode;
  final String avatarUrl;
  final String currentRoute;
  final bool isEnoughWorkingDays;
  final String lastUpdated;

  User({
    required this.id,
    required this.name,
    required this.employeeCode,
    required this.avatarUrl,
    required this.currentRoute,
    required this.isEnoughWorkingDays,
    required this.lastUpdated,
  });
}
