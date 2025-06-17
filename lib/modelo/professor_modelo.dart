class ProfessorModelo {
  String idProf;
  String nomeProf;
  String idEscola;
  String nomeEscola;
  List idDisciplinas;
  String bairro;
  String cep;
  String cidade;
  String endereco;
  String ensino;
  int numero;
  String numeroRegistro;
  int idade;
  String estadoCivil;
  String curso;
  int ano;
  String formacao;

  ProfessorModelo({
    required this.idProf,
    required this.idEscola,
    required this.nomeEscola,
    required this.bairro,
    required this.cep,
    required this.cidade,
    required this.endereco,
    required this.ensino,
    required this.nomeProf,
    required this.numero,
    required this.numeroRegistro,
    required this.idade,
    required this.estadoCivil,
    required this.curso,
    required this.ano,
    required this.idDisciplinas,
    required this.formacao,
  });
}