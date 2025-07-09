import 'package:controle_chamada_quadritech/modelo/cores.dart';
import 'package:controle_chamada_quadritech/modelo/escola_modelo.dart';
import 'package:controle_chamada_quadritech/widgets/botao_padrao.dart';
import 'package:controle_chamada_quadritech/widgets/input_padrao.dart';
import 'package:controle_chamada_quadritech/widgets/menu_web.dart';
import 'package:controle_chamada_quadritech/widgets/snackbar.dart';
import 'package:controle_chamada_quadritech/widgets/texto_padrao.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/services.dart';

class EscolasTela extends StatefulWidget {
  const EscolasTela({super.key});

  @override
  State<EscolasTela> createState() => _EscolasTelaState();
}

class _EscolasTelaState extends State<EscolasTela> {

  TextEditingController nome = TextEditingController();
  TextEditingController endereco = TextEditingController();
  TextEditingController numero = TextEditingController();
  TextEditingController bairro = TextEditingController();
  TextEditingController cidade = TextEditingController();
  TextEditingController cep = TextEditingController();
  TextEditingController numeroRegistro = TextEditingController();
  TextEditingController ensino = TextEditingController();
  TextEditingController pesquisar = TextEditingController();
  bool salvando = false;
  bool exibirCampos = false;
  List<EscolaModelo> escolasLista = [];
  String idEscola = '';
  verificarCampos(){
    if(nome.text.length>2){
      if(endereco.text.length>2){
        if(numero.text.isNotEmpty){
          if(bairro.text.length>2){
            if(cidade.text.length>2){
              if(cep.text.length==10){
                if(ensino.text.length>2){
                  idEscola.isEmpty?salvarEscola():editarEscola();
                }else{
                  showSnackBar(context, 'Ensino Incompleto', Cores.erro);
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
      showSnackBar(context, 'Nome Incompleto', Cores.erro);
    }
  }

  salvarEscola(){
    salvando = true;
    setState(() {});

    final docRef = FirebaseFirestore.instance.collection('escolas').doc();
    FirebaseFirestore.instance.collection('escolas').doc(docRef.id).set({
      'id'              : docRef.id,
      'nome'            : nome.text.toUpperCase(),
      'endereco'        : endereco.text.toUpperCase(),
      'numero'          : int.parse(numero.text),
      'bairro'          : bairro.text.toUpperCase(),
      'cidade'          : cidade.text.toUpperCase(),
      'cep'             : cep.text,
      'numeroRegistro'  : numeroRegistro.text.toUpperCase(),
      'ensino'          : ensino.text.toUpperCase(),
      'status'          : 'ativo'
    }).then((_){
      nome.clear();
      endereco.clear();
      numero.clear();
      bairro.clear();
      cidade.clear();
      cep.clear();
      numeroRegistro.clear();
      ensino.clear();
      salvando = false;
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  editarEscola(){
    FirebaseFirestore.instance.collection('escolas').doc(idEscola).update({
      'nome'            : nome.text.toUpperCase(),
      'endereco'        : endereco.text.toUpperCase(),
      'numero'          : int.parse(numero.text),
      'bairro'          : bairro.text.toUpperCase(),
      'cidade'          : cidade.text.toUpperCase(),
      'cep'             : cep.text,
      'numeroRegistro'  : numeroRegistro.text.toUpperCase(),
      'ensino'          : ensino.text.toUpperCase(),
    }).then((_){
      nome.clear();
      endereco.clear();
      numero.clear();
      bairro.clear();
      cidade.clear();
      cep.clear();
      numeroRegistro.clear();
      ensino.clear();
      salvando = false;
      idEscola = '';
      setState(() {});
      showSnackBar(context, 'Alterado com sucesso', Colors.green);
    });
  }

  apagarEscola(){
    FirebaseFirestore.instance.collection('escolas')
        .doc(idEscola)
        .update({
          'status' : 'inativo'
        }).then((_){
          nome.clear();
          endereco.clear();
          numero.clear();
          bairro.clear();
          cidade.clear();
          cep.clear();
          numeroRegistro.clear();
          ensino.clear();
          salvando = false;
          idEscola = '';
          Navigator.pop(context);
          setState(() {});
          showSnackBar(context, 'Excluído com sucesso', Colors.green);
    });
  }

  void pesquisarEscola() async {
    escolasLista.clear();
    exibirCampos = false;
    idEscola = '';

    if (pesquisar.text.isNotEmpty) {
      String termo = pesquisar.text.toUpperCase().trim();

      print(termo);

      QuerySnapshot escolasDoc = await FirebaseFirestore.instance
          .collection('escolas')
          .orderBy('nome')
          .where('status', isNotEqualTo: 'inativo')
          .startAt([termo])
          .endAt(['$termo\uf8ff'])
          .get();

      // Se não encontrou nada, tenta buscar por numeroRegistro

      print(escolasDoc.docs.length);
      print(termo);

      if (escolasDoc.docs.isEmpty) {
        escolasDoc = await FirebaseFirestore.instance
            .collection('escolas')
            .orderBy('numeroRegistro')
            .where('status', isNotEqualTo: 'inativo')
            .startAt([termo])
            .endAt(['$termo\uf8ff'])
            .get();

        print(escolasDoc.docs.length);
      }

      for (var doc in escolasDoc.docs) {
        escolasLista.add(
          EscolaModelo(
            idEscola: doc.id,
            bairro: doc['bairro'],
            cep: doc['cep'],
            cidade: doc['cidade'],
            endereco: doc['endereco'],
            ensino: doc['ensino'],
            nome: doc['nome'],
            numero: doc['numero'],
            numeroRegistro: doc['numeroRegistro'],
          )
        );
      }

      setState(() {});

      if (escolasLista.isEmpty) {
        showSnackBar(context, 'Nenhuma escola encontrada', Cores.erro);
      }
    } else {
      carregarEscolas();
      showSnackBar(context, 'Digite pelo menos 1 caracter para pesquisar', Cores.erro);
    }

    setState(() {});
  }

  preencherCampos(EscolaModelo escola){
    nome.text = escola.nome;
    endereco.text = escola.endereco;
    numero.text = escola.numero.toString();
    bairro.text = escola.bairro;
    cidade.text = escola.cidade;
    cep.text = escola.cep;
    numeroRegistro.text = escola.numeroRegistro;
    ensino.text = escola.ensino;
    idEscola = escola.idEscola;
    exibirCampos = true;
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
              texto: 'Deseja confirmar a exclusão da escola?',
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
                  apagarEscola();
                }
              ),
            ],
          );
        }
    );
  }

  carregarEscolas(){
    FirebaseFirestore.instance.collection('escolas')
        .orderBy('nome')
        .where('status',isNotEqualTo: 'inativo')
        .get().then((escolasDoc){
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

  @override
  void initState() {
    super.initState();
    carregarEscolas();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white
          ),
          backgroundColor: Cores.corPrincipal,
          title: TextoPadrao(texto: 'CADASTRO DE ESCOLAS',)
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
              padding: EdgeInsets.all(50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InputPadrao(
                    controller: pesquisar,
                    titulo: 'Pesquisar pelo nome da escola ou registro',
                    largura: 400,
                  ),
                  SizedBox(width: 20,),
                  BotaoPadrao(
                    titulo: 'Pesquisar',
                    largura: 120,
                    funcao: (){
                      pesquisarEscola();
                    }
                  ),
                  SizedBox(width: 20,),
                  BotaoPadrao(
                      titulo: exibirCampos?'x':'+',
                      largura: 50,
                      funcao: (){
                        pesquisar.clear();
                        escolasLista.clear();
                        idEscola = '';
                        exibirCampos = !exibirCampos;
                        setState(() {});
                      }
                  ),
                ],
              ),
            ),
            Spacer(),
            !exibirCampos?Container(
              height: 450,
              width: 500,
              child: ListView.builder(
                itemCount: escolasLista.length,
                itemBuilder: (context,i){
                  return Container(
                    color: Colors.grey[200],
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                    child: ListTile(
                      title: TextoPadrao(
                        textAling: TextAlign.start,
                        texto: escolasLista[i].nome,
                        corTexto: Cores.corPrincipal,
                      ),
                      subtitle: TextoPadrao(
                        textAling: TextAlign.start,
                        texto: 'Cidade : ${escolasLista[i].cidade}',
                        corTexto: Cores.corPrincipal,
                        tamanhoTexto: 15,
                      ),
                      onTap: (){
                        preencherCampos(escolasLista[i]);
                      },
                    ),
                  );
                }
              ),
            ):Container(
              height: 450,
              width: 450,
              child: ListView(
                children: [
                  InputPadrao(
                    titulo: 'Escola *',
                    controller: nome,
                    largura: 450,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InputPadrao(
                        titulo: 'Endereço *',
                        controller: endereco,
                        largura: 330,
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InputPadrao(
                        titulo: 'Bairro *',
                        controller: bairro,
                        largura: 215,
                      ),
                      InputPadrao(
                        titulo: 'Cidade *',
                        controller: cidade,
                        largura: 215,
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InputPadrao(
                        titulo: 'CEP *',
                        controller: cep,
                        largura: 215,
                        textInputType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          CepInputFormatter()
                        ],
                      ),
                      InputPadrao(
                        titulo: 'Número Registro',
                        controller: numeroRegistro,
                        largura: 215,
                      ),
                    ],
                  ),
                  InputPadrao(
                    titulo: 'Ensino *',
                    controller: ensino,
                    largura: 450,
                  ),
                  BotaoPadrao(
                    titulo: idEscola.isEmpty?'Salvar':'Alterar',
                    funcao: (){
                      verificarCampos();
                    },
                  ),
                  idEscola.isNotEmpty?BotaoPadrao(
                    titulo: 'Excluir',
                    corBotao: Cores.erro,
                    funcao: (){
                      exibirExclusao();
                    },
                  ):Container()
                ],
              ),
            ),
            Spacer(),
          ],
        ),
      )
    );
  }
}
