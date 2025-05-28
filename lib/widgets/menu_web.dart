import 'package:controle_chamada_quadritech/widgets/logo_home.dart';
import 'package:flutter/material.dart';
import '../telas/cadastro_alunos_tela.dart';
import '../telas/cadastro_disciplinas_tela.dart';
import '../telas/cadastro_escolas_tela.dart';
import '../telas/cadastro_professores_tela.dart';
import '../telas/login_tela.dart';
import 'item_menu.dart';

class MenuWeb extends StatelessWidget {
  const MenuWeb({super.key});

  @override
  Widget build(BuildContext context) {

    double largura = MediaQuery.of(context).size.width;

    return  Column(
      children: [
        Row(
          children: [
            LogoHome(),
            ItemMenu(
              texto: 'ESCOLAS',
              destino: CadastroEscolasTela(),
            ),
            ItemMenu(
              texto: 'DISCIPLINAS',
              destino: CadastroDisciplinasTela(),
            ),
            ItemMenu(
              texto: 'PROFESSORES',
              destino: CadastroProfessoresTela(),
            ),
            ItemMenu(
              texto: 'ALUNOS',
              destino: CadastroAlunosTela(),
            ),
            ItemMenu(
              texto: 'SAIR',
              destino: LoginTela(),
            ),
          ],
        ),
        Container(
          height: 2,
          width: largura,
          child: Divider(
            thickness: 2.0,
          ),
        )
      ],
    );
  }
}
