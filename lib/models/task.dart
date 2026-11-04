/// Humor do fantasma (reflete o quanto o usuário está em dia).
enum GhostMood { sad, happy, calm, worried, anxious, degraded }

extension GhostMoodX on GhostMood {
  String get message => switch (this) {
        GhostMood.sad => 'Sem tarefas... tô sozinho aqui.',
        GhostMood.happy => 'Tudo feito! Você é incrível!',
        GhostMood.calm => 'Tudo sob controle... por enquanto.',
        GhostMood.worried => 'Hum... tem tarefa atrasada.',
        GhostMood.anxious => 'Duas atrasadas?! Tô vendo coisas...',
        GhostMood.degraded => 'VOCÊ ME ABANDONOU. BUUUU!',
      };
}

class Task {
  Task({
    required this.id,
    required this.title,
    required this.createdAt,
    this.deadline,
    this.done = false,
  });

  final String id;
  String title;
  bool done;
  DateTime createdAt;
  DateTime? deadline;

  /// Atrasada = pendente e passou do prazo.
  /// Sem prazo definido, vale o período de tolerância ([grace]) desde a criação.
  bool isOverdue(DateTime now, Duration grace) {
    if (done) return false;
    return now.isAfter(deadline ?? createdAt.add(grace));
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'done': done,
        'createdAt': createdAt.toIso8601String(),
        'deadline': deadline?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> j) => Task(
        id: j['id'] as String,
        title: j['title'] as String,
        done: j['done'] as bool? ?? false,
        createdAt: DateTime.parse(j['createdAt'] as String),
        deadline:
            j['deadline'] == null ? null : DateTime.parse(j['deadline'] as String),
      );
}
