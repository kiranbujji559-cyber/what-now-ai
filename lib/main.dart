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

// 3D GLOW SPLASH
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulse, _float;
  late Animation<double> _p, _f;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _float = AnimationController(vsync: this, duration: const Duration(milliseconds: 3000))..repeat(reverse: true);
    _p = Tween<double>(begin: 0.9, end: 1.15).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
    _f = Tween<double>(begin: -10, end: 10).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNav()));
    });
  }
  @override
  void dispose() { _pulse.dispose(); _float.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment.center, radius: 1.2, colors: [Color(0xFF1E2460), Color(0xFF080C1F)]),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_p, _f]),
            builder: (c, child) => Transform.translate(offset: Offset(0, _f.value), child: Transform.scale(scale: _p.value, child: child)),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF), Color(0xFFFF3CAC)]),
                  boxShadow: [BoxShadow(color: const Color(0xFF00E5FF).withOpacity(0.7), blurRadius: 40), BoxShadow(color: const Color(0xFF8A5CFF).withOpacity(0.7), blurRadius: 50)],
                ),
                child: Container(margin: const EdgeInsets.all(3), decoration: BoxDecoration(color: const Color(0xFF0A0F2A), borderRadius: BorderRadius.circular(25)), child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 50)),
              ),
              const SizedBox(height: 20),
              ShaderMask(
                shaderCallback: (b) => const LinearGradient(colors: [Colors.white, Color(0xFF8A5CFF), Color(0xFF00E5FF)]).createShader(b),
                child: const Text("WHAT NOW AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1)),
              ),
              const SizedBox(height: 8),
              const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
            ]),
          ),
        ),
      ),
    );
  }
}

class MainNav extends StatefulWidget { const MainNav({super.key}); @override State<MainNav> createState() => _MainNavState(); }
class _MainNavState extends State<MainNav> {
  int idx = 0;
  final pages = [const HomePage(), const HistoryPage(), const SettingsPage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx, onTap: (i) => setState(() => idx = i),
        backgroundColor: const Color(0xFF0F1230), selectedItemColor: const Color(0xFF8A5CFF), unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings"),
        ],
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
        Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.chat_bubble, size: 20)), const SizedBox(width: 10), const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.w800))]),
        const SizedBox(height: 20),
        const Text("Anything confusing?", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
        const Text("Send it to WHAT NOW.", style: TextStyle(color: Colors.white60, fontSize: 16)),
        const SizedBox(height: 16),
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white12)), child: const TextField(maxLines: 3, decoration: InputDecoration(border: InputBorder.none, hintText: "Paste a message, bill, offer, email or anything...", hintStyle: TextStyle(color: Colors.white38)), style: TextStyle(color: Colors.white))),
        const SizedBox(height: 16),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [ _act(Icons.content_paste, "Paste"), _act(Icons.image, "Photo"), _act(Icons.description, "File"), _act(Icons.link, "Link"), _act(Icons.mic, "Voice")]),
        const SizedBox(height: 16),
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF4A8CFF), Color(0xFF8A5CFF)]), borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: const Color(0xFF8A5CFF).withOpacity(0.5), blurRadius: 20)]), child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, color: Colors.white), SizedBox(width: 8), Text("WHAT SHOULD I DO?", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.white))])),
        const SizedBox(height: 20),
        const Text("Try an example", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _ex(Icons.warning_amber, Colors.red, "Suspicious message", "Your account will be blocked today..."),
        _ex(Icons.receipt_long, Colors.green, "Bill or payment", "Electricity bill due tomorrow..."),
        _ex(Icons.work, Colors.purple, "Job offer", "You have been selected for a job..."),
        _ex(Icons.description, Colors.blue, "Agreement", "Please review the document..."),
        _ex(Icons.local_offer, Colors.orange, "Product", "Best deal on this product..."),
      ]))),
    );
  }
  static Widget _act(IconData ic, String l) => Column(children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)), child: Icon(ic, size: 20)), const SizedBox(height: 5), Text(l, style: const TextStyle(fontSize: 11, color: Colors.white60))]);
  static Widget _ex(IconData ic, Color c, String t, String s) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(10)), child: Icon(ic, size: 18, color: Colors.white)), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(s, style: const TextStyle(color: Colors.white54, fontSize: 11))]))]));
}

class HistoryPage extends StatelessWidget { const HistoryPage({super.key}); @override Widget build(BuildContext context) { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: [const Text("History", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 15), Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(14)), child: Row(children: [Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.receipt, size: 18)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Electricity bill", style: TextStyle(fontWeight: FontWeight.bold)), Text("Bill reminder - ₹2,450", style: TextStyle(color: Colors.white54, fontSize: 11))]))]))]))) ;}}
class SettingsPage extends StatelessWidget { const SettingsPage({super.key}); @override Widget build(BuildContext context) { return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F1440), Color(0xFF080C1F)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(20), children: const [Text("Settings", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), SizedBox(height: 20), Text("WHAT NOW AI v1.0.0 - 3D Glow Edition", style: TextStyle(color: Colors.white70))]))) ;}}
