import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(TelaHome());
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('App aula 03 - BD - Shared preferences'),
      ),
      body: MaterialApp(
        home: TelaApp(),
      ),
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

  static const String _kUsername = 'username';
  bool _existeUsername = false;
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
    if(nome.isEmpty){
      _mostrarSnack('Digite um nome antes de salvar');
      return;
    }
    await prefs.setString(_kUsername, nome); // salva a informaçao
    _mostrarSnack('Nome salvo com sucesso ${nome} !');
    await _carregarNome(); // atualiza exibição


  }
  // Função para carregar o nome no aplicativo

  Future<void> _carregarNome()async{
    // realiza a leitura do que está armazenado
    final prefs = await SharedPreferences.getInstance();
    final nome = prefs.getString(_kUsername)??''; 
    final existe = prefs.containsKey(_kUsername);
    setState(() {
      _nomeSalvo =nome;
      _existeUsername=existe;
    });

  }

  // Função para remover um nome
  Future<void> _removerNome()async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUsername);
    _mostrarSnack('Nome removido');

  }

  // Cria a função da snack
  void _mostrarSnack(String msg){
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
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
                      onPressed:_existeUsername? _removerNome:null,icon: Icon(Icons.delete), 
                      label: Text('Remover')))
              ],
            ),
            SizedBox(height: 24,),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('Resultado',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                  SizedBox(height: 8,),
                  Text('Nome salvo: ${_nomeSalvo.isEmpty? '(vazio)':_nomeSalvo}'),
                  SizedBox(height: 4,),
                  Text(_existeUsername ?'A chave "$_kUsername existe no armazenamento':'A chave "$_kUsername" nao existe no armazenamento'),
         
                    
                  ],
                ),
              ),
            )
          ],
               ),
       ),
    );
  }
}