import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';
import 'dart:typed_data';
import 'dart:html' as html; // Untuk clipboard & WhatsApp Web di Web
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
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAndShareProgress() async {
    final completedHabits = _hiveService
        .getHabits()
        .where((habit) => habit.isCompleted)
        .map((habit) => "✅ ${habit.name}")
        .join("\n");

    final textToShare =
        "Aku sudah mencoba aplikasi habit tracker! Kamu kapan? 🌟\n\n$completedHabits\n\nDownload: [https://www.youtube.com/]";

    if (kIsWeb) {
      // 🔹 **Web: Simpan ke Clipboard & Buka WhatsApp Web**
      html.window.navigator.clipboard!.writeText(textToShare);
      html.window.open(
          "https://wa.me/?text=${Uri.encodeComponent(textToShare)}", "_blank");
    } else {
      // 🔹 **Mobile: Share dengan Gambar**
      try {
        final ByteData bytes = await rootBundle.load('assets/images/logo.png');
        final Uint8List byteList = bytes.buffer.asUint8List();

        final tempDir = Directory.systemTemp;
        final file = await File('${tempDir.path}/logo.png').create();
        await file.writeAsBytes(byteList);

        await Share.shareXFiles(
          [XFile(file.path)],
          text: textToShare,
        );
      } catch (e) {
        print("Error saat membagikan: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Habit yang Selesai",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ),
            ValueListenableBuilder(
              valueListenable: _hiveService.getBox().listenable(),
              builder: (context, Box<Habit> box, _) {
                final completedHabits =
                    box.values.where((h) => h.isCompleted).toList();
                return completedHabits.isEmpty
                    ? const ListTile(title: Text("Belum ada yang selesai"))
                    : Column(
                        children: completedHabits
                            .map((habit) =>
                                ListTile(title: Text("✅ ${habit.name}")))
                            .toList(),
                      );
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text("Bagikan Progress"),
              onTap: _downloadAndShareProgress,
            ),
            const Divider(), // Garis pemisah sebelum teks "by Far"
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  "by Far",
                  style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ),
              ),
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
        ],
      ),
    );
  }
}
