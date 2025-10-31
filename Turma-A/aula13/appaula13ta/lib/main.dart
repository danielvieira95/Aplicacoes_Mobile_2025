import 'package:appaula13ta/screens/scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(TelaApp());
}

class TelaApp extends StatelessWidget {
  const TelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App aula 13 TA - QR Code',
      theme: ThemeData(useMaterial3: true,colorSchemeSeed: Colors.indigo),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String ? _ultimoConteudo;

  Future<void> _abrirLeitor()async{
    // abre a camera QRScannerPage retorna a string com Navigator.pop
    final resultado = await Navigator.push<String>(context, 
    MaterialPageRoute(builder: (_)=>QrScannerPage()));
    if(!mounted) return;
    if(resultado !=null && resultado.isNotEmpty){
      setState(() => _ultimoConteudo = resultado);  
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Qr code lido com sucesso')));
      
    }

  }
  @override
  Widget build(BuildContext context) {
    final conteudo = _ultimoConteudo ?? 'Nada lido ainda ! Toque no botão abaixo';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text('Ler QR Code',style: TextStyle(color: Colors.white),),
      ),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300)
              ),
              child: SelectableText(
                conteudo,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 12,),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: Icon(Icons.qr_code_scanner),
                    onPressed: _abrirLeitor, 
                  label: Text('Abrir câmera'))),
                  SizedBox(width: 12,),
                  IconButton.filledTonal(
                    tooltip: 'Copiar',
                    
                    onPressed: _ultimoConteudo==null? null:()async{
                      await Clipboard.setData(ClipboardData(text: _ultimoConteudo!));
                      if(!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Copiado'))
                      );
                    }, icon: Icon(Icons.copy)),
                    SizedBox(width: 8,),
                    IconButton.filledTonal(
                      tooltip: 'Limpar',
                      
                      onPressed: _ultimoConteudo==null?null:()=>setState(
                        ()=>_ultimoConteudo=null), icon: Icon(Icons.clear))
              ],
            )
          ],
        ),
      ),
    );
  }
}