import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:smartgoaltracker/charts.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: FutureBuilder<String>(
          future: _fetchUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text("Hello, ...", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24));
            }
            return Text("Hello, ${snapshot.data}", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24));
          },
        ),
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()).toUpperCase(),
              style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            // Search by Date Button
            ElevatedButton(
              onPressed: (){Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TaskByDateScreen()),
              );},
              child: Text("Search by Date", style: GoogleFonts.poppins(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade900, // Black button
                ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _fetchTasksWithSchedule(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No tasks found", style: TextStyle(color: Colors.white)));
                  }

                  final tasks = snapshot.data!;
                  return ListView(
                    children: tasks.entries.map((entry) {
                      final task = entry.value;
                      final bool isCompleted = task['completed'] ?? false;
                      final String taskName = task['task_name'] ?? "Ongoing Task";
                      final int actualDuration = task['actualDuration'] ?? 0;
                      final int expectedDuration = task['expected'] ?? 0;

                      double completionPercentage = expectedDuration > 0
                          ? (actualDuration / expectedDuration).clamp(0, 1).toDouble()
                          : 0.0;

                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircularPercentIndicator(
                              radius: 50.0,
                              lineWidth: 8.0,
                              percent: completionPercentage,
                              center: Text(
                                "${(completionPercentage * 100).toStringAsFixed(1)}%",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: completionPercentage == 1.0 ? Colors.green : Colors.black,
                                ),
                              ),
                              progressColor: completionPercentage == 1.0 ? Colors.green : Colors.blue,
                              backgroundColor: Colors.grey[300]!,
                              circularStrokeCap: CircularStrokeCap.round,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    taskName,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text("Target Time: $expectedDuration mins", style: TextStyle(color: Colors.black87)),
                                  Text("Your Time: $actualDuration mins", style: TextStyle(color: Colors.black87)),
                                  SizedBox(height: 4),
                                  Text(
                                    "Status: ${isCompleted || completionPercentage == 1.0 ? 'Completed' : 'Ongoing'}",
                                    style: TextStyle(
                                      color: isCompleted || completionPercentage == 1.0 ? Colors.green : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.blueAccent,
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
            case 1:
              Navigator.pushReplacementNamed(context, '/tasktrack');
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

  Future<String> _fetchUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      return snapshot['firstName'] ?? "User";
    }
    return "User";
  }

  Future<Map<String, dynamic>> _fetchTasksWithSchedule() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String today = selectedDate != null
          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
          : DateFormat('yyyy-MM-dd').format(DateTime.now());

      DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('task_logs')
          .doc(today)
          .get();

      Map<String, dynamic> tasks = {};
      if (taskSnapshot.exists) {
        tasks = taskSnapshot.data() as Map<String, dynamic>;
      }

      tasks.forEach((key, value) {
        value['scheduledDuration'] = value['expected'] ?? 0;
        value['actualDuration'] = value['duration'] ?? 0;
      });

      return tasks;
    }
    return {};
  }

  // Function to pick date
  _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }
}

void main() => runApp(MaterialApp(
  home: Home(),
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
));
