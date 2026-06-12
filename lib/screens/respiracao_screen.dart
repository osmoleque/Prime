import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class RespiracaoScreen extends StatefulWidget {
  const RespiracaoScreen({super.key});

  @override
  State<RespiracaoScreen> createState() => _RespiracaoScreenState();
}

class _RespiracaoScreenState extends State<RespiracaoScreen> {
  int _segundosRestantes = 300; // 5 min
  Timer? _timer;
  bool _iniciado = false;

  void _iniciarTimer() {
    if (_timer != null) return;
    _iniciado = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_segundosRestantes <= 1) {
        t.cancel();
        setState(() => _segundosRestantes = 0);
      } else {
        setState(() => _segundosRestantes--);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatar(int segundos) {
    final min = segundos ~/ 60;
    final seg = segundos % 60;
    return '${min.toString().padLeft(2, '0')}:${seg.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final cor = appState.corPrimaria;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _formatar(_segundosRestantes),
                  style: TextStyle(
                      fontSize: 72, fontWeight: FontWeight.bold, color: cor),
                ),
                const SizedBox(height: 24),
                if (!_iniciado)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: cor),
                    onPressed: _iniciarTimer,
                    child: const Text('Iniciar respiração',
                        style: TextStyle(color: Colors.black)),
                  ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: cor.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(appState.fraseDia,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: cor)),
                      const SizedBox(height: 8),
                      if (appState.motivoPessoal.isNotEmpty)
                        Text('"${appState.motivoPessoal}"',
                            style: TextStyle(
                                color: cor, fontWeight: FontWeight.w600)),
                      TextButton(
                        onPressed: () => _editarMotivo(context, appState),
                        child: const Text('Editar motivo pessoal'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _editarMotivo(BuildContext context, AppState appState) {
    final controller = TextEditingController(text: appState.motivoPessoal);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Motivo pessoal'),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration:
              const InputDecoration(hintText: 'Por que você quer parar?'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          TextButton(
            onPressed: () {
              appState.setMotivoPessoal(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }
}
