import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalDetailPage extends StatelessWidget {
  final String goalId;
  final Map<String, dynamic> goalData;

  const GoalDetailPage({
    Key? key,
    required this.goalId,
    required this.goalData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,  // Set the background color to black
      appBar: AppBar(
        foregroundColor: Colors.white,  // White text/icons
        title: Text(
          "Details for $goalId",
          style: GoogleFonts.poppins(
            color: Colors.white,  // White text
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.transparent,  // Transparent background
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black], // Using similar gradient colors to the goal cards
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
            ),
            itemCount: goalData.length,
            itemBuilder: (context, index) {
              final entry = goalData.entries.elementAt(index);
              final key = entry.key;
              final value = entry.value;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.white,Colors.white],  // Active plan gradient
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),  // Rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    getLogo(key),
                    const SizedBox(height: 12),
                    Text(
                      key,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.black,  // White text for the goal name
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (value is Map) ...[
                      ...value.entries.map((subEntry) {
                        return Text(
                          "${subEntry.key}: ${subEntry.value}",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.black ,  // Lighter text color
                            fontSize: 14,
                          ),
                        );
                      }).toList(),
                    ] else ...[
                      Text(
                        value.toString(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.black,  // Lighter text color
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget getLogo(String activityKey) {
    switch (activityKey.toLowerCase()) {
      case 'breakfast':
        return const Icon(Icons.breakfast_dining, color: Colors.black, size: 50);
      case 'clg':
        return const Icon(Icons.school, color: Colors.black, size: 50);
      case 'dinner':
        return const Icon(Icons.dinner_dining, color: Colors.black, size: 50);
      case 'morning':
        return const Icon(Icons.wb_sunny, color: Colors.black, size: 50);
      case 'nightstudy':
        return const Icon(Icons.nightlight, color: Colors.black, size: 50);
      default:
        return const Icon(Icons.star, color: Colors.black, size: 50);
    }
  }
}
