import 'package:hive/hive.dart';

part 'schedule_model.g.dart';

@HiveType(typeId: 0)
class ScheduleModel extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String day;

  @HiveField(2)
  String startTime;

  @HiveField(3)
  String endTime;

  ScheduleModel({
    required this.title,
    required this.day,
    required this.startTime,
    required this.endTime,
  });
}
