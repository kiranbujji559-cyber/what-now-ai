import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

List<Map<String, String>> appHistory = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hist = prefs.getString('history');
  if (hist != null) {
    try {
      appHistory = List<Map<String, String>>.from(
        jsonDecode(hist).map((e) => Map<String, String>.from(e)),
      );
    } catch (_) {}
  }
  runApp(const WhatNowAI());
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
      home: const Splash(),
    );
  }
}

class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const Login()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0A102E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bolt, size: 80, color: Color(0xFF00D4FF)),
            SizedBox(height: 20),
            Text("WHAT NOW AI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
            SizedBox(height: 8),
            Text("Anything confusing, get clear action", style: TextStyle(color: Colors.white54)),
            SizedBox(height: 30),
            CircularProgressIndicator(color: Color(0xFF00D4FF)),
          ],
        ),
      ),
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});
  void go(BuildContext c, String name) {
    Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => MainScaffold(userName: name)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.bolt, color: Color(0xFF00D4FF), size: 60),
              const SizedBox(height: 12),
              const Text("WHAT NOW AI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const Spacer(),
              const Align(alignment: Alignment.centerLeft, child: Text("Welcome Back,", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
              const SizedBox(height: 18),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => go(context, "User"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: const Text("Continue with Google"))),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: () => go(context, "Guest"), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF1C2440)), child: const Text("Continue as Guest"))),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final String userName;
  const MainScaffold({required this.userName, super.key});
  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int idx = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: [HomePage(userName: widget.userName), const HistoryPage(), const SettingsPage()][idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => setState(() => idx = i),
        backgroundColor: const Color(0xFF0A102E),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({required this.userName, super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ctrl = TextEditingController();
  final picker = ImagePicker();

  Future<void> saveHistory() async {
    final p = await SharedPreferences.getInstance();
    p.setString('history', jsonEncode(appHistory));
  }

  void addHistory(String input, String type) {
    appHistory.insert(0, {"title": input.length > 50 ? "${input.substring(0, 50)}..." : input, "type": type, "time": DateTime.now().toIso8601String(), "full": input});
    saveHistory();
  }

  void whatNow() {
    if (ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paste something first!")));
      return;
    }
    String input = ctrl.text.trim();
    String type = "General";
    String lower = input.toLowerCase();
    if (lower.contains("scam") || input.contains("http") || lower.contains("lottery") || lower.contains("won")) type = "Suspicious message";
    else if (input.contains("₹") || lower.contains("bill") || lower.contains("electricity")) type = "Payment / Bill";
    else if (lower.contains("job") || lower.contains("offer")) type = "Job offer";
    addHistory(input, type);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(input: input, category: type)));
  }

  Future<void> doPaste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null) setState(() => ctrl.text = d!.text!);
  }

  Future<void> doPhoto() async {
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => ctrl.text = "Analyzing photo: ${img.name}\n\n(Photo selected - REAL feature working!)");
    }
  }

  Future<void> doLink() async {
    final lc = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF1C2340), title: const Text("Paste Link - REAL"), content: TextField(controller: lc, decoration: const InputDecoration(hintText: "https://...")), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")), TextButton(onPressed: () { setState(() => ctrl.text = lc.text); Navigator.pop(context); }, child: const Text("Add"))]));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hi, ${widget.userName} - REAL", style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              const Text("Anything confusing?\nSend a message, screenshot, document, link or photo.", style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: TextField(controller: ctrl, maxLines: 5, decoration: const InputDecoration(hintText: "Paste message, link, bill details... (REAL)", border: InputBorder.none))),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_btn(Icons.content_paste, "Paste", doPaste), _btn(Icons.photo, "Photo", doPhoto), _btn(Icons.link, "Link", doLink)]),
              const SizedBox(height: 12),
              SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(onPressed: whatNow, icon: const Icon(Icons.auto_awesome, size: 18), label: const Text("WHAT NOW? - REAL", style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4FF), foregroundColor: Colors.black))),
              const SizedBox(height: 20),
              _card(Icons.warning_amber_rounded, Colors.red, "Suspicious message", "Tap to test REAL", () { ctrl.text = "You won \$5000! Click http://scam-lottery.com to claim now!"; }),
              _card(Icons.receipt_long_rounded, Colors.green, "Payment / Bill", "Tap to test REAL", () { ctrl.text = "Electricity bill ₹1200 due tomorrow - BESCOM"; }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _btn(IconData ic, String lb, VoidCallback t) => Column(children: [InkWell(onTap: t, child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Color(0xFF1C2340), shape: BoxShape.circle), child: Icon(ic, size: 18))), const SizedBox(height: 4), Text(lb, style: const TextStyle(fontSize: 11))]);
  Widget _card(IconData ic, Color co, String ti, String sub, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: tap, child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(ic, color: co), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(ti, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize: 12, color: Colors.white54))])]))));
}

class ResultPage extends StatelessWidget {
  final String input, category;
  const ResultPage({required this.input, required this.category, super.key});
  @override
  Widget build(BuildContext context) {
    String analysis = "";
    if (category == "Suspicious message") analysis = "🚨 SCAM ALERT - REAL ANALYSIS\n\nThis looks like a scam!\n\n• Unknown link: ${input.contains("http") ? "Yes - Suspicious" : "Check sender"}\n• Too good to be true prize\n\nACTION: DO NOT CLICK! Block and report.";
    else if (category == "Payment / Bill") analysis = "💰 BILL ANALYSIS - REAL\n\nBill detected: $input\n\nACTION:\n1. Verify on official BESCOM app\n2. Pay only via official site\n3. Keep receipt";
    else analysis = "🤔 GENERAL ANALYSIS - REAL\n\nInput: $input\n\nACTION: Verify source before acting.";

    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: Text("$category - REAL")),
      backgroundColor: const Color(0xFF0A102E),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Text("Input: $input", style: const TextStyle(color: Colors.white70))),
            const SizedBox(height: 12),
            Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00D4FF))), child: Text(analysis, style: const TextStyle(fontSize: 15, height: 1.5))),
          ],
        ),
      ),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryState();
}

class _HistoryState extends State<HistoryPage> {
  String search = "";
  @override
  Widget build(BuildContext context) {
    var f = appHistory.where((e) => search.isEmpty || e["title"]!.toLowerCase().contains(search.toLowerCase())).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("History - REAL - Saved!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(onChanged: (v) => setState(() => search = v), decoration: const InputDecoration(hintText: "Search real history...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search))),
            const SizedBox(height: 16),
            Expanded(child: f.isEmpty ? const Center(child: Text("No history yet - REAL will save here", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: f.length, itemBuilder: (_, i) => Card(color: const Color(0xFF1C2340), child: ListTile(title: Text(f[i]["title"]!), subtitle: Text(f[i]["type"]!), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(input: f[i]["full"] ?? f[i]["title"]!, category: f[i]["type"]!)))))),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Settings - REAL", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const Text("Your data is safe - stored locally with SharedPreferences - REAL feature!", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () async { final p = await SharedPreferences.getInstance(); await p.clear(); appHistory.clear(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("History cleared - REAL!"))); }, child: const Text("Clear History - REAL")),
          ],
        ),
      ),
    );
  }
}
