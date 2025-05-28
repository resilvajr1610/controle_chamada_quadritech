import 'package:controle_chamada_quadritech/widgets/texto_padrao.dart';
import 'package:flutter/material.dart';
import '../modelo/cores.dart';

class ItemMenu extends StatelessWidget {
  String texto;
  var destino;

  ItemMenu({
    required this.texto,
    required this.destino
  });

  @override
  Widget build(BuildContext context) {

    double altura = MediaQuery.of(context).size.height;
    double largura = MediaQuery.of(context).size.width;

    return Card(
      child: Container(
        height: 50,
        width: largura*0.15,
        child: ListTile(
          onTap: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> destino));
          },
          title: TextoPadrao(
            negrito: true,
            texto: texto,
            corTexto: Cores.corPrincipal,
            tamanhoTexto: largura*0.01,
          ),
        ),
      ),
    );
  }
}
