import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WhatNowApp());
}

class WhatNowApp extends StatelessWidget {
  const WhatNowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF070812),
        fontFamily: 'sans',
      ),
      home: const SplashScreen(),
    );
  }
}

// ─────────────────────────────────────────────
// SPLASH
// ─────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> scale;
  late Animation<double> opacity;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    scale = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    );

    opacity = CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    );

    controller.forward();

    Timer(const Duration(milliseconds: 2200), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF090A18),
              Color(0xFF151044),
              Color(0xFF090A18),
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return Opacity(
                opacity: opacity.value,
                child: Transform.scale(
                  scale: scale.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF5B5FFF),
                        Color(0xFFB84DFF),
                        Color(0xFFFF4FA3),
                      ],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        blurRadius: 35,
                        spreadRadius: 4,
                        color: Color(0x665B5FFF),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'W',
                      style: TextStyle(
                        fontSize: 54,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'WHAT NOW AI',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'From confusion → clear action',
                  style: TextStyle(
                    color: Colors.white.withOpacity(.65),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME
// ─────────────────────────────────────────────

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  final TextEditingController inputController = TextEditingController();

  void analyze(String text) {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tell me what you received or what is confusing you.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(input: text),
      ),
    );
  }

  @override
  void dispose() {
    inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedIndex == 1) {
      return HistoryScreen(
        onHome: () => setState(() => selectedIndex = 0),
      );
    }

    if (selectedIndex == 2) {
      return SettingsScreen(
        onHome: () => setState(() => selectedIndex = 0),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5B5FFF),
                          Color(0xFFB84DFF),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'WHAT NOW',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .5,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.07),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.notifications_none_rounded),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              const Text(
                'What should I\ndo next?',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.8,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Send anything confusing.\nI’ll turn it into clear actions.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.45,
                  color: Colors.white.withOpacity(.62),
                ),
              ),

              const SizedBox(height: 28),

              // INPUT CARD
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  color: Colors.white.withOpacity(.055),
                  border: Border.all(
                    color: Colors.white.withOpacity(.09),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 30,
                      color: Color(0x33000000),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: inputController,
                      maxLines: 5,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Paste a message, bill, offer, problem or anything...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(.38),
                        ),
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _SmallAction(
                          icon: Icons.content_paste_rounded,
                          label: 'Paste',
                          onTap: () async {
                            final data =
                                await Clipboard.getData(Clipboard.kTextPlain);
                            if (data?.text != null) {
                              inputController.text = data!.text!;
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        _SmallAction(
                          icon: Icons.camera_alt_outlined,
                          label: 'Photo',
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        _SmallAction(
                          icon: Icons.attach_file_rounded,
                          label: 'File',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF5B5FFF),
                              Color(0xFFB84DFF),
                              Color(0xFFFF4FA3),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 22,
                              color: Color(0x445B5FFF),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () =>
                              analyze(inputController.text),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.auto_awesome_rounded),
                              SizedBox(width: 10),
                              Text(
                                'WHAT NOW?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: .5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'TRY AN EXAMPLE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: Colors.white.withOpacity(.45),
                ),
              ),

              const SizedBox(height: 14),

              _ExampleCard(
                icon: Icons.work_outline_rounded,
                title: 'Job offer',
                subtitle: 'Is this offer safe and what should I do?',
                onTap: () {
                  analyze(
                    'I received a job offer. They are asking me to pay a training fee before joining. Salary is ₹35,000 per month.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _ExampleCard(
                icon: Icons.warning_amber_rounded,
                title: 'Suspicious message',
                subtitle: 'Is this SMS genuine or risky?',
                onTap: () {
                  analyze(
                    'Your electricity bill is overdue. Pay immediately using this link or your connection will be disconnected today.',
                  );
                },
              ),

              const SizedBox(height: 10),

              _ExampleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Online purchase',
                subtitle: 'Should I buy it or wait?',
                onTap: () {
                  analyze(
                    'This phone costs ₹49,999. It has a 1 year warranty and 7 day replacement policy. Should I buy it now?',
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        selected: selectedIndex,
        onChanged: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// ANALYSIS
// ─────────────────────────────────────────────

class AnalysisScreen extends StatefulWidget {
  final String input;

  const AnalysisScreen({
    super.key,
    required this.input,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool showConsequence = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'AI Analysis',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _AnimatedCard(
              delay: 0,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF292B75),
                      Color(0xFF642B76),
                    ],
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome_rounded),
                        SizedBox(width: 8),
                        Text(
                          'WHAT NOW AI',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Here’s what matters.',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'I’ve turned the information into simple next steps.',
                      style: TextStyle(
                        color: Colors.white70,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _SectionCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'WHAT IS THIS?',
              child:
                  'This appears to be information that requires your attention. The important part is identifying the action, deadline and possible risk before doing anything.',
            ),

            _SectionCard(
              icon: Icons.priority_high_rounded,
              title: 'URGENCY',
              badge: 'CHECK SOON',
              child:
                  'Do not ignore it until you understand the deadline or consequence. Verify the original source before taking any payment or sharing personal information.',
            ),

            _SectionCard(
              icon: Icons.shield_outlined,
              title: 'RISK',
              badge: 'MEDIUM',
              child:
                  'There may be financial or security risk depending on the source. Never click an unexpected payment link without independently verifying it.',
            ),

            _SectionCard(
              icon: Icons.calendar_today_outlined,
              title: 'DEADLINE',
              child:
                  'No reliable deadline was detected from this demo input. Check the original message or document for an exact date.',
            ),

            _SectionCard(
              icon: Icons.check_circle_outline_rounded,
              title: 'WHAT TO DO NOW',
              child:
                  'Pause → verify the source → identify the deadline → complete the safest next action.',
            ),

            const SizedBox(height: 4),

            GestureDetector(
              onTap: () {
                setState(() => showConsequence = !showConsequence);
              },
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF161728),
                  border: Border.all(
                    color: const Color(0x665B5FFF),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
           
