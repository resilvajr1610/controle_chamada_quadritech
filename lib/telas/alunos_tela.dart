import 'dart:async';
import 'dart:convert';
import 'package:controle_chamada_quadritech/modelo/aluno_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/disciplina_modelo.dart';
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
import 'package:brasil_fields/brasil_fields.dart';
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
  List<DisciplinaMultiplaListaModelo> disciplinasBanco = [];
  TextEditingController nome = TextEditingController();
  TextEditingController ensino = TextEditingController();
  TextEditingController curso = TextEditingController();
  TextEditingController ano = TextEditingController();
  TextEditingController endereco = TextEditingController();
  TextEditingController numero = TextEditingController();
  TextEditingController bairro = TextEditingController();
  TextEditingController cidade = TextEditingController();
  TextEditingController idade = TextEditingController();
  TextEditingController cep = TextEditingController();
  TextEditingController sexo = TextEditingController();
  TextEditingController numeroRegistro = TextEditingController();
  TextEditingController estadoCivil = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  String idAluno = '';
  Uint8List? imagemweb;
  String urlImagem = '';
  List<MultiSelectItem> disciplinaMultiple = [];
  List disciplinasSelecionadas = [];

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

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
        if(nome.text.length>5){
          if(curso.text.length>2){
            if(ano.text.length==4){
              if(ensino.text.length>2){
                  if(endereco.text.length>2){
                    if(numero.text.isNotEmpty){
                      if(bairro.text.length>2){
                        if(cidade.text.length>2){
                          if(cep.text.length==10){
                            if(estadoCivil.text.length>2){
                              if(idade.text.isNotEmpty){
                                if(sexo.text.length>2){
                                  if(disciplinasSelecionadas.isNotEmpty){
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
                                    showSnackBar(context, 'Selecione uma disciplina para avançar', Colors.red);
                                  }
                                }else{
                                  showSnackBar(context, 'Sexo Incompleto', Cores.erro);
                                }
                              }else{
                                showSnackBar(context, 'Idade Incompleta', Cores.erro);
                              }
                            }else{
                              showSnackBar(context, 'Estado Cívil Incompleto', Cores.erro);
                            }
                          }else{
                            showSnackBar(context, 'CEP Incompleto', Cores.erro);
                          }
                        }else{
                          showSnackBar(context, 'Cidade Incompleta', Cores.erro);
                        }
                      }else{
                        showSnackBar(context, 'Bairro Incompleto', Cores.erro);
                      }
                    }else{
                      showSnackBar(context, 'Número Incompleto', Cores.erro);
                    }
                  }else{
                    showSnackBar(context, 'Endereço Incompleto', Cores.erro);
                  }
              }else{
                showSnackBar(context, 'Ensino Incompleto', Cores.erro);
              }
            }else{
              showSnackBar(context, 'Ano Incompleto', Cores.erro);
            }
          }else{
            showSnackBar(context, 'Curso Incompleto', Cores.erro);
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
    List idDisciplinas = [];

    for(int i =0; disciplinasBanco.length>i;i++){
      if(disciplinasSelecionadas.contains(disciplinasBanco[i].nomeDisciplina)){
        idDisciplinas.add(disciplinasBanco[i].idDisciplina);
      }
    }

    final docRef = FirebaseFirestore.instance.collection('alunos').doc();
    FirebaseFirestore.instance.collection('alunos').doc(docRef.id).set({
      'idAluno'       : docRef.id,
      'nomeAluno'     : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplinas' : idDisciplinas,
      'bairro'        : bairro.text.toUpperCase(),
      'cep'           : cep.text,
      'cidade'        : cidade.text.toUpperCase(),
      'idade'         : int.parse(idade.text),
      'endereco'      : endereco.text.toUpperCase(),
      'numero'        : int.parse(numero.text),
      'numeroRegistro': numeroRegistro.text,
      'curso'         : curso.text.toUpperCase(),
      'ano'           : int.parse(ano.text),
      'ensino'        : ensino.text.toUpperCase(),
      'estadoCivil'   : estadoCivil.text.toUpperCase(),
      'sexo'          : sexo.text.toUpperCase(),
      'urlImagem'     : urlImagem,
      'status'        : 'ativo',
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      curso.clear();
      bairro.clear();
      cep.clear();
      cidade.clear();
      idade.clear();
      endereco.clear();
      numero.clear();
      numeroRegistro.clear();
      estadoCivil.clear();
      ano.clear();
      ensino.clear();
      urlImagem = '';
      imagemweb = null;
      salvando = false;
      disciplinasSelecionadas.clear();
      exibirCampos = false;
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarAluno(){
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

    FirebaseFirestore.instance.collection('alunos').doc(idAluno).update({
      'nomeAluno'     : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplinas' : idDisciplinas,
      'bairro'        : bairro.text.toUpperCase(),
      'cep'           : cep.text,
      'cidade'        : cidade.text.toUpperCase(),
      'idade'         : int.parse(idade.text),
      'endereco'      : endereco.text.toUpperCase(),
      'numero'        : int.parse(numero.text),
      'numeroRegistro': numeroRegistro.text,
      'curso'         : curso.text.toUpperCase(),
      'ano'           : int.parse(ano.text),
      'ensino'        : ensino.text.toUpperCase(),
      'estadoCivil'   : estadoCivil.text.toUpperCase(),
      'sexo'          : sexo.text.toUpperCase(),
      'urlImagem'     : urlImagem,
    }).then((_){
      escolaSelecionadaCadastro = null;
      escolaSelecionadaPesquisa = null;
      pesquisar.clear();
      nome.clear();
      curso.clear();
      bairro.clear();
      cep.clear();
      cidade.clear();
      idade.clear();
      endereco.clear();
      numero.clear();
      numeroRegistro.clear();
      estadoCivil.clear();
      ano.clear();
      ensino.clear();
      urlImagem = '';
      imagemweb = null;
      salvando = false;
      disciplinasSelecionadas.clear();
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
              cep: doc['cep'],
              cidade: doc['cidade'],
              bairro: doc['bairro'],
              numero: doc['numero'],
              endereco: doc['endereco'],
              numeroRegistro: doc['numeroRegistro'],
              estadoCivil: doc['estadoCivil'],
              idade: doc['idade'],
              curso: doc['curso'],
              ano: doc['ano'],
              ensino: doc['ensino'],
              sexo: doc['sexo'],
              idDisciplinas: data.containsKey('idDisciplinas') ? data['idDisciplinas'] : [],
              urlImagem: data.containsKey('urlImagem') ? data['urlImagem'] : '',
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
    bairro.text = aluno.bairro;
    cep.text = aluno.cep;
    cidade.text = aluno.cidade;
    endereco.text = aluno.endereco;
    numero.text = aluno.numero.toString();
    numeroRegistro.text = aluno.numeroRegistro;
    estadoCivil.text = aluno.estadoCivil;
    idade.text = aluno.idade.toString();
    ensino.text = aluno.ensino;
    curso.text = aluno.curso;
    sexo.text = aluno.sexo;
    ano.text = aluno.ano.toString();
    urlImagem = aluno.urlImagem;
    List idsDisciplinas = aluno.idDisciplinas;

    exibirCampos = true;
    alunosLista.clear();
    for(int i = 0; escolasLista.length>i; i++){
      if(aluno.idEscola == escolasLista[i].idEscola){
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
      estadoCivil.clear();
      idade.clear();
      curso.clear();
      ano.clear();
      endereco.clear();
      numero.clear();
      bairro.clear();
      cidade.clear();
      ensino.clear();
      sexo.clear();
      cep.clear();
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
            title: TextoPadrao(texto: 'CADASTRO DE ALUNOS',)
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
                                    estadoCivil.clear();
                                    idade.clear();
                                    curso.clear();
                                    ano.clear();
                                    ensino.clear();
                                    sexo.clear();
                                    endereco.clear();
                                    numero.clear();
                                    bairro.clear();
                                    cidade.clear();
                                    cep.clear();
                                    numeroRegistro.clear();
                                    imagemweb = null;
                                    urlImagem = '';
                                    disciplinasSelecionadas.clear();
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
                                carregarDisciplinasEscola(escolaSelecionadaCadastro!.idEscola);
                                setState(() {});
                              },
                            ),
                          ),
                          disciplinaMultiple.isEmpty?Container():Container(
                            height: disciplinasSelecionadas.isEmpty?80:130,
                            width: 485,
                            alignment:Alignment.bottomCenter,
                            child: ListView(
                              children: [
                                Container(
                                  alignment: Alignment.bottomLeft,
                                  child: TextoPadrao(texto: 'Disciplinas *',tamanhoTexto: 18,corTexto: Cores.corPrincipal,)
                                ),
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
                          ),
                          InputPadrao(
                            titulo: 'Nome aluno(a) *',
                            controller: nome,
                            largura: 485,
                          ),
                          Container(
                            width: 485,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'Estado Cívil *',
                                  controller: estadoCivil,
                                  largura: 230,
                                ),
                                InputPadrao(
                                  titulo: 'Idade *',
                                  controller: idade,
                                  largura: 230,
                                  textInputType: TextInputType.number,
                                  maximoCaracteres: 2,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 485,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'Curso *',
                                  controller: curso,
                                  largura: 230,
                                ),
                                InputPadrao(
                                  titulo: 'Ano *',
                                  controller: ano,
                                  largura: 230,
                                  textInputType: TextInputType.number,
                                  maximoCaracteres: 4,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 485,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'Ensino *',
                                  controller: ensino,
                                  largura: 230,
                                ),
                                InputPadrao(
                                  titulo: 'Sexo *',
                                  controller: sexo,
                                  largura: 230,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 490,
                            child:
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'Endereço *',
                                  controller: endereco,
                                  largura: 370,
                                ),
                                InputPadrao(
                                  titulo: 'Número *',
                                  controller: numero,
                                  largura: 100,
                                  textInputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 485,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'Bairro *',
                                  controller: bairro,
                                  largura: 230,
                                ),
                                InputPadrao(
                                  titulo: 'Cidade *',
                                  controller: cidade,
                                  largura: 230,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 485,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'CEP *',
                                  controller: cep,
                                  largura: 230,
                                  textInputType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CepInputFormatter()
                                  ],
                                ),
                                InputPadrao(
                                  titulo: 'Número Registro',
                                  controller: numeroRegistro,
                                  largura: 230,
                                ),
                              ],
                            ),
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