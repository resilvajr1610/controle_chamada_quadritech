import 'package:controle_chamada_quadritech/modelo/cores.dart';
import 'package:controle_chamada_quadritech/modelo/escola_modelo.dart';
import 'package:controle_chamada_quadritech/widgets/texto_padrao.dart';
import 'package:flutter/material.dart';

class DropdownEscolas extends StatelessWidget {
  var onChanged;
  EscolaModelo? selecionado;
  String titulo;
  double tamanhoFonte;
  List lista;
  double largura;
  double larguraContainer;
  String hint;

  DropdownEscolas({
    required this.onChanged,
    required this.selecionado,
    required this.titulo,
    required this.lista,
    required this.largura,
    this.tamanhoFonte = 15,
    this.larguraContainer = 300,
    this.hint = 'Selecione',
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        titulo.isEmpty?Container():TextoPadrao(texto: titulo,tamanhoTexto: 18,corTexto: Cores.corPrincipal,),
        Container(
          width: largura*0.95,
          padding: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            color: Colors.grey[300],
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.all(Radius.circular(10))
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
                hint: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: TextoPadrao(texto: hint,tamanhoTexto: 15,corTexto: Colors.black,),
                ),
                value: selecionado,
                items: lista.map((value) => DropdownMenuItem(
                  value: value,
                  child: Container(
                    width: larguraContainer,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.0),
                      child: TextoPadrao(
                        texto: value.nome,
                        tamanhoTexto: tamanhoFonte,
                        corTexto: Colors.black,
                        textAling: TextAlign.start,
                      ),
                    ),
                  ),
                )
                ).toList(),
                onChanged:onChanged
            ),
          ),
        ),
      ],
    );
  }
}