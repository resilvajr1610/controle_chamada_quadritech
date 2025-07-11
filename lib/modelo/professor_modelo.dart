class ProfessorModelo {
  String idProf;
  String nomeProf;
  String idEscola;
  String nomeEscola;
  List idDisciplinas;
  String numeroRegistro;
  String urlImagem;

  ProfessorModelo({
    required this.idProf,
    required this.idEscola,
    required this.nomeEscola,
    required this.nomeProf,
    required this.numeroRegistro,
    required this.idDisciplinas,
    required this.urlImagem,
  });
}