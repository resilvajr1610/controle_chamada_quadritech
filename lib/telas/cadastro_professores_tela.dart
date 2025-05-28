import 'package:controle_chamada_quadritech/modelo/professor_modelo.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_disciplinas.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../modelo/disciplina_modelo.dart';
import '../modelo/escola_modelo.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/dropdown_escolas.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';
import 'package:brasil_fields/brasil_fields.dart';

class CadastroProfessoresTela extends StatefulWidget {
  const CadastroProfessoresTela({super.key});

  @override
  State<CadastroProfessoresTela> createState() => _CadastroProfessoresTelaState();
}

class _CadastroProfessoresTelaState extends State<CadastroProfessoresTela> {

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
  TextEditingController numeroRegistro = TextEditingController();
  TextEditingController formacao = TextEditingController();
  TextEditingController estadoCivil = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  bool salvando = false;
  bool novoCadastro = false;
  List<DisciplinaModelo> disciplinasListaPesquisa = [];
  List<DisciplinaModelo> disciplinasListaCadastro = [];
  List<EscolaModelo> escolasLista = [];
  List<ProfessorModelo> professoresLista = [];
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;
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

  carregarDisciplinas(){
    disciplinasListaCadastro.clear();
    disciplinaSelecionadaCadastro = null;
    setState(() {});
    print('aqui');
    FirebaseFirestore.instance.collection('disciplinas')
        .where('idEscola',isEqualTo:escolaSelecionadaCadastro!.idEscola).get().then((disciplinasDoc){
      for(int i = 0; disciplinasDoc.docs.length > i;i++){
        disciplinasListaCadastro.add(
            DisciplinaModelo(
              idEscola: disciplinasDoc.docs[i]['idEscola'],
              nomeEscola: disciplinasDoc.docs[i]['nomeEscola'],
              idDisciplina: disciplinasDoc.docs[i].id,
              nomeDisciplina: disciplinasDoc.docs[i]['nomeDisciplina'],
              ensino: disciplinasDoc.docs[i]['ensino'],
              ano: disciplinasDoc.docs[i]['ano'],
              curso: disciplinasDoc.docs[i]['curso'],
            )
        );
      }
      if(disciplinasListaCadastro.isEmpty){
        showSnackBar(context, 'Nenhuma disciplina cadastrada nessa escola', Cores.erro);
      }
      print('disci ${disciplinasListaCadastro.length}');
      setState(() {});
    });
  }

  verificarCampos(){
    if(escolaSelecionadaCadastro!=null){
      if(disciplinaSelecionadaCadastro!=null){
        if(nome.text.length>5){
          if(curso.text.length>2){
            if(ano.text.length==4){
              if(ensino.text.length>2){
                if(formacao.text.length>2){
                  if(endereco.text.length>2){
                    if(numero.text.isNotEmpty){
                      if(bairro.text.length>2){
                        if(cidade.text.length>2){
                          if(cep.text.length==10){
                            if(estadoCivil.text.length>2){
                              if(idade.text.isNotEmpty){
                                salvarProfessor();
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
                  showSnackBar(context, 'Formação Incompleta', Cores.erro);
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
        showSnackBar(context, 'Selecione uma disciplina', Cores.erro);
      }
    }else{
      showSnackBar(context, 'Selecione uma escola', Cores.erro);
    }
  }

  salvarProfessor(){
    salvando = true;
    setState(() {});

    final docRef = FirebaseFirestore.instance.collection('professores').doc();
    FirebaseFirestore.instance.collection('professores').doc(docRef.id).set({
      'idProf'        : docRef.id,
      'nomeProf'      : nome.text.toUpperCase(),
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplina'  : disciplinaSelecionadaCadastro!.idDisciplina,
      'nomeDisciplina': disciplinaSelecionadaCadastro!.nomeDisciplina,
      'bairro'        : bairro.text.toUpperCase(),
      'cep'           : cep.text,
      'cidade'        : cidade.text.toUpperCase(),
      'idade'         : int.parse(idade.text),
      'endereco'      : endereco.text.toUpperCase(),
      'numero'        : int.parse(numero.text),
      'numeroRegistro': numeroRegistro.text,
      'curso'         : curso.text.toUpperCase(),
      'formacao'      : formacao.text.toUpperCase(),
      'ano'           : int.parse(ano.text),
      'ensino'        : ensino.text.toUpperCase(),
      'estadoCivil'   : estadoCivil.text.toUpperCase(),
    }).then((_){
      escolaSelecionadaCadastro = null;
      nome.clear();
      curso.clear();
      ano.clear();
      ensino.clear();
      salvando = false;
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  pesquisarProfessor(){
    professoresLista.clear();
    novoCadastro = false;
    if(pesquisar.text.length>2){
      if(escolaSelecionadaPesquisa!=null){
        FirebaseFirestore.instance.collection('professores')
            .where('nomeEscola',isEqualTo: escolaSelecionadaPesquisa!.nome)
            .orderBy('nomeProf')
            .startAt([pesquisar.text.toUpperCase()])
            .endAt(['${pesquisar.text.toUpperCase()}\uf8ff']).get().then((professoresDoc){

          for(int i = 0; professoresDoc.docs.length > i;i++){
            professoresLista.add(
                ProfessorModelo(
                  idEscola: professoresDoc.docs[i]['idEscola'],
                  nomeEscola: professoresDoc.docs[i]['nomeEscola'],
                  idProf: professoresDoc.docs[i].id,
                  nomeProf: professoresDoc.docs[i]['nomeProf'],
                  idDisciplina:  professoresDoc.docs[i]['idDisciplina'],
                  cep:  professoresDoc.docs[i]['cep'],
                  formacao:  professoresDoc.docs[i]['formacao'],
                  cidade:  professoresDoc.docs[i]['cidade'],
                  bairro:  professoresDoc.docs[i]['bairro'],
                  numero:  professoresDoc.docs[i]['numero'],
                  endereco:  professoresDoc.docs[i]['endereco'],
                  numeroRegistro:  professoresDoc.docs[i]['numeroRegistro'],
                  estadoCivil:  professoresDoc.docs[i]['estadoCivil'],
                  idade:  professoresDoc.docs[i]['idade'],
                  nomeDisciplina: professoresDoc.docs[i]['nomeDisciplina'],
                  curso: professoresDoc.docs[i]['curso'],
                  ano: professoresDoc.docs[i]['ano'],
                  ensino: professoresDoc.docs[i]['ensino'],
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

 @override
  void initState() {
    super.initState();
    carregarEscolas();
  }

  @override
  Widget build(BuildContext context) {

    double altura = MediaQuery.of(context).size.height;
    double largura = MediaQuery.of(context).size.width;

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
                          novoCadastro?Container(width: 350):Container(
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
                              novoCadastro?Container(width: 350,):InputPadrao(
                                controller: pesquisar,
                                titulo: 'Pesquisar pelo nome do(a) professor(a)',
                                largura: 350,
                              ),
                              SizedBox(width: 20,),
                              novoCadastro?Container(width: 120,):BotaoPadrao(
                                  titulo: 'Pesquisar',
                                  largura: 120,
                                  funcao: (){
                                    pesquisarProfessor();
                                  }
                              ),
                              SizedBox(width: 20,),
                              BotaoPadrao(
                                  titulo: novoCadastro?'x':'+',
                                  largura: 50,
                                  funcao: (){
                                    pesquisar.clear();
                                    disciplinasListaPesquisa.clear();
                                    novoCadastro = !novoCadastro;
                                    setState(() {});
                                  }
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    !novoCadastro?Container(
                      height: 500,
                      width: 500,
                      child: ListView.builder(
                          itemCount: professoresLista.length,
                          itemBuilder: (context,i){
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                              child: TextoPadrao(
                                texto: professoresLista[i].nomeProf,
                                corTexto: Cores.corPrincipal,
                              ),
                            );
                          }
                      ),
                    ):Container(
                      height: 750,
                      width: 450,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 500,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      carregarDisciplinas();
                                    },
                                  ),
                                ),
                                Container(
                                  width: 240,
                                  child: DropdownDisciplinas(
                                    selecionado: disciplinaSelecionadaCadastro,
                                    titulo: 'Disciplina *',
                                    hint: 'Selecione uma disciplina',
                                    lista: disciplinasListaCadastro,
                                    largura: 240,
                                    larguraContainer: 100,
                                    onChanged: (valor){
                                      disciplinaSelecionadaCadastro = valor;
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          InputPadrao(
                            titulo: 'Nome professor(a) *',
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
                                  titulo: 'Formação *',
                                  controller: formacao,
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
                            titulo: 'Salvar',
                            funcao: (){
                              verificarCampos();
                            },
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
