class RegistroHumor {
  DateTime data;
  String humor; // Excelente, Bom, Neutro, Difícil, Muito difícil
  String? observacao;

  RegistroHumor({
    required this.data,
    required this.humor,
    this.observacao,
  });

  Map<String, dynamic> toJson() => {
        'data': data.toIso8601String(),
        'humor': humor,
        'observacao': observacao,
      };

  factory RegistroHumor.fromJson(Map<String, dynamic> json) => RegistroHumor(
        data: DateTime.parse(json['data']),
        humor: json['humor'],
        observacao: json['observacao'],
      );
}
