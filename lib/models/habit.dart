class Habit {
  final String id;
  final String userId;
  final String title;
  final String description;
  final String category;
  final int frequency; // vezes por semana
  final List<String> daysOfWeek; // ['monday', 'tuesday', etc.]
  final TimeOfDay reminderTime;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? lastCompleted;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.category,
    required this.frequency,
    required this.daysOfWeek,
    required this.reminderTime,
    this.isActive = true,
    required this.createdAt,
    this.lastCompleted,
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      frequency: json['frequency'],
      daysOfWeek: List<String>.from(json['days_of_week']),
      reminderTime: _parseTimeOfDay(json['reminder_time']),
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      lastCompleted: json['last_completed'] != null 
          ? DateTime.parse(json['last_completed']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'category': category,
      'frequency': frequency,
      'days_of_week': daysOfWeek,
      'reminder_time': '${reminderTime.hour}:${reminderTime.minute}',
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'last_completed': lastCompleted?.toIso8601String(),
    };
  }

  static TimeOfDay _parseTimeOfDay(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }
}

class TimeOfDay {
  final int hour;
  final int minute;

  TimeOfDay({required this.hour, required this.minute});
}
