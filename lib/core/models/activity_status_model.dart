import 'package:hive/hive.dart';

part 'activity_status_model.g.dart';

@HiveType(typeId: 1)
class ActivityStatusModel extends HiveObject {
  @HiveField(0)
  String scheduleKey;

  @HiveField(1)
  String date;

  @HiveField(2)
  bool isCompleted;

  ActivityStatusModel({
    required this.scheduleKey,
    required this.date,
    required this.isCompleted,
  });
}
