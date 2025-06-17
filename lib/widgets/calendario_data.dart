import 'package:brasil_fields/brasil_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../modelo/cores.dart';
import 'input_padrao.dart';

class CalendarioData extends StatelessWidget {

  var controller;
  bool validaData;
  var onChanged;
  var funcaoBotao;
  String titulo;
  String msgErro;
  Color corInput;

  CalendarioData({
    required this.controller,
    required this.validaData,
    required this.onChanged,
    required this.funcaoBotao,
    required this.titulo,
    required this.msgErro,
    this.corInput = Colors.white,
  });


  @override
  Widget build(BuildContext context) {

    double largura = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.only(left: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 150,
            child: InputPadrao(
              controller: controller,
              titulo: titulo,
              textInputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                DataInputFormatter(),
              ],
            ),
          ),
          Column(
            children: [
              SizedBox(height: 28),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Cores.corPrincipal,
                    minimumSize: Size(20, 50),
                    shape: RoundedRectangleBorder(borderRadius: new BorderRadius.all(Radius.circular(10),
                    ))
                ),
                child: Icon(Icons.date_range,color: Colors.white,size: 23,),
                onPressed: funcaoBotao,
              ),
            ],
          )
        ],
      ),
    );
  }
}
