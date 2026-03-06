import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../widgets/app_drawer.dart';
import '../../core/models/schedule_model.dart';
import '../../core/models/activity_status_model.dart';
import '../../core/services/schedule_service.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final ScheduleService _service = ScheduleService();
  late Box<ActivityStatusModel> statusBox;

  @override
  void initState() {
    super.initState();
    statusBox = Hive.box<ActivityStatusModel>('activity_status');
  }

  String _todayName() {
    final weekday = DateTime.now().weekday;

    const days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];

    return days[weekday - 1];
  }

  String _todayDate() {
    final now = DateTime.now();
    return "${now.year}-${now.month}-${now.day}";
  }

  bool _isCompleted(String scheduleKey) {
    final key = "${scheduleKey}_${_todayDate()}";

    final status = statusBox.get(key);

    if (status == null) return false;

    return status.isCompleted;
  }

  void _toggleActivity(ScheduleModel schedule) {
    final key = "${schedule.key}_${_todayDate()}";

    final status = statusBox.get(key);

    if (status == null) {
      statusBox.put(
        key,
        ActivityStatusModel(
          scheduleKey: schedule.key.toString(),
          date: _todayDate(),
          isCompleted: true,
        ),
      );
    } else {
      status.isCompleted = !status.isCompleted;
      status.save();
    }

    setState(() {});
  }

  double _calculateProgress(List<ScheduleModel> schedules) {
    if (schedules.isEmpty) return 0;

    int completed = 0;

    for (var s in schedules) {
      if (_isCompleted(s.key.toString())) {
        completed++;
      }
    }

    return completed / schedules.length;
  }

  @override
  Widget build(BuildContext context) {
    final today = _todayName();

    final schedules = _service
        .getSchedules()
        .where((s) => s.day == today)
        .toList();

    final progress = _calculateProgress(schedules);

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Activity")),
      drawer: const AppDrawer(currentRoute: '/activity'),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// PROGRESS BAR
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      "Today's Progress",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(value: progress, minHeight: 10),

                    const SizedBox(height: 10),

                    Text(
                      "${(progress * 100).toStringAsFixed(0)}% Completed",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ACTIVITY LIST
            Expanded(
              child: schedules.isEmpty
                  ? const Center(child: Text("No activities today"))
                  : ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];

                        final completed = _isCompleted(schedule.key.toString());

                        return Card(
                          child: CheckboxListTile(
                            title: Text(schedule.title),

                            subtitle: Text(
                              "${schedule.startTime} - ${schedule.endTime}",
                            ),

                            value: completed,

                            onChanged: (_) {
                              _toggleActivity(schedule);
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
