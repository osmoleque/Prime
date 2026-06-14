import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import 'calendario_screen.dart';
import 'tarefas_screen.dart';
import 'abstinencia_screen.dart';
import 'registros_screen.dart';
import 'perfil_screen.dart';

class InicioScreen extends StatefulWidget {
  const InicioScreen({super.key});
  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  late Timer _timer;
  String _horaAtual = '';

  @override
  void initState() {
    super.initState();
    _atualizarHora();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _atualizarHora());
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _atualizarHora() {
    final now = DateTime.now();
    setState(() {
      _horaAtual =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final local = AppLocalizations.of(context);
    final temVicios = appState.vicios.isNotEmpty;
    final vicio = temVicios ? appState.vicioAtivo : null;
    final conquistas = appState.conquistasDesbloqueadas.toList()..sort();
    final cor = appState.corPrimaria;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(_horaAtual,
                      style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: cor)),
                  IconButton(
                    icon: Icon(Icons.settings, color: cor),
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PerfilScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: temVicios
                              ? null
                              : () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AbstinenciaScreen())),
                          child: Card(
                            color: Colors.white10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: temVicios
                                    ? BorderSide.none
                                    : BorderSide(color: cor, width: 1.5)),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: temVicios
                                  ? Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(vicio!.icone,
                                                  style: const TextStyle(
                                                      fontSize: 32)),
                                              const SizedBox(width: 8),
                                              Text('${vicio.diasLimpos}',
                                                  style: TextStyle(
                                                      fontSize: 48,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: cor)),
                                            ]),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${local.translate('clean_days_of')} ${vicio.nome}',
                                            style: const TextStyle(fontSize: 14)),
                                        if (vicio.motivo != null &&
                                            vicio.motivo!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            '"${vicio.motivo}"',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontStyle: FontStyle.italic,
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ],
                                    )
                                  : Column(
                                      children: [
                                        Container(
                                          width: 64, height: 64,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                  color: cor, width: 2)),
                                          child: Icon(Icons.add,
                                              size: 32, color: cor),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(local.translate('add_vice'),
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: cor)),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (temVicios && conquistas.isNotEmpty)
                          Card(
                            color: Colors.white10,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(local.translate('achievements'),
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: cor)),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    children: conquistas.map((dias) {
                                      String emoji = dias >= 365
                                          ? '👑'
                                          : dias >= 180
                                              ? '🏆'
                                              : dias >= 90
                                                  ? '💪'
                                                  : dias >= 60
                                                      ? '🌟'
                                                      : dias >= 30
                                                          ? '🏅'
                                                          : '🎖️';
                                      return Chip(
                                        avatar: Text(emoji,
                                            style: const TextStyle(fontSize: 18)),
                                        label: Text('$dias d',
                                            style: const TextStyle(color: Colors.black)),
                                        backgroundColor: cor,
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: cor.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(appState.fraseDia,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.white70)),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _atalho(context, local.translate('calendar'),
                                Icons.calendar_month, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const CalendarioScreen()));
                            }),
                            const SizedBox(width: 24),
                            _atalho(context, local.translate('tasks'),
                                Icons.check_circle_outline, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const TarefasScreen()));
                            }),
                            const SizedBox(width: 24),
                            _atalho(context, local.translate('vices'),
                                Icons.shield_outlined, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const AbstinenciaScreen()));
                            }),
                            const SizedBox(width: 24),
                            _atalho(context, local.translate('records'),
                                Icons.book_outlined, () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => const RegistrosScreen()));
                            }),
                          ],
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

  Widget _atalho(BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final cor = context.read<AppState>().corPrimaria;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: cor, size: 32),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: cor, fontSize: 13)),
        ],
      ),
    );
  }
}