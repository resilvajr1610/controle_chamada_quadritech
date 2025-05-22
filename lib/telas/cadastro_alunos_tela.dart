import 'package:flutter/material.dart';

import '../modelo/cores.dart';
import '../widgets/menu_web.dart';
import '../widgets/texto_padrao.dart';

class CadastroAlunosTela extends StatefulWidget {
  const CadastroAlunosTela({super.key});

  @override
  State<CadastroAlunosTela> createState() => _CadastroAlunosTelaState();
}

class _CadastroAlunosTelaState extends State<CadastroAlunosTela> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white
            ),
            backgroundColor: Cores.corPrincipal,
            title: TextoPadrao(texto: 'CADASTRO DE ALUNOS',)
        ),
        body: Container(
          child: Row(
            children: [
              MenuWeb()
            ],
          ),
        )
    );
  }
}
