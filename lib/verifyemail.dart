import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smartgoaltracker/loginpage.dart';
import 'home.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isVerified = false;
  bool isLoading = false;
  String errorMessage = '';

  Future<void> checkEmailVerified() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    await _auth.currentUser?.reload();
    isVerified = _auth.currentUser?.emailVerified ?? false;

    setState(() {
      isLoading = false;
    });

    if (isVerified) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else {
      setState(() {
        errorMessage = 'Email not verified. Please check your inbox.';
      });
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      setState(() {
        errorMessage = 'Verification email sent again. Check your inbox.';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to send verification email. Try again later.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Verify Email"),
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
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Verify Your Email",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  "A verification email has been sent to your registered email address. Please check your inbox and click on the verification link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 30),
                if (isLoading) CircularProgressIndicator(color: Colors.white),
                if (errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ElevatedButton(
                  onPressed: checkEmailVerified,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    "I Have Verified",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: resendVerificationEmail,
                  child: Text(
                    "Resend Verification Email",
                    style: TextStyle(color: Colors.blue),
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
