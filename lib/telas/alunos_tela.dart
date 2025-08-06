import 'dart:async';
import 'dart:convert';
import 'package:controle_chamada_quadritech/modelo/aluno_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/curso_multipla_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/turma_multipla_modelo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../modelo/disciplina_professor_modelo.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';
import 'dart:html' as html;
import 'package:multi_select_flutter/multi_select_flutter.dart';

class AlunosTela extends StatefulWidget {
  const AlunosTela({super.key});

  @override
  State<AlunosTela> createState() => _AlunosTelaState();
}

class _AlunosTelaState extends State<AlunosTela> {

  bool salvando = false;
  bool exibirCampos = false;
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
  List<EscolaModelo> escolasLista = [];
  List<AlunoModelo> alunosLista = [];
  List<CursoMultiplaListaModelo> cursosBanco = [];
  List<TurmaMultiplaListaModelo> turmasBanco = [];
  TextEditingController nome = TextEditingController();
  TextEditingController numeroRegistro = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  String idAluno = '';
  Uint8List? imagemweb;
  String urlImagem = '';
  List<MultiSelectItem> cursosMultiple = [];
  List<MultiSelectItem> turmasMultiple = [];
  List cursosSelecionados = [];
  List turmasSelecionadas = [];

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

  carregarCursos(EscolaModelo escolaSelecionada){
    cursosMultiple.clear();
    List cursos = [];

    FirebaseFirestore.instance.collection('cursos')
        .where('idEscola',isEqualTo: escolaSelecionada!.idEscola)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('curso').get().then((cursosDoc){

      for(int i = 0; cursosDoc.docs.length > i;i++){
        cursos.add( cursosDoc.docs[i]['curso']);
        cursosBanco.add(
            CursoMultiplaListaModelo(
              idEscola: cursosDoc.docs[i]['idEscola'],
              nomeEscola: cursosDoc.docs[i]['nomeEscola'],
              idCurso: cursosDoc.docs[i].id,
              nomeCurso: cursosDoc.docs[i]['curso'],
            )
        );
      }
      cursosMultiple =cursos.map((e) => MultiSelectItem(e, e.toString())).toList();
      if(cursosBanco.isEmpty){
        showSnackBar(context, 'Nenhum curso encontrado', Cores.erro);
      }
      setState(() {});
    });
  }
  carregarTurmas(EscolaModelo escolaSelecionada){
    turmasMultiple.clear();
    List turmas = [];

    FirebaseFirestore.instance.collection('turmas')
        .where('idEscola',isEqualTo: escolaSelecionada!.idEscola)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('turma').get().then((turmasDoc){

      for(int i = 0; turmasDoc.docs.length > i;i++){
        turmas.add( turmasDoc.docs[i]['turma']);
        turmasBanco.add(
            TurmaMultiplaListaModelo(
              idEscola: turmasDoc.docs[i]['idEscola'],
              nomeEscola: turmasDoc.docs[i]['nomeEscola'],
              idCurso: turmasDoc.docs[i]['idCurso'],
              nomeCurso: turmasDoc.docs[i]['nomeCurso'],
              idTurma: turmasDoc.docs[i]['idTurma'],
              nomeTurma: turmasDoc.docs[i]['turma'],
            )
        );
      }
      turmasMultiple = turmas.map((e) => MultiSelectItem(e, e.toString())).toList();
      if(turmasBanco.isEmpty){
        showSnackBar(context, 'Nenhuma turma encontrada', Cores.erro);
      }
      setState(() {});
    });
  }

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
        if(nome.text.length>5){
          if(cursosSelecionados.isNotEmpty){
            if(turmasSelecionadas.isNotEmpty){
              if(imagemweb!=null || urlImagem.isNotEmpty){
                if(imagemweb!=null){
                  salvarFoto();
                }else{
                  idAluno.isEmpty?salvarAluno():editarAluno();
                }
              }else{
                showSnackBar(context, 'Selecione uma foto do rosto do aluno(a) para avançar', Colors.red);
              }
            }else{
              showSnackBar(context, 'Selecione uma turma para avançar', Colors.red);
            }
          }else{
            showSnackBar(context, 'Selecione um curso para avançar', Colors.red);
          }
        }else{
          showSnackBar(context, 'Nome Incompleto', Cores.erro);
        }
    }else{
      showSnackBar(context, 'Selecione uma escola', Cores.erro);
    }
  }

  salvarAluno(){
    salvando = true;
    setState(() {});
    List idCursos = [];
    List idTurmas = [];

    for(int i =0; cursosBanco.length>i;i++){
      if(cursosSelecionados.contains(cursosBanco[i].nomeCurso)){
        idCursos.add(cursosBanco[i].idCurso);
      }
    }
    for(int i =0; turmasBanco.length>i;i++){
      if(turmasSelecionadas.contains(turmasBanco[i].nomeTurma)){
        idTurmas.add(turmasBanco[i].idTurma);
      }
    }

    final docRef = FirebaseFirestore.instance.collection('alunos').doc();
    FirebaseFirestore.instance.collection('alunos').doc(docRef.id).set({
      'idAluno'       : docRef.id,
      'nomeAluno'     : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idCursos'      : idCursos,
      'idTurmas'      : idTurmas,
      'numeroRegistro': numeroRegistro.text,
      'urlImagem'     : urlImagem,
      'status'        : 'ativo',
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      numeroRegistro.clear();
      urlImagem = '';
      imagemweb = null;
      salvando = false;
      cursosSelecionados.clear();
      turmasSelecionadas.clear();
      exibirCampos = false;
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarAluno(){
    salvando = true;
    setState(() {});
    List idCursos = [];
    List idTurmas = [];
    for(int i =0; cursosBanco.length>i;i++){
      if(cursosSelecionados.contains(cursosBanco[i].nomeCurso)){
        idCursos.add(cursosBanco[i].idCurso);
      }
    }

    for(int i =0; turmasBanco.length>i;i++){
      if(turmasSelecionadas.contains(turmasBanco[i].nomeTurma)){
        idTurmas.add(turmasBanco[i].idTurma);
      }
    }
    List aux = idCursos.toSet().toList();
    idCursos = aux;

    FirebaseFirestore.instance.collection('alunos').doc(idAluno).update({
      'nomeAluno'     : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idCursos' : idCursos,
      'idTurmas'      : idTurmas,
      'numeroRegistro': numeroRegistro.text,
      'urlImagem'     : urlImagem,
    }).then((_){
      escolaSelecionadaCadastro = null;
      escolaSelecionadaPesquisa = null;
      pesquisar.clear();
      nome.clear();
      numeroRegistro.clear();
      urlImagem = '';
      imagemweb = null;
      salvando = false;
      cursosSelecionados.clear();
      exibirCampos = false;
      idAluno = '';
      setState(() {});
      showSnackBar(context, 'Alterado com sucesso', Colors.green);
    });
  }

  void pesquisarAluno() async {
    alunosLista.clear();
    exibirCampos = false;

    if (pesquisar.text.length > 0) {
      if (escolaSelecionadaPesquisa != null) {
        String termo = pesquisar.text.toUpperCase();

        QuerySnapshot alunosDoc = await FirebaseFirestore.instance
            .collection('alunos')
            .where('nomeEscola', isEqualTo: escolaSelecionadaPesquisa!.nome)
            .where('status', isNotEqualTo: 'inativo')
            .orderBy('nomeAluno')
            .startAt([termo])
            .endAt(['$termo\uf8ff'])
            .get();

        if (alunosDoc.docs.isEmpty) {
          alunosDoc = await FirebaseFirestore.instance
              .collection('alunos')
              .where('nomeEscola', isEqualTo: escolaSelecionadaPesquisa!.nome)
              .where('status', isNotEqualTo: 'inativo')
              .orderBy('numeroRegistro')
              .startAt([termo])
              .endAt(['$termo\uf8ff'])
              .get();
        }

        for (var doc in alunosDoc.docs) {
          final data = doc.data() as Map<String, dynamic>;
          alunosLista.add(
            AlunoModelo(
              idEscola: doc['idEscola'],
              nomeEscola: doc['nomeEscola'],
              idAluno: doc.id,
              nomeAluno: doc['nomeAluno'],
              numeroRegistro: doc['numeroRegistro'],
              urlImagem: data.containsKey('urlImagem') ? data['urlImagem'] : '',
              idCursos: data.containsKey('idCursos') ? data['idCursos'] : [],
              idTurmas: data.containsKey('idTurmas') ? data['idTurmas'] : [],
            )
          );
        }

        if (alunosLista.isEmpty) {
          showSnackBar(context, 'Nenhum(a) aluno(a) encontrado(a)', Cores.erro);
        }

        setState(() {});
      } else {
        showSnackBar(context, 'Selecione uma escola para pesquisar', Cores.erro);
      }
    } else {
      showSnackBar(context, 'Digite pelo menos 1 caracter para pesquisar', Cores.erro);
    }

    setState(() {});
  }

  preencherCampos(AlunoModelo aluno){
    idAluno = aluno.idAluno;
    nome.text = aluno.nomeAluno;
    numeroRegistro.text = aluno.numeroRegistro;
    urlImagem = aluno.urlImagem;
    List idsCursos = aluno.idCursos;
    List idsTurmas = aluno.idTurmas;

    exibirCampos = true;
    alunosLista.clear();
    for(int i = 0; escolasLista.length>i; i++){
      if(aluno.idEscola == escolasLista[i].idEscola){
        escolaSelecionadaCadastro = escolasLista[i];
        break;
      }
    }
    for (var curso in cursosBanco) {
      for (var id in idsCursos) {
        if (curso.idCurso == id) {
          cursosSelecionados.add(curso.nomeCurso);
        }
      }
    }
    for (var turma in turmasBanco) {
      for (var id in idsTurmas) {
        if (turma.idTurma == id) {
          turmasSelecionadas.add(turma.nomeTurma);
        }
      }
    }
    List auxCurso = cursosSelecionados.toSet().toList();
    cursosSelecionados = auxCurso;
    List auxTurma = turmasSelecionadas.toSet().toList();
    turmasSelecionadas = auxTurma;
    setState(() {});
  }

  exibirExclusao(){
    return showDialog(
        context: context,
        builder: (context){
          return AlertDialog(
            title: TextoPadrao(
              texto: 'Confirmar Exclusão',
              corTexto: Cores.erro,
            ),
            content: TextoPadrao(
              texto: 'Deseja confirmar a exclusão do(a) aluno(a)?',
              corTexto: Cores.erro,
            ),
            actions: [
              BotaoPadrao(
                  titulo: 'Cancelar',
                  corBotao: Colors.green,
                  funcao:(){
                    Navigator.pop(context);
                  }
              ),
              BotaoPadrao(
                  titulo: 'Excluir',
                  corBotao: Cores.erro,
                  funcao:(){
                    apagarAluno();
                  }
              ),
            ],
          );
        }
    );
  }

  apagarAluno(){
    FirebaseFirestore.instance.collection('alunos')
        .doc(idAluno)
        .update({
      'status' : 'inativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      numeroRegistro.clear();
      salvando = false;
      idAluno = '';
      Navigator.pop(context);
      setState(() {});
      showSnackBar(context, 'Excluído com sucesso', Colors.green);
    });
  }

  adionarFoto() {
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();
    html.document.body!.append(uploadInput);
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      final file = files![0];
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) {
        var _bytesData = Base64Decoder().convert(reader.result.toString().split(",").last);
        setState(() {
          imagemweb = _bytesData;
          urlImagem = '';
        });
      });
      reader.readAsDataUrl(file);
    });
    uploadInput.remove();
  }

  carregarAlunos(){
    FirebaseFirestore.instance.collection('alunos').where('idEscola',isEqualTo: escolaSelecionadaPesquisa!.idEscola).get().then((alunosDoc) {
      alunosDoc.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        alunosLista.add(
            AlunoModelo(
              idEscola: doc['idEscola'],
              nomeEscola: doc['nomeEscola'],
              idAluno: doc.id,
              nomeAluno: doc['nomeAluno'],
              numeroRegistro: doc['numeroRegistro'],
              urlImagem: data.containsKey('urlImagem') ? data['urlImagem'] : '',
              idCursos: data.containsKey('idCursos') ? data['idCursos'] : [],
              idTurmas: data.containsKey('idTurmas') ? data['idTurmas'] : [],
            )
        );
      });
      setState(() {});
    });
  }

  salvarFoto() async {
    salvando = true;
    setState(() {});

    String nomeImagem = 'aluno_${DateTime.now().toIso8601String()}.jpg';
    Uint8List arquivoSelecionado = imagemweb!;

    if (arquivoSelecionado.isEmpty) {
      return;
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref('alunos/fotos/').child(nomeImagem);
    UploadTask uploadTaskSnapshot = reference.putData(arquivoSelecionado);

    final TaskSnapshot downloadUrl = await uploadTaskSnapshot;
    urlImagem = (await downloadUrl.ref.getDownloadURL());
    Future.delayed(Duration(seconds: 1),(){
      idAluno.isEmpty?salvarAluno():editarAluno();
    });
  }

  @override
  void initState() {
    super.initState();
    carregarEscolas();
  }

  @override
  Widget build(BuildContext context) {

    double altura = MediaQuery.of(context).size.height;

    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white
            ),
            backgroundColor: Cores.corPrincipal,
            title: TextoPadrao(texto: 'ALUNOS',)
        ),
        body: salvando?Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextoPadrao(texto: 'Salvando ...',corTexto: Cores.corPrincipal,),
              CircularProgressIndicator(color: Cores.corPrincipal,)
            ],
          ),
        ):Container(
          child: Column(
            children: [
              MenuWeb(),
              Container(
                height: altura*0.8,
                width: 680,
                child: ListView(
                  children: [
                    Container(
                      width: 350,
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          exibirCampos?Container(width: 350):Container(
                            width: 350,
                            child: DropdownEscolas(
                              selecionado: escolaSelecionadaPesquisa,
                              titulo: 'Escolas',
                              lista: escolasLista,
                              largura: 400,
                              larguraContainer: 300,
                              onChanged: (valor){
                                escolaSelecionadaPesquisa = valor;
                                pesquisar.clear();
                                carregarAlunos();
                                carregarCursos(escolaSelecionadaPesquisa!);
                                carregarTurmas(escolaSelecionadaPesquisa!);
                                setState(() {});
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              exibirCampos?Container(width: 350,):InputPadrao(
                                controller: pesquisar,
                                titulo: 'Pesquisar pelo nome do(a) aluno(a) ou número de registro',
                                largura: 350,
                              ),
                              SizedBox(width: 20,),
                              exibirCampos?Container(width: 120,):BotaoPadrao(
                                  titulo: 'Pesquisar',
                                  largura: 120,
                                  funcao: (){
                                    pesquisarAluno();
                                  }
                              ),
                              SizedBox(width: 20,),
                              BotaoPadrao(
                                  titulo: exibirCampos?'x':'+',
                                  largura: 50,
                                  funcao: (){
                                    pesquisar.clear();
                                    escolaSelecionadaPesquisa = null;
                                    escolaSelecionadaCadastro = null;
                                    nome.clear();
                                    numeroRegistro.clear();
                                    imagemweb = null;
                                    urlImagem = '';
                                    cursosSelecionados.clear();
                                    turmasSelecionadas.clear();
                                    exibirCampos = !exibirCampos;
                                    setState(() {});
                                  }
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    !exibirCampos?Container(
                      height: 500,
                      width: 500,
                      child: ListView.builder(
                          itemCount: alunosLista.length,
                          itemBuilder: (context,i){
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                              child: ListTile(
                                title: TextoPadrao(
                                  texto: alunosLista[i].nomeAluno,
                                  corTexto: Cores.corPrincipal,
                                  textAling: TextAlign.start,
                                ),
                                onTap: (){
                                  preencherCampos(alunosLista[i]);
                                },
                              ),
                            );
                          }
                      ),
                    ):Container(
                      height: 950,
                      width: 450,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () => adionarFoto(),
                            child: CircleAvatar(
                              backgroundColor: Colors.grey,
                              maxRadius: 50,
                              backgroundImage: urlImagem.isNotEmpty
                                  ? NetworkImage(urlImagem)
                                  : (imagemweb != null ? MemoryImage(imagemweb!) : null) as ImageProvider?,
                              child: imagemweb == null && urlImagem.isEmpty
                                ? Icon(
                                  Icons.add_a_photo,
                                  size: 30,
                                  color: Colors.white,
                                )
                                : null,
                            ),
                          ),
                          Container(
                            width: 485,
                            child: DropdownEscolas(
                              selecionado: escolaSelecionadaCadastro,
                              titulo: 'Escola *',
                              hint: 'Selecione uma escola',
                              lista: escolasLista,
                              largura: 519,
                              larguraContainer: 400,
                              onChanged: (valor){
                                escolaSelecionadaCadastro = valor;
                                carregarCursos(escolaSelecionadaCadastro!);
                                carregarTurmas(escolaSelecionadaCadastro!);
                                setState(() {});
                              },
                            ),
                          ),
                          cursosMultiple.isEmpty?Container():Container(
                            height: cursosSelecionados.isEmpty?80:130,
                            width: 485,
                            alignment:Alignment.bottomCenter,
                            child: ListView(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: TextoPadrao(texto: 'Cursos *',tamanhoTexto: 18,corTexto: Cores.corPrincipal,)
                                ),
                                MultiSelectDialogField(
                                  items: cursosMultiple,
                                  initialValue: cursosSelecionados,
                                  title: Text("Cursos",style: TextStyle(color: Cores.corPrincipal),),
                                  selectedColor: Cores.corPrincipal,
                                  dialogHeight: altura*0.5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.0),
                                      width: 0,
                                    ),
                                  ),
                                  buttonText: Text(
                                    "Selecione o(s) cursos(s)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onConfirm: (results) {
                                    cursosSelecionados.clear();
                                    cursosSelecionados = results;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          turmasMultiple.isEmpty?Container():Container(
                            height: turmasSelecionadas.isEmpty?80:130,
                            width: 485,
                            alignment:Alignment.bottomCenter,
                            child: ListView(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: TextoPadrao(texto: 'Turmas *',tamanhoTexto: 18,corTexto: Cores.corPrincipal,)
                                ),
                                MultiSelectDialogField(
                                  items: turmasMultiple,
                                  initialValue: turmasSelecionadas,
                                  title: Text("Turmas",style: TextStyle(color: Cores.corPrincipal),),
                                  selectedColor: Cores.corPrincipal,
                                  dialogHeight: altura*0.5,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.0),
                                      width: 0,
                                    ),
                                  ),
                                  buttonText: Text(
                                    "Selecione a(s) turma(s)",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                  onConfirm: (results) {
                                    turmasSelecionadas.clear();
                                    turmasSelecionadas = results;
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                          InputPadrao(
                            titulo: 'Nome aluno(a) *',
                            controller: nome,
                            largura: 485,
                          ),
                          InputPadrao(
                            titulo: 'Número Registro',
                            controller: numeroRegistro,
                            largura: 485,
                          ),
                          BotaoPadrao(
                            titulo: idAluno.isEmpty?'Salvar':'Alterar',
                            funcao: (){
                              verificarCampos();
                            },
                          ),
                          idAluno.isNotEmpty?BotaoPadrao(
                            titulo: 'Excluir',
                            corBotao: Cores.erro,
                            funcao: (){
                              exibirExclusao();
                            },
                          ):Container()
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}