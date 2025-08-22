class HabitLog {
  final String id;
  final String habitId;
  final String userId;
  final DateTime completedAt;
  final String? notes;
  final int? rating; // 1-5 stars

  HabitLog({
    required this.id,
    required this.habitId,
    required this.userId,
    required this.completedAt,
    this.notes,
    this.rating,
  });

  factory HabitLog.fromJson(Map<String, dynamic> json) {
    return HabitLog(
      id: json['id'],
      habitId: json['habit_id'],
      userId: json['user_id'],
      completedAt: DateTime.parse(json['completed_at']),
      notes: json['notes'],
      rating: json['rating'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'user_id': userId,
      'completed_at': completedAt.toIso8601String(),
      'notes': notes,
      'rating': rating,
    };
  }
}
