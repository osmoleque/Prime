import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../widgets/cor_seletor.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final local = AppLocalizations.of(context);
    final cor = appState.corPrimaria;
    final marcos = appState.marcosConquistas;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(local.translate('achievements'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: marcos.length,
                itemBuilder: (_, index) {
                  final dias = marcos[index];
                  final desbloqueado = appState.conquistasDesbloqueadas.contains(dias);
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        desbloqueado ? Icons.emoji_events : Icons.lock,
                        size: 36,
                        color: desbloqueado ? cor : Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      Text('$dias d', style: TextStyle(fontSize: 12, color: desbloqueado ? cor : Colors.grey)),
                    ],
                  );
                },
              ),
              const Divider(color: Colors.white24, height: 32),
              Text(local.translate('language'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: cor.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: appState.idioma,
                  isExpanded: true,
                  underline: const SizedBox(),
                  dropdownColor: Colors.black,
                  style: TextStyle(color: cor),
                  items: const [
                    DropdownMenuItem(value: 'pt_BR', child: Text('🇧🇷 Português')),
                    DropdownMenuItem(value: 'en_US', child: Text('🇺🇸 English')),
                    DropdownMenuItem(value: 'es_ES', child: Text('🇪🇸 Español')),
                  ],
                  onChanged: (v) {
                    if (v != null) appState.setIdioma(v);
                  },
                ),
              ),
              const Divider(color: Colors.white24, height: 32),
              Text(local.translate('color'),
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cor)),
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
                    backgroundColor: Colors.red.shade900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.delete_forever),
                  label: Text(local.translate('delete_all')),
                  onPressed: () => _confirmarReset(context, appState, local),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarReset(BuildContext context, AppState appState, AppLocalizations local) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(local.translate('delete_all')),
        content: Text(local.translate('delete_confirm')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(local.translate('cancel'))),
          TextButton(
            onPressed: () {
              appState.apagarTodosDados();
              Navigator.pop(context);
            },
            child: Text(local.translate('confirm')),
          ),
        ],
      ),
    );
  }
}