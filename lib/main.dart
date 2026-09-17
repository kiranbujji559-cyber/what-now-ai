import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const WhatNowAI());
}

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF080914),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ================= SPLASH =================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animation;

  @override
  void initState() {
    super.initState();

    animation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF090A18),
              Color(0xFF301A6B),
              Color(0xFF090A18),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutBack,
            ),
            child: FadeTransition(
              opacity: animation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF5B5FFF),
                          Color(0xFFB34DFF),
                          Color(0xFFFF4FA3),
                        ],
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x665B5FFF),
                          blurRadius: 35,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'W',
                        style: TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'WHAT NOW AI',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'From confusion → clear action',
                    style: TextStyle(
                      color: Colors.white.withOpacity(.65),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ================= HOME =================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int page = 0;

  final TextEditingController controller = TextEditingController();

  void analyze(String text) {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Type or paste something first.'),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(
          input: text.trim(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (page == 1) {
      return const HistoryScreen();
    }

    if (page == 2) {
      return const SettingsScreen();
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Logo(size: 48),
                  const SizedBox(width: 12),
                  const Text(
                    'WHAT NOW',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 35),

              const Text(
                'What should I\ndo next?',
                style: TextStyle(
                  fontSize: 39,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                'Send anything confusing.\n'
                'I’ll turn it into clear actions.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.white.withOpacity(.62),
                ),
              ),

              const SizedBox(height: 28),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.055),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: Colors.white.withOpacity(.09),
                  ),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: controller,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            'Paste a message, bill, offer, problem...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(.35),
                        ),
                        border: InputBorder.none,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        ActionButton(
                          icon: Icons.content_paste_rounded,
                          title: 'Paste',
                          onTap: () async {
                            final data = await Clipboard.getData(
                              Clipboard.kTextPlain,
                            );

                            if (data?.text != null) {
                              controller.text = data!.text!;
                            }
                          },
                        ),
                        ActionButton(
                          icon: Icons.camera_alt_outlined,
                          title: 'Photo',
                          onTap: () {
                            showMessage(context, 'Photo feature coming next.');
                          },
                        ),
                        ActionButton(
                          icon: Icons.attach_file_rounded,
                          title: 'File',
                          onTap: () {
                            showMessage(context, 'File feature coming next.');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    GradientButton(
                      title: 'WHAT NOW?',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () => analyze(controller.text),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'TRY AN EXAMPLE',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(.45),
                ),
              ),

              const SizedBox(height: 14),

              ExampleCard(
                icon: Icons.work_outline_rounded,
                title: 'Job offer',
                subtitle: 'Is this offer safe?',
                onTap: () => analyze(
                  'I received a job offer for ₹35,000 salary. '
                  'They are asking me to pay a training fee before joining.',
                ),
              ),

              ExampleCard(
                icon: Icons.warning_amber_rounded,
                title: 'Suspicious message',
                subtitle: 'Is this message risky?',
                onTap: () => analyze(
                  'Your electricity bill is overdue. '
                  'Pay immediately using this link or your connection '
                  'will be disconnected today.',
                ),
              ),

              ExampleCard(
                icon: Icons.shopping_bag_outlined,
                title: 'Online purchase',
                subtitle: 'Should I buy it?',
                onTap: () => analyze(
                  'This phone costs ₹49,999. '
                  'It has a one year warranty and seven day replacement.',
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: page,
        onDestinationSelected: (value) {
          setState(() {
            page = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ================= ANALYSIS =================

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
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WHAT NOW AI',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
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
                        'AI ANALYSIS',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Here’s what matters.',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Information converted into simple next steps.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            InfoCard(
              icon: Icons.lightbulb_outline_rounded,
              title: 'WHAT IS THIS?',
              text:
                  'This looks like information that needs your attention. '
                  'Check the source, terms, deadline and requested action.',
            ),

            InfoCard(
              icon: Icons.priority_high_rounded,
              title: 'URGENCY',
              badge: 'CHECK SOON',
              text:
                  'Check whether there is a real deadline before taking action.',
            ),

            InfoCard(
              icon: Icons.shield_outlined,
              title: 'RISK',
              badge: 'MEDIUM',
              text:
                  'Be careful with unexpected links, payments or requests '
                  'for personal information.',
            ),

            InfoCard(
              icon: Icons.calendar_today_outlined,
              title: 'DEADLINE',
              text:
                  'No reliable deadline was detected. Check the original '
                  'message or document for an exact date.',
            ),

            InfoCard(
              icon: Icons.check_circle_outline_rounded,
              title: 'WHAT TO DO NOW',
              text:
                  'Pause → verify the source → check the deadline → '
                  'take the safest next action.',
            ),

            const SizedBox(height: 5),

            GestureDetector(
              onTap: () {
                setState(() {
                  expanded = !expanded;
                });
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF151626),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0x665B5FFF),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.help_outline_rounded),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'WHAT IF I DO NOTHING?',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(
                          expanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                        ),
                      ],
                    ),

                    if (expanded) ...[
                      const SizedBox(height: 14),
                      Text(
                        'You could miss an important deadline or allow '
                        'a possible risk to continue. Verify important '
                        'information before acting.',
                        style: TextStyle(
                          height: 1.5,
                          color: Colors.white.withOpacity(.65),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 15),

            const InfoCard(
              icon: Icons.format_list_numbered_rounded,
              title: 'NEXT 3 STEPS',
              text:
                  '1. Verify the source.\n'
                  '2. Check the exact deadline and terms.\n'
                  '3. Take the safest action and keep a record.',
            ),

            const InfoCard(
              icon: Icons.reply_rounded,
              title: 'DRAFT REPLY',
              text:
                  '“Thanks. Before I proceed, please confirm the official '
                  'details, deadline and any payment requirements.”',
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showMessage(
                        context,
                        'Reminder feature coming next.',
                      );
                    },
                    icon: const Icon(Icons.alarm_outlined),
                    label: const Text('Remind me'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showMessage(
                        context,
                        'Share feature coming next.',
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                'Demo analysis • Verify important information.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(.35),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HISTORY =================

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          HistoryItem(
            icon: Icons.work_outline,
            title: 'Job offer',
            subtitle: 'Training fee • Medium risk',
          ),
          HistoryItem(
            icon: Icons.warning_amber_rounded,
  
