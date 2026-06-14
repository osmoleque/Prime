import 'package:flutter/material.dart';

class CorSeletor extends StatelessWidget {
  final Color corAtual;
  final Function(Color) onCorSelecionada;

  const CorSeletor({super.key, required this.corAtual, required this.onCorSelecionada});

  // Branco é a primeira cor
  static const List<Color> cores = [
    Colors.white,
    Colors.cyanAccent,
    Colors.lightGreenAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.purpleAccent,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.amber,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: cores.map((c) {
        final selected = corAtual.toARGB32() == c.toARGB32();
        return GestureDetector(
          onTap: () => onCorSelecionada(c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: Colors.white, width: 3)
                  : Border.all(color: Colors.white24, width: 1),
              boxShadow: selected
                  ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 12)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}