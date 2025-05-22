import 'package:flutter/material.dart';

import '../modelo/cores.dart';
import '../widgets/menu_web.dart';
import '../widgets/texto_padrao.dart';

class CadastroDisciplinasTela extends StatefulWidget {
  const CadastroDisciplinasTela({super.key});

  @override
  State<CadastroDisciplinasTela> createState() => _CadastroDisciplinasTelaState();
}

class _CadastroDisciplinasTelaState extends State<CadastroDisciplinasTela> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white
            ),
            backgroundColor: Cores.corPrincipal,
            title: TextoPadrao(texto: 'CADASTRO DE DISCIPLINAS',)
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
