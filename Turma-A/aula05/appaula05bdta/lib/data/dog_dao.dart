import 'package:appaula05bdta/data/app_database.dart';
import 'package:appaula05bdta/models/dog.dart';
import 'package:sqflite/sqflite.dart';



class DogDao {
  static const table = 'dogs';

  Future<int> insert(Dog dog)async{
    final db = await AppDatabase.instance.database;
    return db.insert(
      table, dog.toMap(),
      conflictAlgorithm:  ConflictAlgorithm.replace
      );

  }

  // Cria função para listar todos os dogs cadastrados
  Future<List<Dog>> getAll()async{
    final db = await AppDatabase.instance.database;
    final maps = await db.query(table,orderBy: 'id DESC');
    return maps.map((m)=>Dog.fromMap(m)).toList();

  }

  //  Cria uma função para atualizar os dogs cadastrados

  Future<int> update(Dog dog)async{
    final db = await AppDatabase.instance.database;
    return db.update(
      table, dog.toMap(),
      where: 'id = ?',
      whereArgs: [dog.id]
      );

  }

  // Cria a função para deletar um arquivo

  Future<int> delete(int id)async{
    final db = await AppDatabase.instance.database;
    return db.delete(table,
    where: 'id = ?',
    whereArgs: [id]);
  }

  // Cria a função para fazer a busca por nome (Opcional)
  Future<List<Dog>> searchByName(String query)async{
    final db = await AppDatabase.instance.database;
    final maps = await db.query(
      table,where: 'nome LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'nome ASC',
    );
    return maps.map((m)=>Dog.fromMap(m)).toList();
  }

}