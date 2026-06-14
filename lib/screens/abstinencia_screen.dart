import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';
import '../models/vicio.dart';
import '../widgets/anotacao_dialog.dart';

class AbstinenciaScreen extends StatelessWidget {
  const AbstinenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final local = AppLocalizations.of(context);
    final temVicios = appState.vicios.isNotEmpty;
    final vicioAtivo = temVicios ? appState.vicioAtivo : null;
    final cor = appState.corPrimaria;

    if (temVicios) appState.verificarConquistas();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (temVicios) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: cor.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButton<int>(
                    value: appState.vicioAtivoIndex,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: Colors.black,
                    style: TextStyle(color: cor),
                    items: List.generate(appState.vicios.length, (i) {
                      return DropdownMenuItem<int>(
                        value: i,
                        child: Text('${appState.vicios[i].icone} ${appState.vicios[i].nome}'),
                      );
                    }),
                    onChanged: (i) {
                      if (i != null) appState.setVicioAtivo(i);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildProgressCard(appState, vicioAtivo!, local),
                        const SizedBox(height: 16),
                        _buildBotaoRecair(appState, local, context),
                        const SizedBox(height: 20),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 16),
                        const _AdicionarVicioWidget(),
                        const SizedBox(height: 16),
                        _buildSugestoesVicios(context, local),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildSugestoesIniciais(context, local),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: temVicios
          ? FloatingActionButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AnotacaoDialog(data: DateTime.now()),
              ),
              child: const Icon(Icons.edit),
            )
          : null,
    );
  }

  Widget _buildProgressCard(AppState appState, Vicio vicio, AppLocalizations local) {
    final cor = appState.corPrimaria;
    return Card(
      color: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(vicio.icone, style: const TextStyle(fontSize: 40)),
                const SizedBox(width: 12),
                Text(vicio.nome,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: cor)),
              ],
            ),
            const SizedBox(height: 12),
            Text('${local.translate('clean_days')}: ${vicio.diasLimpos}',
                style: const TextStyle(fontSize: 16)),
            Text('${local.translate('start_date')}: ${vicio.dataInicio.day}/${vicio.dataInicio.month}/${vicio.dataInicio.year}',
                style: const TextStyle(fontSize: 14)),
            Text('${local.translate('record')}: ${vicio.recordeDiasLimpos} ${local.translate('days')}',
                style: const TextStyle(fontSize: 14)),
            if (vicio.motivo != null && vicio.motivo!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                '"${vicio.motivo}"',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBotaoRecair(AppState appState, AppLocalizations local, BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text(local.translate('relapse')),
            content: Text(local.translate('relapse_confirm')),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(local.translate('cancel'))),
              TextButton(
                onPressed: () {
                  appState.registrarRecaida();
                  Navigator.pop(context);
                },
                child: Text(local.translate('confirm')),
              ),
            ],
          ),
        ),
        icon: const Icon(Icons.warning),
        label: Text(local.translate('relapse'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildSugestoesIniciais(BuildContext context, AppLocalizations local) {
    final appState = context.read<AppState>();
    final cor = appState.corPrimaria;
    final vicioKeys = [
      {'key': 'vicio_alcool', 'icone': '🍺'},
      {'key': 'vicio_cigarro', 'icone': '🚬'},
      {'key': 'vicio_redes_sociais', 'icone': '📱'},
      {'key': 'vicio_jogos', 'icone': '🎮'},
      {'key': 'vicio_drogas_geral', 'icone': '💊'},
      {'key': 'vicio_apostas', 'icone': '🎰'},
      {'key': 'vicio_compras', 'icone': '🛒'},
      {'key': 'vicio_cafe', 'icone': '☕'},
      {'key': 'vicio_pornografia', 'icone': '🔞'},
      {'key': 'vicio_doces', 'icone': '🍫'},
      {'key': 'vicio_tv_streaming', 'icone': '📺'},
      {'key': 'vicio_trabalho', 'icone': '💼'},
      {'key': 'vicio_maconha', 'icone': '🌿'},
      {'key': 'vicio_cocaina', 'icone': '❄️'},
      {'key': 'vicio_lsd', 'icone': '🌈'},
      {'key': 'vicio_anabolizantes', 'icone': '💉'},
      {'key': 'vicio_musica', 'icone': '🎵'},
      {'key': 'vicio_vape', 'icone': '💨'},
      {'key': 'vicio_energeticos', 'icone': '⚡'},
      {'key': 'vicio_fofoca', 'icone': '🗣️'},
      {'key': 'vicio_roer_unhas', 'icone': '💅'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(local.translate('add_vice_prompt'),
            style: TextStyle(fontSize: 16, color: cor)),
        const SizedBox(height: 16),
        ...vicioKeys.map((v) => ListTile(
              leading: Text(v['icone']!, style: const TextStyle(fontSize: 28)),
              title: Text(local.translate(v['key']!), style: TextStyle(color: cor)),
              trailing: Icon(Icons.add_circle_outline, color: cor),
              onTap: () => _mostrarDialogoMotivo(context, local, v['icone']!, local.translate(v['key']!)),
            )),
        const Divider(color: Colors.white24),
        const SizedBox(height: 12),
        const _AdicionarVicioWidget(),
      ],
    );
  }

  Widget _buildSugestoesVicios(BuildContext context, AppLocalizations local) {
    final appState = context.read<AppState>();
    final cor = appState.corPrimaria;
    final vicioKeys = [
      {'key': 'vicio_alcool', 'icone': '🍺'},
      {'key': 'vicio_cigarro', 'icone': '🚬'},
      {'key': 'vicio_redes_sociais', 'icone': '📱'},
      {'key': 'vicio_jogos', 'icone': '🎮'},
      {'key': 'vicio_drogas_geral', 'icone': '💊'},
      {'key': 'vicio_apostas', 'icone': '🎰'},
      {'key': 'vicio_compras', 'icone': '🛒'},
      {'key': 'vicio_cafe', 'icone': '☕'},
      {'key': 'vicio_pornografia', 'icone': '🔞'},
      {'key': 'vicio_doces', 'icone': '🍫'},
      {'key': 'vicio_tv_streaming', 'icone': '📺'},
      {'key': 'vicio_trabalho', 'icone': '💼'},
      {'key': 'vicio_maconha', 'icone': '🌿'},
      {'key': 'vicio_cocaina', 'icone': '❄️'},
      {'key': 'vicio_lsd', 'icone': '🌈'},
      {'key': 'vicio_anabolizantes', 'icone': '💉'},
      {'key': 'vicio_musica', 'icone': '🎵'},
      {'key': 'vicio_vape', 'icone': '💨'},
      {'key': 'vicio_energeticos', 'icone': '⚡'},
      {'key': 'vicio_fofoca', 'icone': '🗣️'},
      {'key': 'vicio_roer_unhas', 'icone': '💅'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(local.translate('add_quick'),
            style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: vicioKeys.map((v) => ActionChip(
            label: Text('${v['icone']} ${local.translate(v['key']!)}',
                style: const TextStyle(fontSize: 12)),
            backgroundColor: Colors.white12,
            labelStyle: TextStyle(color: cor),
            onPressed: () => _mostrarDialogoMotivo(context, local, v['icone']!, local.translate(v['key']!)),
          )).toList(),
        ),
      ],
    );
  }

  void _mostrarDialogoMotivo(BuildContext context, AppLocalizations local, String icone, String nome) {
    final motivoCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text('$icone $nome'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(local.translate('motivo_label')),
            const SizedBox(height: 12),
            TextField(
              controller: motivoCtrl,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: local.translate('motivo_hint'),
                hintStyle: TextStyle(color: Colors.white38),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: context.read<AppState>().corPrimaria)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(local.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              final motivo = motivoCtrl.text.trim();
              context.read<AppState>().adicionarVicio(
                nome,
                icone,
                motivo: motivo.isEmpty ? null : motivo,
              );
              Navigator.pop(ctx);
            },
            child: Text(local.translate('confirm')),
          ),
        ],
      ),
    );
  }
}

// Widget _AdicionarVicioWidget (com campo de motivo)
class _AdicionarVicioWidget extends StatefulWidget {
  const _AdicionarVicioWidget();
  @override
  State<_AdicionarVicioWidget> createState() => _AdicionarVicioWidgetState();
}

class _AdicionarVicioWidgetState extends State<_AdicionarVicioWidget> {
  final _nomeCtrl = TextEditingController();
  final _motivoCtrl = TextEditingController();
  String _iconeSelecionado = '⚡';
  DateTime _dataInicio = DateTime.now();
  bool _mostrarForm = false;

  final List<String> iconesDisponiveis = [
    '🍺', '🚬', '📱', '🎮', '💊', '🍷', '💻', '🎰', '🍔', '☕',
    '💉', '🧠', '💪', '🏃', '📺', '🛒', '🎵', '📚', '✈️', '❤️',
    '🔞', '🍫', '💼', '🧹', '🎲', '🏈', '💄', '🎧', '🛁', '💤',
    '🌿', '❄️', '🌈', '💨', '⚡', '🗣️', '💅', '🎯', '🧩', '🎭'
  ];

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _motivoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cor = context.watch<AppState>().corPrimaria;
    final local = AppLocalizations.of(context);
    if (!_mostrarForm) {
      return TextButton.icon(
        onPressed: () => setState(() => _mostrarForm = true),
        icon: Icon(Icons.add, color: cor),
        label: Text(local.translate('create_custom_vice'), style: TextStyle(color: cor)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: cor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(local.translate('new_vice'),
              style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nomeCtrl,
            style: TextStyle(color: cor),
            decoration: InputDecoration(
              hintText: local.translate('vice_name'),
              hintStyle: TextStyle(color: cor.withValues(alpha: 0.5)),
              enabledBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: cor)),
              focusedBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: cor)),
            ),
          ),
          const SizedBox(height: 12),
          Text(local.translate('choose_icon'), style: TextStyle(color: cor)),
          Wrap(
            spacing: 8,
            children: iconesDisponiveis.map((icone) => GestureDetector(
              onTap: () => setState(() => _iconeSelecionado = icone),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _iconeSelecionado == icone
                        ? cor
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(icone, style: const TextStyle(fontSize: 24)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('${local.translate('start_date')}: ', style: TextStyle(color: cor)),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataInicio,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark()
                          .copyWith(colorScheme: ColorScheme.dark(primary: cor)),
                      child: child!,
                    ),
                  );
                  if (date != null) setState(() => _dataInicio = date);
                },
                child: Text(
                  '${_dataInicio.day}/${_dataInicio.month}/${_dataInicio.year}',
                  style: TextStyle(color: cor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(local.translate('motivo_label'),
              style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _motivoCtrl,
            maxLines: 2,
            style: TextStyle(color: cor),
            decoration: InputDecoration(
              hintText: local.translate('motivo_hint'),
              hintStyle: TextStyle(color: cor.withValues(alpha: 0.5)),
              enabledBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: cor)),
              focusedBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: cor)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () => setState(() => _mostrarForm = false),
                  child: Text(local.translate('cancel'))),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cor),
                onPressed: () {
                  final nome = _nomeCtrl.text.trim();
                  if (nome.isEmpty) return;
                  context.read<AppState>().adicionarVicio(
                    nome,
                    _iconeSelecionado,
                    dataInicio: _dataInicio,
                    motivo: _motivoCtrl.text.trim(),
                  );
                  setState(() {
                    _nomeCtrl.clear();
                    _motivoCtrl.clear();
                    _mostrarForm = false;
                  });
                },
                child: Text(local.translate('save'), style: const TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}