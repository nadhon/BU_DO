import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/task.dart';

class TaskStore extends ChangeNotifier {
  static const _key = 'budo_tasks_v1';

  /// Tempo que uma tarefa SEM prazo pode ficar parada antes de contar como atrasada.
  static const grace = Duration(hours: 24);

  final List<Task> _tasks = [];
  Timer? _ticker;

  /// Pendentes primeiro, concluídas no fim.
  List<Task> get tasks => [
        ..._tasks.where((t) => !t.done),
        ..._tasks.where((t) => t.done),
      ];

  int get total => _tasks.length;
  int get doneCount => _tasks.where((t) => t.done).length;
  int get pendingCount => total - doneCount;

  int get overdueCount {
    final now = DateTime.now();
    return _tasks.where((t) => t.isOverdue(now, grace)).length;
  }

  GhostMood get mood {
    if (_tasks.isEmpty) return GhostMood.sad;
    if (pendingCount == 0) return GhostMood.happy;
    return switch (overdueCount) {
      0 => GhostMood.calm,
      1 => GhostMood.worried,
      2 => GhostMood.anxious,
      _ => GhostMood.degraded,
    };
  }

  /// 0.0 (tudo ok) -> 1.0 (3+ tarefas atrasadas = assombração total).
  double get haunting => (overdueCount / 3).clamp(0.0, 1.0);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _tasks
        ..clear()
        ..addAll(list.map((e) => Task.fromJson(e as Map<String, dynamic>)));
    }
    // Reavalia atrasos a cada 30s mesmo sem interação.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) => notifyListeners());
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_tasks.map((t) => t.toJson()).toList()));
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  void add(String title, {DateTime? deadline}) {
    _tasks.add(Task(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      createdAt: DateTime.now(),
      deadline: deadline,
    ));
    _commit();
  }

  void update(Task t, String title, DateTime? deadline) {
    t.title = title;
    t.deadline = deadline;
    _commit();
  }

  void toggle(Task t) {
    t.done = !t.done;
    _commit();
  }

  void remove(Task t) {
    _tasks.removeWhere((x) => x.id == t.id);
    _commit();
  }

  /// Para testar: envelhece as tarefas pendentes em 25h (segure o título do app).
  void debugAgeTasks() {
    for (final t in _tasks.where((t) => !t.done)) {
      t.createdAt = t.createdAt.subtract(const Duration(hours: 25));
      if (t.deadline != null) {
        t.deadline = t.deadline!.subtract(const Duration(hours: 25));
      }
    }
    _commit();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
