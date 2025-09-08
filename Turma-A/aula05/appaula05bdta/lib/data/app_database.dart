// Arquivo para criar as funções para inicializar o banco de dados

import 'package:sqflite/sqflite.dart'; // biblioteca que permite criar o banco de dados
import 'package:path/path.dart'; // biblioteca para acessar o caminho onde o banco de dados é criado


class AppDatabase {
  // Singleton
  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();

  static const _dbName = 'pets.db';
  static const _dbVersion=1;

  Database? _db; 

  Future<Database> get database async{
    if(_db!=null) return _db!;
    _db = await _open();
    return _db!;
  }

  // Função open

  Future<Database> _open()async{
    final dbPath = await getDatabasesPath();
    final path = join(dbPath,_dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate:(db,version)async{
        await db.execute(
          '''
          CREATE TABLE dogs(
          id INTEGER PRIMARY KEY  AUTOINCREMENT, nome TEXT NOT NULL, idade INTEGER NOT NULL)
          '''
        );

      },
      // Se precisar de migrações futuramente
      // onUpgrade (db, oldV,newV)async
      );

  }
}