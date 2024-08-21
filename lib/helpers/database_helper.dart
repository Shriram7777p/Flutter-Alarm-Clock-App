import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/alarm.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('alarms.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE alarms(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT NOT NULL,
        repeatDays TEXT NOT NULL,
        alarmName TEXT NOT NULL,
        isExpired INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertAlarm(Alarm alarm) async {
    final db = await instance.database;
    return await db.insert('alarms', alarm.toMap());
  }

  Future<List<Alarm>> getAlarms() async {
    final db = await instance.database;
    final result = await db.query('alarms');
    return result.map((json) => Alarm.fromMap(json)).toList();
  }

  Future<int> updateAlarm(Alarm alarm) async {
    final db = await instance.database;
    return await db.update(
      'alarms',
      alarm.toMap(),
      where: 'id = ?',
      whereArgs: [alarm.id],
    );
  }

  Future<int> deleteAlarm(int id) async {
    final db = await instance.database;
    return await db.delete(
      'alarms',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Alarm>> searchAlarms(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'alarms',
      where: 'alarmName LIKE ?',
      whereArgs: ['%$query%'],
    );
    return result.map((json) => Alarm.fromMap(json)).toList();
  }
}
