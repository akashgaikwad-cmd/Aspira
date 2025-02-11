import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'gemini.dart';
import 'goalselection.dart';
import 'loginpage.dart';
import 'home.dart';
import 'goals.dart';
import 'tasktrack.dart';
import 'profile.dart';



Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Background Message: ${message.messageId}");
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await AndroidAlarmManager.initialize();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

  runApp(const MyApp());
}

// WorkManager Callback Function
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("WorkManager executed: Checking for missed tasks...");

    // Here, we can recheck the database and send notifications for missed tasks.

    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Goal Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: FirebaseAuth.instance.currentUser == null ? '/login' : '/home',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => Home(),
        '/goal': (context) => CreateGoalPage(),
        '/chat': (context) => GeminiPromptPage(),
        '/plans': (context) => GoalListPage(),
        '/tasktrack': (context) => TaskSchedulerPage(),
        '/profile':(context)=>UserProfilePage(),
      },
    );
  }
}
