import 'package:appaula08prep/screens/cadastroprod.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(TleaHome());
}

class TleaHome extends StatelessWidget {
  const TleaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Cadastroproduto(),
    );
  }
}