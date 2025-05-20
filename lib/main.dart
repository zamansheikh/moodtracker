import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:moodtracker/views/dashboard_page.dart';
import 'package:moodtracker/views/record_page.dart';

void main() async {
  await dotenv.load(fileName: ".env"); // Load environment variables
  runApp(const MoodTrackerApp());
}

class MoodTrackerApp extends StatelessWidget {
  const MoodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mood Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const DashboardPage(),
        '/record': (context) => const RecordPage(),
      },
    );
  }
}

