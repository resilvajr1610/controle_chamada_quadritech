import 'package:controle_chamada_quadritech/widgets/texto_padrao.dart';
import 'package:flutter/material.dart';
import '../modelo/cores.dart';

class BotaoPadrao extends StatelessWidget {
  String titulo;
  var funcao;
  double largura;
  double altura;
  Color corBotao;

  BotaoPadrao({
    required this.titulo,
    required this.funcao,
    this.largura = 300,
    this.altura = 50,
    this.corBotao = Cores.corPrincipal
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10,left: 5),
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: corBotao,
          minimumSize: Size(largura, altura),
        ),
        child: TextoPadrao(texto: titulo,),
        onPressed: funcao,
      ),
    );
  }
}
