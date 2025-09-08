import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(TelaHome());
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Aula 03 App Sharedpreferences',
      home: TelaApp(),
      
      theme: ThemeData(useMaterial3: true,colorSchemeSeed: Colors.blue),
      
    );
    
  } 
    
   
}

class TelaApp extends StatefulWidget {
  const TelaApp({super.key});

  @override
  State<TelaApp> createState() => _TelaAppState();
}

class _TelaAppState extends State<TelaApp> {
  final _ctrlNome = TextEditingController(); // Variavel para armazenar o que o usuario digita
  String _nomeSalvo =""; // Variavel para pegar informações do banco de dados

  static const String _kUsernames = 'usernames';
  bool _existeUsername = false;
  // Cria uma lista para armazenar os nomes
  List<String> _nomes =[];
  @override
  void initState(){
    super.initState();
    _carregarNome();
  }

  @override
  // Função monitorar o texteditcontroller
  void dispose(){
    _ctrlNome.dispose();
    super.dispose();
  }

  // Função para salvar o nome 
  Future<void> _salvarNome()async{
    // Faz a leitura do Sharedpreferences
    final prefs =await SharedPreferences.getInstance();
    final nome = _ctrlNome.text.trim(); // trim remove os espaços em branco
    final atuais = prefs.getStringList(_kUsernames)??[];
    if(atuais.contains(nome)){
      _snack('Esse nome ja esta na lista');
      return;
    }
    atuais.add(nome); // atualiza a lista de nomes
    await prefs.setStringList(_kUsernames, atuais); // salva a informaçao
     setState(() => _nomes = List<String>.from(atuais));
     _ctrlNome.clear(); // limpa o campo texto

    
    _snack('Nome salvo com sucesso  !');
    


  }
  // Função para carregar o nome no aplicativo

  Future<void> _carregarNome()async{
    // realiza a leitura do que está armazenado
    final prefs = await SharedPreferences.getInstance();
    setState(()=> _nomes = prefs.getStringList(_kUsernames)??[]);
     

  }

  // Função para remover um nome
  Future<void> _removerNome(String nome)async{
    final prefs = await SharedPreferences.getInstance();
    final atuais =  prefs.getStringList(_kUsernames)?? [];
    atuais.remove(nome);
    await prefs.setStringList(_kUsernames, atuais);
    setState(() =>_nomes =List<String>.from(atuais));
    _snack('Removido $nome');
      
    

  }

Future<void> _limparTudo()async{
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kUsernames);
  setState(() => _nomes=[]);

}
  // Cria a função da snack
  void _snack(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text('App aula 03 - SharedPreferences'),
        centerTitle: true,
      ),
      body: 
       Padding(
         padding: const EdgeInsets.all(8.0),
         child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Digite um nome e salve localmente com SharedPreferences',
            style: TextStyle(fontSize: 16),),
            SizedBox(height: 12,),
            TextField(
              controller: _ctrlNome,
              decoration: InputDecoration(labelText: 'Nome',
              border: OutlineInputBorder(),
               ),
               textInputAction: TextInputAction.done,
               // salva o nome no shared preferences
               onSubmitted: (_) => _salvarNome() ,
              
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(onPressed: _salvarNome,icon: Icon(Icons.save),
                  label: Text('Salvar'),)),
                  SizedBox(height: 8,),
                  Expanded(
                    child: OutlinedButton.icon(onPressed: _carregarNome, icon: Icon(Icons.refresh),
                    label: Text('Carregar'))),
                    SizedBox(height: 8,),
                    Expanded(child: OutlinedButton.icon(
                      onPressed:_nomes.isEmpty? null: _limparTudo,icon: Icon(Icons.delete), 
                      label: Text('Remover')))
              ],
            ),
            SizedBox(height: 16,),
            Expanded(
              child: _nomes.isEmpty?
              const Center(
                child: Text('Sem nomes salvos'),
              ):ListView.separated(
                itemCount: _nomes.length,
                separatorBuilder: (_,__)=>const Divider(height: 1,),
                itemBuilder: (context,i){
                  final nome = _nomes[i];
                  return Dismissible(
                    key: ValueKey(nome),
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.delete),
                    ),
                      secondaryBackground: Container(
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Icon(Icons.delete),
                                           ),
                     onDismissed: (__)=>_removerNome(nome),
                     child: ListTile(
                      leading: CircleAvatar(
                        child: Text(nome.isNotEmpty? nome[0].toUpperCase():'?'),
                      ),
                      title: Text(nome),
                      trailing: IconButton(
                        onPressed: ()=>_removerNome(nome), icon: Icon(Icons.delete)),
                     ),
                     
                     
                     );
                     

                },
                )

              ),
              Align(
                alignment: Alignment.centerRight,
                child: Text('Total: ${_nomes.length}'),
              )
            
                    
                  ],
                ),
              ),
    );
  }
}