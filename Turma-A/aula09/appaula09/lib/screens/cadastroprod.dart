

import 'package:appaula09/screens/prodscreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Cadastroproduto extends StatefulWidget {
  const Cadastroproduto({super.key});

  @override
  State<Cadastroproduto> createState() => _CadastroprodutoState();
}

class _CadastroprodutoState extends State<Cadastroproduto> {
  // Criando variaveis para cadastro dos produtos
  TextEditingController nomeprod = TextEditingController();
  TextEditingController qte = TextEditingController();
  TextEditingController price = TextEditingController();

  // cria funçao para cadastro do produto
  _cadastrarproduto()async{
    String url = "http://10.109.83.10:8000/api/produtos/";
    // cria estrutura da mensagem para cadastro dos produtos
    Map<String,dynamic>prod={
      "nome":nomeprod.text,
      "quantidade":qte.text,
      "preco":price.text
    };
    await http.post(Uri.parse(url),
    headers: <String,String>{
    'Content-type':'application/json; charset=UTF-8'},
    body: jsonEncode(prod)
    );
    nomeprod.text="";
    price.text="";
    qte.text="";
    // função para deletar um produto
    showDialog(
        context: context, 
        builder: (BuildContext){
          return AlertDialog(
            content: Text("Produto ${nomeprod.text} cadastrado !"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Fechar"))
            ],
          );

        });
  }
    _deletarproduto(){
      // metodo para deletar um produto
      http.delete(Uri.parse("http://192.168.15.12:8000/api/produtos/${nomeprod.text}"));
      nomeprod.text="";
      showDialog(
        context: context, 
        builder: (BuildContext){
          return AlertDialog(
            content: Text("Produto ${nomeprod.text} deletado !"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                }, child: Text("Fechar"))
            ],
          );

        });
    }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text("App Ecommerce"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                hintText: "Digite o nome do produto"
              ),
              controller: nomeprod,
            ),
          ),
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                hintText: "Digite o valor do produto"
              ),
              controller: price,
            ),
          ),
           Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                ),
                hintText: "Digite a qtde do produto"
              ),
              controller: qte,
            ),
          ),
            
          ElevatedButton(onPressed: _cadastrarproduto, child: Text("Cadastrar produto")),
          ElevatedButton(onPressed: _deletarproduto, child: Text("Deletar produto")),
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(
              builder: (context)=>Produto_screen()));
          }, child: Text("Produtos screen"))
        ],
      ),
    );
  }
}