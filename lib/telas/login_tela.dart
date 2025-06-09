import 'package:controle_chamada_quadritech/modelo/cores.dart';
import 'package:controle_chamada_quadritech/telas/reconhecimento_tela.dart';
import 'package:controle_chamada_quadritech/widgets/botao_padrao.dart';
import 'package:controle_chamada_quadritech/widgets/input_padrao.dart';
import 'package:flutter/material.dart';

import '../widgets/snackbar.dart';

class LoginTela extends StatefulWidget {
  const LoginTela({super.key});

  @override
  State<LoginTela> createState() => _LoginTelaState();
}

class _LoginTelaState extends State<LoginTela> {

  TextEditingController email = TextEditingController();
  TextEditingController senha = TextEditingController();
  bool oculto = true;

  ocultarSenha(){
    oculto = !oculto;
    setState(() {});
  }

  //login teste
  //senha teste123
  fazerLogin(){
    if(email.text=='teste' && senha.text == 'teste123'){
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ReconhecimentoTela()));
    }else{
      showSnackBar(context, 'E-mail e/ou senha incorreto(s)', Cores.erro);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/imagens/logo.png',width: 300,),
            InputPadrao(
              controller: email,
              titulo: 'E - mail',
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                InputPadrao(
                  controller: senha,
                  titulo: 'Senha',
                  oculto: oculto,
                ),
                IconButton(
                  icon: Icon(oculto?Icons.remove_red_eye:Icons.remove_red_eye_outlined,color: Cores.corPrincipal,size: 30,),
                  onPressed: (){
                   ocultarSenha();
                  },
                )
              ],
            ),
            BotaoPadrao(
              titulo: 'Entrar',
              funcao: (){
                fazerLogin();
              }
            )
          ],
        ),
      ),
    );
  }
}
