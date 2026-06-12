import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/cor_seletor.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cor = appState.corPrimaria;

    // Conquistas
    final marcos = [1, 7, 30, 90, 365];
    final icones = ['🥇', '🥈', '🥉', '🏅', '🏆'];

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Conquistas',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: List.generate(marcos.length, (i) {
                  final desbloqueado =
                      appState.conquistasDesbloqueadas.contains(marcos[i]);
                  return Column(
                    children: [
                      Icon(
                        desbloqueado ? Icons.emoji_events : Icons.lock,
                        size: 40,
                        color: desbloqueado ? cor : Colors.grey,
                      ),
                      Text('${marcos[i]} dias',
                          style: TextStyle(
                              color: desbloqueado ? cor : Colors.grey)),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 24),
              Text('Cor Principal', style: TextStyle(fontSize: 20, color: cor)),
              const SizedBox(height: 8),
              CorSeletor(
                corAtual: appState.corPrimaria,
                onCorSelecionada: (c) => appState.setCorPrimaria(c),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade900),
                  icon: const Icon(Icons.delete_forever, color: Colors.white),
                  label: const Text('Apagar todos os dados',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Colors.grey[900],
                      title: const Text('Reset total'),
                      content: const Text(
                          'Todos os dados serão perdidos. Continuar?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar')),
                        TextButton(
                          onPressed: () {
                            appState.apagarTodosDados();
                            Navigator.pop(context);
                          },
                          child: const Text('Sim, apagar tudo'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
