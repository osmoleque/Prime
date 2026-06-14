import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/anotacao_diaria.dart';
import '../providers/app_state.dart';
import '../l10n/app_localizations.dart';

class AnotacaoDialog extends StatefulWidget {
  final DateTime data;
  const AnotacaoDialog({super.key, required this.data});

  @override
  State<AnotacaoDialog> createState() => _AnotacaoDialogState();
}

class _AnotacaoDialogState extends State<AnotacaoDialog> {
  final _textoDiaCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final existente = context.read<AppState>().getAnotacaoDoDia(widget.data);
    if (existente != null) {
      _textoDiaCtrl.text = existente.textoDia ?? '';
    }
  }

  @override
  void dispose() {
    _textoDiaCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final local = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        '${local.translate('annotation_title')} ${widget.data.day}/${widget.data.month}/${widget.data.year}',
        style: TextStyle(color: appState.corPrimaria),
      ),
      content: SingleChildScrollView(
        child: TextField(
          controller: _textoDiaCtrl,
          maxLines: 5,
          autofocus: true,
          style: TextStyle(color: appState.corPrimaria),
          decoration: InputDecoration(
            labelText: local.translate('what_happened'),
            labelStyle: TextStyle(color: appState.corPrimaria),
            enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: appState.corPrimaria)),
            focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: appState.corPrimaria)),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(local.translate('cancel'))),
        TextButton(
          onPressed: () {
            final anotacao = AnotacaoDiaria(
              data: widget.data,
              textoDia: _textoDiaCtrl.text,
            );
            appState.adicionarOuAtualizarAnotacao(anotacao);
            Navigator.pop(context);
          },
          child: Text(local.translate('save_annotation')),
        ),
      ],
    );
  }
}