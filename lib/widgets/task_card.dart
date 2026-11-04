import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme.dart';

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Palette.purple,
    this.size = 38,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Palette.deepPurple, width: 3),
        ),
        child: Icon(icon, color: Colors.black, size: size * 0.55),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.overdue,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  final Task task;
  final bool overdue;
  final VoidCallback onToggle, onDelete, onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            padding: const EdgeInsets.fromLTRB(16, 12, 36, 18),
            decoration: BoxDecoration(
              color: task.done ? Palette.purple.withOpacity(0.55) : Palette.purple,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: overdue ? Palette.red : Palette.deepPurple, width: 3),
            ),
            child: Center(
              child: Text(
                task.title.toUpperCase(),
                textAlign: TextAlign.center,
                style: displayStyle(14).copyWith(
                  decoration: task.done ? TextDecoration.lineThrough : null,
                  decorationThickness: 2.5,
                ),
              ),
            ),
          ),
          Positioned(right: -8, top: -8, child: RoundIconButton(icon: Icons.edit, onTap: onEdit)),
          Positioned(
            left: -8,
            bottom: -16,
            child: RoundIconButton(
              icon: Icons.check,
              onTap: onToggle,
              color: task.done ? Palette.green : Palette.purple,
              size: 42,
            ),
          ),
          Positioned(
            left: 38,
            bottom: -14,
            child: RoundIconButton(icon: Icons.delete_outline, onTap: onDelete, color: Palette.lilac),
          ),
        ],
      ),
    );
  }
}
