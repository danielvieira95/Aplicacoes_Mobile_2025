import 'package:sqflite/sqflite.dart'; // importa biblioteca para utilizar banco de dados
import 'package:path/path.dart'; // biblioteca que permite acessar o diretorio onde cria o banco de dados

// classe que inicializa o banco de dados
class AppDatabase {

  // Singleon

  AppDatabase._internal();
  static final AppDatabase instance = AppDatabase._internal();
  static const _dbName='pets.db'; // nome do banco de dados
  static const _dbVersion =1;
  Database? _db;

 // Métodos para realizar o crud com o banco de dados

 Future<Database> get database async{
  if(_db != null) return _db!;
  _db = await _open();
  return _db!;
 }

 // Método para abrir o banco de dados

 Future<Database> _open()async{
  final dbPath = await getDatabasesPath(); // pega o caminho de onde o banco de dados foi criado
  final path = join(dbPath,_dbName);
  return await openDatabase(
  path,
  version: _dbVersion,
  onCreate: (db, version) async{
    await db.execute('''
  CREATE TABLE  dogs(id INTEGER PRIMARY KEY AUTOINCREMENT,
  nome TEXT NOT NULL, idade INTEGER NOT NULL  )
    
'''
);
    
  },
  );
 }

}