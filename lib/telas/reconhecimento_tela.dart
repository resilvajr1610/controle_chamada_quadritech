import 'dart:async';
import 'dart:convert';
import 'package:controle_chamada_quadritech/widgets/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:controle_chamada_quadritech/modelo/cores.dart';
import 'package:controle_chamada_quadritech/widgets/botao_padrao.dart';
import 'package:controle_chamada_quadritech/widgets/menu_web.dart';
import 'package:controle_chamada_quadritech/widgets/texto_padrao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modelo/disciplina_modelo.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/dropdown_disciplinas.dart';
import '../widgets/dropdown_escolas.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:http_parser/http_parser.dart';

class ReconhecimentoTela extends StatefulWidget {
  const ReconhecimentoTela({super.key});

  @override
  State<ReconhecimentoTela> createState() => _ReconhecimentoTelaState();
}

class _ReconhecimentoTelaState extends State<ReconhecimentoTela> {

  List<EscolaModelo> escolasLista = [];
  List<DisciplinaModelo> disciplinasLista = [];
  EscolaModelo? escolaSelecionada;
  List<DisciplinaModelo> disciplinasBanco = [];
  DisciplinaModelo? disciplinaSelecionada;
  html.VideoElement? _video;
  html.MediaStream? _mediaStream;
  Timer? _timer;
  String _resultado = '';
  bool aguardando = false;

  carregarEscolas(){
    FirebaseFirestore.instance.collection('escolas')
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('nome')
        .get()
        .then((escolasDoc){
      for(int i = 0; escolasDoc.docs.length > i;i++){
        escolasLista.add(
            EscolaModelo(
              idEscola: escolasDoc.docs[i].id,
              bairro: escolasDoc.docs[i]['bairro'],
              cep: escolasDoc.docs[i]['cep'],
              cidade: escolasDoc.docs[i]['cidade'],
              endereco: escolasDoc.docs[i]['endereco'],
              ensino: escolasDoc.docs[i]['ensino'],
              nome: escolasDoc.docs[i]['nome'],
              numero: escolasDoc.docs[i]['numero'],
              numeroRegistro: escolasDoc.docs[i]['numeroRegistro'],
            )
        );
      }
      setState(() {});
    });
  }

  carregarDisciplinas(String idEscola){

    disciplinasBanco.clear();
    disciplinaSelecionada = null;
    setState(() {});
    FirebaseFirestore.instance.collection('disciplinas')
        .where('idEscola',isEqualTo: idEscola)
        .where('status',isEqualTo: 'ativo')
        .orderBy('nomeDisciplina')
        .get()
        .then((disciplinasDoc){

      for(int i = 0; disciplinasDoc.docs.length > i;i++){
        disciplinasBanco.add(
            DisciplinaModelo(
              idEscola: disciplinasDoc.docs[i].id,
              ensino: disciplinasDoc.docs[i]['ensino'],
              nomeDisciplina: disciplinasDoc.docs[i]['nomeDisciplina'],
              ano: disciplinasDoc.docs[i]['ano'],
              curso: disciplinasDoc.docs[i]['curso'],
              idDisciplina: disciplinasDoc.docs[i].id,
              nomeEscola: disciplinasDoc.docs[i]['nomeEscola'],
            )
        );
      }
      setState(() {});
    });
  }

  Future<void> iniciarCamera() async {
    if (_video != null) return;

    _video = html.VideoElement()
      ..autoplay = true
      ..width = 320
      ..height = 240
      ..style.width = '320px'
      ..style.height = '240px';

    // Registra o vídeo para ser exibido no Flutter
    ui.platformViewRegistry.registerViewFactory(
      'webcam-video',
      (int viewId) => _video!,
    );

    setState(() {});

    _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({'video': true});

    _video!.srcObject = _mediaStream;
    final canvas = html.CanvasElement(width: 640, height: 480);

    Timer.periodic(const Duration(seconds: 5), (_) async {
      aguardando = true;
      setState(() {});
      final context = canvas.context2D;
      context.drawImage(_video!, 0, 0);
      final blob = await canvas.toBlob('image/jpeg');
      final reader = html.FileReader();
      reader.readAsArrayBuffer(blob!);
      await reader.onLoadEnd.first;
      final frame = reader.result as Uint8List;
      if(_video!=null){
        _resultado = await comparar(frame);
        aguardando = false;
        setState(() {});
        print('resultado: $_resultado');
      }
    });
  }

  Future<String> comparar(Uint8List frame) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/verificar'),
      )
        ..fields['id_disciplina'] = disciplinaSelecionada!.idDisciplina
        ..files.add(http.MultipartFile.fromBytes(
          'imagem',
          frame,
          filename: 'webcam.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));

      final response = await request.send();
      final body = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final nomeAluno = data['aluno'] ?? 'Desconhecido';
        final verificado = data['verificado'] ?? false;
        if(verificado){
          registrarPresenca(data);
        }
        
        return verificado?'Presença Confirmada aluno(a): $nomeAluno':'Aluno não encontrado';
      } else {
        return 'Erro na comparação: $body';
      }
    } catch (e) {
      return 'Erro na requisição: $e';
    }
  }
  
  registrarPresenca(Map resposta){
    final docRef = FirebaseFirestore.instance.collection('presencas').doc();
    FirebaseFirestore.instance.collection('presencas').doc(docRef.id).set({
      'idPresenca'    : docRef.id,
      'idDisciplina'  : disciplinaSelecionada!.idDisciplina,
      'nomeDisciplina': disciplinaSelecionada!.nomeDisciplina,
      'idEscola'      : escolaSelecionada!.idEscola,
      'nomeEscola'    : escolaSelecionada!.nome,
      'nomeAluno'     : resposta['aluno'],
      'alunoId'       : resposta['aluno_id'],
      'dataHora'      : DateTime.now(),
      'situacao'      : 'entrada1'
    });
    showSnackBar(context, 'Presença Registrada', Colors.green);
  }

  @override
  void initState() {
    super.initState();
    carregarEscolas();
  }

  void dispose() {
    _timer?.cancel();
    _mediaStream?.getTracks().forEach((t) => t.stop());
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    double altura = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Cores.corPrincipal,
        title: TextoPadrao(texto: 'RECONHECIMENTO FACIAL',)
      ),
      body: Container(
        child: Column(
          children: [
           MenuWeb(),
            Container(
              height: altura*0.8,
              width: 390,
              alignment: Alignment.center,
              child: ListView(
                children: [
                  Container(
                    width: 350,
                    alignment: Alignment.center,
                    child: DropdownEscolas(
                      selecionado: escolaSelecionada,
                      titulo: 'Escolas',
                      lista: escolasLista,
                      largura: 400,
                      larguraContainer: 300,
                      onChanged: (valor){
                        escolaSelecionada = valor;
                        setState(() {});
                        carregarDisciplinas(escolaSelecionada!.idEscola);
                      },
                    ),
                  ),
                  escolaSelecionada==null?Container():
                  Container(
                    width: 350,
                    alignment: Alignment.center,
                    child: DropdownDisciplinas(
                      selecionado: disciplinaSelecionada,
                      titulo: 'Disciplina *',
                      hint: 'Selecione uma disciplina',
                      lista: disciplinasBanco,
                      largura: 400,
                      larguraContainer: 300,
                      onChanged: (valor){
                        disciplinaSelecionada = valor;
                        setState(() {});
                      },
                    ),
                  ),
                  disciplinaSelecionada!=null && escolaSelecionada!=null?Center(
                    child: BotaoPadrao(
                      titulo: 'Abrir Camera',
                      largura: 250,
                      funcao: (){
                        iniciarCamera();
                      }
                    ),
                  ):Container(),
                  const Text('Vídeo da webcam:'),
                  SizedBox(
                    width: 320,
                    height: 240,
                    child: _video != null
                        ? const HtmlElementView(viewType: 'webcam-video')
                        : const Center(child: Text('Webcam não iniciada')),
                  ),
                  const SizedBox(height: 20),
                  aguardando?
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Cores.corPrincipal,),
                          TextoPadrao(texto: 'Verificando...',corTexto: Cores.corPrincipal,)
                        ],
                      ):
                      Text('Resultado: $_resultado',
                        style: TextStyle(
                            color: _resultado!.contains('Confirmada') ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 20
                        ),
                      )
                ],
              ),
            )
          ],
        ),
      )
    );
  }
}
