import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
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
      appBar: AppBar(
        title: const Text("Schedules"),
        actions: [
          IconButton(
            icon: Icon(showTodayOnly ? Icons.today : Icons.calendar_month),
            onPressed: () {
              setState(() {
                showTodayOnly = !showTodayOnly;
              });
            },
          ),
        ],
      ),

      drawer: AppDrawer(currentRoute: '/viewall'),

      body: schedules.isEmpty
          ? const Center(child: Text("No schedules found"))
          : ListView.builder(
              itemCount: schedules.length,
              itemBuilder: (context, index) {
                final schedule = schedules[index];

                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(schedule.title),
                    subtitle: Text(
                      "${schedule.day} | ${schedule.startTime} - ${schedule.endTime}",
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// EDIT
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _showEditDialog(schedule, index);
                          },
                        ),

                        /// DELETE
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
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
