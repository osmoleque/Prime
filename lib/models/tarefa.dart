class Tarefa {
  String titulo;
  DateTime data;
  bool concluida;

  Tarefa({required this.titulo, required this.data, this.concluida = false});

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'data': data.toIso8601String(),
        'concluida': concluida,
      };

  factory Tarefa.fromJson(Map<String, dynamic> json) => Tarefa(
        titulo: json['titulo'],
        data: DateTime.parse(json['data']),
        concluida: json['concluida'] ?? false,
      );
}
