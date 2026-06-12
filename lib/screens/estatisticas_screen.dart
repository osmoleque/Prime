import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../widgets/anotacao_dialog.dart';

class RegistrosScreen extends StatelessWidget {
  const RegistrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final cor = appState.corPrimaria;
    final anotacoes = appState.anotacoes;

    // Ordenar por data decrescente
    anotacoes.sort((a, b) => b.data.compareTo(a.data));

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registros de Anotações',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: cor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: anotacoes.isEmpty
                    ? Center(
                        child: Text(
                          'Nenhuma anotação registrada.\nUse o botão "Anotar dia" na tela de Vícios.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: anotacoes.length,
                        itemBuilder: (_, index) {
                          final anotacao = anotacoes[index];
                          return Card(
                            color: Colors.white10,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                DateFormat('dd/MM/yyyy').format(anotacao.data),
                                style: TextStyle(
                                    color: cor, fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                anotacao.humor ?? 'Sem humor',
                                style: TextStyle(color: cor.withValues(alpha: 0.7)),
                              ),
                              trailing: Icon(Icons.edit_note, color: cor),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) =>
                                      AnotacaoDialog(data: anotacao.data),
                                );
                              },
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
