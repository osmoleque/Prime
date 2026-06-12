class AnotacaoDiaria {
  DateTime data;
  String? humor; // Feliz, Neutro, Triste, Ansioso, Motivado
  String? desafios;
  String? vitorias;
  String? aprendizado;
  double nivelEnergia; // 1-10
  double nivelAnsiedade; // 1-10

  AnotacaoDiaria({
    required this.data,
    this.humor,
    this.desafios,
    this.vitorias,
    this.aprendizado,
    this.nivelEnergia = 5,
    this.nivelAnsiedade = 5,
  });

  Map<String, dynamic> toJson() => {
        'data': data.toIso8601String(),
        'humor': humor,
        'desafios': desafios,
        'vitorias': vitorias,
        'aprendizado': aprendizado,
        'nivelEnergia': nivelEnergia,
        'nivelAnsiedade': nivelAnsiedade,
      };

  factory AnotacaoDiaria.fromJson(Map<String, dynamic> json) => AnotacaoDiaria(
        data: DateTime.parse(json['data']),
        humor: json['humor'],
        desafios: json['desafios'],
        vitorias: json['vitorias'],
        aprendizado: json['aprendizado'],
        nivelEnergia: (json['nivelEnergia'] ?? 5).toDouble(),
        nivelAnsiedade: (json['nivelAnsiedade'] ?? 5).toDouble(),
      );
}
