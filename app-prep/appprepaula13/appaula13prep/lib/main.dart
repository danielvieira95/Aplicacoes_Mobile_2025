import 'package:appaula13prep/screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // para copiar para área de transferência
          // importe sua página do scanner

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leitor QR',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _ultimoConteudo;

  Future<void> _abrirLeitor() async {
    // abre a câmera; QrScannerPage retorna a string com Navigator.pop(context, raw)
    final resultado = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const QrScannerPage()),
    );

    if (!mounted) return;
    if (resultado != null && resultado.isNotEmpty) {
      setState(() => _ultimoConteudo = resultado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('QR Code lido com sucesso!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = _ultimoConteudo ?? 'Nada lido ainda. Toque no botão abaixo.';
    return Scaffold(
      appBar: AppBar(title: const Text('Ler QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Container que exibe o texto lido
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                conteudo,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Abrir câmera'),
                    onPressed: _abrirLeitor,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: 'Copiar',
                  onPressed: _ultimoConteudo == null
                      ? null: () async {
                          await Clipboard.setData(ClipboardData(text: _ultimoConteudo!));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copiado!')),
                          );
                        },
                  icon: const Icon(Icons.copy),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Limpar',
                  onPressed: _ultimoConteudo == null
                      ? null
                      : () => setState(() => _ultimoConteudo = null),
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

