import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HiveService _hiveService = HiveService();
  final TextEditingController _habitController = TextEditingController();

  void _addHabit() {
    if (_habitController.text.isNotEmpty) {
      _hiveService.addHabit(Habit(name: _habitController.text));
      _habitController.clear();
      setState(() {}); // Update UI
    }
  }

  void _toggleHabitCompletion(int index, Habit habit) {
    _hiveService.updateHabit(index, Habit(name: habit.name, isCompleted: !habit.isCompleted));
    if (!habit.isCompleted) {
      NotificationService.showNotification(
        id: index,
        title: 'Habit Tracker',
        body: 'Selamat! Anda telah menyelesaikan kebiasaan "${habit.name}" 🎉',
      );
    }
    setState(() {});
  }

  void _deleteHabit(int index) {
    _hiveService.deleteHabit(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _habitController,
                    decoration: const InputDecoration(labelText: 'Tambah Habit'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _addHabit,
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('habits').listenable(),
              builder: (context, Box box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('Belum ada kebiasaan'));
                }

                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    Habit habit = box.getAt(index);
                    return Dismissible(
                      key: Key(habit.name),
                      background: Container(color: Colors.red, child: const Icon(Icons.delete, color: Colors.white)),
                      onDismissed: (direction) => _deleteHabit(index),
                      child: ListTile(
                        title: Text(habit.name),
                        trailing: Checkbox(
                          value: habit.isCompleted,
                          onChanged: (value) => _toggleHabitCompletion(index, habit),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
