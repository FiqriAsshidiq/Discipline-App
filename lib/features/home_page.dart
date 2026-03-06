import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../widgets/app_drawer.dart';
import '../../../core/services/schedule_service.dart';
import '../../../core/models/schedule_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScheduleService _service = ScheduleService();

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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

  /// 🔹 Filter berdasarkan nama hari
  List<ScheduleModel> _getActivitiesForDay(DateTime date) {
    String selectedDayName = _getDayName(date.weekday);

    return _service.getSchedules().where((schedule) {
      return schedule.day == selectedDayName;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final activities = _getActivitiesForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      drawer: const AppDrawer(currentRoute: '/home'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 📅 CALENDAR
            TableCalendar(
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

            const SizedBox(height: 15),

            Text(
              "Activities for ${_getDayName(_selectedDay.weekday)}",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            /// 📋 LIST ACTIVITY
            Expanded(
              child: activities.isEmpty
                  ? const Center(
                      child: Text(
                        "No activity for this day",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: activities.length,
                      itemBuilder: (context, index) {
                        final activity = activities[index];

                        return Card(
                          elevation: 3,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            title: Text(
                              activity.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              "${activity.startTime} - ${activity.endTime}",
                            ),
                            leading: const Icon(Icons.event),
                          ),
                        );
                      },
                    ),
            ),

            /// 🔵 BUTTON OPEN ACTIVITY
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/activity');
                },
                child: const Text("Open Activity"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
