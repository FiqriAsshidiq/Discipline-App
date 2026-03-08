import 'package:flutter/material.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/services/schedule_service.dart';
import '../../widgets/app_drawer.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  final _titleController = TextEditingController();
  final _startController = TextEditingController();
  final _endController = TextEditingController();

  final ScheduleService _service = ScheduleService();

  String _selectedDay = "Senin";

  final List<String> _days = [
    "Senin",
    "Selasa",
    "Rabu",
    "Kamis",
    "Jumat",
    "Sabtu",
    "Minggu",
  ];

  Future<void> _pickTime(TextEditingController controller) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      final formatted =
          "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";

      controller.text = formatted;
    }
  }

  void _saveSchedule() async {
    if (_titleController.text.isEmpty ||
        _startController.text.isEmpty ||
        _endController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    final schedule = ScheduleModel(
      title: _titleController.text,
      day: _selectedDay,
      startTime: _startController.text,
      endTime: _endController.text,
    );

    await _service.addSchedule(schedule);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Schedule Saved")));

    _titleController.clear();
    _startController.clear();
    _endController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/create'),

      appBar: AppBar(title: const Text("Create Activity"), elevation: 0),

      backgroundColor: const Color.fromARGB(255, 241, 241, 241),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Create New Activity",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 6),

                  Text(
                    "Add activity to your weekly schedule",
                    style: TextStyle(color: Color.fromARGB(228, 255, 255, 255)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 📋 FORM CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    /// TITLE
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: "Activity Title",
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DAY
                    DropdownButtonFormField<String>(
                      value: _selectedDay,
                      items: _days
                          .map(
                            (day) =>
                                DropdownMenuItem(value: day, child: Text(day)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedDay = value!;
                        });
                      },
                      decoration: const InputDecoration(
                        labelText: "Day",
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// START TIME
                    TextField(
                      controller: _startController,
                      readOnly: true,
                      onTap: () => _pickTime(_startController),
                      decoration: const InputDecoration(
                        labelText: "Start Time",
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// END TIME
                    TextField(
                      controller: _endController,
                      readOnly: true,
                      onTap: () => _pickTime(_endController),
                      decoration: const InputDecoration(
                        labelText: "End Time",
                        prefixIcon: Icon(Icons.access_time),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Activity",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
