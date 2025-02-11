import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
class EditProfilePage extends StatefulWidget {
  final String userId;
  final String firstName;
  final String lastName;
  final String phone;

  EditProfilePage({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phone,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    firstNameController.text = widget.firstName;
    lastNameController.text = widget.lastName;
    phoneController.text = widget.phone;
  }

  Future<void> _updateUserData() async {
    await _firestore.collection('users').doc(widget.userId).update({
      'firstName': firstNameController.text.trim(),
      'lastName': lastNameController.text.trim(),
      'phone': phoneController.text.trim(),
    });

    Navigator.pop(context); // Return to Profile Page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField('First Name', firstNameController),
            _buildTextField('Last Name', lastNameController),
            _buildTextField('Phone', phoneController),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUserData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade900,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('Save Changes', style: GoogleFonts.poppins(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.white70),
          enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
          focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }
}
