import 'package:hive/hive.dart';

part 'habit.g.dart'; // Diperlukan untuk Hive TypeAdapter

@HiveType(typeId: 0) // Set ID unik untuk Hive
class Habit {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool isCompleted;

  Habit({required this.name, this.isCompleted = false});
}
