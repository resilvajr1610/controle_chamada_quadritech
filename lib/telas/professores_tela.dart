import 'dart:convert';

import 'package:controle_chamada_quadritech/modelo/professor_modelo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../modelo/disciplina_modelo.dart';
import '../modelo/disciplina_professor_modelo.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'dart:html' as html;
import 'package:firebase_storage/firebase_storage.dart';

class ProfessoresTela extends StatefulWidget {
  const ProfessoresTela({super.key});

  @override
  State<ProfessoresTela> createState() => _ProfessoresTelaState();
}

class _ProfessoresTelaState extends State<ProfessoresTela> {

  TextEditingController nome = TextEditingController();
  TextEditingController numeroRegistro = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  bool salvando = false;
  bool exibirCampos = false;
  List<DisciplinaMultiplaListaModelo> disciplinasBanco = [];
  List<EscolaModelo> escolasLista = [];
  List<ProfessorModelo> professoresLista = [];
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
  List disciplinasSelecionadas = [];
  String idProfessor = '';
  List<MultiSelectItem> disciplinaMultiple = [];
  Uint8List? imagemweb;
  String urlImagem = '';

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

  carregarDisciplinasEscola(String idEscola){
    FirebaseFirestore.instance.collection('disciplinas').where('idEscola',isEqualTo: idEscola).get().then((disciplinasDoc) {
      List disciplinas = [];
      disciplinasDoc.docs.forEach((doc) {
        disciplinas.add(doc['nomeDisciplina']);
        disciplinasBanco.add(
            DisciplinaMultiplaListaModelo(
              idEscola: doc['idEscola'],
              nomeEscola: doc['nomeEscola'],
              idDisciplina: doc.id,
              nomeDisciplina: doc['nomeDisciplina'],
          )
        );
      });
      disciplinaMultiple =disciplinas.map((e) => MultiSelectItem(e, e.toString())).toList();
      setState(() {});
    });
  }

  carregarProfessor(String idEscola){
    professoresLista.clear();
    FirebaseFirestore.instance.collection('professores').where('idEscola',isEqualTo: idEscola).get().then((profDocs) {
      profDocs.docs.forEach((doc) {
        final data = doc.data() as Map<String, dynamic>;
        professoresLista.add(
            ProfessorModelo(
              idProf: doc.id,
              nomeProf: doc['nomeProf'],
              idEscola: doc['idEscola'],
              nomeEscola: doc['nomeEscola'],
              numeroRegistro: doc['numeroRegistro'],
              idDisciplinas: doc['idDisciplinas'],
              urlImagem: data.containsKey('urlImagem') ? data['urlImagem'] : '',
            )
        );
      });
      setState(() {});
    });
  }

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
      if(disciplinasSelecionadas.isNotEmpty){
        if(nome.text.length>5){
          if(imagemweb!=null || urlImagem.isNotEmpty){
            if(imagemweb!=null){
              salvarFoto();
            }else{
              idProfessor.isEmpty?salvarProfessor():editarProfessor();
            }
          }else{
            showSnackBar(context, 'Selecione uma foto do rosto do aluno(a) para avançar', Colors.red);
          }
        }else{
          showSnackBar(context, 'Nome Incompleto', Cores.erro);
        }
      }else{
        showSnackBar(context, 'Selecione pelo menos uma disciplina', Cores.erro);
      }
    }else{
      showSnackBar(context, 'Selecione uma escola', Cores.erro);
    }
  }

  salvarProfessor(){
    salvando = true;
    setState(() {});
    List idDisciplinas = [];

    for(int i =0; disciplinasBanco.length>i;i++){
      if(disciplinasSelecionadas.contains(disciplinasBanco[i].nomeDisciplina)){
        idDisciplinas.add(disciplinasBanco[i].idDisciplina);
      }
    }
    final docRef = FirebaseFirestore.instance.collection('professores').doc();
    FirebaseFirestore.instance.collection('professores').doc(docRef.id).set({
      'idProf'        : docRef.id,
      'nomeProf'      : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplinas' : idDisciplinas,
      'numeroRegistro': numeroRegistro.text,
      'urlImagem'     : urlImagem,
      'status'          : 'ativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      disciplinasSelecionadas = [];
      nome.clear();
      numeroRegistro.clear();
      salvando = false;
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarProfessor(){
    salvando = true;
    setState(() {});
    List idDisciplinas = [];
    for(int i =0; disciplinasBanco.length>i;i++){
      if(disciplinasSelecionadas.contains(disciplinasBanco[i].nomeDisciplina)){
        idDisciplinas.add(disciplinasBanco[i].idDisciplina);
      }
    }
    List aux = idDisciplinas.toSet().toList();
    idDisciplinas = aux;

    FirebaseFirestore.instance.collection('professores').doc(idProfessor).update({
      'nomeProf'      : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplinas' : idDisciplinas,
      'numeroRegistro': numeroRegistro.text,
      'urlImagem'     : urlImagem,
    }).then((_){
      escolaSelecionadaCadastro = null;
      escolaSelecionadaPesquisa = null;
      disciplinasSelecionadas = [];
      nome.clear();
      numeroRegistro.clear();

      idProfessor = '';
      salvando = false;
      setState(() {});
      showSnackBar(context, 'Alterado com sucesso', Colors.green);
    });
  }

  pesquisarProfessor(){
    professoresLista.clear();
    exibirCampos = false;
    if(pesquisar.text.length>2){
      if(escolaSelecionadaPesquisa!=null){
        FirebaseFirestore.instance.collection('professores')
            .where('nomeEscola',isEqualTo: escolaSelecionadaPesquisa!.nome)
            .where('status',isNotEqualTo: 'inativo')
            .orderBy('nomeProf')
            .startAt([pesquisar.text.toUpperCase()])
            .endAt(['${pesquisar.text.toUpperCase()}\uf8ff']).get().then((professoresDoc){

          for(int i = 0; professoresDoc.docs.length > i;i++){
            final data = professoresDoc.docs[i].data() as Map<String, dynamic>;
            professoresLista.add(
                ProfessorModelo(
                  idEscola: professoresDoc.docs[i]['idEscola'],
                  nomeEscola: professoresDoc.docs[i]['nomeEscola'],
                  idProf: professoresDoc.docs[i].id,
                  nomeProf: professoresDoc.docs[i]['nomeProf'],
                  idDisciplinas: professoresDoc.docs[i]['idDisciplinas'],
                  numeroRegistro:  professoresDoc.docs[i]['numeroRegistro'],
                  urlImagem: data.containsKey('urlImagem') ? data['urlImagem'] : '',
                )
            );
          }
          print(professoresLista.length);
          if(professoresLista.isEmpty){
            showSnackBar(context, 'Nenhum(a) professor(a) encontrado(a)', Cores.erro);
          }
          setState(() {});
        });
      }else{
        showSnackBar(context, 'Selecione uma escola para pesquisar', Cores.erro);
      }
    }else{
      showSnackBar(context, 'Digite pelo menos 3 caracteres para pesquisar', Cores.erro);
    }
    setState(() {});
  }

  preencherCampos(ProfessorModelo professor){
    idProfessor = professor.idProf;
    nome.text = professor.nomeProf;
    urlImagem = professor.urlImagem;
    numeroRegistro.text = professor.numeroRegistro;
    List idsDisciplinas = professor.idDisciplinas;
    exibirCampos = true;
    professoresLista.clear();
    for(int i = 0; escolasLista.length>i; i++){
      if(professor.idEscola == escolasLista[i].idEscola){
        escolaSelecionadaCadastro = escolasLista[i];
        break;
      }
    }
    for (var disciplina in disciplinasBanco) {
      for (var id in idsDisciplinas) {
        if (disciplina.idDisciplina == id) {
          disciplinasSelecionadas.add(disciplina.nomeDisciplina);
        }
      }
    }
    List aux = disciplinasSelecionadas.toSet().toList();
    disciplinasSelecionadas = aux;
    print('disciplinas professor: $disciplinasSelecionadas');
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
              texto: 'Deseja confirmar a exclusão do(a) professor(a)?',
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
                    apagarProfessor();
                  }
              ),
            ],
          );
        }
    );
  }

  apagarProfessor(){
    FirebaseFirestore.instance.collection('professores')
        .doc(idProfessor)
        .update({
      'status' : 'inativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      disciplinasSelecionadas = [];
      nome.clear();
      numeroRegistro.clear();
      salvando = false;
      idProfessor = '';
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

  salvarFoto() async {
    salvando = true;
    setState(() {});

    String nomeImagem = 'aluno_${DateTime.now().toIso8601String()}.jpg';
    Uint8List arquivoSelecionado = imagemweb!;

    if (arquivoSelecionado.isEmpty) {
      return;
    }

    FirebaseStorage storage = FirebaseStorage.instance;
    Reference reference = storage.ref('professores/fotos/').child(nomeImagem);
    UploadTask uploadTaskSnapshot = reference.putData(arquivoSelecionado);

    final TaskSnapshot downloadUrl = await uploadTaskSnapshot;
    urlImagem = (await downloadUrl.ref.getDownloadURL());
    Future.delayed(Duration(seconds: 1),(){
      idProfessor.isEmpty?salvarProfessor():editarProfessor();
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
            title: TextoPadrao(texto: 'CADASTRO DE PROFESSORES',)
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
                                carregarDisciplinasEscola(escolaSelecionadaPesquisa!.idEscola);
                                carregarProfessor(escolaSelecionadaPesquisa!.idEscola);
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
                                titulo: 'Pesquisar pelo nome do(a) professor(a)',
                                largura: 350,
                              ),
                              SizedBox(width: 20,),
                              exibirCampos?Container(width: 120,):BotaoPadrao(
                                  titulo: 'Pesquisar',
                                  largura: 120,
                                  funcao: (){
                                    pesquisarProfessor();
                                  }
                              ),
                              SizedBox(width: 20,),
                              BotaoPadrao(
                                  titulo: exibirCampos?'x':'+',
                                  largura: 50,
                                  funcao: (){
                                    pesquisar.clear();
                                    exibirCampos = !exibirCampos;
                                    escolaSelecionadaPesquisa = null;
                                    escolaSelecionadaCadastro = null;
                                    nome.clear();
                                    numeroRegistro.clear();
                                    disciplinasSelecionadas.clear();
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
                          itemCount: professoresLista.length,
                          itemBuilder: (context,i){
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                              child: ListTile(
                                title: TextoPadrao(
                                  texto: professoresLista[i].nomeProf,
                                  corTexto: Cores.corPrincipal,
                                  textAling: TextAlign.start,
                                ),
                                onTap: (){
                                  preencherCampos(professoresLista[i]);
                                },
                              ),
                            );
                          }
                      ),
                    ):Container(
                      height: 755,
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
                            width: 500,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 250,
                                  child: DropdownEscolas(
                                    selecionado: escolaSelecionadaCadastro,
                                    titulo: 'Escola *',
                                    hint: 'Selecione uma escola',
                                    lista: escolasLista,
                                    largura: 250,
                                    larguraContainer: 200,
                                    onChanged: (valor){
                                      escolaSelecionadaCadastro = valor;
                                      setState(() {});
                                      carregarDisciplinasEscola(escolaSelecionadaCadastro!.idEscola);
                                    },
                                  ),
                                ),
                                disciplinaMultiple.isEmpty?Container():Container(
                                  height: disciplinasSelecionadas.isEmpty?80:(80+(disciplinasSelecionadas.length.toDouble()*40)),
                                  width: 250,
                                  alignment:Alignment.bottomCenter,
                                  child: ListView(
                                    children: [
                                      TextoPadrao(texto: 'Disciplinas *',tamanhoTexto: 18,corTexto: Cores.corPrincipal,),
                                      MultiSelectDialogField(
                                        items: disciplinaMultiple,
                                        initialValue: disciplinasSelecionadas,
                                        title: Text("Disciplinas",style: TextStyle(color: Cores.corPrincipal),),
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
                                          "Selecione a(s) disciplina(s)",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16,
                                          ),
                                        ),
                                        onConfirm: (results) {
                                          disciplinasSelecionadas.clear();
                                          disciplinasSelecionadas = results;
                                          setState(() {});
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          InputPadrao(
                            titulo: 'Nome professor(a) *',
                            controller: nome,
                            largura: 485,
                          ),
                          InputPadrao(
                            titulo: 'Número Registro',
                            controller: numeroRegistro,
                            largura: 485,
                          ),
                          BotaoPadrao(
                            titulo: idProfessor.isEmpty?'Salvar':'Alterar',
                            funcao: (){
                              verificarCampos();
                            },
                          ),
                          idProfessor.isNotEmpty?BotaoPadrao(
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
