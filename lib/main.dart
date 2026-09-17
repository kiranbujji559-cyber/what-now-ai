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
      title: 'WHAT NOW AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
        fontFamily: 'sans',
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// SPLASH SCREEN
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scale = Tween<double>(
      begin: 0.75,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1900), () {
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainNavigation(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF111225),
              Color(0xFF090A0F),
              Color(0xFF15101F),
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Logo(size: 86),
                  SizedBox(height: 24),
                  Text(
                    'WHAT NOW',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'AI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 6,
                    ),
                  ),
                  SizedBox(height: 22),
                  Text(
                    'Send anything. Get clear actions.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
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

// ============================================================
// MAIN NAVIGATION
// ============================================================

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF101116),
        indicatorColor: const Color(0xFF29213F),
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() {
            _index = value;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
            selectedIcon: Icon(Icons.history_toggle_off),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();

  Future<void> pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    if (!mounted) return;

    if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
      setState(() {
        _controller.text = data.text!;
      });

      showMessage('Text pasted successfully.');
    } else {
      showMessage('Nothing found in clipboard.');
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void openAnalysis() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      showMessage('Paste or type something first.');
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AnalysisScreen(input: text),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Logo(size: 46),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'WHAT NOW AI',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      showMessage('Notifications coming soon.');
                    },
                    icon: const Icon(Icons.notifications_none),
                  ),
                ],
              ),

              const SizedBox(height: 38),

              const Text(
                'Anything confusing?',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Send it to WHAT NOW.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white60,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 28),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12141C),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white10,
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  minLines: 7,
                  maxLines: 10,
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText:
                        'Paste a message, bill, email, offer, warning or anything you do not understand...',
                    hintStyle: TextStyle(
                      color: Colors.white38,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(20),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: ActionButton(
                      icon: Icons.content_paste,
                      label: 'Paste',
                      onTap: pasteText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionButton(
                      icon: Icons.photo_outlined,
                      label: 'Photo',
                      onTap: () {
                        showMessage('Photo input coming next.');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ActionButton(
                      icon: Icons.attach_file,
                      label: 'File',
                      onTap: () {
                        showMessage('File input coming next.');
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: openAnalysis,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'WHAT NOW?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'TRY IT WITH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.8,
                  color: Colors.white38,
                ),
              ),

              const SizedBox(height: 14),

              ExampleCard(
                icon: Icons.receipt_long_outlined,
                title: 'A bill or payment message',
                subtitle: '“Do I need to pay this?”',
                onTap: () {
                  _controller.text =
                      'Your payment of ₹4,999 is due by 25 September. Late payment may attract additional charges.';
                },
              ),

              ExampleCard(
                icon: Icons.work_outline,
                title: 'A job offer',
                subtitle: '“Is this offer safe?”',
                onTap: () {
                  _controller.text =
                      'Congratulations! You have been selected for a work-from-home job. Pay ₹2,000 registration fee to start.';
                },
              ),

              ExampleCard(
                icon: Icons.link,
                title: 'A suspicious message',
                subtitle: '“What should I do?”',
                onTap: () {
                  _controller.text =
                      'Your account will be blocked today. Click this link immediately and verify your details.';
                },
              ),

              const SizedBox(height: 20),

              const Center(
                child: Text(
                  'Your information stays in your control.',
                  style: TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ANALYSIS SCREEN
// ============================================================

class AnalysisScreen extends StatelessWidget {
  final String input;

  const AnalysisScreen({
    super.key,
    required this.input,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WHAT NOW?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 35),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Here is what matters.',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              input,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white45,
                fontSize: 13,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 24),

            const InfoCard(
              icon: Icons.info_outline,
              title: 'WHAT IS THIS?',
              text:
                  'This appears to be a message or document that requires your attention.',
            ),

            const SizedBox(height: 12),

            const Row(
              children: [
                Expanded(
                  child: SmallInfoCard(
                    title: 'URGENCY',
                    value: 'Medium',
                    icon: Icons.bolt,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: SmallInfoCard(
                    title: 'RISK',
                    value: 'Check',
                    icon: Icons.shield_outlined,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            const InfoCard(
              icon: Icons.event_outlined,
              title: 'DEADLINE',
              text:
                  'Check the original message carefully for an exact date or time.',
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF171421),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF7C5CFF).withOpacity(0.35),
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.play_arrow_rounded,
                        color: Color(0xFF9B82FF),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'WHAT SHOULD I DO NOW?',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  StepRow(
                    number: '1',
                    text: 'Verify the sender and important details.',
                  ),
                  StepRow(
                    number: '2',
                    text: 'Check the deadline before taking action.',
                  ),
                  StepRow(
                    number: '3',
                    text: 'Do not pay or share sensitive information until verified.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            const IgnoreCard(),

            const SizedBox(height: 14),

            const Text(
              'NEXT 3 STEPS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.7,
                color: Colors.white38,
              ),
            ),

            const SizedBox(height: 12),

            const NumberedCard(
              number: '01',
              title: 'Verify',
              text: 'Confirm that the information is genuine.',
            ),

            const NumberedCard(
              number: '02',
              title: 'Decide',
              text: 'Compare the deadline, cost and possible risk.',
            ),

            const NumberedCard(
              number: '03',
              title: 'Act',
              text: 'Take the appropriate next step only after checking.',
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF12141A),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text(
                        'DRAFT REPLY',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14),
                  Text(
                    '“Thanks for the information. I will verify the details and get back to you shortly.”',
                    style: TextStyle(
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
