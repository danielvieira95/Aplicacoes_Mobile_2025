import 'package:appbitdoglab/telaapp.dart';
import 'package:appbitdoglab/telaapp2.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(TelaHome());
}


class TelaHome extends StatelessWidget {
  const TelaHome({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Telaacionamento2(),
    );
  }
}