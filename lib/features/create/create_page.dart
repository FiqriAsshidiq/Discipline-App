import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/services/schedule_service.dart';
import '../../../features/create/schedule_list_page.dart';
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
  void dispose() {
    _titleController.dispose();
    _startController.dispose();
    _endController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Schedule"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: AppDrawer(currentRoute: '/create'),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('asset/images/BG_create.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.4)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                    child: Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            "Create Schedule",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 20),

                          TextField(
                            controller: _titleController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration("Activity Title"),
                          ),

                          const SizedBox(height: 15),

                          DropdownButtonFormField<String>(
                            value: _selectedDay,
                            dropdownColor: Colors.black87,
                            style: const TextStyle(color: Colors.white),
                            items: _days
                                .map(
                                  (day) => DropdownMenuItem(
                                    value: day,
                                    child: Text(day),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedDay = value!;
                              });
                            },
                            decoration: _inputDecoration("Day"),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: _startController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            onTap: () => _pickTime(_startController),
                            decoration: _inputDecoration("Start Time"),
                          ),

                          const SizedBox(height: 15),

                          TextField(
                            controller: _endController,
                            readOnly: true,
                            style: const TextStyle(color: Colors.white),
                            onTap: () => _pickTime(_endController),
                            decoration: _inputDecoration("End Time"),
                          ),

                          const SizedBox(height: 25),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveSchedule,
                              child: const Text("Save"),
                            ),
                          ),

                          const SizedBox(height: 10),

                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ScheduleListPage(),
                                  ),
                                );
                              },
                              child: const Text(
                                "View All Schedules",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(15),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
