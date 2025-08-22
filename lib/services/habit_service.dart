import '../models/habit.dart';
import '../models/habit_log.dart';

abstract class HabitService {
  Future<List<Habit>> getUserHabits(String userId);
  Future<Habit> createHabit(Habit habit);
  Future<Habit> updateHabit(Habit habit);
  Future<void> deleteHabit(String habitId);
  Future<List<HabitLog>> getHabitLogs(String habitId);
  Future<HabitLog> logHabitCompletion(HabitLog log);
  Future<void> deleteHabitLog(String logId);
}

class MockHabitService implements HabitService {
  final List<Habit> _habits = [];
  final List<HabitLog> _logs = [];

  @override
  Future<List<Habit>> getUserHabits(String userId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _habits.where((habit) => habit.userId == userId).toList();
  }

  @override
  Future<Habit> createHabit(Habit habit) async {
    await Future.delayed(Duration(milliseconds: 500));
    _habits.add(habit);
    return habit;
  }

  @override
  Future<Habit> updateHabit(Habit habit) async {
    await Future.delayed(Duration(milliseconds: 500));
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index != -1) {
      _habits[index] = habit;
    }
    return habit;
  }

  @override
  Future<void> deleteHabit(String habitId) async {
    await Future.delayed(Duration(milliseconds: 500));
    _habits.removeWhere((habit) => habit.id == habitId);
    _logs.removeWhere((log) => log.habitId == habitId);
  }

  @override
  Future<List<HabitLog>> getHabitLogs(String habitId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return _logs.where((log) => log.habitId == habitId).toList();
  }

  @override
  Future<HabitLog> logHabitCompletion(HabitLog log) async {
    await Future.delayed(Duration(milliseconds: 500));
    _logs.add(log);
    return log;
  }

  Future<HabitLog> createHabitLog(HabitLog log) async {
    await Future.delayed(Duration(milliseconds: 500));
    _logs.add(log);
    return log;
  }

  @override
  Future<void> deleteHabitLog(String logId) async {
    await Future.delayed(Duration(milliseconds: 500));
    _logs.removeWhere((log) => log.id == logId);
  }
}
