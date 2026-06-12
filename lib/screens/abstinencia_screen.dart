import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../widgets/anotacao_dialog.dart';

class AbstinenciaScreen extends StatelessWidget {
  const AbstinenciaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final vicioAtivo = appState.vicioAtivo;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (appState.vicios.isEmpty)
                Expanded(
                  child: _buildSugestoesIniciais(context),
                )
              else ...[
                DropdownButton<int>(
                  value: appState.vicioAtivoIndex,
                  isExpanded: true,
                  dropdownColor: Colors.black,
                  style: TextStyle(color: appState.corPrimaria),
                  items: List.generate(appState.vicios.length, (i) {
                    return DropdownMenuItem<int>(
                      value: i,
                      child: Text(
                          '${appState.vicios[i].icone} ${appState.vicios[i].nome}'),
                    );
                  }),
                  onChanged: (i) {
                    if (i != null) appState.setVicioAtivo(i);
                  },
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          color: Colors.white10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(vicioAtivo.icone,
                                        style: const TextStyle(fontSize: 40)),
                                    const SizedBox(width: 12),
                                    Text(vicioAtivo.nome,
                                        style: TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: appState.corPrimaria)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text('Dias limpos: ${vicioAtivo.diasLimpos}'),
                                Text(
                                    'Início: ${vicioAtivo.dataInicio.day}/${vicioAtivo.dataInicio.month}/${vicioAtivo.dataInicio.year}'),
                                Text(
                                    'Recorde: ${vicioAtivo.recordeDiasLimpos} dias'),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _botaoAcao('Anotar dia', () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AnotacaoDialog(
                                            data: DateTime.now()),
                                      );
                                    }),
                                    _botaoAcao('Reiniciar', () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          backgroundColor: Colors.grey[900],
                                          title:
                                              const Text('Confirmar recaída'),
                                          content: const Text(
                                              'Isso registrará uma recaída e reiniciará a contagem. Continuar?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancelar')),
                                            TextButton(
                                              onPressed: () {
                                                appState.reiniciarVicio();
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Sim, recaí'),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                    _botaoAcao('Apagar', () {
                                      if (appState.vicios.length <= 1) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Mantenha pelo menos um vício')),
                                        );
                                        return;
                                      }
                                      appState.removerVicio(
                                          appState.vicioAtivoIndex);
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const _AdicionarVicioWidget(),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: appState.vicios.isEmpty
          ? null
          : FloatingActionButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AnotacaoDialog(data: DateTime.now()),
                );
              },
              child: const Icon(Icons.edit),
            ),
    );
  }

  Widget _botaoAcao(String texto, VoidCallback onPressed) {
    return TextButton(onPressed: onPressed, child: Text(texto));
  }

  Widget _buildSugestoesIniciais(BuildContext context) {
    final appState = context.read<AppState>();
    final cor = appState.corPrimaria;
    final sugestoes = appState.sugestoesVicios;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Comece adicionando um vício que deseja superar:',
            style: TextStyle(fontSize: 16, color: cor),
          ),
          const SizedBox(height: 16),
          ...sugestoes.map((s) => ListTile(
                leading:
                    Text(s['icone']!, style: const TextStyle(fontSize: 28)),
                title: Text(s['nome']!, style: TextStyle(color: cor)),
                trailing: Icon(Icons.add_circle_outline, color: cor),
                onTap: () {
                  appState.adicionarVicio(s['nome']!, s['icone']!);
                },
              )),
          const Divider(color: Colors.white24),
          const SizedBox(height: 12),
          const _AdicionarVicioWidget(),
        ],
      ),
    );
  }
}

class _AdicionarVicioWidget extends StatefulWidget {
  const _AdicionarVicioWidget();

  @override
  State<_AdicionarVicioWidget> createState() => _AdicionarVicioWidgetState();
}

class _AdicionarVicioWidgetState extends State<_AdicionarVicioWidget> {
  final _nomeCtrl = TextEditingController();
  String _iconeSelecionado = '⚡';
  DateTime _dataInicio = DateTime.now();
  bool _mostrarForm = false;

  final List<String> iconesDisponiveis = [
    '🍺',
    '🚬',
    '📱',
    '🎮',
    '💊',
    '🍷',
    '💻',
    '🎰',
    '🍔',
    '☕',
    '💉',
    '🧠',
    '💪',
    '🏃',
    '📺',
    '🛒',
    '🎵',
    '📚',
    '✈️',
    '❤️',
    '🔞',
    '🍫',
    '💼',
    '🧹',
    '🎲',
    '🏈',
    '💄',
    '🎧',
    '🛁',
    '💤'
  ];

  @override
  Widget build(BuildContext context) {
    final cor = context.watch<AppState>().corPrimaria;
    if (!_mostrarForm) {
      return TextButton.icon(
        onPressed: () => setState(() => _mostrarForm = true),
        icon: Icon(Icons.add, color: cor),
        label: Text('Criar vício personalizado', style: TextStyle(color: cor)),
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
          Text('Novo vício',
              style: TextStyle(color: cor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _nomeCtrl,
            style: TextStyle(color: cor),
            decoration: InputDecoration(
              hintText: 'Nome do vício',
              hintStyle: TextStyle(color: cor.withValues(alpha: 0.5)),
              enabledBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: cor)),
              focusedBorder:
                  OutlineInputBorder(borderSide: BorderSide(color: cor)),
            ),
          ),
          const SizedBox(height: 12),
          Text('Escolha um ícone:', style: TextStyle(color: cor)),
          Wrap(
            spacing: 8,
            children: iconesDisponiveis
                .map((icone) => GestureDetector(
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
                        child:
                            Text(icone, style: const TextStyle(fontSize: 24)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Data de início: ', style: TextStyle(color: cor)),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _dataInicio,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: ThemeData.dark().copyWith(
                        colorScheme: ColorScheme.dark(primary: cor),
                      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => setState(() => _mostrarForm = false),
                child: const Text('Cancelar'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: cor),
                onPressed: () {
                  final nome = _nomeCtrl.text.trim();
                  if (nome.isEmpty) return;
                  context.read<AppState>().adicionarVicio(
                      nome, _iconeSelecionado,
                      dataInicio: _dataInicio);
                  setState(() {
                    _nomeCtrl.clear();
                    _mostrarForm = false;
                  });
                },
                child:
                    const Text('Salvar', style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
