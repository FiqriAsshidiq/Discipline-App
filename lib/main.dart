import 'package:discipline_app/features/home_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/models/schedule_model.dart';
import 'features/create/create_page.dart';
import 'features/create/schedule_list_page.dart';
import 'features/home_page.dart';
import 'widgets/app_drawer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ScheduleModelAdapter());
  }

  await Hive.openBox('disciplineBox');
  await Hive.openBox<ScheduleModel>('scheduleBox');

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
        '/home': (context) => HomePage(),
        '/create': (context) => const CreatePage(),
        '/viewall': (context) => const ScheduleListPage(),
      },
    );
  }
}
