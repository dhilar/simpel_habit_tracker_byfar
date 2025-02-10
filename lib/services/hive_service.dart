import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/habit.dart';

class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  late Box<Habit> _habitBox;
  bool _isInitialized =
      false; // ✅ Tambahkan untuk memastikan Hive hanya inisialisasi sekali

  /// **Inisialisasi Hive**
  Future<void> initHive() async {
    if (_isInitialized) return; // ✅ Cegah inisialisasi ganda

    await Hive.initFlutter();

    /// **Registrasi Adapter jika belum terdaftar**
    if (!Hive.isAdapterRegistered(HabitAdapter().typeId)) {
      Hive.registerAdapter(HabitAdapter());
    }

    /// **Buka Box Habit**
    _habitBox = await Hive.openBox<Habit>('habits');

    _isInitialized = true; // ✅ Tandai bahwa Hive sudah diinisialisasi
  }

  /// **Tambah Habit**
  Future<void> addHabit(Habit habit) async {
    await _habitBox.add(habit);
  }

  /// **Update Habit**
  Future<void> updateHabit(int index, Habit habit) async {
    await _habitBox.putAt(index, habit);
  }

  /// **Hapus Habit**
  Future<void> deleteHabit(int index) async {
    await _habitBox.deleteAt(index);
  }

  /// **Ambil Semua Habit**
  List<Habit> getHabits() {
    if (!_isInitialized) {
      throw Exception("Hive belum diinisialisasi. Panggil initHive() dulu.");
    }
    return _habitBox.values.toList();
  }

  /// **Ambil Box untuk penggunaan langsung**
  Box<Habit> getBox() {
    if (!_isInitialized) {
      throw Exception("Hive belum diinisialisasi. Panggil initHive() dulu.");
    }
    return _habitBox;
  }
}
