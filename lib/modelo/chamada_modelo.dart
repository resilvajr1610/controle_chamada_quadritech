import 'package:cloud_firestore/cloud_firestore.dart';

class ChamadaModelo {
  String idPresenca;
  String idAluno;
  String nomeAluno;
  String idEscola;
  String nomeEscola;
  String idDisciplina;
  String nomeDisciplina;
  Timestamp dataHora;
  String situacao;

  ChamadaModelo({
    required this.idPresenca,
    required this.idAluno,
    required this.nomeAluno,
    required this.idEscola,
    required this.nomeEscola,
    required this.idDisciplina,
    required this.nomeDisciplina,
    required this.dataHora,
    required this.situacao,
  });
}