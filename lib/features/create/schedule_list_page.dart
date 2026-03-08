import 'package:flutter/material.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/services/schedule_service.dart';
import '../../../widgets/app_drawer.dart';

class ScheduleListPage extends StatefulWidget {
  const ScheduleListPage({super.key});

  @override
  State<ScheduleListPage> createState() => _ScheduleListPageState();
}

class _ScheduleListPageState extends State<ScheduleListPage> {
  final ScheduleService _service = ScheduleService();
  bool showTodayOnly = false;

  @override
  Widget build(BuildContext context) {
    final schedules = showTodayOnly
        ? _service.getTodaySchedules()
        : _service.getSchedules();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const AppDrawer(currentRoute: '/viewall'),
      appBar: AppBar(
        title: const Text("Schedules"),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: "Toggle Today Schedule",
            icon: Icon(showTodayOnly ? Icons.today : Icons.calendar_month),
            onPressed: () {
              setState(() {
                showTodayOnly = !showTodayOnly;
              });
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER INFO
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Your Schedules",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        "${schedules.length} activities",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Icon(Icons.event_note, color: Colors.white, size: 35),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// LIST SCHEDULE
            Expanded(
              child: schedules.isEmpty
                  ? const Center(
                      child: Text(
                        "No schedules found",
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];

                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),

                            /// ICON
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.schedule,
                                color: Colors.blue,
                              ),
                            ),

                            /// TITLE
                            title: Text(
                              schedule.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),

                            /// SUBTITLE
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                "${schedule.day} • ${schedule.startTime} - ${schedule.endTime}",
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ),

                            /// ACTIONS
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                /// EDIT
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue,
                                  onPressed: () {
                                    _showEditDialog(schedule, index);
                                  },
                                ),

                                /// DELETE
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  color: Colors.red,
                                  onPressed: () async {
                                    await _service.deleteSchedule(index);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
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

  void _showEditDialog(ScheduleModel schedule, int index) {
    final titleController = TextEditingController(text: schedule.title);
    final startController = TextEditingController(text: schedule.startTime);
    final endController = TextEditingController(text: schedule.endTime);

    String selectedDay = schedule.day;

    final List<String> days = [
      "Senin",
      "Selasa",
      "Rabu",
      "Kamis",
      "Jumat",
      "Sabtu",
      "Minggu",
    ];

    Future<void> pickTime(TextEditingController controller) async {
      final picked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (picked != null) {
        controller.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      }
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Edit Schedule"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: selectedDay,
                  items: days
                      .map(
                        (day) => DropdownMenuItem(value: day, child: Text(day)),
                      )
                      .toList(),
                  onChanged: (value) {
                    selectedDay = value!;
                  },
                  decoration: const InputDecoration(labelText: "Day"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: startController,
                  readOnly: true,
                  onTap: () => pickTime(startController),
                  decoration: const InputDecoration(labelText: "Start Time"),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: endController,
                  readOnly: true,
                  onTap: () => pickTime(endController),
                  decoration: const InputDecoration(labelText: "End Time"),
                ),
              ],
            ),
          ),

          actions: [
            TextButton(
              onPressed: () async {
                final updated = ScheduleModel(
                  title: titleController.text,
                  day: selectedDay,
                  startTime: startController.text,
                  endTime: endController.text,
                );

                await _service.updateSchedule(index, updated);

                setState(() {});
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
