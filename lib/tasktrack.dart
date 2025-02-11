import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class TaskSchedulerPage extends StatefulWidget {
  const TaskSchedulerPage({Key? key}) : super(key: key);

  @override
  _TaskSchedulerPageState createState() => _TaskSchedulerPageState();
}

class _TaskSchedulerPageState extends State<TaskSchedulerPage> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  void initializeNotifications() {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('app_icon');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String userId = "";
  List<Map<String, dynamic>> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
  }

  Future<void> _fetchCurrentUserId() async {
    User? user = _auth.currentUser;
    if (user == null) return;
    userId = user.uid;
    _fetchUserSelectedPlan(userId);
  }

  Future<void> _fetchUserSelectedPlan(String userId) async {
    try {
      DocumentSnapshot userSnapshot =
      await _firestore.collection('users').doc(userId).get();
      if (!userSnapshot.exists) return;
      String selectedPlan = userSnapshot.get('selectedPlan');
      _fetchTasks(selectedPlan);
    } catch (e) {
      print("Error fetching user plan: $e");
    }
  }

  Future<void> _fetchTasks(String selectedPlan) async {
    try {
      DocumentSnapshot planSnapshot =
      await _firestore.collection('topgoals').doc(selectedPlan).get();
      if (!planSnapshot.exists) return;

      final data = planSnapshot.data() as Map<String, dynamic>;
      List<Map<String, dynamic>> taskList = [];

      DateTime now = DateTime.now();
      String todayDate = DateFormat('yyyy-MM-dd').format(now);
      print("📌 Current Date: $todayDate");
      print("⏳ Current Time: ${DateFormat('HH:mm').format(now)}");

      for (var entry in data.entries) {
        String taskName = entry.key;
        Map<String, dynamic>? taskData =
        entry.value is Map<String, dynamic> ? entry.value : null;

        if (taskData != null &&
            taskData.containsKey('start') &&
            taskData.containsKey('end')) {
          print("🔹 Checking Task: $taskName");
          print("  - Start Time: ${taskData['start']}");
          print("  - End Time: ${taskData['end']}");
          int expectedtime = calculateDurationDirect(taskData['start'], taskData['end']); // ✅ Correct

          DateTime startTime = DateFormat('h:mm a').parse(taskData['start']);
          DateTime endTime = DateFormat('h:mm a').parse(taskData['end']);

          DateTime fullStartTime = DateTime(now.year, now.month, now.day,
              startTime.hour, startTime.minute);
          DateTime fullEndTime = DateTime(now.year, now.month, now.day,
              endTime.hour, endTime.minute);

          // 🛠️ Fix for overnight tasks
          if (fullEndTime.isBefore(fullStartTime)) {
            fullEndTime = fullEndTime.add(const Duration(days: 1));
          }

          print("  - Adjusted Full End Time: $fullEndTime");

          // ✅ Ensure the task is ongoing
          if (now.isAfter(fullStartTime) && now.isBefore(fullEndTime)) {
            print("✅ Task is active: $taskName");
            taskList.add({
              'name': taskName,
              'start': taskData['start'],
              'end': taskData['end'],
              'date': todayDate,
            });
          } else {
            print("❌ Task is NOT active: $taskName");
          }
        }
      }

      setState(() => tasks = taskList);
      print("✅ Active Tasks: ${tasks.length}");
    } catch (e) {
      print("❌ Error fetching tasks: $e");
    }
  }
  int calculateDurationDirect(String start, String end) {
    // Convert "8:00 AM" -> [8, 0, "AM"]
    List<String> startParts = start.split(RegExp(r'[:\s]'));
    List<String> endParts = end.split(RegExp(r'[:\s]'));

    // Extract hour, minute and period
    int startHour = int.parse(startParts[0]);
    int startMinute = int.parse(startParts[1]);
    String startPeriod = startParts[2]; // AM or PM

    int endHour = int.parse(endParts[0]);
    int endMinute = int.parse(endParts[1]);
    String endPeriod = endParts[2]; // AM or PM

    // Convert 12-hour format to 24-hour format
    if (startPeriod == "PM" && startHour != 12) startHour += 12;
    if (startPeriod == "AM" && startHour == 12) startHour = 0;
    if (endPeriod == "PM" && endHour != 12) endHour += 12;
    if (endPeriod == "AM" && endHour == 12) endHour = 0;

    // Convert time to total minutes
    int startTotalMinutes = (startHour * 60) + startMinute;
    int endTotalMinutes = (endHour * 60) + endMinute;

    // If end time is earlier than start time, assume the end time is on the next day
    if (endTotalMinutes < startTotalMinutes) {
      endTotalMinutes += 24 * 60; // Add 24 hours to the end time
    }

    // Calculate duration
    return endTotalMinutes - startTotalMinutes;
  }

  Future<void> _startTask(String taskName) async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Find the task data from the tasks list
    Map<String, dynamic>? taskData = tasks.firstWhere(
          (task) => task['name'] == taskName,
      orElse: () => {},
    );

    if (taskData.isNotEmpty) {
      int expectedTime = calculateDurationDirect(taskData['start'], taskData['end']); // Calculate expected time

      await _firestore
          .collection("users")
          .doc(userId)
          .collection("task_logs")
          .doc(todayDate)
          .set({
        taskName: {
          "task_name": taskName,
          "start_time": Timestamp.now(),
          "completed": false,
          "expected": expectedTime, // Save expected duration
        }
      }, SetOptions(merge: true));

      print("Task '$taskName' started and stored with expected time: $expectedTime minutes.");
      setState(() {});
    } else {
      print("❌ Task data not found!");
    }
  }


  Future<void> _completeTask(String taskName) async {
    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    DocumentSnapshot taskLog = await _firestore
        .collection("users")
        .doc(userId)
        .collection("task_logs")
        .doc(todayDate)
        .get();

    if (!taskLog.exists) return;

    Map<String, dynamic> taskData = taskLog.data() as Map<String, dynamic>;
    if (!taskData.containsKey(taskName)) return;

    Timestamp? startTimestamp = taskData[taskName]["start_time"];
    if (startTimestamp == null) return;

    DateTime startTime = startTimestamp.toDate();
    int elapsedMinutes = DateTime.now().difference(startTime).inMinutes;

    await _firestore
        .collection("users")
        .doc(userId)
        .collection("task_logs")
        .doc(todayDate)
        .set({
      taskName: {
        "completed": true,
        "end_time": Timestamp.now(),
        "duration": elapsedMinutes,
      }
    }, SetOptions(merge: true));

    print("Task '$taskName' marked as completed.");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Current Task",style:GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24)),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: Container(
        color: Colors.black, // Black background
        child: tasks.isEmpty
            ? const Center(child: Text("No active tasks currently", style: TextStyle(color: Colors.white)))
            : ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.white, // White background for the card
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              shadowColor: Colors.white.withOpacity(0.3),
              elevation: 5,
              child: ListTile(
                title: Text(
                  task['name'],
                  style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Start: ${task['start']} | End: ${task['end']}",
                  style: TextStyle(color: Colors.black.withOpacity(0.7)),
                ),
                trailing: FutureBuilder<DocumentSnapshot>(
                  future: _firestore
                      .collection("users")
                      .doc(userId)
                      .collection("task_logs")
                      .doc(task['date'])
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasData && snapshot.data!.exists) {
                      Map<String, dynamic> taskData =
                      snapshot.data!.data() as Map<String, dynamic>;

                      bool started = taskData.containsKey(task['name']) &&
                          taskData[task['name']].containsKey("start_time");

                      bool completed = started &&
                          taskData[task['name']].containsKey("completed") &&
                          taskData[task['name']]['completed'] == true;

                      if (completed) {
                        return const Text("Completed ✅",
                            style: TextStyle(color: Colors.green));
                      }

                      return started
                          ? ElevatedButton(
                        onPressed: () => _completeTask(task['name']),
                        child: const Text("Complete"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black,
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () => _startTask(task['name']),
                        child: const Text("Start"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black,
                        ),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: () => _startTask(task['name']),
                        child: const Text("Start"),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white, backgroundColor: Colors.black,
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.blueAccent,
        currentIndex: 1,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: "Tasks",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flag),
            label: "Goals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: "ChatWithUs",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/plans');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/chat');
              break;
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
