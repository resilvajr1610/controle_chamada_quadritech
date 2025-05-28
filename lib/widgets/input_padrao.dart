import 'package:controle_chamada_quadritech/modelo/cores.dart';
import 'package:controle_chamada_quadritech/widgets/texto_padrao.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputPadrao extends StatelessWidget {
  TextEditingController controller;
  double largura;
  String titulo;
  bool oculto;
  TextInputType textInputType;
  List<TextInputFormatter>? inputFormatters = [];
  int maximoCaracteres;

  InputPadrao({
    required this.controller,
    required this.titulo,
    this.largura = 300,
    this.oculto = false,
    this.textInputType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    this.maximoCaracteres = 0,
  })
    : inputFormatters = inputFormatters ?? [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextoPadrao(texto: titulo,corTexto: Cores.corPrincipal,tamanhoTexto: 18,),
        Container(
          width: largura,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(10)
          ),
          child: TextFormField(
            controller: controller,
            obscureText: oculto,
            keyboardType: textInputType,
            inputFormatters: inputFormatters,
            maxLength: maximoCaracteres==0?null:maximoCaracteres,
            decoration: InputDecoration(
              counterText: '',
              border: InputBorder.none,
            ),
          ),
        )
      ],
    );
  }
}
