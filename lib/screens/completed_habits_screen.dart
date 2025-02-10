import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import '../models/habit.dart';
import '../services/hive_service.dart';

class CompletedHabitsScreen extends StatelessWidget {
  final HiveService _hiveService = HiveService();

  CompletedHabitsScreen({super.key});

  void _shareCompletedHabits(BuildContext context) {
    final Box<Habit> box = _hiveService.getBox();
    List<String> completedHabits = box.values
        .where((habit) => habit.isCompleted)
        .map((habit) => "✅ ${habit.name}")
        .toList();

    String appLink = "https://github.com/user/simpel_habit_tracker_byfar";
    String message =
        "Aku sudah mencoba aplikasi habit tracker! Kamu kapan? 🚀\n\n"
        "${completedHabits.join("\n")}\n\n"
        "Download: [$appLink]";

    if (completedHabits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tidak ada habit yang sudah selesai!")),
      );
      return;
    }

    if (kIsWeb) {
      try {
        html.window.navigator.clipboard!.writeText(message);
        html.window.open(
            "https://wa.me/?text=${Uri.encodeComponent(message)}", "_blank");
      } catch (e) {
        print("Gagal menyalin ke clipboard: $e");
      }
    } else {
      Share.share(message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit yang Selesai')),
      body: ValueListenableBuilder(
        valueListenable: _hiveService.getBox().listenable(),
        builder: (context, Box<Habit> box, _) {
          List<Habit> completedHabits =
              box.values.where((habit) => habit.isCompleted).toList();

          if (completedHabits.isEmpty) {
            return const Center(child: Text('Belum ada habit yang selesai.'));
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: completedHabits.length,
                  itemBuilder: (context, index) {
                    Habit habit = completedHabits[index];
                    return ListTile(
                      title: Text("✅ ${habit.name}"),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton.icon(
                  onPressed: () => _shareCompletedHabits(context),
                  icon: const Icon(Icons.share),
                  label: const Text("Bagikan Progress"),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
