import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile_page.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfilePage extends StatefulWidget {
  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String name = "Loading...";
  String email = "";
  String phone = "";
  bool isLoading = true;
  String userId = "";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: user.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var userDoc = querySnapshot.docs.first;
        setState(() {
          userId = userDoc.id;
          name = "${userDoc['firstName']} ${userDoc['lastName']}";
          email = userDoc['email'];
          phone = userDoc['phone'];
          isLoading = false;
        });
      } else {
        setState(() {
          name = "User Not Found";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        name = "Error Loading Data";
        isLoading = false;
      });
    }
  }

  // Logout function
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      Navigator.pushReplacementNamed(context, '/login'); // Navigate to the login page
    } catch (e) {
      print("Error logging out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('User Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: Colors.white))
          : Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/logo.png'),
                ),
                SizedBox(height: 20),
                Text(
                  name,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 16),
                _buildInfoCard(Icons.email, 'Email', email),
                _buildInfoCard(Icons.phone, 'Phone', phone),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          userId: userId,
                          firstName: name.split(" ")[0],
                          lastName: name.split(" ").length > 1 ? name.split(" ")[1] : "",
                          phone: phone,
                        ),
                      ),
                    ).then((_) => _fetchUserData()); // Refresh on return
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Edit Profile',  style: GoogleFonts.poppins(color: Colors.white)),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text('Logout', style: GoogleFonts.poppins(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.blueAccent,
        currentIndex: 4,
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
            case 2:
              Navigator.pushReplacementNamed(context, '/plans');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/chat');
              break;
          }
        },
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Text('$label:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                style: TextStyle(fontSize: 16, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
