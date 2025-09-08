import 'package:appaula05bdtb/data/app_database.dart';
import 'package:appaula05bdtb/models/dog.dart';
import 'package:sqflite/sqflite.dart';




class DogDao{
  static const table ='dogs'; // cria a tabela do banco de dados

  // Criando os metodos para interagir com o banco de dados
  Future<int> insert(Dog dog)async{
    final db = await AppDatabase.instance.database;
    return db.insert(table, dog.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace);

  }

  // Método para listar todos os dogs cadastrados
  Future<List<Dog>> getAll()async{
    final db = await AppDatabase.instance.database;
    final maps = await db.query(table,orderBy: 'id DESC');
    return maps.map((m)=>Dog.fromMap(m)).toList();

  }

  // Metodo para atualizar um dog cadastrado

  Future<int> update(Dog dog)async{
    final db = await AppDatabase.instance.database;
    return db.update(table, dog.toMap(),
    where: 'id=?',
    whereArgs: [dog.id]);

  }

  // Metodo para deletar um dog cadastrado

  Future<int> delete(int id)async{
    final db = await AppDatabase.instance.database;
    return db.delete(table,
    where: 'id=?',
    whereArgs: [id]);
  }

  // Exemplo de busca por nome opcional
  Future<List<Dog>> searchByName(String query)async{
    final db = await AppDatabase.instance.database;
    final maps = await db.query(table,where: 'nome LIKE?',
    whereArgs: ['%$query%'],
    orderBy: 'nome ASC',
    );
    return maps.map((m)=>Dog.fromMap(m)).toList();
  }

}