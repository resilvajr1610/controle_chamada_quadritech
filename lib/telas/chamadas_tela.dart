import 'dart:async';
import 'dart:convert';
import 'package:controle_chamada_quadritech/modelo/aluno_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/chamada_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/disciplina_modelo.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/dropdown_disciplinas.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'dart:html' as html;

class ChamadasTela extends StatefulWidget {
  const ChamadasTela({super.key});

  @override
  State<ChamadasTela> createState() => _ChamadasTelaState();
}

class _ChamadasTelaState extends State<ChamadasTela> {

  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
  List<EscolaModelo> escolasLista = [];
  List<ChamadaModelo> alunosLista = [];
  List<DisciplinaModelo> disciplinasBanco = [];
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
  DisciplinaModelo? disciplinaSelecionadaCadastro;

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
    disciplinaSelecionadaCadastro = null;
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

  pesquisarAluno(){
    alunosLista.clear();
    if(pesquisar.text.length>2){
      if(escolaSelecionadaPesquisa!=null){
        FirebaseFirestore.instance.collection('presencas')
            .where('nomeEscola',isEqualTo: escolaSelecionadaPesquisa!.nome)
            .orderBy('nomeAluno')
            .startAt([pesquisar.text.toUpperCase()])
            .endAt(['${pesquisar.text.toUpperCase()}\uf8ff']).get().then((chamadasDoc){

          for(int i = 0; chamadasDoc.docs.length > i;i++){
            alunosLista.add(
                ChamadaModelo(
                  idPresenca: chamadasDoc.docs[i].id,
                  idEscola: chamadasDoc.docs[i]['idEscola'],
                  nomeEscola: chamadasDoc.docs[i]['nomeEscola'],
                  idAluno: chamadasDoc.docs[i].id,
                  nomeAluno: chamadasDoc.docs[i]['nomeAluno'],
                  idDisciplina: chamadasDoc.docs[i]['idDisciplina'],
                  nomeDisciplina: chamadasDoc.docs[i]['nomeDisciplina'],
                  dataHora: chamadasDoc.docs[i]['dataHora'],
                  situacao: chamadasDoc.docs[i]['situacao'],
                )
            );
          }
          print(alunosLista.length);
          if(alunosLista.isEmpty){
            showSnackBar(context, 'Nenhum(a) chamada encontrada', Cores.erro);
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
            title: TextoPadrao(texto: 'CONTROLE DE CHAMADAS',)
        ),
        body: Container(
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
                                pesquisar.clear();
                                setState(() {});
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                            InputPadrao(
                                controller: pesquisar,
                                titulo: 'Pesquisar pelo nome do(a) aluno(a)',
                                largura: 350,
                              ),
                              SizedBox(width: 20,),
                              BotaoPadrao(
                                  titulo: 'Pesquisar',
                                  largura: 120,
                                  funcao: (){
                                    pesquisarAluno();
                                  }
                              ),
                            ],
                          ),
                          Container(
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
                                        texto: '${alunosLista[i].nomeAluno} - ${alunosLista[i].nomeDisciplina} - ${alunosLista[i].dataHora.toString()}',
                                        corTexto: Cores.corPrincipal,
                                        textAling: TextAlign.start,
                                      ),
                                      onTap: (){
                                      },
                                    ),
                                  );
                                }
                            ),
                          )
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