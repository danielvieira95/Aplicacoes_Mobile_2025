import 'dart:async'; // requisições assincronas
import 'dart:convert'; // conversao json
import 'package:flutter/material.dart'; // widgets flutter
import 'package:http/http.dart' as http;

class Telaapp extends StatefulWidget {
  const Telaapp({super.key});

  @override
  State<Telaapp> createState() => _TelaappState();
}

class _TelaappState extends State<Telaapp> {
  // ip da bitdog lab
   static const String baseUrl = "http://192.168.4.1";

   // Estado mostrado 
   Color statusCor = Colors.grey;
   double? temperatura;
   String btnA = 'solto';
   String btnB = 'solto';
   String ledR ='off',ledG ='off',ledB='off';

   // Guarda o ultimo snapshot para evitar setState redundante

   String _lastBtnsKey = '';
   String _lastLedsKey = '';
   double? _lastTemp;

   // Timer do polling
   Timer? _poll;


   // Http
   Future<http.Response> _post(String path, Map<String,dynamic> data) async{
    final uri = Uri.parse('$baseUrl$path');
    return await http.post(uri, headers: {
      'Content-type':'application/json'
    },
    body:  jsonEncode(data)).timeout(const Duration(seconds: 3));
    
    
   }

   // Get
   Future<http.Response> _get(String path) async{
    final uri = Uri.parse('$baseUrl$path');
    return await http.get(uri).timeout(Duration(seconds: 3));
   }

   // Status Get /status_json
   Future<void> _leitura({bool forceSetState = false})async{
    try{
      final resp = await _get('/status_json');
      if(resp.statusCode !=200) return;
      final j = jsonDecode(resp.body);
      final s = j['status']?? j;

      final newTemp = (s['temperatura_c']??0).toDouble();
      final leds = (s['leds']?? {}) as Map;
      final newR = (leds['R']?? 'off').toString();
      final newG = (leds['G'] ?? 'off').toString();
      final newB = (leds['B'] ?? 'off').toString();

      final btns = (s['botoes'] ?? {}) as Map;
      final newA = (btns['A'] ?? 'solto').toString();
      final newBbtn =(btns['B'] ?? 'solto').toString();
      final newBtnsKey = '$newA|$newBbtn';
      final newLedsKey = '$newR|$newG|$newB';
      final anyOn = (newR == 'on')|| (newG == 'on') || (newB =='on');
      final newStatusCor = _colorFromLeds(r:newR,g:newG,b:newB);

      final changed = forceSetState || newBtnsKey != _lastBtnsKey ||newLedsKey != _lastLedsKey ||
      _lastTemp != newTemp || statusCor != newStatusCor;

      if(changed && mounted){
        setState(() {
          temperatura = newTemp;
          btnA = newA;
          btnB = newBbtn;
          ledR = newR;
          ledG = newG;
          ledB = newB;
          statusCor = newStatusCor;

          _lastBtnsKey = newBtnsKey;
          _lastLedsKey = newLedsKey;
          _lastTemp = newTemp;
        });
      }else{
        // sem nada a fazer
      }
    }catch(_){}
   }

   // Leds por post

   Future<void> _rgbSet({
    required bool r, required bool g, required bool b}) async{
      try{
        final resp =  await _post('/rgb', {'r':r,'g':g,'b':b});
        if(resp.statusCode ==200) await _leitura(forceSetState: true);
      }catch(_){}

   }

   Future<void> _rgbOn() async => _rgbSet(r: true, g: true, b: true);
   Future<void> _rgbOff() async => _rgbSet(r: false, g: false, b: false);
   // função para ativar o led vermelho
   Future<void> _rSet(bool on)async{
    try{
      final r = await _post('/r_on', {'on':on ? 1:0});
      if(r.statusCode ==200) await _leitura(forceSetState: true);
    }catch(_){}
   }

   Future<void> _gSet(bool on)async{
    try{
      final g = await _post('/g_on', {'on':on ? 1:0});
      if(g.statusCode ==200) await _leitura(forceSetState: true);
    }catch(_){}
   }

   Future<void> _bSet(bool on)async{
    try{
      final b = await _post('/b_on', {'on':on ? 1:0});
      if(b.statusCode ==200) await _leitura(forceSetState: true);
    }catch(_){}
   }
   // função para ativar o beep
   Future<void> _beep({int freq=1200, int ms =90})async{
    try{
      await _post('/beep', {'freq':freq,'ms':ms});
    }catch(_){}

   }


   // Funçao para fazer desenho na matriz de led

   Future<void> _drawPattern(String name)async{
    try{
      await _post('/matrix', {'pattern':name});
    }catch(_){}

   }

   // Função para limpar a matriz
   Future<void> _clearMatrix() async{
    try{
      await _post('/matrix', {
        'bitmap':["00000","00000","00000","00000","00000"]
      });
    }catch(_){}
   }

  // Ciclo de vida
  @override
  void initState(){
    super.initState();
    _leitura(forceSetState: true);
    // Polling de 300 ms (Ajuste se quiser mais responsivo ou menos)
    _poll = Timer.periodic(Duration(milliseconds: 300),(_)=> _leitura());
  }

  @override
  void dispose(){
    _poll?.cancel();
    super.dispose();
  }
  @override
  // UI 
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: Text('BitDog Lab',
        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        centerTitle: true,

      ),
      body:  Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: 220,
                height: 160,
                decoration: BoxDecoration(
                  color: statusCor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('RGB ${statusCor == Colors.green ? "LIGADO":"DESLIGADO"}\n'
                'Temp: ${temperatura?.toStringAsFixed(2) ?? "--"}C \n'
                'Btns: A = $btnA B $btnB \n' 
                'LEDS: R = $ledR G = $ledG B = $ledB \n',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
                
                
                ),
              ),
              SizedBox(height: 12,),
              _fullBtn('RGB ON',_rgbOn),
              _fullBtn('RGB OFF',_rgbOff),
              _fullBtn('Leitura agora',()=>_leitura(forceSetState: true)),
              SizedBox(height: 16,),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _miniBtn('R ON',()=>_rSet(true)),
                  _miniBtn('R OFF',()=>_rSet(false)),
                  _miniBtn('G ON',()=>_gSet(true)),
                  _miniBtn('G OFF',()=>_gSet(false)),
                  _miniBtn('B ON',()=>_bSet(true)),
                  _miniBtn('B OFF',()=>_bSet(false)),
                  _miniBtn('Beep',()=>_beep()),
                ],
              ),
              SizedBox(height: 12,),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _miniBtn('S',()=>_drawPattern('S')),
                  _miniBtn('Smile',()=>_drawPattern('smile')),
                  _miniBtn('Giraffe',()=>_drawPattern('giraffe')),
                  _miniBtn('Heart',()=>_drawPattern('heart')),
                  _miniBtn('Pacman',()=>_drawPattern('pacman')),
                  _miniBtn('Happy',()=>_drawPattern('happy')),
                  _miniBtn('Duck',()=>_drawPattern('duck')),
                  _miniBtn('Limpar',()=>_clearMatrix()),

                ],
              )
            ],

          ),
        ),
      ),
    );
  }
}

// Estilos botoes
Widget _fullBtn(String label, VoidCallback onPressed ) =>SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,foregroundColor: Colors.white),
    onPressed: onPressed, child: Text(label)),
);

Widget _miniBtn(String label,VoidCallback onPressed)=>ElevatedButton(
  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal,foregroundColor: Colors.white,
  padding: EdgeInsets.symmetric(horizontal: 14,vertical: 10)),
  onPressed: onPressed, child: Text(label));


// Classe das cores
Color _colorFromLeds({required String r, required String g, required String b}){
  final rr = r== 'on';
  final gg = g== 'on';
  final bb = b== 'on';

  if(!rr && !gg && ! bb) return Colors.grey; // tudo off
  if(!rr && gg && ! bb) return Colors.green; // green
  if(!rr && !gg &&  bb) return Colors.blue; // blue

  // combinações

  if(rr && gg && ! bb) return Colors.yellow; // amarelo
  if(rr && !gg &&  bb) return Colors.purple; // purple
  if(!rr && gg &&  bb) return Colors.cyan; // cyano
  return Colors.blueGrey;
}