import 'package:sqflite/sqflite.dart';
import '../models/dog.dart';
import 'app_database.dart';

class DogDao {
  static const table = 'dogs';

  Future<int> insert(Dog dog) async {
    final db = await AppDatabase.instance.database;
    return db.insert(
      table,
      dog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Dog>> getAll() async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(table, orderBy: 'id DESC');
    return maps.map((m) => Dog.fromMap(m)).toList();
  }

  Future<int> update(Dog dog) async {
    final db = await AppDatabase.instance.database;
    return db.update(
      table,
      dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await AppDatabase.instance.database;
    return db.delete(
      table,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Exemplo de busca por nome (opcional)
  Future<List<Dog>> searchByName(String query) async {
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      table,
      where: 'nome LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nome ASC',
    );
    return maps.map((m) => Dog.fromMap(m)).toList();
  }
}
