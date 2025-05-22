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
              texto: 'Escolas',
              destino: CadastroEscolasTela(),
            ),
            ItemMenu(
              texto: 'Professores',
              destino: CadastroProfessoresTela(),
            ),
            ItemMenu(
              texto: 'Alunos',
              destino: CadastroAlunosTela(),
            ),
            ItemMenu(
              texto: 'Disciplinas',
              destino: CadastroDisciplinasTela(),
            ),
            ItemMenu(
              texto: 'Sair',
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
