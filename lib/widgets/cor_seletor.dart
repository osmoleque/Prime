import 'package:flutter/material.dart';

class CorSeletor extends StatelessWidget {
  final Color corAtual;
  final Function(Color) onCorSelecionada;

  const CorSeletor(
      {super.key, required this.corAtual, required this.onCorSelecionada});

  static const List<Color> cores = [
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    Colors.amber,
    Colors.pink,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: cores
          .map((c) => GestureDetector(
                onTap: () => onCorSelecionada(c),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: corAtual.toARGB32() == c.toARGB32()
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
