import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class TaskByDateScreen extends StatefulWidget {
  @override
  _TaskByDateScreenState createState() => _TaskByDateScreenState();
}

class _TaskByDateScreenState extends State<TaskByDateScreen> {
  DateTime? selectedDate;
  Map<String, dynamic> tasks = {};
  bool isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      await _fetchTasksForSelectedDate();
    }
  }

  Future<void> _fetchTasksForSelectedDate() async {
    if (selectedDate == null) return;

    setState(() {
      isLoading = true;
      tasks = {};
    });

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
      DocumentSnapshot taskSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('task_logs')
          .doc(formattedDate)
          .get();

      if (taskSnapshot.exists) {
        setState(() {
          tasks = taskSnapshot.data() as Map<String, dynamic>;
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks By Date", style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "Select a date"
                        : "Selected Date: ${DateFormat('EEEE, MMM d, yyyy').format(selectedDate!)}",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            SizedBox(height: 16),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : tasks.isEmpty
                ? Expanded(
              child: Center(
                child: Text("No tasks found", style: TextStyle(color: Colors.white)),
              ),
            )
                : Expanded(
              child: ListView(
                children: tasks.entries.map((entry) {
                  final task = entry.value;
                  final String taskName = task['task_name'] ?? "Ongoing Task";
                  final int actualDuration = task['duration'] ?? 0;
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
  home: TaskByDateScreen(),
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
));
