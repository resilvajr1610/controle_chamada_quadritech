class AlunoModelo {
  String idAluno;
  String nomeAluno;
  String idEscola;
  String nomeEscola;
  List idDisciplinas;
  String endereco;
  int numero;
  String bairro;
  String cidade;
  String cep;
  String numeroRegistro;
  String ensino;
  String sexo;
  int idade;
  String estadoCivil;
  String curso;
  int ano;
  String urlImagem;

  AlunoModelo({
    required this.idAluno,
    required this.nomeAluno,
    required this.idEscola,
    required this.nomeEscola,
    required this.idDisciplinas,
    required this.endereco,
    required this.numero,
    required this.bairro,
    required this.cidade,
    required this.cep,
    required this.numeroRegistro,
    required this.ensino,
    required this.sexo,
    required this.idade,
    required this.estadoCivil,
    required this.curso,
    required this.ano,
    required this.urlImagem,
  });
}