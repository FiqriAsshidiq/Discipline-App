import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/models/schedule_model.dart';
import '../../../core/services/schedule_service.dart';

class ScheduleListPage extends StatelessWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ScheduleService();

    return Scaffold(
      appBar: AppBar(title: const Text("All Schedules")),
      body: ValueListenableBuilder(
        valueListenable: service.listenToSchedules(),
        builder: (context, Box<ScheduleModel> box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No Schedule Yet"));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final schedule = box.getAt(index);

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(schedule?.title ?? ''),
                  subtitle: Text(
                    "${schedule?.day} | ${schedule?.startTime} - ${schedule?.endTime}",
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Schedule"),
                          content: const Text("Are you sure?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                service.deleteSchedule(index);
                                Navigator.pop(context);
                              },
                              child: const Text("Delete"),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
