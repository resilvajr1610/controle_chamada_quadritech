import 'package:flutter/material.dart';

import '../modelo/cores.dart';
import '../widgets/menu_web.dart';
import '../widgets/texto_padrao.dart';

class CadastroProfessoresTela extends StatefulWidget {
  const CadastroProfessoresTela({super.key});

  @override
  State<CadastroProfessoresTela> createState() => _CadastroProfessoresTelaState();
}

class _CadastroProfessoresTelaState extends State<CadastroProfessoresTela> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            iconTheme: IconThemeData(
                color: Colors.white
            ),
            backgroundColor: Cores.corPrincipal,
            title: TextoPadrao(texto: 'CADASTRO DE PROFESSORES',)
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
