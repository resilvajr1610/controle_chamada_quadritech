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

class CadastroEscolasTela extends StatefulWidget {
  const CadastroEscolasTela({super.key});

  @override
  State<CadastroEscolasTela> createState() => _CadastroEscolasTelaState();
}

class _CadastroEscolasTelaState extends State<CadastroEscolasTela> {

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
  bool novoCadastro = false;
  List<EscolaModelo> escolasLista = [];

  verificarCampos(){
    if(nome.text.length>2){
      if(endereco.text.length>2){
        if(numero.text.isNotEmpty){
          if(bairro.text.length>2){
            if(cidade.text.length>2){
              if(cep.text.length==10){
                if(ensino.text.length>2){
                  salvarEscola();
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
      'numeroRegistro'  : numeroRegistro.text,
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
      setState(() {});
      showSnackBar(context, 'Salvo com sucesso', Colors.green);
    });
  }

  pesquisarEscola(){
    escolasLista.clear();
    novoCadastro = false;
    if(pesquisar.text.length>2){
      FirebaseFirestore.instance.collection('escolas')
          .orderBy('nome')
          .startAt([pesquisar.text.toUpperCase()])
          .endAt(['${pesquisar.text.toUpperCase()}\uf8ff']).get().then((escolasDoc){

          for(int i = 0; escolasDoc.docs.length > i;i++){
            escolasLista.add(
              EscolaModelo(
                id: escolasDoc.docs[i].id,
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
    }else{
      showSnackBar(context, 'Digite pelo menos 3 caracteres para pesquisar', Cores.erro);
    }
    setState(() {});
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
                    titulo: 'Pesquisar nome da escola',
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
                      titulo: novoCadastro?'Fechar':'Cadastrar',
                      largura: 120,
                      funcao: (){
                        pesquisar.clear();
                        novoCadastro = !novoCadastro;
                        setState(() {});
                      }
                  ),
                ],
              ),
            ),
            Spacer(),
            !novoCadastro?Container(
              height: 500,
              width: 500,
              child: ListView.builder(
                itemCount: escolasLista.length,
                itemBuilder: (context,i){
                  return Container(
                    color: Colors.grey[200],
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.symmetric(vertical: 10,horizontal: 30),
                    child: TextoPadrao(
                      texto: escolasLista[i].nome,
                      corTexto: Cores.corPrincipal,
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
                    titulo: 'Nome da escola *',
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
                    titulo: 'Salvar',
                    funcao: (){
                      verificarCampos();
                    },
                  )
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
