import 'dart:async';
import 'dart:convert';
import 'package:controle_chamada_quadritech/modelo/professor_modelo.dart';
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
import 'package:firebase_storage/firebase_storage.dart';
import '../widgets/dropdown_professores.dart';

class ReconhecimentoTela extends StatefulWidget {
  const ReconhecimentoTela({super.key});

  @override
  State<ReconhecimentoTela> createState() => _ReconhecimentoTelaState();
}

class _ReconhecimentoTelaState extends State<ReconhecimentoTela> {

  List<EscolaModelo> escolasLista = [];
  List<ProfessorModelo> professoresLista = [];
  List<DisciplinaModelo> disciplinasLista = [];
  EscolaModelo? escolaSelecionada;
  ProfessorModelo? professorSelecionado;
  DisciplinaModelo? disciplinaSelecionada;
  html.VideoElement? _video;
  html.MediaStream? _mediaStream;
  Timer? _timer;
  String _resultado = '';
  bool aguardando = false;
  bool travarOpcoes = false;
  String viewId = '';
  String status = 'Verificando...';

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

  carregarProfessores(String idEscola){

    professoresLista.clear();
    professorSelecionado = null;
    setState(() {});
    FirebaseFirestore.instance.collection('professores')
        .where('idEscola',isEqualTo: idEscola)
        .where('status',isEqualTo: 'ativo')
        .orderBy('nomeProf')
        .get()
        .then((professoresDoc){

      for(int i = 0; professoresDoc.docs.length > i;i++){
        professoresLista.add(
            ProfessorModelo(
              idProf: professoresDoc.docs[i].id,
              nomeProf: professoresDoc.docs[i]['nomeProf'],
              idEscola: professoresDoc.docs[i]['idEscola'],
              nomeEscola: professoresDoc.docs[i]['nomeEscola'],
              idDisciplinas: professoresDoc.docs[i]['idDisciplinas'],
              numeroRegistro: '',
              urlImagem: ''
            )
        );
      }
      setState(() {});
    });
  }

  buscarDisciplinas(String idEscola, List idDisciplinas){
    FirebaseFirestore.instance.collection('disciplinas')
        .where('idEscola',isEqualTo: idEscola)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('nomeDisciplina').get().then((escolasDoc){

      for(int i = 0; escolasDoc.docs.length > i;i++){
       if(idDisciplinas.contains(escolasDoc.docs[i].id)){
         disciplinasLista.add(
             DisciplinaModelo(
               idEscola: escolasDoc.docs[i]['idEscola'],
               nomeEscola: escolasDoc.docs[i]['nomeEscola'],
               idDisciplina: escolasDoc.docs[i].id,
               nomeDisciplina: escolasDoc.docs[i]['nomeDisciplina'],
               curso: escolasDoc.docs[i]['curso'],
               ano: escolasDoc.docs[i]['ano'],
               ensino: escolasDoc.docs[i]['ensino'],
             )
         );
       }
      }
      if(disciplinasLista.isEmpty){
        showSnackBar(context, 'Nenhuma disciplina encontrada', Cores.erro);
      }
      setState(() {});
    });
    setState(() {});
  }

  Future<void> iniciarCamera() async {
    if (_video != null) return;

    _video = html.VideoElement()
      ..autoplay = true
      ..width = 390
      ..height = 300
      ..style.width = '390px'
      ..style.height = '300px';

    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => _video!,
    );
    travarOpcoes = true;
    setState(() {});

    _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia({'video': true});

    _video!.srcObject = _mediaStream;
    final canvas = html.CanvasElement(width: 390, height: 300);

    Timer.periodic(const Duration(seconds: 10), (_) async {
      aguardando = true;
      status = 'Verificando...';
      if (!mounted) return;
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
        if (!mounted) return;

        aguardando = false;
        setState(() {});
      }
    });
  }

  Future<String> comparar(Uint8List frame) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://localhost:5000/verificar'),
        // Uri.parse('https://presenca.quadritech.com.br/valida'),
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

      print('resultado: $body');

      if (response.statusCode == 200) {
        final data = jsonDecode(body);
        final verificado = data['verificado'] ?? false;
        if(verificado){
          int diferenca = await verificarDiferencaUltimaPresenca(data['id']);
          if(diferenca>=10){
            String situacao = await obterProximaSituacao(data['id']);
            status = 'salvando captura ...';
            aguardando = true;
            salvarFoto(data,situacao,frame);
          }else{
            showSnackBar(context, 'Aluno(a) ${data['aluno']} registrado nos ultimos 10 minutos', Colors.blue);
          }
        }else{
          showSnackBar(context, 'Aluno(a) não reconhecido\n Tente centralizar melhor o rosto e verifique a luz do ambiente!', Colors.red);
        }
        return '';
      } else {
        print('Erro na comparação: $body');
        return '';
      }
    } catch (e) {
      showSnackBar(context, 'Erro de rede ou no servidor', Colors.red);
      print('Erro na requisição: $e');
      return '';
    }
  }

  Future<String> obterProximaSituacao(String id) async {
    final agora = DateTime.now();
    final inicioDoDia = DateTime(agora.year, agora.month, agora.day);

    // Busca apenas os registros daquele aluno, daquela disciplina, no dia atual
    final snapshot = await FirebaseFirestore.instance
        .collection('presencas')
        .where('id', isEqualTo: id)
        .where('idDisciplina', isEqualTo: disciplinaSelecionada!.idDisciplina)
        .where('dataHora', isGreaterThanOrEqualTo: Timestamp.fromDate(inicioDoDia))
        .orderBy('dataHora', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Nenhum registro hoje para essa disciplina -> começa com ENTRADA 1
      return 'ENTRADA 1';
    }

    final ultimo = snapshot.docs.first;
    final String ultimaSituacao = ultimo['situacao'];

    final partes = ultimaSituacao.split(' ');
    final tipo = partes[0]; // ENTRADA ou SAIDA
    final numero = int.tryParse(partes[1]) ?? 1;

    if (tipo == 'ENTRADA') {
      return 'SAIDA $numero';
    } else {
      return 'ENTRADA ${numero + 1}';
    }
  }

  registrarPresenca(Map resposta, String situacao, Uint8List frame,String urlImagem){
    final docRef = FirebaseFirestore.instance.collection('presencas').doc();
    FirebaseFirestore.instance.collection('presencas').doc(docRef.id).set({
      'idPresenca'    : docRef.id,
      'idDisciplina'  : disciplinaSelecionada!.idDisciplina,
      'nomeDisciplina': disciplinaSelecionada!.nomeDisciplina,
      'idEscola'      : escolaSelecionada!.idEscola,
      'nomeEscola'    : escolaSelecionada!.nome,
      'idProfessor'   : professorSelecionado!.idProf,
      'nomeProfessor' : professorSelecionado!.nomeProf,
      'nome'          : resposta['nome'],
      'idReconhecido' : resposta['id'],
      'dataHora'      : DateTime.now(),
      'situacao'      : situacao,
      'urlImagem'     : urlImagem,
      'tipo'          : resposta['tipo']
    });
    status = '';
    showSnackBar(context, 'Presença Registrada para o(a) aluno(a) ${resposta['aluno']}', Colors.green);
  }

  salvarFoto(Map resposta, String situacao, Uint8List frame) async {
    setState(() {});

    String nomeImagem = 'reconhecimento_${DateTime.now().toIso8601String()}.jpg';
    Uint8List arquivoSelecionado = frame!;

    if (arquivoSelecionado.isEmpty) {
      return;
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref('reconhecimento/${resposta['tipo']}/fotos/').child(nomeImagem);
    UploadTask uploadTaskSnapshot = reference.putData(arquivoSelecionado);
    final TaskSnapshot downloadUrl = await uploadTaskSnapshot;
    String urlImagem = (await downloadUrl.ref.getDownloadURL());
    registrarPresenca(resposta,situacao,frame,urlImagem);
  }

  Future<int> verificarDiferencaUltimaPresenca(String id) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('presencas')
        .where('id', isEqualTo: id)
        .where('idDisciplina', isEqualTo: disciplinaSelecionada!.idDisciplina)
        .orderBy('dataHora', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 10;
    }

    final ultimoRegistro = snapshot.docs.first;
    final Timestamp timestamp = ultimoRegistro['dataHora'];
    final DateTime dataUltimaPresenca = timestamp.toDate();
    final DateTime agora = DateTime.now();

    int difMinutos = agora.difference(dataUltimaPresenca).inMinutes;
    print('Diferença: ${difMinutos} minutos');
    return difMinutos;
  }

  @override
  void initState() {
    super.initState();
    viewId = 'webcam-video-${DateTime.now().millisecondsSinceEpoch}';
    carregarEscolas();
  }
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  void dispose() {
    _timer?.cancel();
    _mediaStream?.getTracks().forEach((t) => t.stop());
    _video = null;
    scaffoldMessengerKey.currentState?.clearSnackBars();
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
              child: Column(
                children: [
                  Container(
                    width: 350,
                    alignment: Alignment.center,
                    child: DropdownEscolas(
                      selecionado: escolaSelecionada,
                      titulo: 'Escola *',
                      lista: escolasLista,
                      largura: 400,
                      larguraContainer: 300,
                      onChanged: travarOpcoes?null:(valor){
                        escolaSelecionada = valor;
                        setState(() {});
                        carregarProfessores(escolaSelecionada!.idEscola);
                      },
                    ),
                  ),
                  escolaSelecionada==null?Container():
                  Container(
                    width: 350,
                    alignment: Alignment.center,
                    child: DropdownProfessores(
                      selecionado: professorSelecionado,
                      titulo: 'Professor *',
                      hint: 'Selecione um(a) professor(a)',
                      lista: professoresLista,
                      largura: 400,
                      larguraContainer: 300,
                      onChanged: travarOpcoes?null:(valor){
                        professorSelecionado = valor;
                        buscarDisciplinas(professorSelecionado!.idEscola, professorSelecionado!.idDisciplinas);
                        setState(() {});
                      },
                    ),
                  ),
                  professorSelecionado == null?Container():Container(
                    width: 350,
                    child: DropdownDisciplinas(
                      selecionado: disciplinaSelecionada,
                      titulo: 'Disciplina *',
                      lista: disciplinasLista,
                      largura: 400,
                      larguraContainer: 300,
                      onChanged:travarOpcoes?null: (valor){
                        disciplinaSelecionada = valor;
                        print(disciplinaSelecionada!.idDisciplina);
                        print(disciplinaSelecionada!.nomeDisciplina);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  professorSelecionado!=null && escolaSelecionada!=null && disciplinaSelecionada!= null?Center(
                    child: travarOpcoes?Container():BotaoPadrao(
                      titulo: 'Abrir Camera',
                      largura: 250,
                      funcao: (){
                        iniciarCamera();
                      }
                    ),
                  ):Container(),
                  Container(
                    alignment: Alignment.center,
                    width: 390,
                    height: 300,
                    child: _video != null
                        ? HtmlElementView(viewType: viewId)
                        : Container(),
                  ),
                  const SizedBox(height: 20),
                  aguardando?
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Cores.corPrincipal,),
                          TextoPadrao(texto: status,corTexto: Cores.corPrincipal,)
                        ],
                      ):
                      Text('$_resultado',
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
