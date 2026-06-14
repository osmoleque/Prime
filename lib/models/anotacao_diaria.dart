class AnotacaoDiaria {
  DateTime data;
  String? textoDia;

  AnotacaoDiaria({required this.data, this.textoDia});

  Map<String, dynamic> toJson() => {
        'data': data.toIso8601String(),
        'textoDia': textoDia,
      };

  factory AnotacaoDiaria.fromJson(Map<String, dynamic> json) => AnotacaoDiaria(
        data: DateTime.parse(json['data']),
        textoDia: json['textoDia'],
      );
}