import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/schedule_model.dart';
import 'features/create/create_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(ScheduleModelAdapter());
  await Hive.openBox('disciplineBox');
  Hive.registerAdapter(ScheduleModelAdapter());
  await Hive.openBox<ScheduleModel>('scheduleBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const CreatePage(),
    );
  }
}
