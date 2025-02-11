import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loginpage.dart';
import 'home.dart';
import 'verifyemail.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController createPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? passwordError;
  String? registrationError;
  String? _errorMessage;

  Future<void> _registerUser() async {
    setState(() {
      _errorMessage = '';
    });

    if (firstNameController.text.isEmpty ||
        emailController.text.isEmpty ||
        createPasswordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in all required fields.';
      });
      return;
    }

    if (createPasswordController.text != confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: createPasswordController.text,
      );

      String uid = userCredential.user?.uid ?? '';
      if (uid.isNotEmpty) {
        await _firestore.collection('users').doc(uid).set({
          'firstName': firstNameController.text,
          'lastName': lastNameController.text,
          'phone': phoneController.text,
          'email': emailController.text,
          'createdAt': Timestamp.now(),
          'emailVerified': false,
        });

        // Send Email Verification
        await userCredential.user?.sendEmailVerification();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailPage()),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Registration failed. Please try again later.';
      });
      print('Error: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Build Your Life!!",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 30),
                  _buildInputField(
                    controller: firstNameController,
                    hintText: "First Name",
                    icon: Icons.person,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: lastNameController,
                    hintText: "Last Name",
                    icon: Icons.person_outline,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: phoneController,
                    hintText: "+91",
                    icon: Icons.phone,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: emailController,
                    hintText: "Email",
                    icon: Icons.email,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: createPasswordController,
                    hintText: "Create password",
                    icon: Icons.lock,
                    obscureText: true,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
                    icon: Icons.lock_outline,
                    obscureText: true,
                  ),
                  if (passwordError != null) ...[
                    SizedBox(height: 10),
                    Text(
                      passwordError!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                  if (registrationError != null) ...[
                    SizedBox(height: 10),
                    Text(
                      registrationError!,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ],
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Icon(icon, color: Colors.white70),
        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      ),
    );
  }
}
