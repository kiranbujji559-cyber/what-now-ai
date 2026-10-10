import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() => runApp(const WhatNowAIApp());

class WhatNowAIApp extends StatelessWidget {
  const WhatNowAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF080C1F)),
      home: const SplashScreen(),
    );
  }
}

// SPLASH WITH 3D GLOW ANIMATION
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late Animation<double> _pulse;
  late Animation<double> _float;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _floatController = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _float = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()));
    });
  }
  @override
  void dispose() { _pulseController.dispose(); _floatController.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center, radius: 1.2,
            colors: [Color(0xFF1A1F4D), Color(0xFF080C1F)],
          ),
        ),
        child: Stack(
          children: [
            // Neon wave bottom
            Positioned(bottom: -50, left: -50, right: -50, child: _neonWave()),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulse, _float]),
                builder: (c, child) => Transform.translate(
                  offset: Offset(0, _float.value),
                  child: Transform.scale(scale: _pulse.value, child: child),
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  _glowingLogo(120),
                  const SizedBox(height: 20),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [Colors.white, Color(0xFF8A5CFF), Color(0xFF00E5FF)]).createShader(b),
                    child: const Text("WHAT NOW AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 40),
                  _featureIcons(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glowingLogo(double size) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF), Color(0xFFFF3CAC)]),
        boxShadow: [
          BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.6), blurRadius: 30, spreadRadius: 2),
          BoxShadow(color: const Color(0xFF8A5CFF).withOpacity(0.6), blurRadius: 40, spreadRadius: 2),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: const Color(0xFF0A0F2A), borderRadius: BorderRadius.circular(25)),
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 50),
      ),
    );
  }

  Widget _featureIcons() => Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
    _miniIcon(Icons.message, const Color(0xFF00D283)), _miniIcon(Icons.image, const Color(0xFF8A5CFF)),
    _miniIcon(Icons.description, const Color(0xFFFF5A5A)), _miniIcon(Icons.link, const Color(0xFF00BFFF)),
    _miniIcon(Icons.mic, const Color(0xFFFF3CAC)),
  ]);
  Widget _miniIcon(IconData i, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: c.withOpacity(0.5), blurRadius: 15)]), child: Icon(i, color: Colors.white, size: 22));
  Widget _neonWave() => Container(height: 200, decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [const Color(0xFF00E5FF).withOpacity(0.0), const Color(0xFF8A5CFF).withOpacity(0.4), const Color(0xFF00E5FF).withOpacity(0.3)]), borderRadius: const BorderRadius.vertical(top: Radius.circular(100))));
}

// MAIN NAVIGATION
class MainNav extends StatefulWidget { const MainNav({super.key}); @override State<MainNav> createState() => _MainNavState(); }
class _MainNavState extends State<MainNav> { int idx = 0; final pages = [const HomePage(), const HistoryPage(), const SettingsPage()]; @override Widget build(BuildContext context) { return Scaffold(body: pages[idx], bottomNavigationBar: _bottomBar()); }
  Widget _bottomBar() => Container(decoration: const BoxDecoration(color: Color(0xFF0F1230), border: Border(top: BorderSide(color: Colors.white12))), child: BottomNavigationBar(currentIndex: idx, onTap: (i)=>setState(()=>idx=i), backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFF8A5CFF), unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings")]));
}

// HOME PAGE - EXACT LIKE IMAGE 1
class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState() => _HomePageState(); }
class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _ctrl; late List<Animation<double>> _anims;
  @override void initState(){ super.initState(); _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200)); _anims = List.generate(6, (i) => Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _ctrl, curve: Interval(i*0.1, 1.0, curve: Curves.elasticOut)))); _ctrl.forward(); }
  @override Widget build(BuildContext context){
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F1440), Color(0xFF080C1F)])),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.chat_bubble, size: 20)), const SizedBox(width: 10), const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]),
        const SizedBox(height: 20),
        const Text("Anything confusing?", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        const Text("Send it to WHAT NOW.", style: TextStyle(color: Colors.white60)),
        const SizedBox(height: 15),
        _inputBox(),
        const SizedBox(height: 15),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _actionBtn(Icons.content_paste, "Paste"), _actionBtn(Icons.image, "Photo"), _actionBtn(Icons.description, "File"), _actionBtn(Icons.link, "Link"), _actionBtn(Icons.mic, "Voice"),
        ]),
        const SizedBox(height: 15),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4A8CFF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: const Color(0xFF8A5CFF).withOpacity(0.5), blurRadius: 20)]), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: Colors.white), SizedBox(width: 8), Text("WHAT SHOULD I DO?", style: TextStyle(fontWeight: FontWeight.w800))])),
        const SizedBox(height: 20),
        const Text("Try an example", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
       ...List.generate(5, (i) => _exampleCard(i)),
      ]))),
    );
  }
  Widget _inputBox() => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)), child: const TextField(maxLines: 3, decoration: InputDecoration(border: InputBorder.none, hintText: "Paste a message, bill, offer,\nemail or anything...", hintStyle: TextStyle(color: Colors.white38)), style: TextStyle(color: Colors.white)));
  Widget _actionBtn(IconData ic, String l) => Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(ic, size: 20)), const SizedBox(height: 5), Text(l, style: const TextStyle(fontSize: 11, color: Colors.white60))]);
  Widget _exampleCard(int i){
    final data = [
      [Icons.warning_amber, Colors.red, "Suspicious message", "Your account will be blocked today..."],
      [Icons.email, Colors.green, "Bill or payment", "Electricity bill due tomorrow..."],
      [Icons.work, Colors.purple, "Job offer", "You have been selected for a job..."],
      [Icons.description, Colors.blue, "Agreement", "Please review the document..."],
      [Icons.local_offer, Colors.orange, "Product", "Best deal on this product..."],
    ];
    return ScaleTransition(scale: _anims[i], child: Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: data[i][1] as Color, borderRadius: BorderRadius.circular(10)), child: Icon(data[i][0] as IconData, size: 18, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(data[i][2] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(data[i][3] as String, style: const TextStyle(color: Colors.white54, fontSize: 11))]))])));
  }
}

// RESULT PAGE WITH 3D CARDS
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});
  @override Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])),
      child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.07), borderRadius: BorderRadius.circular(14)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Your electricity bill reminder", style: TextStyle(fontWeight: FontWeight.bold)), SizedBox(height: 5), Text("\"Your electricity bill of ₹2,450 is due tomorrow. Pay immediately to avoid disconnection.\"", style: TextStyle(color: Colors.white60, fontSize: 12)), SizedBox(height: 5), Text("Today, 10:24 AM", style: TextStyle(color: Colors.white38, fontSize: 10))])),
        const SizedBox(height: 15),
        const Center(child: Text("✦ HERE'S WHAT NOW ✦", style: TextStyle(color: Color(0xFF8A5CFF), fontWeight: FontWeight.w800, letterSpacing: 1))),
        const SizedBox(height: 12),
        _resultCard(Icons.info, "WHAT IS THIS?", "Electricity bill payment reminder.", const Color(0xFF8A5CFF)),
        _resultCard(Icons.bolt, "WHY IT MATTERS?", "Avoid late fee and service disruption.", const Color(0xFF4A8CFF)),
        _resultCard(Icons.check_circle, "WHAT SHOULD I DO?", "Verify with official provider app/website and pay if genuine.", const Color(0xFF00D283)),
        _resultCard(Icons.calendar_today, "DEADLINE", "Tomorrow", const Color(0xFFFF9F43)),
        _resultCard(Icons.warning, "WHAT IF I DO NOTHING?", "Late fee, disconnection possible.", const Color(0xFFFF5A5A)),
        _resultCard(Icons.shield, "RISK CHECK", "Be careful of fake links or payment scams.", const Color(0xFFFF3CAC)),
        const SizedBox(height: 15),
        const Text("NEXT 3 STEPS", style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text("1 Verify bill details on official app/website.\n2 Check payment amount and due date.\n3 Complete payment if genuine.", style: TextStyle(color: Colors.white70, height: 1.6, fontSize: 13)),
        const SizedBox(height: 15),
        Row(children: [Expanded(child: _btn("Copy Reply", Icons.copy, const Color(0xFF8A5CFF))), const SizedBox(width: 10), Expanded(child: _btn("Set Reminder", Icons.alarm, const Color(0xFF4A8CFF)))]),
      ])),
    );
  }
  static Widget _resultCard(IconData ic, String title, String desc, Color c) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(14), border: Border.all(color: c.withOpacity(0.3))), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)), child: Icon(ic, size: 16, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: c, fontWeight: FontWeight.w800, fontSize: 11)), const SizedBox(height: 3), Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12))]))]));
  static Widget _btn(String t, IconData ic, Color c) => Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, size: 16), const SizedBox(width: 6), Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13))]));
}

class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext context) { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text("History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 10), TextField(decoration: InputDecoration(hintText: "Search your history...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white.withOpacity(0.07), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))), const SizedBox(height: 15), Row(children: [ _chip("All", true), _chip("Today", false), _chip("Yesterday", false), _chip("This Week", false)]), const SizedBox(height: 15), _hItem(Icons.receipt, "Electricity bill", "Bill reminder - ₹2,450", Colors.green), _hItem(Icons.work, "Job offer", "Suspicious message", Colors.purple), _hItem(Icons.warning, "Bank alert", "Transaction declined", Colors.blue), _hItem(Icons.description, "Rental agreement", "Document analysis", Colors.orange), _hItem(Icons.flight, "Flight ticket", "Travel details", Colors.blueAccent), _hItem(Icons.shopping_bag, "Product review", "Shopping advice", Colors.pink)]))); } Widget _chip(String t, bool sel) => Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: sel? const Color(0xFF8A5CFF) : Colors.white10, borderRadius: BorderRadius.circular(20)), child: Text(t, style: const TextStyle(fontSize: 12))); Widget _hItem(IconData ic, String title, String sub, Color c) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)), child: Icon(ic, size: 18)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11))])), const Icon(Icons.chevron_right, color: Colors.white38)])); }

class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 15), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E2250), Color(0xFF2A2F6B)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat_bubble, size: 20)), const SizedBox(width: 10), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold)), Text("v1.0.0", style: TextStyle(color: Colors.white54, fontSize: 11))])])), const SizedBox(height: 20), _sItem(Icons.person, "Account", "Profile & preferences"), _sItem(Icons.notifications, "Notifications", "Reminders & alerts"), _sItem(Icons.language, "Language", "English"), _sItem(Icons.dark_mode, "Appearance", "Dark mode"), _sItem(Icons.security, "Privacy & Security", "Your data is safe"), _sItem(Icons.help, "Help & Support", "FAQs & contact"), const SizedBox(height: 10), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF8A5CFF), Color(0xFF6A3DFF)]), borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.star, color: Colors.amber), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Go Pro", style: TextStyle(fontWeight: FontWeight.bold)), Text("More analyses, Premium features.", style: TextStyle(fontSize: 11, color: Colors.white70))]), Spacer(), Icon(Icons.chevron_right)]))]))); } Widget _sItem(IconData ic, String t, String sub) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(ic, color: Colors.white70, size: 20), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11))]), const Spacer(), const Icon(Icons.chevron_right, color: Colors.
