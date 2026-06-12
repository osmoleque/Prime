import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anotacao_diaria.dart';
import '../providers/app_state.dart';

class AnotacaoDialog extends StatefulWidget {
  final DateTime data;
  const AnotacaoDialog({super.key, required this.data});

  @override
  State<AnotacaoDialog> createState() => _AnotacaoDialogState();
}

class _AnotacaoDialogState extends State<AnotacaoDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _humor;
  final _desafiosCtrl = TextEditingController();
  final _vitoriasCtrl = TextEditingController();
  final _aprendizadoCtrl = TextEditingController();
  double _energia = 5;
  double _ansiedade = 5;

  List<String> humores = ['Feliz', 'Neutro', 'Triste', 'Ansioso', 'Motivado'];

  @override
  void initState() {
    super.initState();
    final existente = context.read<AppState>().getAnotacaoDoDia(widget.data);
    if (existente != null) {
      _humor = existente.humor ?? humores[0];
      _desafiosCtrl.text = existente.desafios ?? '';
      _vitoriasCtrl.text = existente.vitorias ?? '';
      _aprendizadoCtrl.text = existente.aprendizado ?? '';
      _energia = existente.nivelEnergia;
      _ansiedade = existente.nivelAnsiedade;
    } else {
      _humor = humores[0];
    }
  }

  @override
  void dispose() {
    _desafiosCtrl.dispose();
    _vitoriasCtrl.dispose();
    _aprendizadoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text('Anotação ${widget.data.day}/${widget.data.month}',
          style: TextStyle(color: appState.corPrimaria)),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _humor,
                dropdownColor: Colors.black,
                style: TextStyle(color: appState.corPrimaria),
                items: humores
                    .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                    .toList(),
                onChanged: (v) => _humor = v!,
                decoration: const InputDecoration(labelText: 'Humor'),
              ),
              TextFormField(
                  controller: _desafiosCtrl,
                  decoration: const InputDecoration(labelText: 'Desafios')),
              TextFormField(
                  controller: _vitoriasCtrl,
                  decoration: const InputDecoration(labelText: 'Vitórias')),
              TextFormField(
                  controller: _aprendizadoCtrl,
                  decoration: const InputDecoration(labelText: 'Aprendizado')),
              const SizedBox(height: 12),
              Text('Nível de energia: ${_energia.round()}'),
              Slider(
                  value: _energia,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => _energia = v),
              Text('Nível de ansiedade: ${_ansiedade.round()}'),
              Slider(
                  value: _ansiedade,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (v) => _ansiedade = v),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            final anotacao = AnotacaoDiaria(
              data: widget.data,
              humor: _humor,
              desafios: _desafiosCtrl.text,
              vitorias: _vitoriasCtrl.text,
              aprendizado: _aprendizadoCtrl.text,
              nivelEnergia: _energia,
              nivelAnsiedade: _ansiedade,
            );
            appState.adicionarOuAtualizarAnotacao(anotacao);
            Navigator.pop(context);
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
