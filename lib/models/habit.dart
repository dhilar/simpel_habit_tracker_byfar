import 'package:hive/hive.dart';

part 'habit.g.dart'; // ✅ Wajib ada untuk Hive Adapter

@HiveType(typeId: 0)
class Habit extends HiveObject {
  // ✅ Gunakan HiveObject untuk memudahkan update/delete
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isCompleted;

  Habit({required this.name, this.isCompleted = false});
}
