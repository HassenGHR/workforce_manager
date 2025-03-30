import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:workforce_manager/models/document_model.dart';
import 'package:workforce_manager/models/employee_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initialize();
    return _database!;
  }

  Future<Database> initialize() async {
    // Get the path to the database file
    String path = join(await getDatabasesPath(), 'workforce_manager.db');

    // Open the database
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    // Create employees table
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        position TEXT NOT NULL,
        department TEXT NOT NULL,
        contactInformation TEXT NOT NULL,
        salary REAL NOT NULL,
        isActive INTEGER NOT NULL DEFAULT 1
      )
    ''');

    // Create documents table
    await db.execute('''
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId INTEGER NOT NULL,
        type INTEGER NOT NULL,
        filePath TEXT NOT NULL,
        generatedAt TEXT NOT NULL,
        FOREIGN KEY (employeeId) REFERENCES employees (id) ON DELETE CASCADE
      )
    ''');
  }

  // Employee CRUD Operations
  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert(
      'employees',
      employee.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  Future<Employee?> getEmployeeById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps =
        await db.query('employees', where: 'id = ?', whereArgs: [id]);
    return maps.isNotEmpty ? Employee.fromMap(maps.first) : null;
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(String id) async {
    final db = await database;
    return await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  // Document CRUD Operations
  Future<int> insertDocument(Document document) async {
    final db = await database;
    return await db.insert(
      'documents',
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Document>> getDocumentsByEmployeeId(int employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db
        .query('documents', where: 'employeeId = ?', whereArgs: [employeeId]);
    return List.generate(maps.length, (i) => Document.fromMap(maps[i]));
  }

  Future<int> getDocumentCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM documents')) ??
        0;
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  // Search and Filter Methods
  Future<List<Employee>> searchEmployees(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'name LIKE ? OR department LIKE ? OR position LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }

  Future<List<Employee>> filterEmployees({
    String? department,
    bool? isActive,
    double? minSalary,
    double? maxSalary,
  }) async {
    final db = await database;

    // Build where clause dynamically
    List<String> whereConditions = [];
    List<dynamic> whereArgs = [];

    if (department != null) {
      whereConditions.add('department = ?');
      whereArgs.add(department);
    }

    if (isActive != null) {
      whereConditions.add('isActive = ?');
      whereArgs.add(isActive ? 1 : 0);
    }

    if (minSalary != null) {
      whereConditions.add('salary >= ?');
      whereArgs.add(minSalary);
    }

    if (maxSalary != null) {
      whereConditions.add('salary <= ?');
      whereArgs.add(maxSalary);
    }

    // Perform query
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: whereConditions.isNotEmpty ? whereConditions.join(' AND ') : null,
      whereArgs: whereConditions.isNotEmpty ? whereArgs : null,
    );

    return List.generate(maps.length, (i) => Employee.fromMap(maps[i]));
  }
}
