import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/vicio.dart';
import '../models/habito.dart';
import '../models/anotacao_diaria.dart';
import '../models/tarefa.dart';
import '../models/rotina.dart';

class AppState extends ChangeNotifier {
  SharedPreferences? _prefs;

  List<Vicio> _vicios = [];
  int _vicioAtivoIndex = 0;
  List<Habito> _habitos = [];
  List<Tarefa> _tarefas = [];
  List<AnotacaoDiaria> _anotacoes = [];

  // Novas listas para rotinas e modelos de tarefas
  List<Rotina> _rotinas = [];
  List<String> _tarefasModelo = [];

  Color _corPrimaria = Colors.white;
  Set<int> _conquistasDesbloqueadas = {};
  String _fraseDia = '';

  String _idioma = 'pt_BR';
  bool _onboardingCompleto = false;
  bool _idiomaSelecionado = false;

  final Map<String, List<String>> _frasesPorIdioma = {};
  List<String>? _frasesCache;

  // ────────── GETTERS ──────────
  List<Vicio> get vicios => _vicios;
  Vicio get vicioAtivo => _vicios.isNotEmpty
      ? _vicios[_vicioAtivoIndex]
      : Vicio(nome: '', icone: '', dataInicio: DateTime.now());
  int get vicioAtivoIndex => _vicioAtivoIndex;
  List<Habito> get habitos => _habitos;
  List<Tarefa> get tarefas => _tarefas;
  List<AnotacaoDiaria> get anotacoes => _anotacoes;
  List<Rotina> get rotinas => _rotinas;
  List<String> get tarefasModelo => _tarefasModelo;
  Color get corPrimaria => _corPrimaria;
  Set<int> get conquistasDesbloqueadas => _conquistasDesbloqueadas;
  String get fraseDia => _fraseDia;
  String get idioma => _idioma;
  bool get onboardingCompleto => _onboardingCompleto;
  bool get idiomaSelecionado => _idiomaSelecionado;

  int get diasLimposTotal {
    if (_vicios.isEmpty) return 0;
    return _vicios.map((v) => v.diasLimpos).reduce((a, b) => a > b ? a : b);
  }

  double get progressoHabitos {
    if (_habitos.isEmpty) return 0;
    return _habitos.where((h) => h.concluido).length / _habitos.length;
  }

  int get concluidosHabitos => _habitos.where((h) => h.concluido).length;

  bool get hasTarefasPassadas {
    final inicioHoje = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return _tarefas.any((t) => t.data.isBefore(inicioHoje));
  }

  List<Map<String, String>> get sugestoesVicios => const [
        {'nome': 'Álcool', 'icone': '🍺'},
        {'nome': 'Cigarro', 'icone': '🚬'},
        {'nome': 'Redes Sociais', 'icone': '📱'},
        {'nome': 'Jogos eletrônicos', 'icone': '🎮'},
        {'nome': 'Drogas (geral)', 'icone': '💊'},
        {'nome': 'Apostas', 'icone': '🎰'},
        {'nome': 'Compras', 'icone': '🛒'},
        {'nome': 'Café', 'icone': '☕'},
        {'nome': 'Pornografia', 'icone': '🔞'},
        {'nome': 'Doces / Açúcar', 'icone': '🍫'},
        {'nome': 'TV / Streaming', 'icone': '📺'},
        {'nome': 'Trabalho excessivo', 'icone': '💼'},
        {'nome': 'Maconha', 'icone': '🌿'},
        {'nome': 'Cocaína', 'icone': '❄️'},
        {'nome': 'LSD', 'icone': '🌈'},
        {'nome': 'Anabolizantes', 'icone': '💉'},
        {'nome': 'Música (ouvir)', 'icone': '🎵'},
        {'nome': 'Vape / Cigarro eletrônico', 'icone': '💨'},
        {'nome': 'Bebidas energéticas', 'icone': '⚡'},
        {'nome': 'Fofoca / Intrigas', 'icone': '🗣️'},
        {'nome': 'Roer unhas', 'icone': '💅'},
      ];

  final List<int> marcosConquistas = [7, 14, 21, 30, 60, 90, 180, 365];

  // ───── INICIALIZAÇÃO ─────
  Future<void> carregarDados() async {
    _prefs = await SharedPreferences.getInstance();
    _onboardingCompleto = _prefs?.getBool('onboardingCompleto') ?? false;
    _idioma = _prefs?.getString('idioma') ?? 'pt_BR';
    _idiomaSelecionado = _onboardingCompleto;
    await _carregarFrasesDoIdioma(_idioma);
    _carregarVicios();
    _carregarHabitos();
    _carregarTarefas();
    _carregarAnotacoes();
    _carregarRotinas();
    _carregarTarefasModelo();
    _carregarCor();
    _carregarConquistas();
    _carregarFraseDia();
    notifyListeners();
  }

  // ───── CACHE DE FRASES POR IDIOMA ─────
  Future<void> _carregarFrasesDoIdioma(String idioma) async {
    String assetPath;
    switch (idioma) {
      case 'en_US':
        assetPath = 'assets/frases_en.txt';
        break;
      case 'es_ES':
        assetPath = 'assets/frases_es.txt';
        break;
      default:
        assetPath = 'assets/frases_pt.txt';
    }
    try {
      final data = await rootBundle.loadString(assetPath);
      _frasesPorIdioma[idioma] = data
          .split('\n')
          .map((linha) => linha.trim())
          .where((linha) => linha.isNotEmpty)
          .toList();
    } catch (_) {
      _frasesPorIdioma[idioma] = ['“A vida é bela.” – Desconhecido'];
    }
    if (idioma == 'pt_BR') {
      _frasesCache = _frasesPorIdioma['pt_BR'];
    }
  }

  // ───── ONBOARDING ─────
  Future<void> completarOnboarding() async {
    _onboardingCompleto = true;
    await _prefs?.setBool('onboardingCompleto', true);
    notifyListeners();
  }

  // ───── IDIOMA ─────
  Future<void> setIdioma(String idioma) async {
    if (_idioma == idioma) return;
    _idioma = idioma;
    await _prefs?.setString('idioma', idioma);
    await _carregarFrasesDoIdioma(idioma);
    await _prefs?.remove('dataFrase');
    _carregarFraseDia();
    notifyListeners();
  }

  Future<void> finalizarSelecaoIdioma(String idioma) async {
    await setIdioma(idioma);
    _idiomaSelecionado = true;
    notifyListeners();
  }

  // ───── VÍCIOS ─────
  void _carregarVicios() {
    final s = _prefs?.getString('vicios');
    if (s != null) {
      _vicios = (jsonDecode(s) as List).map((e) => Vicio.fromJson(e)).toList();
    }
    _vicioAtivoIndex = _prefs?.getInt('vicioAtivoIndex') ?? 0;
    if (_vicioAtivoIndex >= _vicios.length) _vicioAtivoIndex = 0;
  }

  Future<void> _salvarVicios() async {
    await _prefs?.setString('vicios', jsonEncode(_vicios.map((v) => v.toJson()).toList()));
    await _prefs?.setInt('vicioAtivoIndex', _vicioAtivoIndex);
  }

  void adicionarVicio(String nome, String icone, {DateTime? dataInicio, String? motivo}) {
    _vicios.add(Vicio(nome: nome, icone: icone, dataInicio: dataInicio ?? DateTime.now(), motivo: motivo));
    _vicioAtivoIndex = _vicios.length - 1;
    _salvarVicios();
    notifyListeners();
  }

  void removerVicio(int index) {
    if (_vicios.isEmpty) return;
    _vicios.removeAt(index);
    if (_vicioAtivoIndex >= _vicios.length) {
      _vicioAtivoIndex = _vicios.isEmpty ? 0 : _vicios.length - 1;
    }
    _salvarVicios();
    notifyListeners();
  }

  void setVicioAtivo(int index) {
    if (index >= 0 && index < _vicios.length) {
      _vicioAtivoIndex = index;
      _salvarVicios();
      notifyListeners();
    }
  }

  void registrarRecaida() {
    if (_vicios.isEmpty) return;
    final v = _vicios[_vicioAtivoIndex];
    v.recaidas.add(DateTime.now());
    if (v.diasLimpos > v.recordeDiasLimpos) {
      v.recordeDiasLimpos = v.diasLimpos;
    }
    adicionarOuAtualizarAnotacao(AnotacaoDiaria(
      data: DateTime.now(),
      textoDia: 'Recaída registrada.',
    ));
    _salvarVicios();
    notifyListeners();
  }

  // ───── HÁBITOS ─────
  void _carregarHabitos() {
    final s = _prefs?.getString('habitos');
    if (s != null) _habitos = (jsonDecode(s) as List).map((e) => Habito.fromJson(e)).toList();
  }

  Future<void> _salvarHabitos() async {
    await _prefs?.setString('habitos', jsonEncode(_habitos.map((h) => h.toJson()).toList()));
  }

  void adicionarHabito(String t) {
    _habitos.add(Habito(titulo: t));
    _salvarHabitos();
    notifyListeners();
  }

  void removerHabito(int i) {
    _habitos.removeAt(i);
    _salvarHabitos();
    notifyListeners();
  }

  void toggleHabito(int i) {
    _habitos[i].concluido = !_habitos[i].concluido;
    _salvarHabitos();
    notifyListeners();
  }

  // ───── TAREFAS ─────
  void _carregarTarefas() {
    final s = _prefs?.getString('tarefas');
    if (s != null) _tarefas = (jsonDecode(s) as List).map((e) => Tarefa.fromJson(e)).toList();
  }

  Future<void> _salvarTarefas() async {
    await _prefs?.setString('tarefas', jsonEncode(_tarefas.map((t) => t.toJson()).toList()));
  }

  void adicionarTarefa(String titulo, DateTime data) {
    final hoje = DateTime.now();
    if (data.isBefore(DateTime(hoje.year, hoje.month, hoje.day))) return;
    _tarefas.add(Tarefa(titulo: titulo, data: data));
    _salvarTarefas();
    notifyListeners();
  }

  void removerTarefa(int i) {
    if (i < 0 || i >= _tarefas.length) return;
    final hoje = DateTime.now();
    if (_tarefas[i].data.isBefore(DateTime(hoje.year, hoje.month, hoje.day))) return;
    _tarefas.removeAt(i);
    _salvarTarefas();
    notifyListeners();
  }

  void toggleTarefa(int i) {
    if (i < 0 || i >= _tarefas.length) return;
    final t = _tarefas[i];
    if (t.data.isAfter(DateTime.now())) return;
    t.concluida = !t.concluida;
    _salvarTarefas();
    notifyListeners();
  }

  List<Tarefa> getTarefasDoDia(DateTime data) {
    final d = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    return _tarefas.where((t) {
      final td = '${t.data.year}-${t.data.month.toString().padLeft(2, '0')}-${t.data.day.toString().padLeft(2, '0')}';
      return td == d;
    }).toList();
  }

  // ───── ANOTAÇÕES ─────
  void _carregarAnotacoes() {
    final s = _prefs?.getString('anotacoes');
    if (s != null) _anotacoes = (jsonDecode(s) as List).map((e) => AnotacaoDiaria.fromJson(e)).toList();
  }

  Future<void> _salvarAnotacoes() async {
    await _prefs?.setString('anotacoes', jsonEncode(_anotacoes.map((a) => a.toJson()).toList()));
  }

  void adicionarOuAtualizarAnotacao(AnotacaoDiaria a) {
    final d = '${a.data.year}-${a.data.month.toString().padLeft(2, '0')}-${a.data.day.toString().padLeft(2, '0')}';
    final idx = _anotacoes.indexWhere((x) {
      final xd = '${x.data.year}-${x.data.month.toString().padLeft(2, '0')}-${x.data.day.toString().padLeft(2, '0')}';
      return xd == d;
    });
    if (idx != -1) {
      _anotacoes[idx] = a;
    } else {
      _anotacoes.add(a);
    }
    _salvarAnotacoes();
    notifyListeners();
  }

  AnotacaoDiaria? getAnotacaoDoDia(DateTime data) {
    final d = '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';
    try {
      return _anotacoes.firstWhere((a) {
        final ad = '${a.data.year}-${a.data.month.toString().padLeft(2, '0')}-${a.data.day.toString().padLeft(2, '0')}';
        return ad == d;
      });
    } catch (_) {
      return null;
    }
  }

  // ───── ROTINAS ─────
  void _carregarRotinas() {
    final s = _prefs?.getString('rotinas');
    if (s != null) {
      _rotinas = (jsonDecode(s) as List).map((e) => Rotina.fromJson(e)).toList();
    }
  }

  Future<void> _salvarRotinas() async {
    await _prefs?.setString('rotinas', jsonEncode(_rotinas.map((r) => r.toJson()).toList()));
  }

  void adicionarRotina(Rotina rotina) {
    _rotinas.add(rotina);
    _salvarRotinas();
    notifyListeners();
  }

  void removerRotina(int index) {
    if (index < 0 || index >= _rotinas.length) return;
    _rotinas.removeAt(index);
    _salvarRotinas();
    notifyListeners();
  }

  // ───── TAREFAS MODELO ─────
  void _carregarTarefasModelo() {
    final s = _prefs?.getString('tarefasModelo');
    if (s != null) {
      _tarefasModelo = List<String>.from(jsonDecode(s));
    }
  }

  Future<void> _salvarTarefasModelo() async {
    await _prefs?.setString('tarefasModelo', jsonEncode(_tarefasModelo));
  }

  void adicionarTarefaModelo(String titulo) {
    _tarefasModelo.add(titulo);
    _salvarTarefasModelo();
    notifyListeners();
  }

  void removerTarefaModelo(int index) {
    if (index < 0 || index >= _tarefasModelo.length) return;
    _tarefasModelo.removeAt(index);
    _salvarTarefasModelo();
    notifyListeners();
  }

  // ───── COR ─────
  void _carregarCor() {
    final c = _prefs?.getInt('corPrimaria') ?? Colors.white.toARGB32();
    _corPrimaria = Color(c);
  }

  Future<void> _salvarCor() async {
    await _prefs?.setInt('corPrimaria', _corPrimaria.toARGB32());
  }

  void setCorPrimaria(Color c) {
    _corPrimaria = c;
    _salvarCor();
    notifyListeners();
  }

  // ───── CONQUISTAS ─────
  void _carregarConquistas() {
    final l = _prefs?.getStringList('conquistas') ?? [];
    _conquistasDesbloqueadas = l.map(int.parse).toSet();
  }

  Future<void> _salvarConquistas() async {
    await _prefs?.setStringList('conquistas', _conquistasDesbloqueadas.map((e) => e.toString()).toList());
  }

  void verificarConquistas() {
    if (_vicios.isEmpty) return;
    final dias = _vicios[_vicioAtivoIndex].diasLimpos;
    for (var m in marcosConquistas) {
      if (dias >= m) {
        _conquistasDesbloqueadas.add(m);
      }
    }
    _salvarConquistas();
  }

  // ───── FRASE DO DIA ─────
  void _carregarFraseDia() {
    final hoje = DateTime.now();
    final dataFrase = _prefs?.getString('dataFrase');
    if (dataFrase != null && dataFrase == _fmt(hoje) && _fraseDia.isNotEmpty) {
      return;
    }
    final frases = _frasesPorIdioma[_idioma] ?? _frasesCache ?? ['“A vida é bela.” – Desconhecido'];
    if (frases.isNotEmpty) {
      _fraseDia = frases[hoje.day % frases.length];
    } else {
      _fraseDia = '“A vida é bela.” – Desconhecido';
    }
    _prefs?.setString('dataFrase', _fmt(hoje));
    _prefs?.setString('fraseDia', _fraseDia);
  }

  String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ───── RESET ─────
  Future<void> apagarTodosDados() async {
    await _prefs?.clear();
    _vicios = [];
    _vicioAtivoIndex = 0;
    _habitos = [];
    _tarefas = [];
    _anotacoes = [];
    _rotinas = [];
    _tarefasModelo = [];
    _corPrimaria = Colors.white;
    _conquistasDesbloqueadas = {};
    _idioma = 'pt_BR';
    _onboardingCompleto = false;
    _idiomaSelecionado = false;
    await _salvarVicios();
    await _salvarHabitos();
    await _salvarTarefas();
    await _salvarAnotacoes();
    await _salvarRotinas();
    await _salvarTarefasModelo();
    await _salvarCor();
    await _salvarConquistas();
    notifyListeners();
  }
}