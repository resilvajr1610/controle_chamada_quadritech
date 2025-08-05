import 'package:controle_chamada_quadritech/modelo/disciplina_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/escola_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/turma_modelo.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_cursos.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_escolas.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_turmas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../modelo/curso_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisciplinasTela extends StatefulWidget {
  const DisciplinasTela({super.key});

  @override
  State<DisciplinasTela> createState() => _DisciplinasTelaState();
}

class _DisciplinasTelaState extends State<DisciplinasTela> {

  TextEditingController nome = TextEditingController();
  TextEditingController ano = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  bool salvando = false;
  bool exibirCampos = false;
  List<EscolaModelo> escolasLista = [];
  List<CursoModelo> cursosLista = [];
  List<DisciplinaModelo> disciplinasLista = [];
  List<TurmaModelo> turmasLista = [];
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
  CursoModelo? cursoSelecionadoPesquisa;
  CursoModelo? cursoSelecionadoCadastro;
  TurmaModelo? turmaSelecionadaPesquisa;
  TurmaModelo? turmaSelecionadaCadastro;

  String idDisciplina = '';

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

  carregarCurso(EscolaModelo escolaSelecionada){
    turmasLista.clear();
    cursosLista.clear();
    cursoSelecionadoPesquisa = null;
    cursoSelecionadoCadastro = null;
    turmaSelecionadaCadastro = null;
    turmaSelecionadaPesquisa = null;

    FirebaseFirestore.instance.collection('cursos')
        .where('nomeEscola',isEqualTo: escolaSelecionada!.nome)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('curso').get().then((cursosDoc){

      for(int i = 0; cursosDoc.docs.length > i;i++){
        cursosLista.add(
            CursoModelo(
              idEscola: cursosDoc.docs[i]['idEscola'],
              nomeEscola: cursosDoc.docs[i]['nomeEscola'],
              idCurso: cursosDoc.docs[i].id,
              nomeCurso: cursosDoc.docs[i]['curso'],
            )
        );
      }
      print(cursosLista.length);
      if(cursosLista.isEmpty){
        showSnackBar(context, 'Nenhum curso encontrado', Cores.erro);
      }
      setState(() {});
    });
  }

  carregarTurmas(CursoModelo cursoSelecionado){
    turmasLista.clear();
    FirebaseFirestore.instance.collection('turmas')
        .where('idEscola',isEqualTo: cursoSelecionado!.idEscola)
        .where('idCurso',isEqualTo: cursoSelecionado!.idCurso)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('turma').get().then((turmasDoc){

      for(int i = 0; turmasDoc.docs.length > i;i++){
        turmasLista.add(
            TurmaModelo(
              idEscola: turmasDoc.docs[i]['idEscola'],
              nomeEscola: turmasDoc.docs[i]['nomeEscola'],
              idCurso: turmasDoc.docs[i]['idCurso'],
              nomeCurso: turmasDoc.docs[i]['nomeCurso'],
              idTurma: turmasDoc.docs[i]['idTurma'],
              nomeTurma: turmasDoc.docs[i]['turma'],
            )
        );
      }
      if(turmasLista.isEmpty){
        showSnackBar(context, 'Nenhuma turma encontrada', Cores.erro);
      }
      setState(() {});
    });
  }

  carregarDisciplinas(TurmaModelo turmaSelecionada){
    disciplinasLista.clear();
    FirebaseFirestore.instance.collection('disciplinas')
        .where('idEscola',isEqualTo: turmaSelecionada!.idEscola)
        .where('idCurso',isEqualTo: turmaSelecionada!.idCurso)
        .where('idTurma',isEqualTo: turmaSelecionada!.idTurma)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('nomeDisciplina').get().then((disciplinasDoc){

      for(int i = 0; disciplinasDoc.docs.length > i;i++){
        disciplinasLista.add(
            DisciplinaModelo(
              idEscola: disciplinasDoc.docs[i]['idEscola'],
              nomeEscola: disciplinasDoc.docs[i]['nomeEscola'],
              idCurso: disciplinasDoc.docs[i]['idCurso'],
              nomeCurso: disciplinasDoc.docs[i]['nomeCurso'],
              idTurma: disciplinasDoc.docs[i]['idTurma'],
              nomeTurma: disciplinasDoc.docs[i]['nomeTurma'],
              idDisciplina: disciplinasDoc.docs[i].id,
              nomeDisciplina: disciplinasDoc.docs[i]['nomeDisciplina'],
              ano: disciplinasDoc.docs[i]['ano'],
            )
        );
      }
      if(disciplinasLista.isEmpty){
        showSnackBar(context, 'Nenhuma disciplina encontrada', Cores.erro);
      }
      setState(() {});
    });
  }

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
      if(cursoSelecionadoCadastro!=null){
        if(turmaSelecionadaCadastro!=null){
          if(nome.text.length>2){
            if(ano.text.length==4){
              idDisciplina.isEmpty?salvarDisciplina():editarDisciplina();
            }else{
              showSnackBar(context, 'Ano Incompleto', Cores.erro);
            }
          }else{
            showSnackBar(context, 'Nome Incompleto', Cores.erro);
          }
        }else{
          showSnackBar(context, 'Selecione uma Turma', Cores.erro);
        }
      }else{
        showSnackBar(context, 'Selecione um Curso', Cores.erro);
      }
    }else{
      showSnackBar(context, 'Selecione uma escola', Cores.erro);
    }
  }

  salvarDisciplina(){
    salvando = true;
    setState(() {});

    final docRef = FirebaseFirestore.instance.collection('disciplinas').doc();
    FirebaseFirestore.instance.collection('disciplinas').doc(docRef.id).set({
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplina'  : docRef.id,
      'nomeDisciplina': nome.text.toUpperCase(),
      'idCurso'       : cursoSelecionadoCadastro!.idCurso,
      'nomeCurso'     : cursoSelecionadoCadastro!.nomeCurso,
      'idTurma'       : turmaSelecionadaCadastro!.idTurma,
      'nomeTurma'     : turmaSelecionadaCadastro!.nomeTurma,
      'ano'           : int.parse(ano.text),
      'status'        : 'ativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      cursoSelecionadoCadastro = null;
      turmaSelecionadaCadastro = null;
      nome.clear();
      ano.clear();
      salvando = false;
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarDisciplina(){
    salvando = true;
    setState(() {});

    FirebaseFirestore.instance.collection('disciplinas').doc(idDisciplina).update({
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'nomeDisciplina': nome.text.toUpperCase(),
      'idCurso'       : cursoSelecionadoCadastro!.idCurso,
      'nomeCurso'     : cursoSelecionadoCadastro!.nomeCurso,
      'idTurma'       : turmaSelecionadaCadastro!.idTurma,
      'nomeTurma'     : turmaSelecionadaCadastro!.nomeTurma,
      'ano'           : int.parse(ano.text),
    }).then((_){
      escolaSelecionadaCadastro = null;
      cursoSelecionadoCadastro = null;
      turmaSelecionadaCadastro = null;
      nome.clear();
      ano.clear();
      salvando = false;
      idDisciplina = '';
      setState(() {});
      showSnackBar(context, 'Alterado com sucesso', Colors.green);
    });
  }

  pesquisarDisciplina(){
    disciplinasLista.clear();
    exibirCampos = false;
    FirebaseFirestore.instance.collection('disciplinas')
        .where('idEscola',isEqualTo: escolaSelecionadaPesquisa!.idEscola)
        .where('idCurso',isEqualTo: cursoSelecionadoPesquisa!.idCurso)
        .where('idTurma',isEqualTo: turmaSelecionadaPesquisa!.idTurma)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('nomeDisciplina')
        .startAt([pesquisar.text.toUpperCase()])
        .endAt(['${pesquisar.text.toUpperCase()}\uf8ff']).get().then((disciplinasDoc){

      for(int i = 0; disciplinasDoc.docs.length > i;i++){
        disciplinasLista.add(
            DisciplinaModelo(
              idEscola: disciplinasDoc.docs[i]['idEscola'],
              nomeEscola: disciplinasDoc.docs[i]['nomeEscola'],
              idDisciplina: disciplinasDoc.docs[i].id,
              nomeDisciplina: disciplinasDoc.docs[i]['nomeDisciplina'],
              idCurso: disciplinasDoc.docs[i]['idCurso'],
              nomeCurso: disciplinasDoc.docs[i]['nomeCurso'],
              idTurma: disciplinasDoc.docs[i]['idTurma'],
              nomeTurma: disciplinasDoc.docs[i]['nomeTurma'],
              ano: disciplinasDoc.docs[i]['ano'],
            )
        );
      }
      print('displinas selecionadas: ${disciplinasLista.length}');
      if(disciplinasLista.isEmpty){
        showSnackBar(context, 'Nenhuma disciplina encontrada', Cores.erro);
      }
      setState(() {});
    });
    setState(() {});
  }

  preencherCampos(DisciplinaModelo disciplina){
    idDisciplina = disciplina.idDisciplina;
    nome.text = disciplina.nomeDisciplina;
    ano.text = disciplina.ano.toString();
    exibirCampos = true;
    cursoSelecionadoCadastro = cursosLista.firstWhere(
          (curso) => curso.idCurso == disciplina.idCurso,
      orElse: () => null!, // cuidado para tratar esse caso
    );
    turmaSelecionadaCadastro = turmasLista.firstWhere(
          (turma) => turma.idTurma == disciplina.idTurma,
      orElse: () => null!, // cuidado para tratar esse caso
    );
    for(int i = 0; escolasLista.length>i; i++){
      if(disciplina.idEscola == escolasLista[i].idEscola){
        escolaSelecionadaCadastro = escolasLista[i];
        break;
      }
    }
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
              texto: 'Deseja confirmar a exclusão da disciplina?',
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
                    apagarDisciplina();
                  }
              ),
            ],
          );
        }
    );
  }

  apagarDisciplina(){
    FirebaseFirestore.instance.collection('disciplinas')
        .doc(idDisciplina)
        .update({
      'status' : 'inativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      cursoSelecionadoCadastro = null;
      turmaSelecionadaCadastro = null;
      nome.clear();
      ano.clear();
      salvando = false;
      idDisciplina = '';
      Navigator.pop(context);
      setState(() {});
      showSnackBar(context, 'Excluído com sucesso', Colors.green);
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
            title: TextoPadrao(texto: 'DISCIPLINAS',)
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
                                cursoSelecionadoPesquisa = null;
                                turmaSelecionadaPesquisa = null;
                                disciplinasLista.clear();
                                carregarCurso(escolaSelecionadaPesquisa!);
                                setState(() {});
                              },
                            ),
                          ),
                          exibirCampos?Container(width: 350):Container(
                            width: 350,
                            child: DropdownCursos(
                              selecionado: cursoSelecionadoPesquisa,
                              titulo: 'Cursos',
                              lista: cursosLista,
                              largura: 400,
                              larguraContainer: 300,
                              onChanged: (valor){
                                cursoSelecionadoPesquisa = valor;
                                turmaSelecionadaPesquisa = null;
                                disciplinasLista.clear();
                                carregarTurmas(cursoSelecionadoPesquisa!);
                                setState(() {});
                              },
                            ),
                          ),
                          exibirCampos?Container(width: 350):Container(
                            width: 350,
                            child: DropdownTurmas(
                              selecionado: turmaSelecionadaPesquisa,
                              titulo: 'Turmas',
                              lista: turmasLista,
                              largura: 400,
                              larguraContainer: 300,
                              onChanged: (valor){
                                turmaSelecionadaPesquisa = valor;
                                disciplinasLista.clear();
                                carregarDisciplinas(turmaSelecionadaPesquisa!);
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
                                titulo: 'Pesquisar pelo nome da disciplina',
                                largura: 350,
                              ),
                              SizedBox(width: 20,),
                              exibirCampos?Container(width: 120,):BotaoPadrao(
                                  titulo: 'Pesquisar',
                                  largura: 120,
                                  funcao: (){
                                    if(escolaSelecionadaPesquisa!=null){
                                      if(cursoSelecionadoPesquisa!=null){
                                        if(turmaSelecionadaPesquisa!=null){
                                          if(pesquisar.text.isNotEmpty){
                                            pesquisarDisciplina();
                                          }else{
                                            showSnackBar(context, 'Escreva o nome da disciplina', Colors.red);
                                          }
                                        }else{
                                          showSnackBar(context, 'Selecione uma turma', Colors.red);
                                        }
                                      }else{
                                        showSnackBar(context, 'Selecione um curso', Colors.red);
                                      }
                                    }else{
                                      showSnackBar(context, 'Selecione uma escola', Colors.red);
                                    }
                                  }
                              ),
                              SizedBox(width: 20,),
                              BotaoPadrao(
                                  titulo: exibirCampos?'x':'+',
                                  largura: 50,
                                  funcao: (){
                                    pesquisar.clear();
                                    disciplinasLista.clear();
                                    ano.clear();
                                    nome.clear();
                                    escolaSelecionadaCadastro = null;
                                    cursoSelecionadoCadastro = null;
                                    turmaSelecionadaCadastro = null;
                                    idDisciplina = '';
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
                          itemCount: disciplinasLista.length,
                          itemBuilder: (context,i){
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                              child: ListTile(
                                title: TextoPadrao(
                                  texto: disciplinasLista[i].nomeDisciplina,
                                  corTexto: Cores.corPrincipal,
                                  textAling: TextAlign.start,
                                ),
                                onTap: (){
                                  preencherCampos(disciplinasLista[i]);
                                },
                              ),
                            );
                          }
                      ),
                    ):Container(
                      height: 550,
                      width: 450,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 450,
                            child: DropdownEscolas(
                              selecionado: escolaSelecionadaCadastro,
                              titulo: 'Escola *',
                              hint: 'Selecione uma escola',
                              lista: escolasLista,
                              largura: 500,
                              larguraContainer: 300,
                              onChanged: (valor){
                                escolaSelecionadaCadastro = valor;
                                carregarCurso(escolaSelecionadaCadastro!);
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            width: 450,
                            child: DropdownCursos(
                              selecionado: cursoSelecionadoCadastro,
                              titulo: 'Curso *',
                              hint: 'Selecione um curso',
                              lista: cursosLista,
                              largura: 500,
                              larguraContainer: 300,
                              onChanged: (valor){
                                cursoSelecionadoCadastro = valor;
                                turmaSelecionadaCadastro = null;
                                carregarTurmas(cursoSelecionadoCadastro!);
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            width: 450,
                            child: DropdownTurmas(
                              selecionado: turmaSelecionadaCadastro,
                              titulo: 'Turma *',
                              hint: 'Selecione uma turma',
                              lista: turmasLista,
                              largura: 500,
                              larguraContainer: 300,
                              onChanged: (valor){
                                turmaSelecionadaCadastro = valor;
                                setState(() {});
                              },
                            ),
                          ),
                          InputPadrao(
                            titulo: 'Disciplina *',
                            controller: nome,
                            largura: 450,
                          ),
                          Container(
                            width: 450,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InputPadrao(
                                  titulo: 'Ano *',
                                  controller: ano,
                                  largura: 450,
                                  textInputType: TextInputType.number,
                                  maximoCaracteres: 4,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          BotaoPadrao(
                            titulo: idDisciplina.isEmpty?'Salvar':'Alterar',
                            funcao: (){
                              verificarCampos();
                            },
                          ),
                          idDisciplina.isNotEmpty?BotaoPadrao(
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
