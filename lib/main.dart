import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:simpel_habit_tracker_byfar/services/hive_service.dart';
import 'package:simpel_habit_tracker_byfar/services/notification_service.dart';
import 'package:simpel_habit_tracker_byfar/screens/home_screen.dart';
import 'package:simpel_habit_tracker_byfar/screens/splash_screen.dart';
import 'package:simpel_habit_tracker_byfar/models/habit.dart'; // Import model
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Inisialisasi Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HabitAdapter()); // Pastikan adapter terdaftar

  final hiveService = HiveService();
  await hiveService.initHive();

  // 🔹 Inisialisasi Notifikasi (Hanya untuk Android/iOS)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
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
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashScreen(), // Set SplashScreen sebagai halaman awal
    );
  }
}
