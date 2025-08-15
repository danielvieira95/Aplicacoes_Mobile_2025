import 'package:flutter/material.dart';

class TelaCalculadora extends StatefulWidget {
  const TelaCalculadora({super.key});

  @override
  State<TelaCalculadora> createState() => _TelaCalculadoraState();
}

class _TelaCalculadoraState extends State<TelaCalculadora> {
  // Cria variaveis para armazenar o que o usuario digita
  final TextEditingController n1 = TextEditingController();
  final TextEditingController n2 = TextEditingController();
  // variavel para soma
  double soma =0;
  _som(){
    setState(() {
      soma = (double.tryParse(n1.text)!)+(double.tryParse(n2.text)!);
    });
  }
  @override
  
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(),
     body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Numero 1',
              border: OutlineInputBorder(),
            ),
            controller: n1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextFormField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Numero 2',
              border: OutlineInputBorder()
            ),
            controller: n2,
          ),
        ),
        Text('Resultado ${soma}',style: TextStyle(fontSize: 18),),
        ElevatedButton(onPressed: _som, child: Text('Calcular'))
      ],
     ),
    );
  }
}