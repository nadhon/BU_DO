import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/task_store.dart';
import '../theme.dart';
import '../widgets/ghost.dart';
import '../widgets/task_card.dart';

/// Cria (task == null) ou edita uma tarefa. Fundo de "folha pautada" como no protótipo.
class EditScreen extends StatefulWidget {
  const EditScreen({super.key, this.task});
  final Task? task;

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.task?.title ?? '');
  DateTime? _deadline;

  @override
  void initState() {
    super.initState();
    _deadline = widget.task?.deadline;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _deadline ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (d == null || !mounted) return;
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? now),
    );
    if (t == null) return;
    setState(() => _deadline = DateTime(d.year, d.month, d.day, t.hour, t.minute));
  }

  void _save() {
    final text = _ctrl.text.trim();
    final store = context.read<TaskStore>();
    if (text.isNotEmpty) {
      widget.task == null
          ? store.add(text, deadline: _deadline)
          : store.update(widget.task!, text, _deadline);
    }
    Navigator.pop(context);
  }

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Palette.purple,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.deepPurple, width: 3),
                ),
                child: Center(child: Text('TAREFA', style: displayStyle(14))),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Palette.deepPurple, width: 3),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Stack(
                      children: [
                        Positioned.fill(child: CustomPaint(painter: _LinedPaperPainter())),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            controller: _ctrl,
                            autofocus: true,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(fontSize: 16, height: 22 / 16),
                            decoration: const InputDecoration(border: InputBorder.none, hintText: 'O que precisa ser feito?'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  backgroundColor: Palette.lilac,
                  side: const BorderSide(color: Palette.deepPurple, width: 2),
                  avatar: const Icon(Icons.schedule, size: 18, color: Colors.black),
                  label: Text(_deadline == null ? 'Definir prazo (opcional)' : 'Prazo: ${_fmt(_deadline!)}'),
                  onPressed: _pickDeadline,
                  onDeleted: _deadline == null ? null : () => setState(() => _deadline = null),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  RoundIconButton(icon: Icons.check, onTap: _save, size: 48),
                  const SizedBox(width: 12),
                  RoundIconButton(icon: Icons.close, onTap: () => Navigator.pop(context), color: Palette.lilac, size: 48),
                  const Spacer(),
                  const Ghost(mood: GhostMood.calm, size: 90),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinedPaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFB8C4D9)
      ..strokeWidth = 1;
    // Linhas alinhadas com o height 22 do texto.
    for (var y = 22.0 + 13; y < size.height; y += 22) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
