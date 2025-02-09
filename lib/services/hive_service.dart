import 'package:hive/hive.dart';
import '../models/habit.dart';

class HiveService {
  late Box _habitBox;

  // Inisialisasi Hive (Dipanggil sekali saat aplikasi dimulai)
  Future<void> initHive() async {
    if (!Hive.isBoxOpen('habits')) {
      _habitBox = await Hive.openBox('habits');
    } else {
      _habitBox = Hive.box('habits');
    }
  }

  // Menyimpan Habit ke Hive
  Future<void> addHabit(Habit habit) async {
    try {
      await _habitBox.add(habit);
    } catch (e) {
      print('Error menambahkan habit: $e');
    }
  }

  // Mengambil semua Habit
  List<Habit> getAllHabits() {
    try {
      return _habitBox.values.cast<Habit>().toList();
    } catch (e) {
      print('Error mengambil habit: $e');
      return [];
    }
  }

  // Mengupdate status Habit
  Future<void> updateHabit(int index, Habit habit) async {
    try {
      await _habitBox.putAt(index, habit);
    } catch (e) {
      print('Error memperbarui habit: $e');
    }
  }

  // Menghapus Habit
  Future<void> deleteHabit(int index) async {
    try {
      await _habitBox.deleteAt(index);
    } catch (e) {
      print('Error menghapus habit: $e');
    }
  }
}
