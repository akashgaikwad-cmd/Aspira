import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'goalselection.dart';
import 'package:google_fonts/google_fonts.dart';

class GeminiPromptPage extends StatefulWidget {
  const GeminiPromptPage({super.key});

  @override
  State<GeminiPromptPage> createState() => _GeminiPromptPageState();
}

class _GeminiPromptPageState extends State<GeminiPromptPage> {
  final TextEditingController _promptController = TextEditingController();
  String _response = 'Your response will appear here...';

  // To track the selected BottomNavigationBar index
  int _selectedIndex = 1;

  Future<void> _generateResponse() async {
    const apiKey = 'AIzaSyAk7yINPgGoi_Zt_LFZtL-AGG1itwe5wOY'; // Replace with a valid API key
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    setState(() {
      _response = 'Generating response...'; // Show loading text
    });

    try {
      final prompt = _promptController.text;
      final response = await model.generateContent([Content.text(prompt)]);

      setState(() {
        _response = response.text ?? 'No response received.';
      });
    } catch (e) {
      setState(() {
        _response = 'Error: ${e.toString()}';
      });
    }
  }

  void _onBottomNavTap(int index) {
    if (index == _selectedIndex) return; // Prevent unnecessary rebuilds
    setState(() {
      _selectedIndex = index; // Update the selected index
    });

    // Navigate based on the selected index
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home');
        break;
      case 1:
      // Stay on the current page
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CreateGoalPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Allows page to resize when keyboard opens
      appBar: AppBar(
        title: Text('ChatWithUs',style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.black,
        child: SingleChildScrollView( // Ensures scrolling when keyboard opens
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Chatbot Logo
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue.shade900,
                    child: const Icon(
                      Icons.chat_bubble_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                // Input Field
                TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    labelText: 'Enter your prompt',
                    labelStyle: const TextStyle(color: Colors.white),
                    filled: true,
                    fillColor: Colors.grey[800],
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                ),

                const SizedBox(height: 20),

                // Generate Button
                ElevatedButton(
                  onPressed: _generateResponse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade900,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  child: const Text(
                    'Generate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 50),

                // Response Text
                SingleChildScrollView(
                  child: Text(
                    _response,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        unselectedItemColor: Colors.white70,
        selectedItemColor: Colors.blueAccent,
        currentIndex: 3,
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
              Navigator.pushReplacementNamed(context, '/goals');
            case 4:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
