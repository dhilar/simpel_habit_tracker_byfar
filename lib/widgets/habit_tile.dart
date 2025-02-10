import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitTile extends StatelessWidget {
  final Habit habit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(habit.name),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) => onDelete(),
      child: ListTile(
        title: Text(habit.name),
        trailing: Checkbox(
          value: habit.isCompleted,
          onChanged: (value) => onToggle(),
        ),
      ),
    );
  }
}
