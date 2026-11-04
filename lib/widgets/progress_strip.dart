import 'package:flutter/material.dart';

import '../theme.dart';

/// Barra do topo: laranja = concluídas, vermelho = atrasadas, escuro = resto.
class ProgressStrip extends StatelessWidget {
  const ProgressStrip({super.key, required this.total, required this.done, required this.overdue});

  final int total, done, overdue;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, c) {
      final w = c.maxWidth;
      final doneW = total == 0 ? 0.0 : w * done / total;
      final overW = total == 0 ? 0.0 : w * overdue / total;
      final allDone = total > 0 && done == total;
      return Container(
        height: 12,
        color: Palette.deepPurple,
        child: Row(children: [
          AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: doneW,
              color: allDone ? Palette.green : Palette.orange),
          AnimatedContainer(
              duration: const Duration(milliseconds: 400), width: overW, color: Palette.red),
        ]),
      );
    });
  }
}
