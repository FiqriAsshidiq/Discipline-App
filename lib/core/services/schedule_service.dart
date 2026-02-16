import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/schedule_model.dart';
import 'package:flutter/foundation.dart';

class ScheduleService {
  static const String _boxName = 'scheduleBox';

  Future<Box<ScheduleModel>> _openBox() async {
    return await Hive.openBox<ScheduleModel>(_boxName);
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    final box = await _openBox();
    await box.add(schedule);
  }

  List<ScheduleModel> getSchedules() {
    final box = Hive.box<ScheduleModel>(_boxName);
    return box.values.toList();
  }

  Future<void> deleteSchedule(int index) async {
    final box = Hive.box<ScheduleModel>(_boxName);
    await box.deleteAt(index);
  }

  ValueListenable<Box<ScheduleModel>> listenToSchedules() {
    return Hive.box<ScheduleModel>(_boxName).listenable();
  }
}
