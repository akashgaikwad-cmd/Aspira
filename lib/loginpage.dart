import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'register.dart';
import 'verifyemail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'forgetpassword.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool rememberMe = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Google Sign In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Error message
  String emailErrorMessage = "";
  String passwordErrorMessage = "";

  // Login function
  Future<void> login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      // Check if the email is verified
      User? user = _auth.currentUser;
      if (user != null && user.emailVerified) {
        // Navigate to home screen if email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Home()),
        );
      } else {
        setState(() {
          emailErrorMessage = "Please verify your email.";
        });
        // Handle unverified email
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyEmailPage()),
        );
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        emailErrorMessage = "Incorrect email or password.";
        passwordErrorMessage = "Incorrect email or password.";
      });
    }
  }

  // Function to handle Google Sign In
  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          emailErrorMessage = "Google Sign-In was cancelled.";
        });
        return;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
      print(credential);
      // Navigate to home screen after successful Google Sign-In
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    } catch (e) {
      print("Error: $e");
      setState(() {
        emailErrorMessage = "Google Sign-In failed.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    "Smart Goal Tracker",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Welcome Back!",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 40),
                  _buildInputField(
                    controller: emailController,
                    hintText: "E-mail",
                    icon: Icons.email,
                    errorText: emailErrorMessage,
                  ),
                  SizedBox(height: 20),
                  _buildInputField(
                    controller: passwordController,
                    hintText: "Password",
                    icon: Icons.lock,
                    obscureText: true,
                    errorText: passwordErrorMessage,
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: rememberMe,
                            onChanged: (value) {
                              setState(() {
                                rememberMe = value!;
                              });
                            },
                          ),
                          Text(
                            "Remember me",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          "Forgot Password?",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade900,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        "Login",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "or sign up with",
                    style: TextStyle(color: Colors.white70),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton("assets/images/facebook.png", () {}),
                      SizedBox(width: 20),
                      _buildSocialButton("assets/images/google.png", googleSignIn),
                      SizedBox(width: 20),
                      _buildSocialButton("assets/images/apple.png", () {}),
                    ],
                  ),
                  // Add the "Register Now" button below the social icons
                  SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      "New User? Register Now",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
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
    String errorText = "",
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
        errorText: errorText.isEmpty ? null : errorText,  // Display error text if set
      ),
    );
  }

  Widget _buildSocialButton(String assetPath, Function onTap) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Image.asset(
            assetPath,
            width: 24,
            height: 24,
          ),
        ),
      ),
    );
  }
}
