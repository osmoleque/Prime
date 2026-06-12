import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});

  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  DateTime _dataSelecionada = DateTime.now();
  final _novaTarefaCtrl = TextEditingController();

  void _anterior() => setState(() =>
      _dataSelecionada = _dataSelecionada.subtract(const Duration(days: 1)));
  void _seguinte() => setState(
      () => _dataSelecionada = _dataSelecionada.add(const Duration(days: 1)));

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cor = appState.corPrimaria;
    final tarefasDoDia = appState.getTarefasDoDia(_dataSelecionada);

    final sugestoes = [
      'Beber 2L de água',
      'Meditar 10 min',
      'Ler 20 páginas',
      'Alongamento',
      'Diário de gratidão'
    ];

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
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _dataSelecionada,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) => Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(primary: cor),
                          ),
                          child: child!,
                        ),
                      );
                      if (date != null) setState(() => _dataSelecionada = date);
                    },
                    child: Text(
                      DateFormat('EEEE, d MMM', 'pt_BR')
                          .format(_dataSelecionada),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: cor),
                    ),
                  ),
                  IconButton(
                      onPressed: _seguinte,
                      icon: Icon(Icons.chevron_right, color: cor)),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: sugestoes
                    .map((s) => ActionChip(
                          label: Text(s,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black)),
                          backgroundColor: cor,
                          onPressed: () {
                            appState.adicionarTarefa(s, _dataSelecionada);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _novaTarefaCtrl,
                      style: TextStyle(color: cor),
                      decoration: InputDecoration(
                        hintText: 'Nova tarefa...',
                        hintStyle: TextStyle(color: cor.withValues(alpha: 0.5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cor)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.add_circle, color: cor),
                          onPressed: () {
                            final texto = _novaTarefaCtrl.text.trim();
                            if (texto.isNotEmpty) {
                              appState.adicionarTarefa(texto, _dataSelecionada);
                              _novaTarefaCtrl.clear();
                            }
                          },
                        ),
                      ),
                      onSubmitted: (texto) {
                        final t = texto.trim();
                        if (t.isNotEmpty) {
                          appState.adicionarTarefa(t, _dataSelecionada);
                          _novaTarefaCtrl.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: tarefasDoDia.isEmpty
                    ? Center(
                        child: Text('Nenhuma tarefa para este dia',
                            style: TextStyle(color: Colors.white38)),
                      )
                    : ListView.builder(
                        itemCount: tarefasDoDia.length,
                        itemBuilder: (_, index) {
                          final tarefa = tarefasDoDia[index];
                          final realIndex = appState.tarefas.indexOf(tarefa);
                          return ListTile(
                            title: Text(
                              tarefa.titulo,
                              style: TextStyle(
                                color: tarefa.concluida ? Colors.white38 : cor,
                                decoration: tarefa.concluida
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            leading: Checkbox(
                              value: tarefa.concluida,
                              onChanged: (_) =>
                                  appState.toggleTarefa(realIndex),
                              activeColor: cor,
                              checkColor: Colors.black,
                            ),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline, color: cor),
                              onPressed: () =>
                                  appState.removerTarefa(realIndex),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
