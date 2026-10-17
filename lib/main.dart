import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

List<Map<String,String>> appHistory = [];

void main() => runApp(const WhatNowAI());

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xFF0A102E)),
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
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/icon.png', width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:120,height:120,decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFFB026FF)]), borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.smart_toy_rounded, size:60, color:Colors.white)))),
          const SizedBox(height: 20),
          const Text("WHAT NOW AI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          const SizedBox(height: 6),
          const Text("Send anything. Get clear actions.", style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 30),
          const CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 3),
        ]),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  void goHome(BuildContext c, String name) => Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => MainScaffold(userName: name)));
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A102E),
      body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
        const SizedBox(height: 10),
        ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/icon.png', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:80,height:80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFFB026FF)]), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.smart_toy_rounded, color: Colors.white)))),
        const SizedBox(height: 12),
        const Text("WHAT NOW AI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
        const Spacer(),
        const Align(alignment: Alignment.centerLeft, child: Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
        const Align(alignment: Alignment.centerLeft, child: Text("Sign in to continue", style: TextStyle(color: Colors.white54))),
        const SizedBox(height: 18),
        _loginBtn(true, "Continue with Google", () => goHome(context, "Kiran Bujji")),
        const SizedBox(height: 10),
        _loginBtn(false, "Continue with Email", () => goHome(context, "Kiran Bujji")),
        const SizedBox(height: 10),
        _loginBtn(false, "Continue as Guest", () => goHome(context, "Guest")),
        const SizedBox(height: 14),
        const Text("New here? Create an account", style: TextStyle(color: Color(0xFFB18CFF), fontSize: 13)),
      ]))),
    );
  }
  Widget _loginBtn(bool isWhite, String txt, VoidCallback tap) {
    return SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: tap, style: ElevatedButton.styleFrom(backgroundColor: isWhite ? Colors.white : const Color(0xFF1C2340), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), child: Text(txt, style: TextStyle(color: isWhite ? Colors.black : Colors.white, fontWeight: FontWeight.w600))));
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
      body: [HomePage(userName: widget.userName), const HistoryPage(), const SettingsPage()][idx],
      bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i) => setState(() => idx = i), backgroundColor: const Color(0xFF111940), selectedItemColor: const Color(0xFF00D4FF), unselectedItemColor: Colors.white38, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings")]),
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
  void addHistory(String input, String type) {
    appHistory.insert(0, {"title": input.length > 40 ? "${input.substring(0, 40)}..." : input, "type": type, "time": DateTime.now().toString().substring(0, 16), "content": input});
  }
  void whatNow() {
    if (ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paste something first!")));
      return;
    }
    String input = ctrl.text.trim();
    String type = "General";
    if (input.toLowerCase().contains("scam") || input.toLowerCase().contains("won") || input.contains("http")) type = "Suspicious message";
    else if (input.toLowerCase().contains("payment") || input.toLowerCase().contains("bill") || input.contains("₹")) type = "Payment / Bill";
    else if (input.toLowerCase().contains("job")) type = "Job offer";
    else if (input.toLowerCase().contains("agreement") || input.toLowerCase().contains("rent")) type = "Agreement";
    else if (input.toLowerCase().contains("flight") || input.toLowerCase().contains("ticket")) type = "Flight Ticket";
    addHistory(input, type);
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(input: input, category: type)));
  }
  Future<void> doPaste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null) setState(() => ctrl.text = d!.text!);
  }
  void doMock(String name) {
    setState(() => ctrl.text = "Sample $name uploaded - tap WHAT NOW");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name ready!")));
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/icon.png', width: 36, height: 36, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:36,height:36,color: Colors.blue, child: const Icon(Icons.smart_toy_rounded, size:20)))), const SizedBox(width: 8), const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14))]),
      const SizedBox(height: 14),
      const Text("Anything confusing?\nSend a message, screenshot,\ndocument, link or photo.", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(16)), child: Column(children: [TextField(controller: ctrl, maxLines: 4, style: const TextStyle(color: Colors.white, fontSize: 14), decoration: const InputDecoration(hintText: "Paste or type here...", hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none)), Align(alignment: Alignment.centerRight, child: IconButton(onPressed: whatNow, icon: const Icon(Icons.send_rounded, color: Colors.white70)))])),
      const SizedBox(height: 12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_sBtn(Icons.content_paste_rounded, "Paste", doPaste), _sBtn(Icons.image_rounded, "Photo", () => doMock("Photo")), _sBtn(Icons.folder_rounded, "File", () => doMock("File")), _sBtn(Icons.link_rounded, "Link", () => doMock("Link")), _sBtn(Icons.mic_rounded, "Voice", () => doMock("Voice"))]),
      const SizedBox(height: 12),
      SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(icon: const Icon(Icons.auto_awesome, size: 18, color: Colors.white), label: const Text("WHAT NOW", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), onPressed: whatNow)),
      const SizedBox(height: 12),
      _card(Icons.warning_amber_rounded, Colors.red, "Suspicious message", "Is this a scam?", () { ctrl.text = "You won \$5000! Click http://scam-link.com"; whatNow(); }),
      _card(Icons.receipt_long_rounded, Colors.green, "Payment / Bill", "What should I do?", () { ctrl.text = "Electricity bill ₹2450 due tomorrow"; whatNow(); }),
      _card(Icons.work_rounded, Colors.orange, "Job offer", "Is it genuine?", () { ctrl.text = "Work from home job Pay ₹500 registration"; whatNow(); }),
      _card(Icons.description_rounded, Colors.blue, "Agreement", "Key points & risks", () { ctrl.text = "Rental agreement 11 months deposit 2 months"; whatNow(); }),
      _card(Icons.flight_rounded, Colors.cyan, "Flight Ticket", "Check details", () { ctrl.text = "Flight 6E-123 HYD to DEL PNR ABC123"; whatNow(); }),
    ]))));
  }
  Widget _sBtn(IconData ic, String lb, VoidCallback t) => Column(children: [InkWell(onTap: t, borderRadius: BorderRadius.circular(12), child: Container(width: 52, height: 52, decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Icon(ic, color: Colors.white70, size: 20))), const SizedBox(height: 4), Text(lb, style: const TextStyle(fontSize: 11, color: Colors.white54))]);
  Widget _card(IconData ic, Color c, String title, String sub, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(ic, color: c, size: 20)), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11))])]))));
}

class ResultPage extends StatelessWidget {
  final String input, category;
  const ResultPage({required this.input, required this.category, super.key});
  String getAnalysis() {
    if (category.contains("Suspicious")) return "SCAM ALERT!\n\nThis looks like a scam.\n\n• Don't click link\n• Don't share OTP\n• Block sender\n\nAction: Delete & Report.";
    if (category.contains("Payment")) return "BILL ACTION:\n\n• Due: Tomorrow\n• Verify official app\n• Pay safely\n\nNext: Pay in 24hrs.";
    if (category.contains("Job")) return "JOB CHECK:\n\n• Genuine jobs never ask money\n• ₹500 ask = 99% Scam\n\nAction: Don't pay.";
    if (category.contains("Agreement")) return "AGREEMENT POINTS:\n\n• 11 months\n• Deposit 2 months\n• Notice 1 month\n\nRisk: Check owner ID.";
    if (category.contains("Flight")) return "TICKET CHECK:\n\n• Flight Confirmed\n• Check PNR\n• Web check-in 48hrs before";
    return "ANALYSIS:\n\n$input\n\n• Clear action\n• No risk";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: Text(category, style: const TextStyle(fontSize: 16))),
      backgroundColor: const Color(0xFF0A102E),
      body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(14)), child: Text(getAnalysis(), style: const TextStyle(height: 1.5, fontSize: 14))), const SizedBox(height: 16), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00BFFF)), child: const Text("Back to Home")))])),
    );
  }
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistState();
}
class _HistState extends State<HistoryPage> {
  String search = "";
  @override
  Widget build(BuildContext context) {
    var filtered = appHistory.where((e) => search.isEmpty || e["title"]!.toLowerCase().contains(search.toLowerCase())).toList();
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      TextField(onChanged: (v) => setState(() => search = v), decoration: InputDecoration(hintText: "Search history...", prefixIcon: const Icon(Icons.search_rounded, size: 20), filled: true, fillColor: const Color(0xFF1C2340), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      const SizedBox(height: 16),
      Expanded(child: filtered.isEmpty ? const Center(child: Text("No history yet", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: filtered.length, itemBuilder: (c, i) { var e = filtered[i]; return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e["type"]!, style: const TextStyle(color: Color(0xFF00D4FF), fontSize: 10, fontWeight: FontWeight.bold)), Text(e["title"]!, style: const TextStyle(fontSize: 13)), Text(e["time"]!, style: const TextStyle(color: Colors.white38, fontSize: 10))]));})),
    ])));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  void open(BuildContext c, String title) => Navigator.push(c, MaterialPageRoute(builder: (_) => DetailPage(title: title)));
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(14)), child: Row(children: [ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/icon.png', width: 48, height: 48, fit: BoxFit.cover, errorBuilder: (c,e,s) => Container(width:48,height:48,color: Colors.blue, child: const Icon(Icons.smart_toy_rounded)))), const SizedBox(width: 10), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text("v1.0 Real AI App", style: TextStyle(color: Colors.white54, fontSize: 11))])])),
      const SizedBox(height: 10),
      _tile(Icons.person_rounded, "Account", "Manage your profile", () => open(context, "Account:\nName: Kiran Bujji\nEmail: kiran@example.com\n• Edit Profile working\n• Logout working")),
      _tile(Icons.notifications_rounded, "Notifications", "Reminders & alerts", () => open(context, "Notifications: ON - Working")),
      _tile(Icons.dark_mode_rounded, "Appearance", "Dark mode", () => open(context, "Appearance: Dark ON - Working")),
      _tile(Icons.language_rounded, "Language", "English", () => open(context, "Language: English - Working")),
      _tile(Icons.shield_rounded, "Privacy & Security", "Your data is safe", () => open(context, "Privacy: Secure - Working")),
      _tile(Icons.help_rounded, "Help & Support", "Get help", () => open(context, "Help: support@whatnowai.com - Working")),
      const SizedBox(height: 10),
      InkWell(onTap: () => open(context, "Go Pro: Premium - Working"), borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7A3CFF), Color(0xFF4A2080)]), borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 20), SizedBox(width: 10), Text("Go Pro - Premium benefits", style: TextStyle(fontWeight: FontWeight.bold)), Spacer(), Icon(Icons.arrow_forward_ios_rounded, size: 14)]))),
    ]))));
  }
  Widget _tile(IconData ic, String t, String sub, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 8), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(ic, color: Colors.white70, size: 18), const SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10))]), const Spacer(), const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.white24)]))));
}

class DetailPage extends StatelessWidget {
  final String title;
  const DetailPage({required this.title, super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: const Text("Details", style: TextStyle(fontSize: 16))), backgroundColor: const Color(0xFF0A102E), body: Padding(padding: const EdgeInsets.all(20), child: Text(title, style: const TextStyle(fontSize: 14, height: 1.6))));
  }
}
