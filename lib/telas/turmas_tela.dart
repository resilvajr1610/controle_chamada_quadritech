import 'package:controle_chamada_quadritech/modelo/turma_modelo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/cores.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';

class TurmasTela extends StatefulWidget {
  const TurmasTela({super.key});

  @override
  State<TurmasTela> createState() => _TurmasTelaState();
}

class _TurmasTelaState extends State<TurmasTela> {

  bool salvando = false;
  bool exibirCampos = false;
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
  List<EscolaModelo> escolasLista = [];
  TextEditingController pesquisar = TextEditingController();
  TextEditingController nome = TextEditingController();
  List<TurmaModelo> turmasLista = [];
  String idTurma = '';

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

  carregarTurmas(){
    turmasLista.clear();
    FirebaseFirestore.instance.collection('turmas')
        .where('nomeEscola',isEqualTo: escolaSelecionadaPesquisa!.nome)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('turma').get().then((escolasDoc){

      for(int i = 0; escolasDoc.docs.length > i;i++){
        turmasLista.add(
            TurmaModelo(
              idEscola: escolasDoc.docs[i]['idEscola'],
              nomeEscola: escolasDoc.docs[i]['nomeEscola'],
              idTurma: escolasDoc.docs[i].id,
              turma: escolasDoc.docs[i]['turma'],
            )
        );
      }
      print(turmasLista.length);
      if(turmasLista.isEmpty){
        showSnackBar(context, 'Nenhuma turma encontrada', Cores.erro);
      }
      setState(() {});
    });
  }

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
      if(nome.text.isNotEmpty){
        idTurma.isEmpty?salvarTurma():editarTurma();
      }else{
        showSnackBar(context, 'Nome Incompleto', Cores.erro);
      }
    }else{
      showSnackBar(context, 'Selecione uma escola', Cores.erro);
    }
  }

  salvarTurma(){
    salvando = true;
    setState(() {});

    final docRef = FirebaseFirestore.instance.collection('turmas').doc();
    FirebaseFirestore.instance.collection('turmas').doc(docRef.id).set({
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idTurma'  : docRef.id,
      'turma': nome.text.toUpperCase(),
      'status'          : 'ativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      salvando = false;
      setState(() {});
      carregarTurmas();
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarTurma(){
    salvando = true;
    setState(() {});

    FirebaseFirestore.instance.collection('turmas').doc(idTurma).update({
      'idEscola'  : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola': escolaSelecionadaCadastro!.nome,
      'turma'     : nome.text.toUpperCase(),
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      salvando = false;
      setState(() {});
      showSnackBar(context, 'Alterado com sucesso', Colors.green);
    });
  }

  preencherCampos(TurmaModelo turma){
    idTurma = turma.idTurma;
    nome.text = turma.turma;
    exibirCampos = true;
    for(int i = 0; escolasLista.length>i; i++){
      if(turma.idEscola == escolasLista[i].idEscola){
        escolaSelecionadaCadastro = escolasLista[i];
        break;
      }
    }
    setState(() {});
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
          title: TextoPadrao(texto: 'CADASTRO DE TURMAS',)
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
                        Container(
                          width: 350,
                          child: DropdownEscolas(
                            selecionado: escolaSelecionadaPesquisa,
                            titulo: 'Escolas',
                            lista: escolasLista,
                            largura: 400,
                            larguraContainer: 300,
                            onChanged: (valor){
                              escolaSelecionadaPesquisa = valor;
                              carregarTurmas();
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
                              titulo: 'Pesquisar pelo nome da turma',
                              largura: 350,
                            ),
                            SizedBox(width: 20,),
                            exibirCampos?Container(width: 120,):BotaoPadrao(
                                titulo: 'Pesquisar',
                                largura: 120,
                                funcao: (){
                                }
                            ),
                            SizedBox(width: 20,),
                            BotaoPadrao(
                                titulo: exibirCampos?'x':'+',
                                largura: 50,
                                funcao: (){
                                  pesquisar.clear();
                                  exibirCampos = !exibirCampos;
                                  setState(() {});
                                }
                            ),
                          ],
                        ),
                        Container(
                          height: turmasLista.length*100,
                          width: 500,
                          child: ListView.builder(
                              itemCount: turmasLista.length,
                              itemBuilder: (context,i){
                                return Container(
                                  color: Colors.grey[200],
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                                  child: ListTile(
                                    title: TextoPadrao(
                                      texto: turmasLista[i].turma,
                                      corTexto: Cores.corPrincipal,
                                      textAling: TextAlign.start,
                                    ),
                                    onTap: (){
                                      preencherCampos(turmasLista[i]);
                                    },
                                  ),
                                );
                              }
                          ),
                        ),
                        !exibirCampos?Container(width: 350):Column(
                          children: [
                            Container(
                              width: 350,
                              child: DropdownEscolas(
                                selecionado: escolaSelecionadaCadastro,
                                titulo: 'Escolas',
                                lista: escolasLista,
                                largura: 400,
                                larguraContainer: 300,
                                onChanged: (valor){
                                  escolaSelecionadaCadastro = valor;
                                  setState(() {});
                                },
                              ),
                            ),
                            InputPadrao(
                              titulo: 'Turma *',
                              controller: nome,
                              largura: 350,
                            ),
                            BotaoPadrao(
                              titulo: idTurma.isEmpty?'Salvar':'Alterar',
                              funcao: (){
                                verificarCampos();
                              },
                            ),
                          ],
                        ),
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
