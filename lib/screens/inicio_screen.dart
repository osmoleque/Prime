import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import 'respiracao_screen.dart';
import 'diario_humor_screen.dart';
import 'calendario_screen.dart';
import 'tarefas_screen.dart';
import 'abstinencia_screen.dart';
import 'registros_screen.dart';

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
    _timer =
        Timer.periodic(const Duration(seconds: 1), (_) => _atualizarHora());
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
    final temVicios = appState.vicios.isNotEmpty;
    final vicio = temVicios ? appState.vicioAtivo : null;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Relógio + ajuda
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _horaAtual,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: appState.corPrimaria,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.help_outline, color: appState.corPrimaria),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RespiracaoScreen()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Card tracker
              Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: temVicios
                      ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(vicio!.icone,
                                    style: const TextStyle(fontSize: 32)),
                                const SizedBox(width: 8),
                                Text(
                                  '${vicio.diasLimpos}',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: appState.corPrimaria,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text('dias limpos de ${vicio.nome}',
                                style: const TextStyle(fontSize: 14)),
                          ],
                        )
                      : const Column(
                          children: [
                            Icon(Icons.add_circle_outline,
                                size: 48, color: Colors.white38),
                            SizedBox(height: 8),
                            Text(
                              'Adicione um vício para começar a contar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 14, color: Colors.white54),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 16),
              // Nível e XP
              Card(
                color: Colors.white10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        'Nível: ${appState.nivelTitulo}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: appState.corPrimaria,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: appState.xpProgresso,
                        backgroundColor: Colors.white24,
                        color: appState.corPrimaria,
                      ),
                      const SizedBox(height: 4),
                      Text('${appState.xp} XP',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Botão "Resisti ao Impulso" – só aparece se houver vício ativo
              if (temVicios)
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appState.resistiuHoje
                          ? Colors.grey[800]
                          : appState.corPrimaria,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: appState.resistiuHoje
                        ? null
                        : () => appState.resistirImpulso(),
                    child: Text(
                      appState.resistiuHoje
                          ? 'Já resistiu hoje'
                          : 'Resisti ao Impulso',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              if (temVicios) const SizedBox(height: 16),
              // Frase do Dia
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: appState.corPrimaria.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  appState.fraseDia,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: appState.corPrimaria.withValues(alpha: 0.8),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Atalhos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _atalho(context, 'Humor', Icons.mood, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const DiarioHumorScreen()));
                  }),
                  _atalho(context, 'Calendário', Icons.calendar_month, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CalendarioScreen()));
                  }),
                  _atalho(context, 'Tarefas', Icons.check_circle_outline, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TarefasScreen()));
                  }),
                  _atalho(context, 'Vícios', Icons.shield_outlined, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AbstinenciaScreen()));
                  }),
                  _atalho(context, 'Registros', Icons.book_outlined, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegistrosScreen()));
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _atalho(
      BuildContext context, String label, IconData icon, VoidCallback onTap) {
    final cor = context.read<AppState>().corPrimaria;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: cor, size: 32),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: cor)),
        ],
      ),
    );
  }
}
