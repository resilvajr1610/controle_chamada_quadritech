import 'package:controle_chamada_quadritech/telas/alunos_tela.dart';
import 'package:controle_chamada_quadritech/telas/disciplinas_tela.dart';
import 'package:controle_chamada_quadritech/telas/escolas_tela.dart';
import 'package:controle_chamada_quadritech/telas/login_tela.dart';
import 'package:controle_chamada_quadritech/telas/professores_tela.dart';
import 'package:controle_chamada_quadritech/telas/reconhecimento_tela.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDnTpi7ISyosCjN3b7yxjhQVTTFJ8y5M2E",
      appId: "1:833365360200:web:378902b42eda811d30e27d",
      messagingSenderId: "833365360200",
      projectId: "controle-chamadas-quadritech",
      storageBucket: "controle-chamadas-quadritech.firebasestorage.app",
    )
  );
  runApp(
    MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: 'Controle de Chamadas Quadritech',
      home: AlunosTela(),
    )
  );
}
