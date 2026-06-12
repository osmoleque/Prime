import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class HabitosScreen extends StatefulWidget {
  const HabitosScreen({super.key});

  @override
  State<HabitosScreen> createState() => _HabitosScreenState();
}

class _HabitosScreenState extends State<HabitosScreen> {
  final _controller = TextEditingController();

  final List<String> sugestoes = [
    'Beber água',
    'Meditar',
    'Ler 10 páginas',
    'Alongamento'
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cor = appState.corPrimaria;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Progresso do dia
              LinearProgressIndicator(
                value: appState.progressoHabitos,
                backgroundColor: Colors.white24,
                color: cor,
              ),
              const SizedBox(height: 8),
              Text(
                '${appState.concluidosHabitos}/${appState.habitos.length} concluídos (${(appState.progressoHabitos * 100).round()}%)',
                style: TextStyle(color: cor),
              ),
              const SizedBox(height: 16),
              // Lista de hábitos
              Expanded(
                child: ListView.builder(
                  itemCount: appState.habitos.length,
                  itemBuilder: (_, index) {
                    final habito = appState.habitos[index];
                    return ListTile(
                      title: Text(habito.titulo, style: TextStyle(color: cor)),
                      leading: Checkbox(
                        value: habito.concluido,
                        onChanged: (_) => appState.toggleHabito(index),
                        activeColor: cor,
                        checkColor: Colors.black,
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline, color: cor),
                        onPressed: () => appState.removerHabito(index),
                      ),
                    );
                  },
                ),
              ),
              // Sugestões rápidas
              Wrap(
                spacing: 8,
                children: sugestoes
                    .map((s) => ActionChip(
                          label: Text(s,
                              style: const TextStyle(color: Colors.black)),
                          backgroundColor: cor,
                          onPressed: () {
                            appState.adicionarHabito(s);
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: TextStyle(color: cor),
                      decoration: InputDecoration(
                        hintText: 'Hábito personalizado...',
                        hintStyle: TextStyle(color: cor.withValues(alpha: 0.5)),
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cor)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: cor)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.add_circle, color: cor),
                    onPressed: () {
                      if (_controller.text.trim().isNotEmpty) {
                        appState.adicionarHabito(_controller.text.trim());
                        _controller.clear();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
