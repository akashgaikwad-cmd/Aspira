import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CreateGoalPage(),
  ));
}

class CreateGoalPage extends StatefulWidget {
  @override
  _GoalTrackerState createState() => _GoalTrackerState();
}

class _GoalTrackerState extends State<CreateGoalPage> {
  TextEditingController goalNameController = TextEditingController();
  TextEditingController activityController = TextEditingController();

  Map<String, Map<String, TimeOfDay?>> activities = {};

  void addActivity() {
    String activityName = activityController.text.trim();
    if (activityName.isNotEmpty) {
      setState(() {
        activities[activityName] = {"startTime": null, "endTime": null};
        activityController.clear();
      });
    }
  }

  Future<void> pickTime(String activity, String timeType) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        activities[activity]![timeType] = pickedTime;
      });
    }
  }

  void saveGoal() async {
    String goalName = goalNameController.text.trim();
    if (goalName.isNotEmpty && activities.isNotEmpty) {
      Map<String, dynamic> activityData = {};
      activities.forEach((key, value) {
        activityData[key] = {
          "start": value["startTime"] != null
              ? value["startTime"]!.format(context)
              : "Not set",
          "end": value["endTime"] != null
              ? value["endTime"]!.format(context)
              : "Not set",
        };
      });

      await FirebaseFirestore.instance.collection("topgoals").doc(goalName).set(activityData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Goal saved successfully!")),
      );

      goalNameController.clear();
      setState(() {
        activities.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a goal and add activities")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        foregroundColor: Colors.white,
        title: Text(
          "Create Goal",
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.black, // Black AppBar
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF000000), Color(0xFF212121)], // Black to Dark Grey Gradient
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Goal Name", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                TextField(
                  controller: goalNameController,
                  style: GoogleFonts.poppins(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter goal name",
                    hintStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white10,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 20),

                Text("Add Activities", style: GoogleFonts.poppins(color: Colors.white, fontSize: 18)),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: activityController,
                        style: GoogleFonts.poppins(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Enter activity",
                          hintStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white10,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add, color: Colors.white),
                      onPressed: addActivity,
                    ),
                  ],
                ),
                SizedBox(height: 10),

                ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: activities.keys.map((activity) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      decoration: BoxDecoration(
                        color: Colors.white, // White card background
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 3,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: Colors.black.withOpacity(0.1)),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Start: ${activities[activity]!['startTime']?.format(context) ?? "Not set"}",
                                style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.7)),
                              ),
                              IconButton(
                                icon: Icon(Icons.access_time, color: Colors.black),
                                onPressed: () => pickTime(activity, "startTime"),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "End: ${activities[activity]!['endTime']?.format(context) ?? "Not set"}",
                                style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.7)),
                              ),
                              IconButton(
                                icon: Icon(Icons.timer_off, color: Colors.red),
                                onPressed: () => pickTime(activity, "endTime"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: saveGoal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade900, // Black button
                    ),
                    child: Text("Save Goal", style: GoogleFonts.poppins(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
