import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simpel_habit_tracker_byfar/services/notification_service.dart';
import 'screens/home_screen.dart';
import 'dart:io'; // Untuk cek platform
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive
  await Hive.initFlutter();
  await Hive.openBox('habits');

  // Inisialisasi Notifikasi (Hanya di Android/iOS)
  if (!kIsWeb && !Platform.isLinux && !Platform.isWindows && !Platform.isMacOS) {
    await NotificationService.initialize();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simpel Habit Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}
