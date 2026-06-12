class Habito {
  String titulo;
  bool concluido;

  Habito({required this.titulo, this.concluido = false});

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'concluido': concluido,
      };

  factory Habito.fromJson(Map<String, dynamic> json) => Habito(
        titulo: json['titulo'],
        concluido: json['concluido'] ?? false,
      );
}
