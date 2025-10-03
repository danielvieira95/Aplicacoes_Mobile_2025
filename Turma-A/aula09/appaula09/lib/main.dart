import 'package:appaula09/screens/cadastroprod.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(TelaHome());
}

class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      home: Cadastroproduto(),
    );
  }
}