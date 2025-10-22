import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Telaacionamento extends StatefulWidget {
  const Telaacionamento({super.key});

  @override
  State<Telaacionamento> createState() => _TelaacionamentoState();
}

class _TelaacionamentoState extends State<Telaacionamento> {
  // ===== AJUSTE AQUI: IP/porta do seu Pico W =====
  static const String baseUrl = 'http://192.168.15.13'; // exemplo

  Color status_cor = Colors.grey;

  double? temperatura; // do Pico: "temperatura_c"
  String btnA = 'solto';
  String btnB = 'solto';
  String ledR = 'off', ledG = 'off', ledB = 'off';

  // ===== Helpers HTTP =====
  Future<http.Response> _post(String path, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http
        .post(uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data))
        .timeout(const Duration(seconds: 3));
  }

  Future<http.Response> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    return await http.get(uri).timeout(const Duration(seconds: 3));
  }

  // ====== STATUS (GET) ======
  Future<void> _leitura() async {
    try {
      final resp =
          await _get('/status_json'); // pode trocar para POST se preferir
      if (resp.statusCode == 200) {
        final j = jsonDecode(resp.body);
        final s = j['status'] ?? j;
        setState(() {
          temperatura = (s['temperatura_c'] ?? 0).toDouble();
          final leds = (s['leds'] ?? {}) as Map;
          ledR = (leds['R'] ?? 'off').toString();
          ledG = (leds['G'] ?? 'off').toString();
          ledB = (leds['B'] ?? 'off').toString();
          final btns = (s['botoes'] ?? {}) as Map;
          btnA = (btns['A'] ?? 'solto').toString();
          btnB = (btns['B'] ?? 'solto').toString();
          final anyOn = (ledR == 'on') || (ledG == 'on') || (ledB == 'on');
          status_cor = anyOn ? Colors.green : Colors.red;
        });
      } else {
        debugPrint('Erro status_json: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Erro na requisição: $e');
    }
  }

  // ====== LEDS via POST ======
  // Liga/desliga em grupo
  Future<void> _rgbSet(
      {required bool r, required bool g, required bool b}) async {
    try {
      final resp = await _post('/rgb', {'r': r, 'g': g, 'b': b});
      if (resp.statusCode == 200) {
        await _leitura();
      } else {
        debugPrint('rgb POST erro: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('rgb POST exc: $e');
    }
  }

  Future<void> _rgbOn() async => _rgbSet(r: true, g: true, b: true);
  Future<void> _rgbOff() async => _rgbSet(r: false, g: false, b: false);

  // Canais individuais (o seu backend usa a MESMA rota pra on/off)
  Future<void> _rSet(bool on) async {
    try {
      final resp = await _post('/r_on', {'on': on ? 1 : 0});
      if (resp.statusCode == 200) await _leitura();
    } catch (e) {
      debugPrint('r_set erro: $e');
    }
  }

  Future<void> _gSet(bool on) async {
    try {
      final resp = await _post('/g_on', {'on': on ? 1 : 0});
      if (resp.statusCode == 200) await _leitura();
    } catch (e) {
      debugPrint('g_set erro: $e');
    }
  }

  Future<void> _bSet(bool on) async {
    try {
      final resp = await _post('/b_on', {'on': on ? 1 : 0});
      if (resp.statusCode == 200) await _leitura();
    } catch (e) {
      debugPrint('b_set erro: $e');
    }
  }

  // ====== Beep via POST ======
  Future<void> _beep({int freq = 1800, int ms = 150}) async {
    try {
      await _post('/beep', {'freq': freq, 'ms': ms});
    } catch (e) {
      debugPrint('beep erro: $e');
    }
  }

  // ====== Matriz 5x5 via POST ======
  Future<void> _drawPattern(String name) async {
    try {
      await _post('/matrix', {'pattern': name});
    } catch (e) {
      debugPrint('matrix pattern erro: $e');
    }
  }

  Future<void> _clearMatrix() async {
    try {
      await _post('/matrix', {
        'bitmap': ["00000", "00000", "00000", "00000", "00000"]
      });
      // ou, se preferir, crie uma rota POST /clear no firmware
    } catch (e) {
      debugPrint('matrix clear erro: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _leitura();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF5EE),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 0,
       
        title: const Text(
          'BitDog Lab App',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Painel de status
              Container(
                alignment: Alignment.center,
                width: 220,
                height: 160,
                decoration: BoxDecoration(
                  color: status_cor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'RGB ${status_cor == Colors.green ? "LIGADO" : "DESLIGADO"}\n'
                  'Temp: ${temperatura?.toStringAsFixed(2) ?? "--"} °C\n'
                  'Btns: A=$btnA  B=$btnB\n'
                  'LEDs: R=$ledR G=$ledG B=$ledB',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),

              // Botões principais
              _fullBtn('RGB ON', () async {
                await _rgbOn();
              }),
              _fullBtn('RGB OFF', () async {
                await _rgbOff();
              }),
              _fullBtn('Leitura', () async {
                await _leitura();
              }),

              const SizedBox(height: 16),

              // Controles individuais (POST)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _miniBtn('R ON', () => _rSet(true)),
                  _miniBtn('R OFF', () => _rSet(false)),
                  _miniBtn('G ON', () => _gSet(true)),
                  _miniBtn('G OFF', () => _gSet(false)),
                  _miniBtn('B ON', () => _bSet(true)),
                  _miniBtn('B OFF', () => _bSet(false)),
                  _miniBtn('Beep', () => _beep(freq: 1200, ms: 90)),
                ],
              ),

              const SizedBox(height: 12),

              // Matriz 5x5 (POST /matrix)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _miniBtn(
                      'S',
                      () => _drawPattern(
                          'S')), // seu firmware usa nome da rota; pode padronizar para 'S'
                  _miniBtn('Smile', () => _drawPattern('smile')),
                  _miniBtn('Giraffe', () => _drawPattern('giraffe')),
                  _miniBtn('Heart', () => _drawPattern('heart')),
                  _miniBtn('Pacman', () => _drawPattern('pacman')),
                  _miniBtn('Happy', () => _drawPattern('happy')),
                  _miniBtn('Duck', () => _drawPattern('duck')),
                  _miniBtn('Limpar', _clearMatrix),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Estilos =====
  Widget _fullBtn(String label, VoidCallback onPressed) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue, foregroundColor: Colors.white),
          onPressed: onPressed,
          child: Text(label),
        ),
      );

  Widget _miniBtn(String label, VoidCallback onPressed) => ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        ),
        onPressed: onPressed,
        child: Text(label),
      );
}
