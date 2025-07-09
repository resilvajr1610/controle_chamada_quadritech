import 'package:flutter/material.dart';

class TextoPadrao extends StatelessWidget {
 String texto;
 Color corTexto;
 double tamanhoTexto;
 bool negrito;
 TextAlign textAling;


 TextoPadrao({
   required this.texto,
   this.corTexto = Colors.white,
   this.tamanhoTexto = 20.0,
   this.negrito = false,
   this.textAling = TextAlign.center
});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: textAling,
      maxLines: 2,
      style: TextStyle(
        color: corTexto,
        fontSize: tamanhoTexto,
        fontWeight: negrito?FontWeight.bold:FontWeight.normal,
      ),
    );
  }
}
