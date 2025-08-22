import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/habit.dart';
import '../models/habit_log.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'librarium.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de usuários
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_login TEXT
      )
    ''');

    // Tabela de hábitos
    await db.execute('''
      CREATE TABLE habits (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        frequency INTEGER NOT NULL,
        days_of_week TEXT NOT NULL,
        reminder_time TEXT NOT NULL,
        is_active INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        last_completed TEXT,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Tabela de logs de hábitos
    await db.execute('''
      CREATE TABLE habit_logs (
        id TEXT PRIMARY KEY,
        habit_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        completed_at TEXT NOT NULL,
        notes TEXT,
        rating INTEGER,
        FOREIGN KEY (habit_id) REFERENCES habits (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  // Métodos para usuários
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toJson());
  }

  Future<User?> getUser(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isNotEmpty) {
      return User.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update(
      'users',
      user.toJson(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> deleteUser(String id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para hábitos
  Future<int> insertHabit(Habit habit) async {
    final db = await database;
    return await db.insert('habits', habit.toJson());
  }

  Future<List<Habit>> getUserHabits(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );

    return List.generate(maps.length, (i) {
      return Habit.fromJson(maps[i]);
    });
  }

  Future<Habit?> getHabit(String id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Habit.fromJson(maps.first);
    }
    return null;
  }

  Future<int> updateHabit(Habit habit) async {
    final db = await database;
    return await db.update(
      'habits',
      habit.toJson(),
      where: 'id = ?',
      whereArgs: [habit.id],
    );
  }

  Future<int> deleteHabit(String id) async {
    final db = await database;
    return await db.delete(
      'habits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos para logs de hábitos
  Future<int> insertHabitLog(HabitLog log) async {
    final db = await database;
    return await db.insert('habit_logs', log.toJson());
  }

  Future<List<HabitLog>> getHabitLogs(String habitId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_logs',
      where: 'habit_id = ?',
      whereArgs: [habitId],
      orderBy: 'completed_at DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitLog.fromJson(maps[i]);
    });
  }

  Future<List<HabitLog>> getUserHabitLogs(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'habit_logs',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
    );

    return List.generate(maps.length, (i) {
      return HabitLog.fromJson(maps[i]);
    });
  }

  Future<int> deleteHabitLog(String id) async {
    final db = await database;
    return await db.delete(
      'habit_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Métodos de limpeza
  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('habit_logs');
    await db.delete('habits');
    await db.delete('users');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
