import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

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

  bool _temDadosNoMes(AppState appState, DateTime mes) {
    for (var vicio in appState.vicios) {
      if (vicio.dataInicio.year < mes.year ||
          (vicio.dataInicio.year == mes.year && vicio.dataInicio.month <= mes.month)) {
        return true;
      }
    }
    for (var vicio in appState.vicios) {
      for (var rec in vicio.recaidas) {
        if (rec.year == mes.year && rec.month == mes.month) return true;
      }
    }
    for (var tarefa in appState.tarefas) {
      if (tarefa.data.year == mes.year && tarefa.data.month == mes.month) return true;
    }
    for (var anotacao in appState.anotacoes) {
      if (anotacao.data.year == mes.year && anotacao.data.month == mes.month) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final local = AppLocalizations.of(context);
    final cor = appState.corPrimaria;

    final hoje = DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);

    final diasNoMes = DateTime(_mesAtual.year, _mesAtual.month + 1, 0).day;
    final primeiroDiaSemana = DateTime(_mesAtual.year, _mesAtual.month, 1).weekday % 7;
    final locale = Localizations.localeOf(context);

    final mesAnterior = DateTime(_mesAtual.year, _mesAtual.month - 1);
    final podeVoltar = _temDadosNoMes(appState, mesAnterior);

    // ---- INFORMAÇÕES DO VÍCIO ATIVO ----
    final temVicio = appState.vicios.isNotEmpty;
    final inicioVicio = temVicio ? appState.vicioAtivo.dataInicio : null;

    // ---- RECAÍDAS ----
    Set<DateTime> diasRecaida = {};
    int recaidasNoMes = 0;
    for (var vicio in appState.vicios) {
      for (var rec in vicio.recaidas) {
        if (rec.year == _mesAtual.year && rec.month == _mesAtual.month) {
          diasRecaida.add(DateTime(rec.year, rec.month, rec.day));
          recaidasNoMes++;
        }
      }
    }

    // ---- TAREFAS CONCLUÍDAS ----
    int tarefasConcluidasNoMes = 0;
    for (var tarefa in appState.tarefas) {
      if (tarefa.concluida &&
          tarefa.data.year == _mesAtual.year &&
          tarefa.data.month == _mesAtual.month) {
        tarefasConcluidasNoMes++;
      }
    }

    // ---- DIAS LIMPOS (apenas se houver vício) ----
    int diasLimposNoMes = 0;
    if (temVicio) {
      final vicio = appState.vicioAtivo;
      for (int dia = 1; dia <= diasNoMes; dia++) {
        final data = DateTime(_mesAtual.year, _mesAtual.month, dia);
        if (data.isAfter(inicioHoje)) continue; // ignora dias futuros

        final temRecaida = vicio.recaidas.any((r) =>
            r.year == data.year && r.month == data.month && r.day == data.day);
        // Dia é limpo se não tem recaída e está no período de abstinência
        if (!temRecaida && (inicioVicio == null || !data.isBefore(inicioVicio))) {
          diasLimposNoMes++;
        }
      }
    }

    // ---- DIAS DA SEMANA TRADUZIDOS ----
    final diasSemana = [
      local.translate('sun_short'),
      local.translate('mon_short'),
      local.translate('tue_short'),
      local.translate('wed_short'),
      local.translate('thu_short'),
      local.translate('fri_short'),
      local.translate('sat_short'),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Cabeçalho do mês
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (podeVoltar)
                    IconButton(
                      onPressed: _anterior,
                      icon: Icon(Icons.chevron_left, color: cor),
                    )
                  else
                    const SizedBox(width: 48),
                  Text(
                    DateFormat('MMMM yyyy', locale.toString()).format(_mesAtual),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: cor),
                  ),
                  IconButton(
                    onPressed: _seguinte,
                    icon: Icon(Icons.chevron_right, color: cor),
                  ),
                ],
              ),
              // Mensagem caso não haja vícios
              if (!temVicio)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    local.translate('add_vice'),
                    style: TextStyle(color: cor.withValues(alpha: 0.7), fontSize: 14),
                  ),
                ),
              const SizedBox(height: 8),
              // Cards de estatísticas
              Row(
                children: [
                  _buildStatCard(
                    title: local.translate('clean_days'),
                    value: '$diasLimposNoMes',
                    color: Colors.green,
                    corPrimaria: cor,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    title: local.translate('recaidas'),
                    value: '$recaidasNoMes',
                    color: Colors.red,
                    corPrimaria: cor,
                  ),
                  const SizedBox(width: 8),
                  _buildStatCard(
                    title: local.translate('task_count'),
                    value: '$tarefasConcluidasNoMes',
                    color: Colors.blue,
                    corPrimaria: cor,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Dias da semana
              Row(
                children: diasSemana
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: TextStyle(color: cor, fontSize: 13, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              // Grade de dias
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                  ),
                  itemCount: 42,
                  itemBuilder: (context, index) {
                    final dia = index - primeiroDiaSemana + 1;
                    if (dia < 1 || dia > diasNoMes) return const SizedBox();

                    final data = DateTime(_mesAtual.year, _mesAtual.month, dia);
                    final isRecaida = diasRecaida.any((d) => d.day == dia);
                    final isFuturo = data.isAfter(inicioHoje);
                    final isAntesInicio = (inicioVicio != null) &&
                        data.isBefore(DateTime(inicioVicio.year, inicioVicio.month, inicioVicio.day));
                    final isHoje = data.year == hoje.year &&
                        data.month == hoje.month &&
                        data.day == hoje.day;

                    // CORREÇÃO PRINCIPAL: quando não há vícios, tudo é "sem dados"
                    final semDados = !temVicio || isFuturo || isAntesInicio;

                    Color bgColor;
                    if (isRecaida) {
                      bgColor = Colors.red.shade900;
                    } else if (semDados) {
                      bgColor = Colors.grey[850]!;
                    } else {
                      bgColor = Colors.green.shade900;
                    }

                    return Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(6),
                        border: isHoje
                            ? Border.all(color: cor, width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dia',
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              // Legenda
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _legenda(local.translate('legend_clean'), Colors.green.shade900),
                  const SizedBox(width: 16),
                  _legenda(local.translate('legend_relapse'), Colors.red.shade900),
                  const SizedBox(width: 16),
                  _legenda(local.translate('no_data'), Colors.grey[850]!),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required Color corPrimaria,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: corPrimaria.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _legenda(String texto, Color cor) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: cor, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}