import 'package:appaula10tb/screens/prod_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cadastroproduto extends StatefulWidget {
  const Cadastroproduto({super.key});

  @override
  State<Cadastroproduto> createState() => _CadastroprodutoState();
}

class _CadastroprodutoState extends State<Cadastroproduto> {
  // Criando as variaveis para cadastro dos produtos
  TextEditingController nomeprod = TextEditingController();
  TextEditingController qtde = TextEditingController();
  TextEditingController price = TextEditingController();
  // Cria a função para cadastrar o produto

  _cadastrarproduto()async{

    //String url = "http://10.109.83.10:8000/api/produtos/";
    String url = "http://172.20.10.4:8000/api/produtos/";
    // Cria a estrutura da mensagem para cadastro dos produtos
    Map<String,dynamic> prod={
      "nome":nomeprod.text,
      "quantidade":qtde.text,
      "preco":price.text
    };

    await http.post(Uri.parse(url),
    headers: <String,String>{
      'Content-type':'application/json; charset=UTF-8'},
      body: jsonEncode(prod)
    
    );
    nomeprod.text="";
    price.text="";
    qtde.text="";

    // função para deletar um produto

    showDialog(
      context: context, 
      builder: (BuildContext){
        return AlertDialog(
          content: Text("Produto ${nomeprod.text} cadastrado"),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              }, child: Text('Fechar'))
          ],
        );

      });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title:  Text('App com Backend Django'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration:  InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                hintText: 'Digite o nome do produto'
              ),
              controller: nomeprod,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration:  InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                hintText: 'Digite a quantidade do produto'
              ),
              controller: qtde,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration:  InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                hintText: 'Digite o valor do produto'
              ),
              controller: price,
            ),
          ),

          ElevatedButton(
            onPressed: _cadastrarproduto, child: Text('Cadastrar')),
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder:(context)=> Produto_screen()));

            }, child: Text('Produtos screen'))
        ],
      ),

    );
  }
}