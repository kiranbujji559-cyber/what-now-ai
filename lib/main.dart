import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

List<Map<String, String>> appHistory = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadSavedHistory();
  runApp(const WhatNowAI());
}

Future<void> loadSavedHistory() async {
  final prefs = await SharedPreferences.getInstance();
  final String? raw = prefs.getString('what_now_history');
  if (raw != null) {
    final List decoded = jsonDecode(raw);
    appHistory = decoded.map((e) => Map<String, String>.from(e)).toList();
  }
}

Future<void> persistHistory() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('what_now_history', jsonEncode(appHistory));
}

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A102E),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}

class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset('assets/icon.png',
                  width: 120,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFF00D4FF), Color(0xFFB026FF)]),
                          borderRadius: BorderRadius.circular(28)),
                      child: const Icon(Icons.smart_toy_rounded,
                          size: 60, color: Colors.white)))),
          const SizedBox(height: 20),
          const Text("WHAT NOW AI",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text("Send anything. Get clear actions.",
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),
          const CircularProgressIndicator(
              color: Color(0xFF00D4FF), strokeWidth: 3),
        ]),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  void goHome(BuildContext c, String name) => Navigator.pushReplacement(
      c, MaterialPageRoute(builder: (_) => MainScaffold(userName: name)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                const SizedBox(height: 10),
                ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: Image.asset('assets/icon.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [
                                  Color(0xFF00D4FF),
                                  Color(0xFFB026FF)
                                ]),
                                borderRadius: BorderRadius.circular(22)),
                            child: const Icon(Icons.smart_toy_rounded,
                                color: Colors.white)))),
                const SizedBox(height: 12),
                const Text("WHAT NOW AI",
                    style:
                        TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const Text("Send anything.\nGet clear actions.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white54, fontSize: 13)),
                const Spacer(),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Welcome Back!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold))),
                const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Sign in to continue",
                        style: TextStyle(color: Colors.white54))),
                const SizedBox(height: 18),
                _loginBtn(true, "Continue with Google",
                    () => goHome(context, "Kiran Bujji")),
                const SizedBox(height: 10),
                _loginBtn(false, "Continue with Email",
                    () => goHome(context, "Kiran Bujji")),
                const SizedBox(height: 10),
                _loginBtn(false, "Continue as Guest",
                    () => goHome(context, "Guest")),
                const SizedBox(height: 14),
                const Text("New here? Create an account",
                    style: TextStyle(color: Color(0xFFB18CFF), fontSize: 13)),
              ]))),
    );
  }

  Widget _loginBtn(bool isWhite, String txt, VoidCallback tap) {
    return SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
            onPressed: tap,
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    isWhite ? Colors.white : const Color(0xFF1C2340),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28))),
            child: Text(txt,
                style: TextStyle(
                    color: isWhite ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600))));
  }
}

class MainScaffold extends StatefulWidget {
  final String userName;
  const MainScaffold({required this.userName, super.key});
  @override
  State<MainScaffold> createState() => _MainState();
}

class _MainState extends State<MainScaffold> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: [
        HomePage(userName: widget.userName),
        const HistoryPage(),
        SettingsPage(userName: widget.userName)
      ][idx],
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => setState(() => idx = i),
          backgroundColor: const Color(0xFF111940),
          selectedItemColor: const Color(0xFF00D4FF),
          unselectedItemColor: Colors.white38,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.history_rounded), label: "History"),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings_rounded), label: "Settings")
          ]),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({required this.userName, super.key});
  @override
  State<HomePage> createState() => _HomeState();
}

class _HomeState extends State<HomePage> {
  final ctrl = TextEditingController();
  File? attachedFile;
  String? attachedFileName;
  String? attachedMimeType;
  String selectedCategory = "General";
  bool isListening = false;
  final stt.SpeechToText _speech = stt.SpeechToText();

  Future<void> doPaste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null && d!.text!.isNotEmpty) {
      setState(() => ctrl.text = d.text!);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Clipboard is empty!")));
    }
  }

  Future<void> pickPhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        attachedFile = File(image.path);
        attachedFileName = image.name;
        attachedMimeType = "image/jpeg";
      });
    }
  }

  Future<void> pickDocFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'txt', 'jpg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final ext = result.files.single.extension?.toLowerCase() ?? 'pdf';
      setState(() {
        attachedFile = File(path);
        attachedFileName = result.files.single.name;
        attachedMimeType = ext == 'pdf'
            ? 'application/pdf'
            : (ext == 'png' ? 'image/png' : 'image/jpeg');
      });
    }
  }

  Future<void> toggleVoice() async {
    if (!isListening) {
      
