import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class CalendarioScreen extends StatefulWidget {
  const CalendarioScreen({super.key});

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  late DateTime _mesAtual;

  @override
  void initState() {
    super.initState();
    _mesAtual = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _anterior() =>
      setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month - 1));
  void _seguinte() =>
      setState(() => _mesAtual = DateTime(_mesAtual.year, _mesAtual.month + 1));

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cor = appState.corPrimaria;
    final diasNoMes = DateTime(_mesAtual.year, _mesAtual.month + 1, 0).day;
    final primeiroDiaSemana =
        DateTime(_mesAtual.year, _mesAtual.month, 1).weekday % 7;

    Set<DateTime> diasRecaida = {};
    for (var vicio in appState.vicios) {
      for (var rec in vicio.recaidas) {
        if (rec.year == _mesAtual.year && rec.month == _mesAtual.month) {
          diasRecaida.add(DateTime(rec.year, rec.month, rec.day));
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: _anterior,
                      icon: Icon(Icons.chevron_left, color: cor)),
                  Text(
                    DateFormat('MMMM yyyy', 'pt_BR').format(_mesAtual),
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: cor),
                  ),
                  IconButton(
                      onPressed: _seguinte,
                      icon: Icon(Icons.chevron_right, color: cor)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb']
                    .map(
                      (d) => Expanded(
                          child: Center(
                              child: Text(d, style: TextStyle(color: cor)))),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dia = index - primeiroDiaSemana + 1;
                    if (dia < 1 || dia > diasNoMes) return const SizedBox();
                    final data = DateTime(_mesAtual.year, _mesAtual.month, dia);
                    final isRecaida = diasRecaida.any((d) => d.day == dia);
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: isRecaida
                            ? Colors.red.shade900
                            : Colors.green.shade900,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                          child: Text('$dia',
                              style: const TextStyle(color: Colors.white))),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legenda('Sem recaída', Colors.green.shade900),
                  const SizedBox(width: 16),
                  _legenda('Com recaída', Colors.red.shade900),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _legenda(String texto, Color cor) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: cor),
        const SizedBox(width: 4),
        Text(texto, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
