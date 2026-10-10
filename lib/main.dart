import 'package:flutter/material.dart';

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

// --- 3D GLOW SPLASH SCREEN ---
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl, _floatCtrl;
  late Animation<double> _pulse, _float;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.9, end: 1.15).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _float = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()));
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment.center, radius: 1.3, colors: [Color(0xFF1E2460), Color(0xFF080C1F)]),
        ),
        child: Stack(
          children: [
            // Neon wave bottom - 3D merupu
            Positioned(
              bottom: -50, left: -80, right: -80,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [const Color(0xFF00E5FF).withOpacity(0.0), const Color(0xFF8A5CFF).withOpacity(0.4), const Color(0xFF00E5FF).withOpacity(0.25)],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(200)),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_pulse, _float]),
                builder: (c, child) => Transform.translate(offset: Offset(0, _float.value), child: Transform.scale(scale: _pulse.value, child: child)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // 3D GLOW LOGO
                  Container(
                    width: 125, height: 125,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF), Color(0xFFFF3CAC)]),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.8), blurRadius: 40, spreadRadius: 2),
                        BoxShadow(color: const Color(0xFF8A5CFF).withOpacity(0.8), blurRadius: 60, spreadRadius: 2),
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: const Color(0xFF0A0F2A), borderRadius: BorderRadius.circular(27)),
                      child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 55),
                    ),
                  ),
                  const SizedBox(height: 25),
                  ShaderMask(
                    shaderCallback: (b) => const LinearGradient(colors: [Colors.white, Color(0xFF8A5CFF), Color(0xFF00E5FF)]).createShader(b),
                    child: const Text("WHAT NOW AI", style: TextStyle(fontSize: 33, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 10),
                  const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4)),
                  const SizedBox(height: 40),
                  Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: [
                    _mini(Icons.message, const Color(0xFF00D283)), _mini(Icons.image, const Color(0xFF8A5CFF)),
                    _mini(Icons.description, const Color(0xFFFF5A5A)), _mini(Icons.link, const Color(0xFF00BFFF)), _mini(Icons.mic, const Color(0xFFFF3CAC)),
                  ]),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _mini(IconData i, Color c) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: c.withOpacity(0.6), blurRadius: 18)]), child: Icon(i, color: Colors.white, size: 22));
}

class MainNav extends StatefulWidget { const MainNav({super.key}); @override State<MainNav> createState() => _MainNavState(); }
class _MainNavState extends State<MainNav> {
  int idx = 0;
  final pages = [const HomePage(), const HistoryPage(), const SettingsPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(color: Color(0xFF0F1230), border: Border(top: BorderSide(color: Colors.white12))),
        child: BottomNavigationBar(
          currentIndex: idx, onTap: (i) => setState(() => idx = i),
          backgroundColor: Colors.transparent, selectedItemColor: const Color(0xFF8A5CFF), unselectedItemColor: Colors.white54, type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
          ],
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF121752), Color(0xFF080C1F)])),
      child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.chat_bubble, size: 20)), const SizedBox(width: 10), const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16))]),
        const SizedBox(height: 22),
        const Text("Anything confusing?", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
        const Text("Send it to WHAT NOW.", style: TextStyle(color: Colors.white60, fontSize: 16)),
        const SizedBox(height: 18),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)), child: const TextField(maxLines: 3, decoration: InputDecoration(border: InputBorder.none, hintText: "Paste a message, bill, offer,\nemail or anything...", hintStyle: TextStyle(color: Colors.white38)), style: TextStyle(color: Colors.white))),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _act(Icons.content_paste, "Paste"), _act(Icons.image, "Photo"), _act(Icons.description, "File"), _act(Icons.link, "Link"), _act(Icons.mic, "Voice")]),
        const SizedBox(height: 18),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 17), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4A8CFF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: const Color(0xFF8A5CFF).withOpacity(0.6), blurRadius: 25)]), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: Colors.white), SizedBox(width: 8), Text("WHAT SHOULD I DO?", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5))])),
        const SizedBox(height: 22),
        const Text("Try an example", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        _ex(Icons.warning_amber_rounded, Colors.red, "Suspicious message", "Your account will be blocked today..."),
        _ex(Icons.receipt_long, Colors.green, "Bill or payment", "Electricity bill due tomorrow..."),
        _ex(Icons.work_rounded, Colors.purple, "Job offer", "You have been selected for a job..."),
        _ex(Icons.description_rounded, Colors.blue, "Agreement", "Please review the document..."),
        _ex(Icons.local_offer_rounded, Colors.orange, "Product", "Best deal on this product..."),
      ]))),
    );
  }
  static Widget _act(IconData ic, String l) => Column(children: [Container(padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white.withOpacity(0.09), borderRadius: BorderRadius.circular(13)), child: Icon(ic, size: 20)), const SizedBox(height: 6), Text(l, style: const TextStyle(fontSize: 11, color: Colors.white60))]);
  static Widget _ex(IconData ic, Color c, String t, String s) => Container(margin: const EdgeInsets.only(bottom: 11), padding: const EdgeInsets.all(13), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.05))), child: Row(children: [Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)), child: Icon(ic, size: 18, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const SizedBox(height: 2), Text(s, style: const TextStyle(color: Colors.white54, fontSize: 11))]))]));
}

class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext context) { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text("History", style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 15), TextField(decoration: InputDecoration(hintText: "Search your history...", prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.white.withOpacity(0.07), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))), const SizedBox(height: 15), _h(Icons.receipt_rounded, "Electricity bill", "Bill reminder - ₹2,450", Colors.green), _h(Icons.work_rounded, "Job offer", "Suspicious message", Colors.purple), _h(Icons.warning_rounded, "Bank alert", "Transaction declined", Colors.blue)]))); } Widget _h(IconData ic, String t, String s, Color c) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(12)), child: Icon(ic, size: 18)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold)), Text(s, style: const TextStyle(color: Colors.white54, fontSize: 11))])), const Icon(Icons.chevron_right, color: Colors.white38)])); }

class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text("Settings", style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900)), const SizedBox(height: 20), Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1E2250), Color(0xFF2A2F6B)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.chat_bubble, size: 20)), const SizedBox(width: 10), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold)), Text("v1.0.0 • 3D Glow Edition", style: TextStyle(color: Colors.white54, fontSize: 11))])])), const SizedBox(height: 15), _s(Icons.person_rounded, "Account", "Profile & preferences"), _s(Icons.notifications_rounded, "Notifications", "Reminders & alerts"), _s(Icons.security_rounded, "Privacy & Security", "Your data is safe")]))) ;} Widget _s(IconData ic, String t, String s) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Icon(ic, color: Colors.white70, size: 20), const SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.w600)), Text(s, style: const TextStyle(color: Colors.white54, fontSize: 11))]), const Spacer(), const Icon(Icons.chevron_right, color: Colors.white24)])); }
