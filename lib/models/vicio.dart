class Vicio {
  String nome;
  String icone;
  DateTime dataInicio;
  int recordeDiasLimpos;
  List<DateTime> recaidas;
  String? motivo;

  Vicio({
    required this.nome,
    required this.icone,
    required this.dataInicio,
    this.recordeDiasLimpos = 0,
    List<DateTime>? recaidas,
    this.motivo,
  }) : recaidas = recaidas ?? [];

  int get diasLimpos {
    if (recaidas.isEmpty) {
      return DateTime.now().difference(dataInicio).inDays;
    }
    final ultimaRecaida = recaidas.last;
    return DateTime.now().difference(ultimaRecaida).inDays;
  }

  Map<String, dynamic> toJson() => {
        'nome': nome,
        'icone': icone,
        'dataInicio': dataInicio.toIso8601String(),
        'recordeDiasLimpos': recordeDiasLimpos,
        'recaidas': recaidas.map((d) => d.toIso8601String()).toList(),
        'motivo': motivo,
      };

  factory Vicio.fromJson(Map<String, dynamic> json) => Vicio(
        nome: json['nome'],
        icone: json['icone'],
        dataInicio: DateTime.parse(json['dataInicio']),
        recordeDiasLimpos: json['recordeDiasLimpos'] ?? 0,
        recaidas: (json['recaidas'] as List?)
                ?.map((s) => DateTime.parse(s))
                .toList() ??
            [],
        motivo: json['motivo'],
      );
}