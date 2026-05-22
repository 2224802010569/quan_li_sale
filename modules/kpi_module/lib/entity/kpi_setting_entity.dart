class KpiSettingEntity {
  final int id;
  final String userId;
  final int month;
  final int year;
  final double targetRevenue;
  final DateTime createdAt;

  KpiSettingEntity({
    this.id = 0,
    required this.userId,
    required this.month,
    required this.year,
    required this.targetRevenue,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory KpiSettingEntity.fromMap(Map<String, dynamic> map) {
    return KpiSettingEntity(
      id: map['id'] ?? 0,
      userId: map['sale_id'] ?? '',
      month: map['month'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      targetRevenue: (map['target_amount'] ?? 0).toDouble(),
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sale_id': userId,
      'month': month,
      'year': year,
      'target_amount': targetRevenue,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
