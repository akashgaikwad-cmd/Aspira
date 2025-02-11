import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'plandetail.dart';
import 'goalselection.dart';

class GoalListPage extends StatefulWidget {
  @override
  _GoalListPageState createState() => _GoalListPageState();
}

class _GoalListPageState extends State<GoalListPage> with SingleTickerProviderStateMixin {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showInteraction = true;
  String? _selectedPlanId;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _getUserSelectedPlan();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showInteraction = false;
        _animationController.forward();
      });
    });
  }

  Future<void> _getUserSelectedPlan() async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        setState(() {
          _selectedPlanId = userDoc['selectedPlan'] ?? null;
        });
      }
    }
  }

  Future<void> _choosePlan(String newPlanId) async {
    String? userId = _auth.currentUser?.uid;
    if (userId != null) {
      await _firestore.collection('users').doc(userId).set(
        {'selectedPlan': newPlanId},
        SetOptions(merge: true),
      );
      setState(() {
        _selectedPlanId = newPlanId;
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchGoals() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('topgoals').get();
      QuerySnapshot customSnapshot = await _firestore.collection('customGoals').get();

      List<Map<String, dynamic>> goals = snapshot.docs.map((doc) {
        return {'id': doc.id, 'data': doc.data()};
      }).toList();

      List<Map<String, dynamic>> customGoals = customSnapshot.docs.map((doc) {
        return {'id': doc.id, 'data': doc.data()};
      }).toList();

      return [...goals, ...customGoals];
    } catch (e) {
      throw Exception("Failed to fetch goals: $e");
    }
  }

  void _navigateToCreatePlan() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateGoalPage()),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Your Goals",
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: _navigateToCreatePlan,
          ),
        ],
      ),
      body: _showInteraction
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              "Crafting the Perfect Plan...",
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
          : FadeTransition(
        opacity: _animationController,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: fetchGoals(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}", style: TextStyle(color: Colors.red)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No goals found.", style: TextStyle(color: Colors.white, fontSize: 16)),
              );
            } else {
              final goals = snapshot.data!;

              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.4,
                ),
                itemCount: goals.length,
                itemBuilder: (context, index) {
                  final goal = goals[index];
                  final goalId = goal['id'];
                  final goalData = goal['data'];
                  final bool isActive = _selectedPlanId == goalId;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GoalDetailPage(
                            goalId: goalId,
                            goalData: goalData,
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isActive
                              ? [Colors.white, Colors.white]
                              : [Colors.white,Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black54,
                            blurRadius: 15,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goalId,
                            style: GoogleFonts.roboto(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => isActive ? null : _choosePlan(goalId),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isActive ? Colors.green : Colors.black,
                              foregroundColor: isActive ? Colors.black : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              isActive ? "Selected" : "Activate Plan",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),

      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.blueAccent,
        currentIndex: 2,
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
            case 1:
              Navigator.pushReplacementNamed(context, '/tasktrack');
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}