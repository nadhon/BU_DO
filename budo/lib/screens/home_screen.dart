import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/task.dart';
import '../state/task_store.dart';
import '../theme.dart';
import '../widgets/ghost.dart';
import '../widgets/progress_strip.dart';
import '../widgets/task_card.dart';
import 'edit_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Task t) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const _DeleteDialog(),
    );
    if (ok == true && context.mounted) context.read<TaskStore>().remove(t);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<TaskStore>();
    final now = DateTime.now();
    final tasks = s.tasks;

    return Scaffold(
      backgroundColor: Palette.cream,
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              // Segurar o título envelhece as tarefas em 25h: bom para testar o fantasma.
              onLongPress: s.debugAgeTasks,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                color: Palette.purple,
                child: Center(child: Text('BU! DOO', style: displayStyle(26))),
              ),
            ),
            ProgressStrip(total: s.total, done: s.doneCount, overdue: s.overdueCount),
            Expanded(
              child: Stack(
                children: [
                  // Fantasminha apagado de fundo
                  const Positioned(
                    left: 12,
                    bottom: 12,
                    child: Opacity(opacity: 0.15, child: Ghost(mood: GhostMood.calm, size: 70, animate: false)),
                  ),
                  if (tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 120),
                        child: Text('NENHUMA TAREFA\nTOQUE NO + ', textAlign: TextAlign.center, style: displayStyle(16, color: Palette.deepPurple)),
                      ),
                    )
                  else
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 180),
                      itemCount: tasks.length,
                      itemBuilder: (_, i) {
                        final t = tasks[i];
                        return TaskCard(
                          task: t,
                          overdue: t.isOverdue(now, TaskStore.grace),
                          onToggle: () => context.read<TaskStore>().toggle(t),
                          onDelete: () => _confirmDelete(context, t),
                          onEdit: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => EditScreen(task: t)),
                          ),
                        );
                      },
                    ),
                  // Balãozinho de fala do fantasma
                  Positioned(
                    right: 16,
                    bottom: 132,
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 190),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Palette.deepPurple, width: 2),
                      ),
                      child: Text(s.mood.message, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ),
                  Positioned(right: 12, bottom: 8, child: IgnorePointer(child: Ghost(mood: s.mood, size: 120))),
                  Positioned(
                    right: 140,
                    bottom: 20,
                    child: RoundIconButton(
                      icon: Icons.add,
                      size: 48,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const EditScreen()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.cream,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Palette.deepPurple, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Palette.lilac,
                shape: BoxShape.circle,
                border: Border.all(color: Palette.deepPurple, width: 4),
              ),
              child: const Icon(Icons.delete_outline, size: 64, color: Colors.black),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Palette.purple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.deepPurple, width: 3),
              ),
              child: Center(child: Text('EXCLUIR?', style: displayStyle(14))),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RoundIconButton(icon: Icons.check, onTap: () => Navigator.pop(context, true), size: 46),
                const SizedBox(width: 16),
                RoundIconButton(icon: Icons.close, onTap: () => Navigator.pop(context, false), color: Palette.lilac, size: 46),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
