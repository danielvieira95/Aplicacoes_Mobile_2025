import 'package:appaula02/screen/telacalc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' ; // biblioteca que permite importar o gerenciador
// de estados Getx
void main() {
  runApp(TelaHome());
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // retira a faixa debug do app
      debugShowCheckedModeBanner: false,
      title: "App Aula 02 - Responsivo",
      home: ResponsiveHome(),
    );
  }
}
 
 // Tela Responsiva
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
    final isMobile = screenWidth <600;
    final isTablet = screenWidth>=600 && screenWidth<1024;
    final isDesktop = screenWidth >=1024;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Responsive App'),
        backgroundColor: Colors.red,
      ),
      drawer: isMobile ?Drawer(
        backgroundColor: Colors.red,
        child: ListView(
          children: [
            DrawerHeader(
              
              child: Text('Menu'),
              ),
              ListTile(
                title: Text('Item 1'),
                
                onLongPress: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder:(context)=>TelaCalculadora()));
                },
              ),
              ListTile(
                title: Text('Item 2'),
                
                   onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder:(context)=>SumApp()));
                   }
                
              ),

          ],
        ),
      ):null ,
      body: Row(
        children: [
          if(!isMobile)Container(
            width: isTablet?200:250,
            color: Colors.blue[100],
            child: ListView(
              children: [
                DrawerHeader(
                  child: Text('Menu'),
                  ),
                  ListTile(
                    title: Text('Item 1'),
                  ),
                  ListTile(
                    title: Text('Item 2'),
                  )
              ],
            ),
          ),
          // Widget Expanded se adapta conforme o tamanho da tela
          Expanded(child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Screen width: ${screenWidth}',style: TextStyle(fontSize: screenWidth/10),),
                Text('Screen height: ${screenWidth}',style: TextStyle(fontSize: screenWidth/10)),
                if(isMobile) Text('This a mobile view',style: TextStyle(fontSize: screenWidth/10),),
                if(isTablet) Text('This is a tablet view',style: TextStyle(fontSize: screenWidth/10)),
                if(isDesktop) Text('This a desktop view',style: TextStyle(fontSize: screenWidth/10))
              ],
            ),
          ))
        ],
      ),
      
    );
  }
}