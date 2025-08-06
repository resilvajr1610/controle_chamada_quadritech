class AlunoModelo {
  String idAluno;
  String nomeAluno;
  String idEscola;
  String nomeEscola;
  String numeroRegistro;
  String urlImagem;
  List idCursos;
  List idTurmas;

  AlunoModelo({
    required this.idAluno,
    required this.nomeAluno,
    required this.idEscola,
    required this.nomeEscola,
    required this.numeroRegistro,
    required this.urlImagem,
    required this.idCursos,
    required this.idTurmas,
  });
}