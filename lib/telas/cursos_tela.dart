import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../modelo/cores.dart';
import '../modelo/curso_modelo.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';

class CursosTela extends StatefulWidget {
  const CursosTela({super.key});

  @override
  State<CursosTela> createState() => _CursosTelaState();
}

class _CursosTelaState extends State<CursosTela> {

  List<EscolaModelo> escolasLista = [];
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
  bool exibirCampos = false;
  TextEditingController pesquisar = TextEditingController();
  TextEditingController nome = TextEditingController();
  List<CursoModelo> cursosLista = [];
  String idCurso = '';
  bool salvando = false;

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

  preencherCampos(CursoModelo curso){
    idCurso = curso.idCurso;
    nome.text = curso.nomeCurso;
    exibirCampos = true;
    for(int i = 0; escolasLista.length>i; i++){
      if(curso.idEscola == escolasLista[i].idEscola){
        escolaSelecionadaCadastro = escolasLista[i];
        break;
      }
    }
    setState(() {});
  }

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
      if(nome.text.isNotEmpty){
        idCurso.isEmpty?salvarCurso():editarCurso();
      }else{
        showSnackBar(context, 'Nome Incompleto', Cores.erro);
      }
    }else{
      showSnackBar(context, 'Selecione uma escola', Cores.erro);
    }
  }

  salvarCurso(){
    salvando = true;
    setState(() {});

    final docRef = FirebaseFirestore.instance.collection('cursos').doc();
    FirebaseFirestore.instance.collection('cursos').doc(docRef.id).set({
      'idEscola'  : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola': escolaSelecionadaCadastro!.nome,
      'idCurso'   : docRef.id,
      'curso'     : nome.text.toUpperCase(),
      'status'    : 'ativo'
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      salvando = false;
      setState(() {});
      carregarCurso();
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarCurso(){
    salvando = true;
    setState(() {});

    FirebaseFirestore.instance.collection('turmas').doc(idCurso).update({
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

  carregarCurso(){
    cursosLista.clear();
    FirebaseFirestore.instance.collection('cursos')
        .where('nomeEscola',isEqualTo: escolaSelecionadaPesquisa!.nome)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('curso').get().then((escolasDoc){

      for(int i = 0; escolasDoc.docs.length > i;i++){
        cursosLista.add(
            CursoModelo(
              idEscola: escolasDoc.docs[i]['idEscola'],
              nomeEscola: escolasDoc.docs[i]['nomeEscola'],
              idCurso: escolasDoc.docs[i].id,
              nomeCurso: escolasDoc.docs[i]['curso'],
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
          title: TextoPadrao(texto: 'CURSOS',)
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
                              carregarCurso();
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
                              titulo: 'Pesquisar pelo nome do curso',
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
                          height: cursosLista.length*100,
                          width: 500,
                          child: ListView.builder(
                              itemCount: cursosLista.length,
                              itemBuilder: (context,i){
                                return Container(
                                  color: Colors.grey[200],
                                  alignment: Alignment.centerLeft,
                                  padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                                  child: ListTile(
                                    title: TextoPadrao(
                                      texto: cursosLista[i].nomeCurso,
                                      corTexto: Cores.corPrincipal,
                                      textAling: TextAlign.start,
                                    ),
                                    onTap: (){
                                      preencherCampos(cursosLista[i]);
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
                                titulo: 'Escolas *',
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
                              titulo: 'Curso *',
                              controller: nome,
                              largura: 350,
                            ),
                            BotaoPadrao(
                              titulo: idCurso.isEmpty?'Salvar':'Alterar',
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
      ),
    );
  }
}
