import 'package:controle_chamada_quadritech/telas/chamadas_tela.dart';
import 'package:controle_chamada_quadritech/telas/turmas_tela.dart';
import 'package:controle_chamada_quadritech/widgets/logo_home.dart';
import 'package:flutter/material.dart';
import '../telas/alunos_tela.dart';
import '../telas/disciplinas_tela.dart';
import '../telas/escolas_tela.dart';
import '../telas/professores_tela.dart';
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
            Spacer(),
            ItemMenu(
              texto: 'ESCOLAS',
              destino: EscolasTela(),
            ),
            ItemMenu(
              texto: 'TURMAS',
              destino: TurmasTela(),
            ),
            ItemMenu(
              texto: 'DISCIPLINAS',
              destino: DisciplinasTela(),
            ),
            ItemMenu(
              texto: 'PROFESSORES',
              destino: ProfessoresTela(),
            ),
            ItemMenu(
              texto: 'ALUNOS',
              destino: AlunosTela(),
            ),
            ItemMenu(
              texto: 'CHAMADAS',
              destino: ChamadasTela(),
            ),
            Spacer(),
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
