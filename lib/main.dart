import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/schedule_model.dart';
import 'core/models/activity_status_model.dart';
import 'features/home_page.dart';
import 'features/create/create_page.dart';
import 'features/create/schedule_list_page.dart';
import 'features/activity/activity_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ScheduleModelAdapter());
  }

  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(ActivityStatusModelAdapter());
  }

  // Open boxes
  await Hive.openBox<ScheduleModel>('scheduleBox');
  await Hive.openBox<ActivityStatusModel>('activity_status');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      initialRoute: '/home',

      routes: {
        '/home': (context) => const HomePage(),
        '/create': (context) => const CreatePage(),
        '/viewall': (context) => const ScheduleListPage(),
        '/activity': (context) => const ActivityPage(),
      },
    );
  }
}
