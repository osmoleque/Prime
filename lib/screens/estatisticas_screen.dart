import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class EstatisticasScreen extends StatelessWidget {
  const EstatisticasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cor = appState.corPrimaria;

    final totalAnotacoes = appState.anotacoes.length;
    final diasLimpos = appState.diasLimposTotal;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumo Geral',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: cor)),
              const SizedBox(height: 8),
              _infoCard('Total de dias limpos (maior): $diasLimpos', cor),
              _infoCard('Total de anotações: $totalAnotacoes', cor),
              const SizedBox(height: 16),
              Text('Vícios',
                  style: TextStyle(fontSize: 18, color: cor)),
              if (appState.vicios.isEmpty)
                const Text('Nenhum vício cadastrado.',
                    style: TextStyle(color: Colors.white70))
              else
                ...appState.vicios.map((v) => ListTile(
                      leading: Text(v.icone,
                          style: const TextStyle(fontSize: 24)),
                      title: Text(v.nome, style: TextStyle(color: cor)),
                      subtitle: Text(
                          '${v.diasLimpos} dias limpos | Recorde: ${v.recordeDiasLimpos}',
                          style: TextStyle(color: Colors.white70)),
                    )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(String texto, Color cor) => Card(
        color: Colors.white10,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(texto, style: TextStyle(color: cor)),
        ),
      );
}