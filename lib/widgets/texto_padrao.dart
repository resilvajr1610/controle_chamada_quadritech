import 'package:flutter/material.dart';

class TextoPadrao extends StatelessWidget {
 String texto;
 Color corTexto;
 double tamanhoTexto;
 bool negrito;


 TextoPadrao({
   required this.texto,
   this.corTexto = Colors.white,
   this.tamanhoTexto = 20.0,
   this.negrito = false
});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: corTexto,
        fontSize: tamanhoTexto,
        fontWeight: negrito?FontWeight.bold:FontWeight.normal,
      ),
    );
  }
}
