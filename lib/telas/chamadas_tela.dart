import 'package:controle_chamada_quadritech/modelo/aluno_chamada_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/chamada_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/converter_data_modelo.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_aluno_chamada.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_professores_chamada.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../modelo/escola_modelo.dart';
import '../modelo/professor_chamada_modelo.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';

class ChamadasTela extends StatefulWidget {
  const ChamadasTela({super.key});

  @override
  State<ChamadasTela> createState() => _ChamadasTelaState();
}

class _ChamadasTelaState extends State<ChamadasTela> {

  EscolaModelo? escolaSelecionadaPesquisa;
  List<EscolaModelo> escolasLista = [];
  List<ChamadaModelo> alunosListaTodas = [];
  List<ChamadaModelo> alunosListaFiltrada = [];
  List<ProfessorChamadaModelo> professoresBanco = [];
  ProfessorChamadaModelo? professorSelecionado;
  List<AlunoChamadaModelo> alunosBanco = [];
  AlunoChamadaModelo? alunoSelecionado;

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
    professoresBanco.clear();
    professorSelecionado = null;
    alunosListaTodas.clear();
    alunosListaFiltrada.clear();
    alunosBanco.clear();
    alunoSelecionado = null;
    setState(() {});
    FirebaseFirestore.instance.collection('professores')
        .where('idEscola',isEqualTo: idEscola)
        .where('status',isEqualTo: 'ativo')
        .orderBy('nomeProf')
        .get()
        .then((professoresDoc){

      for(int i = 0; professoresDoc.docs.length > i;i++){
        professoresBanco.add(
          ProfessorChamadaModelo(
            idProf: professoresDoc.docs[i].id,
            nomeProf: professoresDoc.docs[i]['nomeProf'],
            idDisciplina: professoresDoc.docs[i]['idDisciplina'],
            nomeDisciplina: professoresDoc.docs[i]['nomeDisciplina'],
            idEscola: professoresDoc.docs[i]['idEscola'],
            nomeEscola: professoresDoc.docs[i]['nomeEscola'],
          )
        );
      }
      setState(() {});
    });
  }

  carregarPresencas(){
    alunosListaTodas.clear();
    alunosListaFiltrada.clear();
    alunosBanco.clear();
    alunoSelecionado = null;
    setState(() {});

    if(escolaSelecionadaPesquisa!=null){
      FirebaseFirestore.instance.collection('presencas')
          .where('idDisciplina',isEqualTo: professorSelecionado!.idDisciplina)
          .orderBy('dataHora').get().then((chamadasDoc){


        List idsAlunos = [];
        for(int i = 0; chamadasDoc.docs.length > i;i++){
          alunosListaTodas.add(
              ChamadaModelo(
                idPresenca: chamadasDoc.docs[i].id,
                idEscola: chamadasDoc.docs[i]['idEscola'],
                nomeEscola: chamadasDoc.docs[i]['nomeEscola'],
                idAluno: chamadasDoc.docs[i]['alunoId'],
                nomeAluno: chamadasDoc.docs[i]['nomeAluno'],
                idDisciplina: chamadasDoc.docs[i]['idDisciplina'],
                nomeDisciplina: chamadasDoc.docs[i]['nomeDisciplina'],
                dataHora: chamadasDoc.docs[i]['dataHora'],
                situacao: chamadasDoc.docs[i]['situacao'],
              )
          );
          if(!idsAlunos.contains(chamadasDoc.docs[i]['alunoId'])){
            alunosBanco.add(
                AlunoChamadaModelo(
                  idAluno: chamadasDoc.docs[i]['alunoId'],
                  nomeAluno: chamadasDoc.docs[i]['nomeAluno'],
                )
            );
            idsAlunos.add(chamadasDoc.docs[i]['alunoId']);
          }
        }
        alunosListaFiltrada.addAll(alunosListaTodas);
        if(alunosListaTodas.isEmpty){
          showSnackBar(context, 'Nenhum(a) chamada encontrada', Cores.erro);
        }
        setState(() {});
      });
    }else{
      showSnackBar(context, 'Selecione uma escola para pesquisar', Cores.erro);
    }
    setState(() {});
  }

  filtrarAlunos(String alunoId){
    alunosListaFiltrada.clear();
    for(int i = 0; alunosListaTodas.length>i; i++){
      if(alunosListaTodas[i].idAluno == alunoId){
        alunosListaFiltrada.add(alunosListaTodas[i]);
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
                                carregarProfessores(escolaSelecionadaPesquisa!.idEscola);
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            width: 350,
                            child: DropdownProfessoresChamada(
                              selecionado: professorSelecionado,
                              titulo: 'Professores',
                              lista: professoresBanco,
                              largura: 400,
                              larguraContainer: 300,
                              onChanged: (valor){
                                professorSelecionado = valor;
                                carregarPresencas();
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            width: 350,
                            child: DropdownAlunoChamada(
                              selecionado: alunoSelecionado,
                              titulo: 'Alunos',
                              lista: alunosBanco,
                              largura: 400,
                              larguraContainer: 300,
                              onChanged: (valor){
                                alunoSelecionado = valor;
                                filtrarAlunos(alunoSelecionado!.idAluno);
                                setState(() {});
                              },
                            ),
                          ),
                          professorSelecionado==null?Container():TextoPadrao(
                            texto: 'DISCIPLINA: ${professorSelecionado!.nomeDisciplina}',
                            corTexto: Cores.corPrincipal,
                            textAling: TextAlign.start,
                            tamanhoTexto: 16,
                          ),
                          Container(
                            height: 500,
                            width: 600,
                            child: ListView.builder(
                                itemCount: alunosListaFiltrada.length,
                                itemBuilder: (context,i){
                                  return Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.centerLeft,
                                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                                    child: Row(
                                      children: [
                                        TextoPadrao(
                                          texto: '${alunosListaFiltrada[i].nomeAluno} - ${ConverterDataModelo().formatarTimestamp(alunosListaFiltrada[i].dataHora)}',
                                          corTexto: Cores.corPrincipal,
                                          textAling: TextAlign.start,
                                          tamanhoTexto: 16,
                                        ),
                                        Spacer(),
                                        Container(
                                          width: 175,
                                          child: TextoPadrao(
                                            texto:'REGISTRO : ${alunosListaFiltrada[i].situacao}',
                                            corTexto: Cores.corPrincipal,
                                            textAling: TextAlign.start,
                                            tamanhoTexto: 16,
                                          ),
                                        )
                                      ],
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