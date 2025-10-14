// Tela de produtos nova

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Prodscreen2 extends StatefulWidget {
  const Prodscreen2({super.key});

  @override
  State<Prodscreen2> createState() => _Prodscreen2State();
}

class _Prodscreen2State extends State<Prodscreen2> {

  final String baseUrl = "http://10.109.83.10:8000/api/produtos";
  

  @override
  void initState(){
    super.initState();
    leituradados();
  }

  // Lista de produtos
  List<Map<String,dynamic>> dado=[];

  Future<void> leituradados()async{
    final resp = await http.get(Uri.parse(baseUrl));

    if(resp.statusCode==200){
      final lista = (jsonDecode(resp.body) as List<dynamic>).cast<Map<String,dynamic>>();
      setState(() {
        dado = lista;
      });
    }else{
      throw Exception('Falha ao consumir API (${resp.statusCode})');
    }

  }

  // Função para atualizar os produtos

  Future<void> _atualizarProduto({
    required int id,
    required String nome,
    required double preco,
    required int quantidade
  })async{

    final url = Uri.parse("$baseUrl$id/");
    final body = jsonEncode({
      "nome":nome,
      "preco":preco,
      "quantidade":quantidade
    });

    final resp = await http.put(url,
    headers: {"Content-Type":"application/json"},
    body:  body
    );

    if(resp.statusCode==200){
      await leituradados();
      if(mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto atualizado com sucesso'))
        );
      }
    }else{
      final msg = resp.body.isNotEmpty? resp.body: 'Erro desconhecido';
      throw Exception('Falha ao atualizar (${resp.statusCode}):$msg'  );

    }
  }

  // Função para deletar os produtos

  Future<void> _deletarProduto(int id)async{
    final url = Uri.parse('$baseUrl$id/');
    final resp = await http.delete(url);

    if(resp.statusCode==204|| resp.statusCode==200){
      // atualiza a lista local sem precisar refazer Get
      setState(() {
        dado.removeWhere((e)=>(e["id"] as num).toInt()==id);
      });
      if (mounted){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produto deletado')));
      }
    }else{
      final msg = resp.body.isNotEmpty? resp.body: 'Erro desconhecido';
      throw Exception('Falha ao deletar (${resp.statusCode}): $msg');
    }

  }

  // Função dialog
  Future<void> _abrirDialogEdicao(Map<String,dynamic>item)async{
    final TextEditingController nomeCtrl = TextEditingController(text: item['nome']?.toString()??"");
    final TextEditingController precoCtrl = TextEditingController(text: item['preco']?.toString()??"");
    final TextEditingController qtdCtrl = TextEditingController(text: item['quantidade']?.toString()??"");

    await showDialog(
      context: context,
       builder: (_)=>AlertDialog(
        title: Text('Editar produto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nomeCtrl,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
          TextField(
              controller: precoCtrl,
              decoration: InputDecoration(labelText: 'Preco (R\$)'),
            ),
            TextField(
              controller: qtdCtrl,
              decoration: InputDecoration(labelText: 'Quantidade'),
            ),

          ],
        ),
        actions: [
          TextButton(
            onPressed: ()=> Navigator.pop(context),
             child: Text('Cancelar')),
             ElevatedButton(
              onPressed: ()async{
                try{
                  final id = (item['id'] as num).toInt();
                  final nome = nomeCtrl.text.trim();
                  final preco = double.parse(precoCtrl.text.replaceAll(',', '.'));
                  final qtd = int.parse(qtdCtrl.text);
                  await _atualizarProduto(
                    id: id, nome: nome, preco: preco, quantidade: qtd);
                    if(mounted) Navigator.pop(context);
                }catch(e){
                  if (mounted){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('erro: $e')));
                  }
                }

              }, child: Text('Salvar'))
        ],

       ));
  }



  // Widgets Dismissible

  Widget _bgDismissLeft()=>Container(
    alignment: Alignment.centerLeft,
    padding: EdgeInsets.symmetric(horizontal: 16),
    color: Colors.red,
    child: Row(
     
      children: [
        Icon(Icons.delete,
        color: Colors.white,),
        SizedBox(
          width: 8,
          
        ),
        Text('Apagar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
      ],
    ),
  );

 // bg right

 Widget _bgDismissRight()=>Container(
    alignment: Alignment.centerRight,
    padding: EdgeInsets.symmetric(horizontal: 16),
    color: Colors.red,
    child: Row(
       mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Icon(Icons.delete,
        color: Colors.white,),
        SizedBox(
          width: 8,
          
        ),
        Text('Apagar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)
      ],
    ),
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text('Aula 11 - App com Django'),
      ),

      body: RefreshIndicator(
         onRefresh: leituradados, child: ListView.builder(
          physics: AlwaysScrollableScrollPhysics(),
          itemCount: dado.length,
          itemBuilder: (context,index){
            final item = dado[index];
            final id = (item['id'] as num).toInt();
            return Dismissible(
              key: ValueKey<int>(id),
              background: _bgDismissLeft(),
              secondaryBackground: _bgDismissRight(),
              direction: DismissDirection.horizontal,
              confirmDismiss: (direction)async{
                // confirmação antes de apagar o produto
                return await showDialog<bool>(
                  context: context, 
                  builder: (_)=>AlertDialog(
                    title: Text('Confirmar exclusão'),
                    content:  Text('Apagar o produto ${item['nome']}?'),
                    actions: [
                      TextButton(
                        onPressed: ()=>Navigator.pop(context,false), 
                        child: Text('Cancelar')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: ()=>Navigator.pop(context,true), child: Text('Apagar'))
                    ],
                  ));
              },
              onDismissed: (direction)async{
                try{
                  await _deletarProduto(id);
                }catch(e){
                  // Se falhar recarrega a lista
                  await leituradados();
                  if(mounted){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Falha ao deletar produto: $e')));
                  }
                }
              },
              
               child: Card(
                margin: EdgeInsets.symmetric(horizontal: 12,vertical: 6),
                child: ListTile(
                  title: Text('Nome: ${item['nome']}',style: TextStyle(fontSize: 18),),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Valor: R\$ ${item['preco']}',style: TextStyle(fontSize: 16),),
                      Text('Qtde: ${item['quantidade']}',style: TextStyle(fontSize: 16),)
                    ],
                  ),
                  trailing: Icon(Icons.edit),
                  onTap: () => _abrirDialogEdicao(item),
                ),
                
               ),
               );

          })),
    );
  }
}