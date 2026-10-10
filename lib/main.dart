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
    _f = Tween<double>(begin: -12, end: 12).animate(CurvedAnimation(parent: _float, curve: Curves.easeInOut));
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
          gradient: RadialGradient(center: Alignment.center, radius: 1.3, colors: [Color(0xFF1E2460), Color(0xFF080C1F)]),
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
              const Text("WHAT NOW AI", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 1)),
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
  @override Widget build(BuildContext context) {
    return Scaffold(
      body: pages[idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx, onTap: (i) => setState(() => idx = i),
        backgroundColor: const Color(0xFF0F1230), selectedItemColor: const Color(0xFF8A5CFF), unselectedItemColor: Colors.white54,
        items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings")],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
