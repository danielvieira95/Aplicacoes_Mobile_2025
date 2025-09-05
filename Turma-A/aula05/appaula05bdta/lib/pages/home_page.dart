import 'package:appaula05bdta/data/dog_dao.dart';
import 'package:appaula05bdta/models/dog.dart';
import 'package:flutter/material.dart';





class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _dao =DogDao(); // variavel que irá permitir a manipulação dos dados
  final _nomeCtrl = TextEditingController();
  final _idadeCtrl =  TextEditingController();
  final _searchCtrl = TextEditingController();

  Dog ? _editing; // null = inserindo, not null editando

  Future<List<Dog>> ? _futureDogs; // vai carregar os dogs salvos no banco de dados

  @override
  void initState(){
    super.initState();
    _reload();
  }



  void _reload(){
    setState(() {
      final q = _searchCtrl.text.trim() ; // trim remove os espaços em branco
      _futureDogs = q.isEmpty? _dao.getAll(): _dao.searchByName(q);
    });
  }

  void _clearForm(){
    _nomeCtrl.clear();
    _idadeCtrl.clear();
    _editing = null;
  }


  void _edit(Dog dog){

    setState(() {
      _editing = dog;
      _nomeCtrl.text = dog.nome;
      _idadeCtrl.text = dog.idade.toString();
    });
  }

  Future<void> _save()async{
    final nome = _nomeCtrl.text.trim();
    final idadeStr = _idadeCtrl.text.trim();

    if(nome.isEmpty || idadeStr.isEmpty){
      _snack('Preencha o nome e idade');
      return;
    }

    final idade = int.tryParse(idadeStr);
    if (idade==null){
      _snack('Idade precisa ser um numero inteiro');
      return;
    }

    if(_editing == null){
      await _dao.insert(Dog(nome: nome, idade: idade));
      _snack('Pet cadastrado');
    } else{
      await _dao.update(_editing!.copyWith(nome: nome,idade: idade));
      _snack('Pet atualizado');
    }
    _clearForm();
    _reload();

  }

  Future<void> _delete(int id)async{
    await _dao.delete(id);
    _snack('Pet removido');
    _reload();

  }

  void _cancelEdit(){
    _clearForm();
    _snack('Edição cancelada');
  }

  void _snack(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  @override

  void dispose(){
    _nomeCtrl.dispose();
    _idadeCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isEditing = _editing !=null;
    return Scaffold(
      appBar: AppBar(
        title: Text('App aula 05 - Pets BD - SQFLITE'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Busca por nome',
                hintText: 'Ex Rocky',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  tooltip: 'Limpar busca',
                  onPressed: (){
                    _searchCtrl.clear();
                    _reload();
                  }, icon: Icon(Icons.clear)),
                  
              ),
              onChanged: (_)=>_reload(),
            ),

            ),


            TextField(
              controller: _nomeCtrl,
              decoration: InputDecoration(
                labelText: 'Nome do pet',
                border: OutlineInputBorder()
              ),
              textInputAction: TextInputAction.next,
            ),
            SizedBox(height: 12,),
            TextField(
              controller: _idadeCtrl,
              decoration: InputDecoration(
                labelText: 'Idade (anos)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                Expanded(
                  
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(isEditing ? Icons.save: Icons.add),
                    
                     label: Text(isEditing? 'Salvar alteraçoes': 'Adicionar')
                     )),
                     if(isEditing)...[
                      SizedBox(width: 8,),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _cancelEdit, 
                          icon: Icon(Icons.close),
                          
                          label: Text('Cancelar')))

                     ]

              ],
            ),
            Divider(
              height: 8,),
              Expanded(
                child: FutureBuilder<List<Dog>>(
                  future: _futureDogs,
                  builder:(context,snapshot){
                    if(snapshot.connectionState==ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    if(snapshot.hasError){
                      return Center(
                        child: Text('Erro ${snapshot.error}')
                      );
                    }
                    final dogs = snapshot.data??[];
                    if(dogs.isEmpty){
                      return Center(
                        child: Text('Nenhum pet encontrado'),);
                    }
                    return ListView.builder(
                      itemCount: dogs.length,
                      itemBuilder: (context,index){

                      final dog = dogs[index];
                      return ListTile(
                        title: Text(dog.nome),
                        subtitle: Text('Idade ${dog.idade}'),
                        leading: CircleAvatar(
                          child: Text((dog.id??0).toString()                     

                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min, // limita a area de exibição
                          children: [
                            IconButton(
                              tooltip: 'Editar',
                              icon: Icon(Icons.edit),
                              onPressed: ()=> _edit(dog), ),

                              IconButton(
                                tooltip: 'Excluir',
                                onPressed: ()=> _delete(dog.id!), 
                                icon: Icon(Icons.delete))

                          ],
                        ),
                      );


                      } );
                  }
                  
                   ,)
                
                )


        ],
      ),
    );
  }
}