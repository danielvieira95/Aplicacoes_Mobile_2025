import 'package:appaula05bdta/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized(); // metodo par evitar que a tela do app fique travada antes de carregar o banco de dados
  runApp(AppBD());
}

class AppBD extends StatelessWidget {
  const AppBD({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pets + SQFLITE',
      theme: ThemeData(useMaterial3: true,
      colorSchemeSeed: Colors.teal),
      home: HomePage(),
    );
  }
}