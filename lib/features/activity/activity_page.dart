import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../core/models/schedule_model.dart';
import '../../core/models/activity_status_model.dart';
import '../../core/services/schedule_service.dart';
import '../../widgets/app_drawer.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  final ScheduleService _service = ScheduleService();

  final List<String> _days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  List<ScheduleModel> todayActivities = [];

  @override
  void initState() {
    super.initState();
    loadTodayActivities();
  }

  void loadTodayActivities() {
    final today = DateTime.now();
    final dayName = _days[today.weekday - 1];

    todayActivities = _service
        .getSchedules()
        .where((s) => s.day == dayName)
        .toList();

    setState(() {});
  }

  bool isCompleted(ScheduleModel activity) {
    final box = Hive.box<ActivityStatusModel>('activity_status');

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = "$today-${activity.key}";

    final data = box.get(key);

    return data?.isCompleted ?? false;
  }

  void toggleComplete(ScheduleModel activity, bool value) {
    final box = Hive.box<ActivityStatusModel>('activity_status');

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = "$today-${activity.key}";

    box.put(
      key,
      ActivityStatusModel(
        scheduleKey: activity.key.toString(),
        date: today,
        isCompleted: value,
      ),
    );

    setState(() {});
  }

  double getProgress() {
    if (todayActivities.isEmpty) return 0;

    int done = todayActivities.where((a) => isCompleted(a)).length;

    return done / todayActivities.length;
  }

  int getStreak() {
    final box = Hive.box<ActivityStatusModel>('activity_status');

    int streak = 0;
    DateTime checkDay = DateTime.now();

    while (true) {
      final dayName = _days[checkDay.weekday - 1];

      final activities = _service
          .getSchedules()
          .where((s) => s.day == dayName)
          .toList();

      if (activities.isEmpty) break;

      bool allDone = activities.every((a) {
        final date = checkDay.toIso8601String().substring(0, 10);
        final key = "$date-${a.key}";
        final data = box.get(key);

        return data?.isCompleted ?? false;
      });

      if (allDone) {
        streak++;
        checkDay = checkDay.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }

  Map<String, int> getWeeklyStats() {
    final box = Hive.box<ActivityStatusModel>('activity_status');

    Map<String, int> stats = {};

    for (int i = 0; i < 7; i++) {
      DateTime day = DateTime.now().subtract(Duration(days: i));

      final dayName = _days[day.weekday - 1];

      final activities = _service
          .getSchedules()
          .where((s) => s.day == dayName)
          .toList();

      int done = activities.where((a) {
        final date = day.toIso8601String().substring(0, 10);
        final key = "$date-${a.key}";
        final data = box.get(key);

        return data?.isCompleted ?? false;
      }).length;

      stats[dayName] = done;
    }

    return stats;
  }

  @override
  Widget build(BuildContext context) {
    final progress = getProgress();
    final weeklyStats = getWeeklyStats();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const AppDrawer(currentRoute: '/activity'),
      appBar: AppBar(title: const Text("Today's Activity"), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 STREAK + PROGRESS CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Today's Progress",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      Text(
                        "🔥 ${getStreak()} Hari",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white24,
                    color: Colors.white,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(10),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "${(progress * 100).toInt()}% Completed",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 LIST ACTIVITY
            Expanded(
              child: todayActivities.isEmpty
                  ? const Center(child: Text("No activity today"))
                  : ListView.builder(
                      itemCount: todayActivities.length,
                      itemBuilder: (context, index) {
                        final activity = todayActivities[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: CheckboxListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            title: Text(
                              activity.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${activity.startTime} - ${activity.endTime}",
                            ),
                            secondary: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.checklist,
                                color: Colors.blue,
                              ),
                            ),
                            value: isCompleted(activity),
                            onChanged: (value) {
                              toggleComplete(activity, value!);
                            },
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 10),

            /// 📈 WEEKLY STATS
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Weekly Stats",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: weeklyStats.entries.map((entry) {
                  return Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.shade200, Colors.blue.shade400],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
