import 'package:controle_chamada_quadritech/telas/chamadas_tela.dart';
import 'package:controle_chamada_quadritech/telas/reconhecimento_tela.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
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
      debugShowCheckedModeBanner: false,
      title: 'Controle de Chamadas Quadritech',
      home: ChamadasTela(),
    )
  );
}
