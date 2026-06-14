import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/anotacao_diaria.dart';

class RegistrosScreen extends StatelessWidget {
  const RegistrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final local = AppLocalizations.of(context);
    final cor = appState.corPrimaria;
    final anotacoes = List<AnotacaoDiaria>.from(appState.anotacoes);

    if (anotacoes.isNotEmpty) {
      anotacoes.sort((a, b) => b.data.compareTo(a.data));
    }

    final locale = Localizations.localeOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                local.translate('registros_title'),
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cor),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: anotacoes.isEmpty
                    ? Center(
                        child: Text(
                          local.translate('no_records'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                      )
                    : ListView.builder(
                        itemCount: anotacoes.length,
                        itemBuilder: (_, index) {
                          final a = anotacoes[index];
                          return Card(
                            color: Colors.white10,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                DateFormat('dd/MM/yyyy', locale.toString()).format(a.data),
                                style: TextStyle(color: cor, fontWeight: FontWeight.bold),
                              ),
                              subtitle: a.textoDia != null && a.textoDia!.isNotEmpty
                                  ? Text(
                                      a.textoDia!,
                                      style: TextStyle(color: Colors.white70),
                                    )
                                  : null,
                              trailing: Icon(Icons.visibility, color: cor.withValues(alpha: 0.5)),
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