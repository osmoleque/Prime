import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/vicio.dart';
import '../models/habito.dart';
import '../models/registro_humor.dart';
import '../models/anotacao_diaria.dart';
import '../models/tarefa.dart';

class AppState extends ChangeNotifier {
  // ─── SharedPreferences ──────────────────────
  SharedPreferences? _prefs;

  // ─── Vícios ─────────────────────────────────
  List<Vicio> _vicios = [];
  int _vicioAtivoIndex = 0;

  // ─── Hábitos ────────────────────────────────
  List<Habito> _habitos = [];

  // ─── Tarefas ────────────────────────────────
  List<Tarefa> _tarefas = [];

  // ─── XP e nível ─────────────────────────────
  int _xp = 0;
  bool _resistiuHoje = false;
  DateTime? _ultimoResistiu;

  // ─── Humor (1 por dia) ──────────────────────
  List<RegistroHumor> _registrosHumor = [];

  // ─── Anotações diárias ──────────────────────
  List<AnotacaoDiaria> _anotacoes = [];

  // ─── Personalização ─────────────────────────
  Color _corPrimaria = Colors.white;

  // ─── Conquistas ─────────────────────────────
  Set<int> _conquistasDesbloqueadas = {};

  // ─── Frase do dia ───────────────────────────
  String _fraseDia = '';
  DateTime? _ultimaFrase;

  // ─── Motivo pessoal respiração ──────────────
  String _motivoPessoal = '';

  // ────────────────────────────────────────────
  // GETTERS
  // ────────────────────────────────────────────
  List<Vicio> get vicios => _vicios;
  Vicio get vicioAtivo => _vicios.isNotEmpty
      ? _vicios[_vicioAtivoIndex]
      : Vicio(nome: '', icone: '', dataInicio: DateTime.now());
  int get vicioAtivoIndex => _vicioAtivoIndex;
  List<Habito> get habitos => _habitos;
  List<Tarefa> get tarefas => _tarefas;
  List<RegistroHumor> get registrosHumor => _registrosHumor;
  List<AnotacaoDiaria> get anotacoes => _anotacoes;
  Color get corPrimaria => _corPrimaria;
  Set<int> get conquistasDesbloqueadas => _conquistasDesbloqueadas;
  String get motivoPessoal => _motivoPessoal;
  bool get resistiuHoje => _resistiuHoje;
  String get fraseDia => _fraseDia;
  int get xp => _xp;

  int get diasLimposTotal {
    if (_vicios.isEmpty) return 0;
    int maior = 0;
    for (var v in _vicios) {
      if (v.diasLimpos > maior) maior = v.diasLimpos;
    }
    return maior;
  }

  String get nivelTitulo {
    if (_xp < 100) return 'Iniciante';
    if (_xp < 500) return 'Determinado';
    if (_xp < 1500) return 'Resiliente';
    if (_xp < 5000) return 'Guerreiro';
    return 'Mestre da Abstinência';
  }

  double get xpProgresso {
    int limiteSuperior = 100;
    if (_xp >= 5000) {
      return 1.0;
    } else if (_xp >= 1500) {
      limiteSuperior = 5000;
    } else if (_xp >= 500) {
      limiteSuperior = 1500;
    } else if (_xp >= 100) {
      limiteSuperior = 500;
    }
    return (_xp / limiteSuperior).clamp(0.0, 1.0);
  }

  double get progressoHabitos {
    if (_habitos.isEmpty) return 0;
    return _habitos.where((h) => h.concluido).length / _habitos.length;
  }

  int get concluidosHabitos => _habitos.where((h) => h.concluido).length;

  // Sugestões de vícios pré‑definidos
  List<Map<String, String>> get sugestoesVicios => [
        {'nome': 'Álcool', 'icone': '🍺'},
        {'nome': 'Cigarro', 'icone': '🚬'},
        {'nome': 'Redes Sociais', 'icone': '📱'},
        {'nome': 'Jogos', 'icone': '🎮'},
        {'nome': 'Drogas', 'icone': '💊'},
        {'nome': 'Apostas', 'icone': '🎰'},
        {'nome': 'Compras', 'icone': '🛒'},
        {'nome': 'Café', 'icone': '☕'},
        {'nome': 'Pornografia', 'icone': '🔞'},
        {'nome': 'Doces', 'icone': '🍫'},
        {'nome': 'TV / Streaming', 'icone': '📺'},
        {'nome': 'Trabalho excessivo', 'icone': '💼'},
      ];

  // ────────────────────────────────────────────
  // INICIALIZAÇÃO
  // ────────────────────────────────────────────
  Future<void> carregarDados() async {
    _prefs = await SharedPreferences.getInstance();
    _carregarVicios();
    _carregarHabitos();
    _carregarTarefas();
    _carregarXP();
    _carregarHumor();
    _carregarAnotacoes();
    _carregarCor();
    _carregarConquistas();
    _carregarMotivo();
    _carregarResistencia();
    _carregarFraseDia();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // PERSISTÊNCIA DE VÍCIOS
  // ────────────────────────────────────────────
  void _carregarVicios() {
    final jsonString = _prefs?.getString('vicios');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _vicios = list.map((e) => Vicio.fromJson(e)).toList();
    } else {
      _vicios = []; // Começa vazio
    }
    _vicioAtivoIndex = _prefs?.getInt('vicioAtivoIndex') ?? 0;
    if (_vicioAtivoIndex >= _vicios.length) _vicioAtivoIndex = 0;
  }

  Future<void> _salvarVicios() async {
    final jsonString = jsonEncode(_vicios.map((v) => v.toJson()).toList());
    await _prefs?.setString('vicios', jsonString);
    await _prefs?.setInt('vicioAtivoIndex', _vicioAtivoIndex);
  }

  void adicionarVicio(String nome, String icone, {DateTime? dataInicio}) {
    _vicios.add(Vicio(
        nome: nome, icone: icone, dataInicio: dataInicio ?? DateTime.now()));
    _salvarVicios();
    notifyListeners();
  }

  void removerVicio(int index) {
    if (_vicios.length <= 1) return;
    _vicios.removeAt(index);
    if (_vicioAtivoIndex >= _vicios.length) _vicioAtivoIndex = 0;
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

  void reiniciarVicio() {
    final v = _vicios[_vicioAtivoIndex];
    v.recaidas.add(DateTime.now());
    if (v.diasLimpos > v.recordeDiasLimpos) {
      v.recordeDiasLimpos = v.diasLimpos;
    }
    adicionarOuAtualizarAnotacao(AnotacaoDiaria(
      data: DateTime.now(),
      humor: 'Triste',
      desafios: 'Recaída',
      vitorias: '',
      aprendizado: 'Recaída registrada automaticamente.',
    ));
    _salvarVicios();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // PERSISTÊNCIA DE HÁBITOS
  // ────────────────────────────────────────────
  void _carregarHabitos() {
    final jsonString = _prefs?.getString('habitos');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _habitos = list.map((e) => Habito.fromJson(e)).toList();
    }
  }

  Future<void> _salvarHabitos() async {
    final jsonString = jsonEncode(_habitos.map((h) => h.toJson()).toList());
    await _prefs?.setString('habitos', jsonString);
  }

  void adicionarHabito(String titulo) {
    _habitos.add(Habito(titulo: titulo));
    _salvarHabitos();
    notifyListeners();
  }

  void removerHabito(int index) {
    _habitos.removeAt(index);
    _salvarHabitos();
    notifyListeners();
  }

  void toggleHabito(int index) {
    _habitos[index].concluido = !_habitos[index].concluido;
    _salvarHabitos();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // PERSISTÊNCIA DE TAREFAS
  // ────────────────────────────────────────────
  void _carregarTarefas() {
    final jsonString = _prefs?.getString('tarefas');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _tarefas = list.map((e) => Tarefa.fromJson(e)).toList();
    }
  }

  Future<void> _salvarTarefas() async {
    final jsonString = jsonEncode(_tarefas.map((t) => t.toJson()).toList());
    await _prefs?.setString('tarefas', jsonString);
  }

  void adicionarTarefa(String titulo, DateTime data) {
    _tarefas.add(Tarefa(titulo: titulo, data: data));
    _salvarTarefas();
    notifyListeners();
  }

  void removerTarefa(int index) {
    if (index >= 0 && index < _tarefas.length) {
      _tarefas.removeAt(index);
      _salvarTarefas();
      notifyListeners();
    }
  }

  void toggleTarefa(int index) {
    if (index >= 0 && index < _tarefas.length) {
      _tarefas[index].concluida = !_tarefas[index].concluida;
      _salvarTarefas();
      notifyListeners();
    }
  }

  List<Tarefa> getTarefasDoDia(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    return _tarefas
        .where((t) => DateFormat('yyyy-MM-dd').format(t.data) == dataStr)
        .toList();
  }

  // ────────────────────────────────────────────
  // XP E RESISTÊNCIA
  // ────────────────────────────────────────────
  void _carregarXP() {
    _xp = _prefs?.getInt('xp') ?? 0;
  }

  Future<void> _salvarXP() async {
    await _prefs?.setInt('xp', _xp);
  }

  void _carregarResistencia() {
    final hoje = DateTime.now();
    final ultimoStr = _prefs?.getString('ultimoResistiu');
    if (ultimoStr != null) {
      _ultimoResistiu = DateTime.parse(ultimoStr);
      _resistiuHoje = (_ultimoResistiu?.year == hoje.year &&
          _ultimoResistiu?.month == hoje.month &&
          _ultimoResistiu?.day == hoje.day);
    } else {
      _resistiuHoje = false;
    }
  }

  Future<void> _salvarResistencia() async {
    if (_ultimoResistiu != null) {
      await _prefs?.setString(
          'ultimoResistiu', _ultimoResistiu!.toIso8601String());
    }
  }

  void resistirImpulso() {
    if (_resistiuHoje) return;
    _resistiuHoje = true;
    _ultimoResistiu = DateTime.now();
    _xp += 10;
    verificarConquistas();
    _salvarResistencia();
    _salvarXP();
    notifyListeners();
  }

  void incrementarXP(int quantidade) {
    _xp += quantidade;
    verificarConquistas();
    _salvarXP();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // HUMOR
  // ────────────────────────────────────────────
  void _carregarHumor() {
    final jsonString = _prefs?.getString('registrosHumor');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _registrosHumor = list.map((e) => RegistroHumor.fromJson(e)).toList();
    }
  }

  Future<void> _salvarHumor() async {
    final jsonString =
        jsonEncode(_registrosHumor.map((r) => r.toJson()).toList());
    await _prefs?.setString('registrosHumor', jsonString);
  }

  void adicionarOuAtualizarHumor(RegistroHumor registro) {
    final dataStr = DateFormat('yyyy-MM-dd').format(registro.data);
    final index = _registrosHumor
        .indexWhere((r) => DateFormat('yyyy-MM-dd').format(r.data) == dataStr);
    if (index != -1) {
      _registrosHumor[index] = registro;
    } else {
      _registrosHumor.add(registro);
    }
    _salvarHumor();
    notifyListeners();
  }

  RegistroHumor? getHumorDoDia(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    try {
      return _registrosHumor.firstWhere(
          (r) => DateFormat('yyyy-MM-dd').format(r.data) == dataStr);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────
  // ANOTAÇÕES DIÁRIAS
  // ────────────────────────────────────────────
  void _carregarAnotacoes() {
    final jsonString = _prefs?.getString('anotacoes');
    if (jsonString != null) {
      final List<dynamic> list = jsonDecode(jsonString);
      _anotacoes = list.map((e) => AnotacaoDiaria.fromJson(e)).toList();
    }
  }

  Future<void> _salvarAnotacoes() async {
    final jsonString = jsonEncode(_anotacoes.map((a) => a.toJson()).toList());
    await _prefs?.setString('anotacoes', jsonString);
  }

  void adicionarOuAtualizarAnotacao(AnotacaoDiaria anotacao) {
    final dataStr = DateFormat('yyyy-MM-dd').format(anotacao.data);
    final index = _anotacoes
        .indexWhere((a) => DateFormat('yyyy-MM-dd').format(a.data) == dataStr);
    if (index != -1) {
      _anotacoes[index] = anotacao;
    } else {
      _anotacoes.add(anotacao);
    }
    _salvarAnotacoes();
    notifyListeners();
  }

  AnotacaoDiaria? getAnotacaoDoDia(DateTime data) {
    final dataStr = DateFormat('yyyy-MM-dd').format(data);
    try {
      return _anotacoes.firstWhere(
          (a) => DateFormat('yyyy-MM-dd').format(a.data) == dataStr);
    } catch (_) {
      return null;
    }
  }

  // ────────────────────────────────────────────
  // COR PRIMÁRIA
  // ────────────────────────────────────────────
  void _carregarCor() {
    final corInt = _prefs?.getInt('corPrimaria') ?? Colors.white.toARGB32();
    _corPrimaria = Color(corInt);
  }

  Future<void> _salvarCor() async {
    await _prefs?.setInt('corPrimaria', _corPrimaria.toARGB32());
  }

  void setCorPrimaria(Color cor) {
    _corPrimaria = cor;
    _salvarCor();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // CONQUISTAS
  // ────────────────────────────────────────────
  void _carregarConquistas() {
    final listStr = _prefs?.getStringList('conquistas') ?? [];
    _conquistasDesbloqueadas = listStr.map((e) => int.parse(e)).toSet();
  }

  Future<void> _salvarConquistas() async {
    await _prefs?.setStringList('conquistas',
        _conquistasDesbloqueadas.map((e) => e.toString()).toList());
  }

  void verificarConquistas() {
    final dias = diasLimposTotal;
    final marcos = [1, 7, 30, 90, 365];
    for (var marco in marcos) {
      if (dias >= marco && !_conquistasDesbloqueadas.contains(marco)) {
        _conquistasDesbloqueadas.add(marco);
      }
    }
    _salvarConquistas();
  }

  // ────────────────────────────────────────────
  // FRASE DO DIA
  // ────────────────────────────────────────────
  String _formatarData(DateTime data) =>
      '${data.year}-${data.month.toString().padLeft(2, '0')}-${data.day.toString().padLeft(2, '0')}';

  void _carregarFraseDia() {
    final hoje = DateTime.now();
    final dataFrase = _prefs?.getString('dataFrase');
    if (dataFrase != null && dataFrase == _formatarData(hoje)) {
      _fraseDia = _prefs?.getString('fraseDia') ?? '';
    } else {
      final frases = [
        '“O que não provoca minha morte faz com que eu fique mais forte.” – Nietzsche',
        '“A vida deve ser vivida para a frente, mas só pode ser compreendida para trás.” – Kierkegaard',
        '“A coragem é a primeira das qualidades humanas, porque garante todas as outras.” – Aristóteles',
        '“Não são as coisas que nos perturbam, mas a opinião que temos delas.” – Epicteto',
      ];
      _fraseDia = frases[hoje.day % frases.length];
      _prefs?.setString('dataFrase', _formatarData(hoje));
      _prefs?.setString('fraseDia', _fraseDia);
    }
  }

  // ────────────────────────────────────────────
  // MOTIVO PESSOAL
  // ────────────────────────────────────────────
  void _carregarMotivo() {
    _motivoPessoal = _prefs?.getString('motivoPessoal') ?? '';
  }

  Future<void> _salvarMotivo() async {
    await _prefs?.setString('motivoPessoal', _motivoPessoal);
  }

  void setMotivoPessoal(String motivo) {
    _motivoPessoal = motivo;
    _salvarMotivo();
    notifyListeners();
  }

  // ────────────────────────────────────────────
  // RESET TOTAL
  // ────────────────────────────────────────────
  Future<void> apagarTodosDados() async {
    await _prefs?.clear();
    _vicios = [];
    _vicioAtivoIndex = 0;
    _habitos = [];
    _tarefas = [];
    _xp = 0;
    _registrosHumor = [];
    _anotacoes = [];
    _corPrimaria = Colors.white;
    _conquistasDesbloqueadas = {};
    _motivoPessoal = '';
    _resistiuHoje = false;
    await _salvarVicios();
    await _salvarHabitos();
    await _salvarTarefas();
    await _salvarXP();
    await _salvarHumor();
    await _salvarAnotacoes();
    await _salvarCor();
    await _salvarConquistas();
    await _salvarMotivo();
    await _salvarResistencia();
    notifyListeners();
  }
}
