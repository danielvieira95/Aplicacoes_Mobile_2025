// Cria uma classe chamada Dog para armazenar os dogs digitados pelo usuario
class Dog{
  final int? id; // nulo ao criar Autoincrement
  final String nome;
  final int idade;

  // Cria o construtor

  Dog({this.id,required this.nome,required this.idade});
 // funçao que copia os parametros da classe dog
  Dog copyWith({int? id, String ? nome,int? idade }){
    return Dog(
      id: id?? this.id,
      nome: nome?? this.nome,
      idade: idade?? this.idade);
  }

  Map<String,dynamic> toMap()=>{
    'id':id,
    'nome':nome,
    'idade':idade
  };

  factory Dog.fromMap(Map<String,dynamic>map)=>Dog(
    id: map['id'] as int ?,
    nome:map['nome'] as String,
    idade:map['idade'] as int
    );


}

