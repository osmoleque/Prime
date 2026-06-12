import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/registro_humor.dart';
import '../providers/app_state.dart';

class DiarioHumorScreen extends StatefulWidget {
  const DiarioHumorScreen({super.key});

  @override
  State<DiarioHumorScreen> createState() => _DiarioHumorScreenState();
}

class _DiarioHumorScreenState extends State<DiarioHumorScreen> {
  DateTime _dataSelecionada = DateTime.now();
  String _humorSelecionado = 'Bom';
  final _obsCtrl = TextEditingController();

  final List<String> humores = [
    'Excelente',
    'Bom',
    'Neutro',
    'Difícil',
    'Muito difícil'
  ];

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  void _carregar() {
    final registro = context.read<AppState>().getHumorDoDia(_dataSelecionada);
    if (registro != null) {
      _humorSelecionado = registro.humor;
      _obsCtrl.text = registro.observacao ?? '';
    } else {
      _humorSelecionado = 'Bom';
      _obsCtrl.clear();
    }
    setState(() {});
  }

  void _anterior() {
    _dataSelecionada = _dataSelecionada.subtract(const Duration(days: 1));
    _carregar();
  }

  void _seguinte() {
    _dataSelecionada = _dataSelecionada.add(const Duration(days: 1));
    _carregar();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final cor = appState.corPrimaria;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Navegação de data
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: _anterior,
                      icon: Icon(Icons.chevron_left, color: cor)),
                  Text(
                    '${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year}',
                    style: TextStyle(fontSize: 18, color: cor),
                  ),
                  IconButton(
                      onPressed: _seguinte,
                      icon: Icon(Icons.chevron_right, color: cor)),
                ],
              ),
              const SizedBox(height: 16),
              // Opções de humor
              Wrap(
                spacing: 8,
                children: humores
                    .map((h) => ChoiceChip(
                          label: Text(h),
                          selected: _humorSelecionado == h,
                          selectedColor: cor,
                          backgroundColor: Colors.white12,
                          onSelected: (s) =>
                              setState(() => _humorSelecionado = h),
                          labelStyle: TextStyle(
                              color:
                                  _humorSelecionado == h ? Colors.black : cor),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _obsCtrl,
                decoration: InputDecoration(
                  labelText: 'Observação (opcional)',
                  labelStyle: TextStyle(color: cor),
                  enabledBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: cor)),
                  focusedBorder:
                      OutlineInputBorder(borderSide: BorderSide(color: cor)),
                ),
                style: TextStyle(color: cor),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: cor),
                  onPressed: () {
                    final registro = RegistroHumor(
                      data: _dataSelecionada,
                      humor: _humorSelecionado,
                      observacao: _obsCtrl.text.isEmpty ? null : _obsCtrl.text,
                    );
                    appState.adicionarOuAtualizarHumor(registro);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Humor salvo!')),
                    );
                  },
                  child: const Text('Salvar',
                      style: TextStyle(color: Colors.black)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
