import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Classe com gerenciador de estado GetX
class SumController extends GetxController{
  var number1 =0.0.obs; // Variavel para armazenar o numero 1
  var number2 = 0.0.obs; // Variavel para armazenar o numero 2
  var result = 0.0.obs; // Variavel para armazenar o resultado


  // criando as funções
  void setNumber1(String value){
    number1.value = double.tryParse(value)??0.0;

  }

  void setNumber2(String value){
    number2.value = double.tryParse(value) ?? 0.0;

  }

  void calculateSum(){
    result.value = number1.value + number2.value; // Calcula a soma
  }

}

// Cria outra classe

class SumApp extends StatelessWidget{
  final SumController controller =Get.put(SumController()); // Injeta o controlador
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
    appBar: AppBar(
      title: Text('Somar numeros - GETX'),
    ),
    body:  Padding(padding: EdgeInsets.all(16),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Numero 1',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) => controller.setNumber1(value), // atualiza numero 1
        ),
        SizedBox(
          height: 16,
        ),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Numero 2',
            border: OutlineInputBorder()
          ),
          onChanged: (value) => controller.setNumber2(value), // atualiza numero 2
        ),
        SizedBox(height: 16,),
        ElevatedButton(onPressed: controller.calculateSum, child: Text('Somar')),
        SizedBox(height: 16,),
        // Gerenciador de estado OBX
        Obx(()=>Text('Resultado: ${controller.result}',style: TextStyle(
          fontSize: 20,fontWeight: FontWeight.bold
        ),))
      ],
    ),),
    );
  }
}



class TelaCalculadora extends StatefulWidget {
  const TelaCalculadora({super.key});

  @override
  State<TelaCalculadora> createState() => _TelaCalculadoraState();
}

class _TelaCalculadoraState extends State<TelaCalculadora> {
  final TextEditingController n1 = TextEditingController();
  final TextEditingController n2 = TextEditingController();
  double soma =0;
  _som(){
    setState(() {
      soma = (double.tryParse(n1.text)!)+ (double.tryParse(n2.text)!) ;
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
              decoration:InputDecoration(
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
              decoration:InputDecoration(
                labelText: 'Numero 2',
                border: OutlineInputBorder(),
                
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