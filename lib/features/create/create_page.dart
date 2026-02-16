import 'package:flutter/material.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/services/schedule_service.dart';
import 'schedule_list_page.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titleController = TextEditingController();
  final _dayController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  final ScheduleService _service = ScheduleService();

  void _saveSchedule() async {
    final schedule = ScheduleModel(
      title: _titleController.text,
      day: _dayController.text,
      startTime: _startController.text,
      endTime: _endController.text,
    );

    await _service.addSchedule(schedule);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Schedule Saved')));

    _titleController.clear();
    _dayController.clear();
    _startController.clear();
    _endController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Schedule")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: _dayController,
              decoration: const InputDecoration(labelText: "Day"),
            ),
            TextField(
              controller: _startController,
              decoration: const InputDecoration(labelText: "Start Time"),
            ),
            TextField(
              controller: _endController,
              decoration: const InputDecoration(labelText: "End Time"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ScheduleListPage()),
                );
              },
              child: const Text("View All Schedules"),
            ),

            ElevatedButton(onPressed: _saveSchedule, child: const Text("Save")),
          ],
        ),
      ),
    );
  }
}
