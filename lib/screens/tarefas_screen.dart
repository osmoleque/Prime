import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/rotina.dart';
import '../l10n/app_localizations.dart';

class TarefasScreen extends StatefulWidget {
  const TarefasScreen({super.key});
  @override
  State<TarefasScreen> createState() => _TarefasScreenState();
}

class _TarefasScreenState extends State<TarefasScreen> {
  DateTime _dataSelecionada = DateTime.now();
  bool _mostrarRotinasModelos = false;

  void _anterior() => setState(() =>
      _dataSelecionada = _dataSelecionada.subtract(const Duration(days: 1)));
  void _seguinte() => setState(() =>
      _dataSelecionada = _dataSelecionada.add(const Duration(days: 1)));

  bool get _ehHojeOuFuturo => !_dataSelecionada.isBefore(DateTime(
      DateTime.now().year, DateTime.now().month, DateTime.now().day));

  // Permite navegação para qualquer data a partir de 2020
  bool get _podeAnterior => _dataSelecionada.isAfter(DateTime(2020, 1, 1));

  final List<String> _sugestoesTarefasKeys = [
    'task_agua', 'task_meditar', 'task_ler', 'task_alongamento',
    'task_gratidao', 'task_cama', 'task_caminhar', 'task_estudar',
    'task_emails', 'task_planejar', 'task_louca', 'task_refeicao',
    'task_redes_1h', 'task_respirar', 'task_ajudar',
    'task_desconectar', 'task_ler_noticias', 'task_organizar_mesa',
    'task_alongamento_olhos', 'task_cha_verde',
  ];

  void _adicionarTarefaSugerida(String texto) {
    context.read<AppState>().adicionarTarefa(texto, _dataSelecionada);
  }

  void _mostrarModalNovaTarefa() {
    final appState = context.read<AppState>();
    final local = AppLocalizations.of(context);
    final cor = appState.corPrimaria;
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(local.translate('new_task'),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: cor)),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(local.translate('cancel')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              autofocus: true,
              style: TextStyle(color: cor),
              decoration: InputDecoration(
                hintText: local.translate('custom_task_hint'),
                hintStyle: TextStyle(color: cor.withValues(alpha: 0.5)),
                enabledBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: cor)),
                focusedBorder:
                    OutlineInputBorder(borderSide: BorderSide(color: cor)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add_circle, color: cor),
                  onPressed: () {
                    final texto = controller.text.trim();
                    if (texto.isNotEmpty) {
                      appState.adicionarTarefa(texto, _dataSelecionada);
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              onSubmitted: (texto) {
                final t = texto.trim();
                if (t.isNotEmpty) {
                  appState.adicionarTarefa(t, _dataSelecionada);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoNovaRotina() {
    final local = AppLocalizations.of(context);
    final cor = context.read<AppState>().corPrimaria;
    final nomeCtrl = TextEditingController();
    final tarefasCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(local.translate('new_routine'), style: TextStyle(color: cor)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: local.translate('routine_name'),
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: cor)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: tarefasCtrl,
                maxLines: 5,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: local.translate('routine_tasks'),
                  hintStyle: const TextStyle(color: Colors.white38),
                  enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: cor)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(local.translate('cancel'))),
          TextButton(
            onPressed: () {
              final nome = nomeCtrl.text.trim();
              final tarefas = tarefasCtrl.text
                  .split('\n')
                  .map((t) => t.trim())
                  .where((t) => t.isNotEmpty)
                  .toList();
              if (nome.isNotEmpty && tarefas.isNotEmpty) {
                context.read<AppState>().adicionarRotina(
                  Rotina(nome: nome, tarefas: tarefas),
                );
                Navigator.pop(ctx);
              }
            },
            child: Text(local.translate('add_routine')),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoNovoModelo() {
    final local = AppLocalizations.of(context);
    final cor = context.read<AppState>().corPrimaria;
    final nomeCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(local.translate('new_model'), style: TextStyle(color: cor)),
        content: TextField(
          controller: nomeCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: local.translate('model_name'),
            hintStyle: const TextStyle(color: Colors.white38),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: cor)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(local.translate('cancel'))),
          TextButton(
            onPressed: () {
              final nome = nomeCtrl.text.trim();
              if (nome.isNotEmpty) {
                context.read<AppState>().adicionarTarefaModelo(nome);
                Navigator.pop(ctx);
              }
            },
            child: Text(local.translate('add_model')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final local = AppLocalizations.of(context);
    final cor = appState.corPrimaria;
    final tarefasDoDia = appState.getTarefasDoDia(_dataSelecionada);
    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Cabeçalho com navegação
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (_podeAnterior)
                      IconButton(
                          onPressed: _anterior,
                          icon: Icon(Icons.chevron_left, color: cor))
                    else
                      const SizedBox(width: 48),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _dataSelecionada,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2030),
                          builder: (context, child) => Theme(
                            data: ThemeData.dark().copyWith(
                                colorScheme: ColorScheme.dark(primary: cor)),
                            child: child!,
                          ),
                        );
                        if (date != null) setState(() => _dataSelecionada = date);
                      },
                      child: Text(
                        DateFormat('EEEE, d MMM', locale.toString())
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
              ),
            ),
            // Sugestões rápidas (apenas para hoje ou futuro)
            if (_ehHojeOuFuturo)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        local.translate('add_tasks_initial'),
                        style: TextStyle(color: cor, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _sugestoesTarefasKeys.map((key) {
                          final texto = local.translate(key);
                          return ActionChip(
                            label: Text(texto,
                                style: const TextStyle(fontSize: 12)),
                            backgroundColor: Colors.white12,
                            labelStyle: TextStyle(color: cor),
                            onPressed: () => _adicionarTarefaSugerida(texto),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            // Botão expandir rotinas/modelos
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: InkWell(
                  onTap: () => setState(() => _mostrarRotinasModelos = !_mostrarRotinasModelos),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: cor.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_mostrarRotinasModelos ? Icons.expand_less : Icons.expand_more,
                            color: cor, size: 18),
                        const SizedBox(width: 6),
                        Text(local.translate('routines_and_models'),
                            style: TextStyle(color: cor, fontSize: 13)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Seção de rotinas e modelos (expansível)
            SliverToBoxAdapter(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: _mostrarRotinasModelos ? 220 : 0,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _mostrarRotinasModelos
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            // Rotinas
                            Text(local.translate('routines'),
                                style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            if (appState.rotinas.isEmpty)
                              Text(local.translate('no_tasks'),
                                  style: TextStyle(color: Colors.white38, fontSize: 12))
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: appState.rotinas.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final rotina = entry.value;
                                  return InputChip(
                                    label: Text(rotina.nome, style: const TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      for (var tarefa in rotina.tarefas) {
                                        appState.adicionarTarefa(tarefa, _dataSelecionada);
                                      }
                                      setState(() => _mostrarRotinasModelos = false);
                                    },
                                    onDeleted: () => appState.removerRotina(index),
                                    deleteIcon: const Icon(Icons.close, size: 14),
                                    backgroundColor: Colors.white12,
                                    labelStyle: TextStyle(color: cor),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 8),
                            // Modelos
                            Text(local.translate('models'),
                                style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            if (appState.tarefasModelo.isEmpty)
                              Text(local.translate('no_tasks'),
                                  style: TextStyle(color: Colors.white38, fontSize: 12))
                            else
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: appState.tarefasModelo.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final modelo = entry.value;
                                  return InputChip(
                                    label: Text(modelo, style: const TextStyle(fontSize: 12)),
                                    onPressed: () {
                                      appState.adicionarTarefa(modelo, _dataSelecionada);
                                      setState(() => _mostrarRotinasModelos = false);
                                    },
                                    onDeleted: () => appState.removerTarefaModelo(index),
                                    deleteIcon: const Icon(Icons.close, size: 14),
                                    backgroundColor: Colors.white12,
                                    labelStyle: TextStyle(color: cor),
                                  );
                                }).toList(),
                              ),
                            const SizedBox(height: 8),
                            // Botões para adicionar
                            Row(
                              children: [
                                TextButton.icon(
                                  onPressed: _mostrarDialogoNovaRotina,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(local.translate('new_routine'),
                                      style: const TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: cor),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: _mostrarDialogoNovoModelo,
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(local.translate('new_model'),
                                      style: const TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: cor),
                                ),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ),
            // Espaçamento
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            // Lista de tarefas do dia
            if (tarefasDoDia.isEmpty)
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(local.translate('no_tasks'),
                        style: TextStyle(color: Colors.white70)),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    final tarefa = tarefasDoDia[index];
                    final realIndex = appState.tarefas.indexOf(tarefa);
                    final podeMarcar =
                        !tarefa.data.isAfter(DateTime.now());
                    final podeRemover = _ehHojeOuFuturo;
                    return ListTile(
                      title: Text(
                        tarefa.titulo,
                        style: TextStyle(
                          color: tarefa.concluida
                              ? Colors.white38
                              : cor,
                          decoration: tarefa.concluida
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      leading: Checkbox(
                        value: tarefa.concluida,
                        onChanged: (value) {
                          if (!podeMarcar) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(local.translate(
                                    'task_future_warning')),
                                backgroundColor: Colors.orange.shade800,
                              ),
                            );
                            return;
                          }
                          appState.toggleTarefa(realIndex);
                        },
                        activeColor: cor,
                        checkColor: Colors.black,
                      ),
                      trailing: podeRemover
                          ? IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: cor),
                              onPressed: () =>
                                  appState.removerTarefa(realIndex),
                            )
                          : null,
                    );
                  },
                  childCount: tarefasDoDia.length,
                ),
              ),
            // Espaço extra para o FAB
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        ),
      ),
      // Botão flutuante para nova tarefa personalizada
      floatingActionButton: _ehHojeOuFuturo
          ? FloatingActionButton(
              heroTag: 'addTarefa',
              backgroundColor: cor,
              onPressed: _mostrarModalNovaTarefa,
              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,
    );
  }
}