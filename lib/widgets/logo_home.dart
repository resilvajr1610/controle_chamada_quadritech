import 'package:controle_chamada_quadritech/telas/reconhecimento_tela.dart';
import 'package:flutter/material.dart';

class LogoHome extends StatelessWidget {
  const LogoHome({super.key});

  @override
  Widget build(BuildContext context) {

    double largura = MediaQuery.of(context).size.width;

    return InkWell(
      child: Image.asset('assets/imagens/logo.png',width: largura*0.15,),
      onTap: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ReconhecimentoTela()));
      },
    );
  }
}
