import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'dms_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE tire_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_tire TEXT NOT NULL,
            vhcid TEXT NOT NULL,
            serial_no TEXT NOT NULL,
            pattern TEXT NOT NULL,
            in_depth TEXT NOT NULL,
            out_dept TEXT NOT NULL,
            mid1_depth TEXT NOT NULL,
            mid2_depth TEXT NOT NULL,
            tekanan_angin TEXT NOT NULL,
            fitpost TEXT NOT NULL,
            note TEXT,
            casing_yes INTEGER,
            casing_no INTEGER,
            alasan_unit TEXT NOT NULL,
            status_unit TEXT NOT NULL,
            kerusakan_ban TEXT NOT NULL,
            masalah_unit TEXT NOT NULL,
            photo_ban TEXT NOT NULL,
            photo_tapak TEXT NOT NULL,
            photo_damage TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> dropTable(String tableName) async {
    final db = await DatabaseHelper.instance.database;
    await db.execute('DROP TABLE IF EXISTS $tableName');
  }

  Future<int> insertItemLogs(Map<String, dynamic> item) async {
    final db = await DatabaseHelper.instance.database;
    return await db.insert('tire_logs', item);
  }

  // final items = await fetchItems(); USE LIKE THIS
  // print(items);
  Future<List<Map<String, dynamic>>> fetchItemsLogs() async {
    final db = await DatabaseHelper.instance.database;
    return await db.query('tire_logs');
  }

  //SAMPLE await updateItem(1, {'name': 'Bananas', 'quantity': 10});
  Future<void> updateItemLOgs(int id, Map<String, dynamic> newValues) async {
    final db = await DatabaseHelper.instance.database;
    await db.update('tire_logs', newValues, where: 'id = ?', whereArgs: [id]);
  }

  //SAMPLE await deleteItem(1);
  Future<int> deleteItemLogs(int id) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('tire_logs', where: 'id = ? ', whereArgs: [id]);
  }

  Future<int> deleteItemLogsByFitPost(String fitpost) async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('tire_logs', where: 'fitpost = ? ', whereArgs: [fitpost]);
  }

  Future<int> deleteItemLogsAll() async {
    final db = await DatabaseHelper.instance.database;
    return await db.delete('tire_logs');
  }

  Future<int> countTableTire() async {
    final db = await DatabaseHelper.instance.database;

    // Use rawQuery to execute a custom SQL query
    var result = await db.rawQuery('SELECT COUNT(*) FROM tire_logs');

    // Extract the count from the result (which is a list of maps)
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<Database> openDatabaseConnection() async {
    final path = await getDatabasePath();  // Get the database path
    return openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('CREATE TABLE tire_logs(id INTEGER PRIMARY KEY, name TEXT)');
    });
  }

  Future<String> getDatabasePath() async {
    final directory = await getApplicationDocumentsDirectory();  // Get the documents directory
    final path = join(directory.path, 'dms_database.db');  // Combine with the database file name
    return path;
  }

  Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath(); // Get the default database path
    final path = join(dbPath, 'dms_database.db'); // Path to your database file

    final file = File(path);

    // Check if the file exists before trying to delete it
    if (await file.exists()) {
      await file.delete();
      print('Database deleted successfully');
    } else {
      print('Database does not exist');
    }
  }
}
