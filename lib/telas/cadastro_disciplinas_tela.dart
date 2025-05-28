import 'package:controle_chamada_quadritech/modelo/disciplina_modelo.dart';
import 'package:controle_chamada_quadritech/modelo/escola_modelo.dart';
import 'package:controle_chamada_quadritech/widgets/dropdown_escolas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import '../widgets/botao_padrao.dart';
import '../widgets/input_padrao.dart';
import '../widgets/menu_web.dart';
import '../widgets/snackbar.dart';
import '../widgets/texto_padrao.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CadastroDisciplinasTela extends StatefulWidget {
  const CadastroDisciplinasTela({super.key});

  @override
  State<CadastroDisciplinasTela> createState() => _CadastroDisciplinasTelaState();
}

class _CadastroDisciplinasTelaState extends State<CadastroDisciplinasTela> {

  TextEditingController nome = TextEditingController();
  TextEditingController ensino = TextEditingController();
  TextEditingController curso = TextEditingController();
  TextEditingController ano = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  bool salvando = false;
  bool novoCadastro = false;
  List<DisciplinaModelo> disciplinasLista = [];
  List<EscolaModelo> escolasLista = [];
  EscolaModelo? escolaSelecionadaPesquisa;
  EscolaModelo? escolaSelecionadaCadastro;

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
      if(nome.text.length>2){
        if(curso.text.length>2){
          if(ano.text.length==4){
            if(ensino.text.length>2){
              salvarDisciplina();
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

  salvarDisciplina(){
    salvando = true;
    setState(() {});

    final docRef = FirebaseFirestore.instance.collection('disciplinas').doc();
    FirebaseFirestore.instance.collection('disciplinas').doc(docRef.id).set({
      'idEscola'      : escolaSelecionadaCadastro!.idEscola,
      'nomeEscola'    : escolaSelecionadaCadastro!.nome,
      'idDisciplina'  : docRef.id,
      'nomeDisciplina': nome.text.toUpperCase(),
      'curso'         : curso.text.toUpperCase(),
      'ano'           : int.parse(ano.text),
      'ensino'        : ensino.text.toUpperCase(),
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

  pesquisarDisciplina(){
    disciplinasLista.clear();
    novoCadastro = false;
    if(pesquisar.text.length>2){
     if(escolaSelecionadaPesquisa!=null){
       FirebaseFirestore.instance.collection('disciplinas')
        .where('nomeEscola',isEqualTo: escolaSelecionadaPesquisa!.nome)
        .where('status',isNotEqualTo: 'inativo')
        .orderBy('nomeDisciplina')
        .startAt([pesquisar.text.toUpperCase()])
        .endAt(['${pesquisar.text.toUpperCase()}\uf8ff']).get().then((escolasDoc){

         for(int i = 0; escolasDoc.docs.length > i;i++){
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
         print(disciplinasLista.length);
         if(disciplinasLista.isEmpty){
           showSnackBar(context, 'Nenhuma disciplina encontrada', Cores.erro);
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
            title: TextoPadrao(texto: 'CADASTRO DE DISCIPLINAS',)
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
                                titulo: 'Pesquisar pelo nome da disciplina',
                                largura: 350,
                              ),
                              SizedBox(width: 20,),
                              novoCadastro?Container(width: 120,):BotaoPadrao(
                                  titulo: 'Pesquisar',
                                  largura: 120,
                                  funcao: (){
                                    pesquisarDisciplina();
                                  }
                              ),
                              SizedBox(width: 20,),
                              BotaoPadrao(
                                  titulo: novoCadastro?'x':'+',
                                  largura: 50,
                                  funcao: (){
                                    pesquisar.clear();
                                    disciplinasLista.clear();
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
                          itemCount: disciplinasLista.length,
                          itemBuilder: (context,i){
                            return Container(
                              color: Colors.grey[200],
                              alignment: Alignment.centerLeft,
                              padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                              child: TextoPadrao(
                                texto: disciplinasLista[i].nomeDisciplina,
                                corTexto: Cores.corPrincipal,
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
                                  titulo: 'Curso *',
                                  controller: curso,
                                  largura: 215,
                                ),
                                InputPadrao(
                                  titulo: 'Ano *',
                                  controller: ano,
                                  largura: 215,
                                  textInputType: TextInputType.number,
                                  maximoCaracteres: 4,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          InputPadrao(
                            titulo: 'Ensino *',
                            controller: ensino,
                            largura: 450,
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
