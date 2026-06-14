class Rotina {
  String nome;
  List<String> tarefas;

  Rotina({required this.nome, required this.tarefas});

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'tarefas': tarefas,
      };

  factory Rotina.fromJson(Map<String, dynamic> json) => Rotina(
        nome: json['nome'],
        tarefas: List<String>.from(json['tarefas']),
      );
}