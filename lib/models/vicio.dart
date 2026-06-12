class Vicio {
  String nome;
  String icone;
  DateTime dataInicio;
  int recordeDiasLimpos; // maior sequência histórica
  List<DateTime> recaidas; // datas de recaída

  Vicio({
    required this.nome,
    required this.icone,
    required this.dataInicio,
    this.recordeDiasLimpos = 0,
    List<DateTime>? recaidas,
  }) : recaidas = recaidas ?? [];

  int get diasLimpos {
    if (recaidas.isEmpty) {
      return DateTime.now().difference(dataInicio).inDays;
    }
    // Pega a última recaída
    final ultimaRecaida = recaidas.last;
    return DateTime.now().difference(ultimaRecaida).inDays;
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'icone': icone,
      'dataInicio': dataInicio.toIso8601String(),
      'recordeDiasLimpos': recordeDiasLimpos,
      'recaidas': recaidas.map((d) => d.toIso8601String()).toList(),
    };
  }

  factory Vicio.fromJson(Map<String, dynamic> json) {
    return Vicio(
      nome: json['nome'],
      icone: json['icone'],
      dataInicio: DateTime.parse(json['dataInicio']),
      recordeDiasLimpos: json['recordeDiasLimpos'] ?? 0,
      recaidas:
          (json['recaidas'] as List?)?.map((s) => DateTime.parse(s)).toList() ??
              [],
    );
  }
}
