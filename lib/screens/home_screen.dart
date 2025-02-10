import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../models/habit.dart';
import '../services/hive_service.dart';
import '../services/notification_service.dart';
import 'completed_habits_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HiveService _hiveService = HiveService();
  final TextEditingController _habitController = TextEditingController();

  final List<String> _motivationalMessages = [
    "Hebat! Satu langkah lebih dekat ke sukses! 🚀",
    "Mantap! Konsistensi adalah kunci! 🔑",
    "Luar biasa! Teruskan semangatnya! 💪",
    "Keren! Disiplin akan membawa hasil besar! ✨"
  ];

  void _addHabit() {
    if (_habitController.text.isNotEmpty) {
      _hiveService.addHabit(Habit(name: _habitController.text));
      _habitController.clear();
      setState(() {});
    }
  }

  void _toggleHabitCompletion(int index, Habit habit) {
    _hiveService.updateHabit(
        index, Habit(name: habit.name, isCompleted: !habit.isCompleted));

    if (!habit.isCompleted) {
      NotificationService.showNotification(
        id: index,
        title: 'Habit Tracker',
        body: 'Selamat! Anda telah menyelesaikan kebiasaan "${habit.name}" 🎉',
      );

      String message = (_motivationalMessages..shuffle()).first;
      _showMotivationalDialog(message);
    }
    setState(() {});
  }

  void _showMotivationalDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Selamat! 🎉"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    String appLink = "https://github.com/user/simpel_habit_tracker_byfar";
    String message =
        "Ayo coba aplikasi Simple Habit Tracker! 🚀\n\nDownload di sini: [$appLink]";

    if (kIsWeb) {
      html.window.navigator.clipboard!.writeText(message);
      html.window.open(
          "https://wa.me/?text=${Uri.encodeComponent(message)}", "_blank");
    } else {
      Share.share(message);
    }
  }

  Future<void> _shareCompletedHabits() async {
    final Box<Habit> box = _hiveService.getBox();
    List<String> completedHabits = box.values
        .where((habit) => habit.isCompleted)
        .map((habit) => "✅ ${habit.name}")
        .toList();

    if (completedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Belum ada habit yang selesai!")),
      );
      return;
    }

    String appLink = "https://github.com/user/simpel_habit_tracker_byfar";
    String message =
        "Aku sudah mencoba aplikasi habit tracker! Kamu kapan? 🚀\n\n"
        "${completedHabits.join("\n")}\n\n"
        "Download: [$appLink]";

    if (kIsWeb) {
      html.window.navigator.clipboard!.writeText(message);
      html.window.open(
          "https://wa.me/?text=${Uri.encodeComponent(message)}", "_blank");
    } else {
      await Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Menu',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                  Text(
                    'by far',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Bagikan Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                _shareApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: const Text('Habit yang Selesai'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CompletedHabitsScreen()),
                );
              },
            ),
          ],
        ),
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
                    decoration:
                        const InputDecoration(labelText: 'Tambah Habit'),
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
              valueListenable: _hiveService.getBox().listenable(),
              builder: (context, Box<Habit> box, _) {
                if (box.isEmpty) {
                  return const Center(child: Text('Belum ada kebiasaan'));
                }
                return ListView.builder(
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    Habit habit = box.getAt(index)!;
                    return Dismissible(
                      key: Key(habit.name),
                      background: Container(
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) =>
                          _hiveService.deleteHabit(index),
                      child: ListTile(
                        title: Text(habit.name),
                        trailing: Checkbox(
                          value: habit.isCompleted,
                          onChanged: (value) =>
                              _toggleHabitCompletion(index, habit),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.share),
              label: const Text("Bagikan Habit Selesai"),
              onPressed: _shareCompletedHabits,
            ),
          ),
        ],
      ),
    );
  }
}
