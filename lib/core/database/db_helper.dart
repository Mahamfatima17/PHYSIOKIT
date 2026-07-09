import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'initial_data.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('physiokit.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';

    // Create tests table
    await db.execute('''
      CREATE TABLE tests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name $textType,
        category $textType,
        region $textType,
        purpose $textType,
        procedure $textType,
        positive_sign $textType,
        patient_position $textTypeNullable,
        therapist_position $textTypeNullable,
        interpretation $textTypeNullable,
        clinical_notes $textTypeNullable,
        sensitivity $textTypeNullable,
        specificity $textTypeNullable,
        important_notes $textTypeNullable,
        illustration $textTypeNullable,
        reference $textTypeNullable
      )
    ''');

    // Create history table
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        test_id $integerType,
        viewed_at $textType
      )
    ''');

    // Seed the database with the pre-parsed tests
    for (var test in initialTestsData) {
      // Basic extraction of positions from procedure if available (optional enhancement)
      String patientPos = '';
      String therapistPos = '';
      String proc = test['procedure'] ?? '';
      
      if (proc.toLowerCase().startsWith('patient sitting') || proc.toLowerCase().startsWith('patient in sitting')) {
        patientPos = 'Sitting';
      } else if (proc.toLowerCase().startsWith('patient supine')) {
        patientPos = 'Supine';
      } else if (proc.toLowerCase().startsWith('patient prone')) {
        patientPos = 'Prone';
      } else if (proc.toLowerCase().startsWith('patient upright') || proc.toLowerCase().startsWith('patient standing')) {
        patientPos = 'Standing / Upright';
      } else if (proc.toLowerCase().startsWith('patient side lying') || proc.toLowerCase().startsWith('patient in side lying')) {
        patientPos = 'Side-lying';
      }

      if (proc.toLowerCase().contains('stand behind patient')) {
        therapistPos = 'Standing behind patient';
      } else if (proc.toLowerCase().contains('stabilize') || proc.toLowerCase().contains('resist')) {
        therapistPos = 'Standing beside patient';
      }

      await db.insert('tests', {
        'name': test['name'] ?? '',
        'category': test['category'] ?? '',
        'region': test['region'] ?? '',
        'purpose': test['purpose'] ?? '',
        'procedure': test['procedure'] ?? '',
        'positive_sign': test['positive_sign'] ?? '',
        'patient_position': patientPos.isNotEmpty ? patientPos : 'Refer to procedure',
        'therapist_position': therapistPos.isNotEmpty ? therapistPos : 'Refer to procedure',
        'interpretation': test['positive_sign'] ?? '',
        'clinical_notes': 'Clinical significance: ' + (test['purpose'] ?? ''),
        'sensitivity': test['sensitivity'] ?? 'N/A',
        'specificity': test['specificity'] ?? 'N/A',
        'important_notes': test['important_notes'] ?? '',
        'illustration': test['illustration'] ?? '',
        'reference': test['reference'] ?? 'The Physiotherapist\'s Pocket Book',
      });
    }
  }

  // Fetch all tests
  Future<List<Map<String, dynamic>>> fetchAllTests() async {
    final db = await instance.database;
    return await db.query('tests', orderBy: 'name ASC');
  }

  // Fetch tests by region
  Future<List<Map<String, dynamic>>> fetchTestsByRegion(String region) async {
    final db = await instance.database;
    return await db.query(
      'tests',
      where: 'region = ?',
      whereArgs: [region],
      orderBy: 'name ASC',
    );
  }

  // Fetch tests by category
  Future<List<Map<String, dynamic>>> fetchTestsByCategory(String category) async {
    final db = await instance.database;
    return await db.query(
      'tests',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
  }

  // Search tests
  Future<List<Map<String, dynamic>>> searchTests(String query) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT * FROM tests 
      WHERE name LIKE ? 
         OR purpose LIKE ? 
         OR region LIKE ? 
         OR category LIKE ?
      ORDER BY name ASC
    ''', List.filled(4, '%$query%'));
  }

  // History operations
  Future<void> addHistory(int testId) async {
    final db = await instance.database;
    final timestamp = DateTime.now().toIso8601String();
    
    // Check and remove duplicates to keep only the latest entry
    await db.delete('history', where: 'test_id = ?', whereArgs: [testId]);
    
    await db.insert('history', {
      'test_id': testId,
      'viewed_at': timestamp,
    });
  }

  Future<List<Map<String, dynamic>>> fetchHistory() async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT h.viewed_at, t.* 
      FROM history h
      JOIN tests t ON h.test_id = t.id
      ORDER BY h.viewed_at DESC
    ''');
  }

  Future<void> clearHistory() async {
    final db = await instance.database;
    await db.delete('history');
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) {
      await db.close();
    }
  }
}
