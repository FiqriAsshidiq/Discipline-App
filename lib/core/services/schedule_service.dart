import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import 'package:flutter/foundation.dart';

class ScheduleService {
  final Box<ScheduleModel> _box = Hive.box<ScheduleModel>('scheduleBox');

  Future<void> addSchedule(ScheduleModel schedule) async {
    await _box.add(schedule);
  }

  List<ScheduleModel> getSchedules() {
    return _box.values.toList();
  }

  Future<void> deleteSchedule(int index) async {
    await _box.deleteAt(index);
  }

  Future<void> updateSchedule(int index, ScheduleModel schedule) async {
    await _box.putAt(index, schedule);
  }

  List<ScheduleModel> getTodaySchedules() {
    final today = _getTodayName();
    return _box.values.where((schedule) => schedule.day == today).toList();
  }

  String _getTodayName() {
    final now = DateTime.now();
    switch (now.weekday) {
      case 1:
        return "Senin";
      case 2:
        return "Selasa";
      case 3:
        return "Rabu";
      case 4:
        return "Kamis";
      case 5:
        return "Jumat";
      case 6:
        return "Sabtu";
      case 7:
        return "Minggu";
      default:
        return "Senin";
    }
  }
}
