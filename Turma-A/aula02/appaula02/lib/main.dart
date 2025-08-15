import 'package:appaula02/screens/calcgetx.dart';
import 'package:appaula02/screens/telacalc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(TelaHome());
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "App - Aula 02 - Responsivo",
      home: ResponsiveHome(),
    );
  }
}


class ResponsiveHome extends StatelessWidget {
  
  @override
 


  Widget build(BuildContext context) {
  // Variavel que irá pegar o tamanho da tela do dispositivo
  final mediaQueryData = MediaQuery.of(context);
  // Armazena a largura da tela
  final screenWidth = mediaQueryData.size.width;
  // Armazena a altura da tela
  final screenHeight = mediaQueryData.size.height;

  // Definindo os breakpoints
  final isMobile = screenWidth <600; // se a largura da tela for menor que 600 é mobile
  final isTablet = screenWidth>=600 && screenWidth<1024; // largura maior  que 600 e menor que 1024 tablet
  final isDesktop = screenWidth>=1024; // se for maior do que 1024 é desktop

    return Scaffold(
      appBar: AppBar(
        title: Text("Flutter Responsive App"),
        backgroundColor: Colors.red,
      ),
      drawer: isMobile?Drawer(
        backgroundColor: Colors.redAccent,
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Menu')),
              ListTile(
                title: Text('Item 1'),
              ),
              ListTile(
                title: Text('Item 2'),
                
              )
          ],
        ),
      ):null,
      body: Row(
        children: [
          if(!isMobile)Container(
            width: isTablet?200:250,
            color: Colors.blue[100],
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text(
                    'Menu'),
                    
                    ),
                    ListTile(
                      title: Text('Soma setstate'),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context)=>TelaCalculadora()));
                      },
                    ),
                    ListTile(
                      title: Text('Soma com GETX '),
                      onLongPress: () => Navigator.push(context, MaterialPageRoute(builder: (context)=>SumApp())),
                    )
              ],
            ),
          ),
          // Widget que se expande conforme o tamanho da tela
          Expanded(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Screen width: ${screenWidth}',style: TextStyle(fontSize: screenWidth/15),),
              Text('Screen height: ${screenHeight}',style: TextStyle(fontSize: screenWidth/15),),
              if(isMobile)Text('É tela mobile',style: TextStyle(fontSize: screenWidth/20),),
              if(isTablet)Text('É tela de tablet',style: TextStyle(fontSize: screenWidth/20),),
              if(isDesktop)Text('É desktop',style:  TextStyle(fontSize: screenWidth/20),)
            ],
          ))
        ],

      ),
    );
  }
}