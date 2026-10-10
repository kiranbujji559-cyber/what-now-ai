import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const WhatNowAIApp());

class WhatNowAIApp extends StatelessWidget {
  const WhatNowAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF070B1F)),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _scaleCtrl, _glowCtrl;
  late Animation<double> _scale, _glow;
  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _glowCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.9, end: 1.15).animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeInOut));
    _glow = Tween<double>(begin: 20, end: 60).animate(_glowCtrl);
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainTabs()));
    });
  }
  @override
  void dispose() {
    _scaleCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment.topCenter, radius: 1.8, colors: [Color(0xFF1A2150), Color(0xFF070B1F)]),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            AnimatedBuilder(
              animation: Listenable.merge([_scale, _glow]),
              builder: (_, __) => Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7B2FFF), Color(0xFFFF2D95)]),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [BoxShadow(color: const Color(0xFF7B2FFF).withOpacity(0.8), blurRadius: _glow.value, spreadRadius: 5)],
                  ),
                  child: const Icon(Icons.chat_bubble_rounded, size: 60, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text("WHAT NOW AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
            const SizedBox(height: 8),
            const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 15)),
            const SizedBox(height: 36),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: const [
              _SChip(Icons.message_rounded, Color(0xFF00E676)),
              _SChip(Icons.image_rounded, Color(0xFF7C4DFF)),
              _SChip(Icons.description_rounded, Color(0xFF2196F3)),
              _SChip(Icons.link_rounded, Color(0xFFFF9800)),
              _SChip(Icons.mic_rounded, Color(0xFFE040FB)),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _SChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _SChip(this.icon, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(color: color.withOpacity(0.18), borderRadius: BorderRadius.circular(14), border: Border.all(color: color, width: 1.2)),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _idx = 0;
  final _pages = [const HomeScreen(), const HistoryScreen(), const SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        backgroundColor: const Color(0xFF10152F),
        selectedItemColor: const Color(0xFF7B5CFF),
        unselectedItemColor: Colors.white38,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _ctrl = TextEditingController();
  void _analyse() {
    if (_ctrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paste something first!")));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(text: _ctrl.text)));
  }
  Future<void> _paste() async {
    final d = await Clipboard.getData("text/plain");
    if (d?.text!= null) setState(() => _ctrl.text = d!.text!);
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7B2FFF)]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat_bubble_rounded, size: 20, color: Colors.white)),
            const SizedBox(width: 8),
            const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Spacer(),
            InkWell(onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Notifications - Coming soon"))), child: const Icon(Icons.notifications_none_rounded)),
          ]),
          const SizedBox(height: 22),
          const Text("Anything confusing?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text("Send it to WHAT NOW.", style: TextStyle(color: Colors.white60)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF181E3D), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.white10)),
            child: Column(children: [
              TextField(controller: _ctrl, maxLines: 4, decoration: const InputDecoration(hintText: "Paste a message, bill, offer, email or anything...", hintStyle: TextStyle(color: Colors.white30, fontSize: 13), border: InputBorder.none)),
              const SizedBox(height: 14),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _action(Icons.content_paste_rounded, "Paste", _paste),
                _action(Icons.image_rounded, "Photo", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Photo picker opening...")))),
                _action(Icons.description_rounded, "File", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("File picker opening...")))),
                _action(Icons.link_rounded, "Link", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paste link in above box!")))),
                _action(Icons.mic_rounded, "Voice", () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice - Future Update!")))),
              ]),
              const SizedBox(height: 16),
              SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B5CFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), onPressed: _analyse, icon: const Icon(Icons.auto_awesome, size: 18), label: const Text("WHAT SHOULD I DO?", style: TextStyle(fontWeight: FontWeight.bold)))),
            ]),
          ),
          const SizedBox(height: 18),
          const Text("Try an example", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _example(const Color(0xFFFF3D57), Icons.warning_rounded, "Suspicious message", "Your account will be blocked today...", "Your account will be blocked today. Click here to verify immediately!"),
          _example(const Color(0xFF00C853), Icons.receipt_rounded, "Bill or payment", "Electricity bill for tomorrow...", "Your electricity bill of Rs 2,450 is due tomorrow. Pay immediately to avoid disconnection."),
          _example(const Color(0xFF448AFF), Icons.work_rounded, "Job offer", "You have been selected for a job...", "You have been selected for a job. Pay Rs 5000 for registration."),
          _example(const Color(0xFF00BCD4), Icons.email_rounded, "Agreement", "Please review the document...", "Rental agreement for review. Monthly rent Rs 15,000."),
          _example(const Color(0xFFFF9800), Icons.shopping_bag_rounded, "Product", "Best deal on this product...", "Best deal! iPhone 15 for Rs 20,000 only! Limited time!"),
        ]),
      ),
    );
  }
  Widget _action(IconData ic, String lb, VoidCallback tap) => InkWell(onTap: tap, borderRadius: BorderRadius.circular(10), child: Column(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(10)), child: Icon(ic, size: 18, color: Colors.white70)), const SizedBox(height: 4), Text(lb, style: const TextStyle(fontSize: 10, color: Colors.white60))]));
  Widget _example(Color c, IconData ic, String t, String sub, String fill) => InkWell(onTap: () => setState(() => _ctrl.text = fill), borderRadius: BorderRadius.circular(12), child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF181E3D), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(9)), child: Icon(ic, color: c, size: 18)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10))]))])));
}

class ResultScreen extends StatelessWidget {
  final String text;
  const ResultScreen({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WHAT NOW AI", style: TextStyle(fontSize: 16)), backgroundColor: const Color(0xFF070B1F)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E2340), borderRadius: BorderRadius.circular(10)), child: Row(children: [const Icon(Icons.description, color: Colors.blue, size: 18), const SizedBox(width: 8), Expanded(child: Text(text, style: const TextStyle(fontSize: 12)))])),
          const SizedBox(height: 16),
          const Row(children: [Icon(Icons.auto_awesome, size: 14, color: Color(0xFF7B5CFF)), SizedBox(width: 6), Text("HERES WHAT NOW", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7B5CFF), fontSize: 12, letterSpacing: 1))]),
          const SizedBox(height: 10),
          _card("WHAT IS THIS?", "Electricity bill payment reminder.", const Color(0xFF7C4DFF), Icons.info_outline),
          _card("WHY IT MATTERS?", "Avoid late fee and service disruption.", const Color(0xFF00E5FF), Icons.bolt),
          _card("WHAT SHOULD I DO?", "Verify with official provider app/website and pay if genuine.", const Color(0xFF00E676), Icons.check_circle),
          _card("DEADLINE", "Tomorrow", const Color(0xFFFF9800), Icons.calendar_today),
          _card("WHAT IF I DO NOTHING?", "Late fee, disconnection possible.", const Color(0xFFFF5252), Icons.warning_rounded),
          _card("RISK CHECK", "Be careful of fake links or payment scams.", const Color(0xFFE040FB), Icons.shield),
          const SizedBox(height: 14),
          const Text("NEXT 3 STEPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 6),
          const Text("1 Verify bill details on official app/website.\n2 Check payment amount and due date.\n3 Complete payment if genuine.", style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5)),
          const SizedBox(height: 18),
          Row(children: [
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.copy, size: 16), label: const Text("Copy Reply", style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7B5CFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () { Clipboard.setData(ClipboardData(text: text)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Copied!"))); })),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.alarm, size: 16), label: const Text("Set Reminder", style: TextStyle(fontSize: 12)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2196F3), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Reminder set for tomorrow 9 AM!"))))),
          ])
        ]),
      ),
    );
  }
  Widget _card(String t, String d, Color c, IconData ic) => Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: c.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Icon(ic, color: c, size: 16)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 10)), const SizedBox(height: 2), Text(d, style: const TextStyle(fontSize: 11))]))]));
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _search = "";
  String _filter = "All";
  final _items = [
    {"title": "Electricity bill", "sub": "Bill reminder - Rs 2,450", "time": "Today - 10:24 AM", "icon": Icons.image_rounded, "color": const Color(0xFF00E676)},
    {"title": "Job offer", "sub": "Suspicious message", "time": "Today - 09:12 AM", "icon": Icons.work_rounded, "color": const Color(0xFF7C4DFF)},
    {"title": "Bank alert", "sub": "Transaction declined", "time": "Today - 08:45 AM", "icon": Icons.email_rounded, "color": const Color(0xFF2196F3)},
    {"title": "Rental agreement", "sub": "Document review", "time": "Yesterday - 07:32 PM", "icon": Icons.description_rounded, "color": const Color(0xFFFF9800)},
    {"title": "Flight ticket", "sub": "Travel details", "time": "Yesterday - 05:18 PM", "icon": Icons.flight_rounded, "color": const Color(0xFF00BCD4)},
    {"title": "Product review", "sub": "Shopping advice", "time": "Yesterday - 02:41 PM", "icon": Icons.shopping_bag_rounded, "color": const Color(0xFFFF5252)},
  ];
  @override
  Widget build(BuildContext context) {
    final filtered = _items.where((e) => (e["title"] as String).toLowerCase().contains(_search.toLowerCase())).toList();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          TextField(onChanged: (v) => setState(() => _search = v), decoration: InputDecoration(hintText: "Search your history...", hintStyle: const TextStyle(fontSize: 12), prefixIcon: const Icon(Icons.search, size: 18), filled: true, fillColor: const Color(0xFF1E2340), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 10))),
          const SizedBox(height: 10),
          SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: ["All", "Today", "Yesterday", "This Week"].map((f) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(f, style: const TextStyle(fontSize: 11)), selected: _filter == f, selectedColor: const Color(0xFF7B5CFF), backgroundColor: const Color(0xFF1E2340), onSelected: (_) => setState(() => _filter = f)))).toList())),
          const SizedBox(height: 12),
          Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_, i) { final e = filtered[i]; return InkWell(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(text: e["sub"] as String))), borderRadius: BorderRadius.circular(12), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: const Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (e["color"] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(e["icon"] as IconData, color: e["color"] as Color, size: 18)), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e["title"] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(e["sub"] as String, style: const TextStyle(color: Colors.white54, fontSize: 10)), Text(e["time"] as String, style: const TextStyle(color: Colors.white38, fontSize: 9))])), const Icon(Icons.chevron_right, color: Colors.white24, size: 16)]))); })),
        ]),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notif = true, _dark = true;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(gradient: const LinearGradient(
