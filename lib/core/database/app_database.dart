import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String databaseName = 'study_flow.db';
  static const int databaseVersion = 1;

  final String? databasePath;
  final DatabaseFactory _databaseFactory;
  final bool singleInstance;

  Database? _database;

  AppDatabase({
    this.databasePath,
    DatabaseFactory? databaseFactory,
    this.singleInstance = true,
  }) : _databaseFactory = databaseFactory ?? databaseFactorySqflitePlugin;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  Future<void> close() async {
    final database = _database;

    if (database == null) return;

    await database.close();
    _database = null;
  }

  Future<Database> _initDatabase() async {
    final path =
        databasePath ??
        p.join(await _databaseFactory.getDatabasesPath(), databaseName);

    return _databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: databaseVersion,
        onConfigure: (database) async {
          await database.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: _onCreate,
        singleInstance: singleInstance,
      ),
    );
  }

  Future<void> _onCreate(Database database, int version) async {
    await database.execute('''
      CREATE TABLE subjects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await database.execute('''
      CREATE TABLE topics (
        id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT NOT NULL,
        priority TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        completed_at TEXT,
        next_review_at TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
      )
    ''');

    await database.execute('''
      CREATE TABLE study_sessions (
        id TEXT PRIMARY KEY,
        subject_id TEXT NOT NULL,
        topic_id TEXT,
        duration_in_minutes INTEGER NOT NULL,
        studied_at TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT,
        FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE SET NULL
      )
    ''');

    await database.execute('''
      CREATE TABLE reviews (
        id TEXT PRIMARY KEY,
        topic_id TEXT NOT NULL,
        scheduled_for TEXT NOT NULL,
        reviewed_at TEXT,
        quality TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (topic_id) REFERENCES topics(id) ON DELETE CASCADE
      )
    ''');
  }
}
