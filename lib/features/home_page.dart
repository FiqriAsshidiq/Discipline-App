import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive/hive.dart';

import '../../widgets/app_drawer.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/models/activity_status_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScheduleService _service = ScheduleService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String _getGreeting() {
    int hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning ☀️";
    } else if (hour < 18) {
      return "Good Afternoon 🌤";
    } else {
      return "Good Evening 🌙";
    }
  }

  String _getDayName(int weekday) {
    const days = [
      "",
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];
    return days[weekday];
  }

  List<ScheduleModel> _getActivitiesForDay(DateTime date) {
    String selectedDayName = _getDayName(date.weekday);

    return _service.getSchedules().where((schedule) {
      return schedule.day == selectedDayName;
    }).toList();
  }

  bool isCompleted(ScheduleModel activity) {
    final box = Hive.box<ActivityStatusModel>('activity_status');

    final today = DateTime.now().toIso8601String().substring(0, 10);
    final key = "$today-${activity.key}";

    final data = box.get(key);

    return data?.isCompleted ?? false;
  }

  double _calculateProgress(List<ScheduleModel> activities) {
    if (activities.isEmpty) return 0;

    int done = activities.where((a) => isCompleted(a)).length;

    return done / activities.length;
  }

  @override
  Widget build(BuildContext context) {
    final activities = _getActivitiesForDay(_selectedDay);
    double progress = _calculateProgress(activities);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const AppDrawer(currentRoute: '/home'),
      appBar: AppBar(elevation: 0, title: const Text("Home")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// GREETING
              Row(
                children: [
                  const Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
                  const SizedBox(width: 10),
                  Text(
                    _getGreeting(),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              const Text(
                "Stay productive today 💪",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),

              const SizedBox(height: 20),

              /// PROGRESS CARD
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Today's Progress",
                      style: TextStyle(color: Colors.white, fontSize: 18),
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

              /// CALENDAR
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Activities for ${_getDayName(_selectedDay.weekday)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              /// LIST ACTIVITY
              activities.isEmpty
                  ? const Center(
                      child: Text(
                        "No activity for this day",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.event,
                                color: Colors.blue,
                              ),
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
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 20),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/activity');
                  },
                  child: const Text(
                    "Open Activity",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
