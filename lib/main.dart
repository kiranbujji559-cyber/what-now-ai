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
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF090A0F),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C5CFF),
          brightness: Brightness.dark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ==================== SPLASH ====================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainScreen(),
        ),
      );
    });
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
              Color(0xFF17152A),
              Color(0xFF090A0F),
              Color(0xFF120E1D),
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppLogo(size: 90),
              SizedBox(height: 25),
              Text(
                'WHAT NOW',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'AI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6,
                  color: Color(0xFF9B82FF),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Send anything. Get clear actions.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== MAIN SCREEN ====================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    HistoryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        backgroundColor: const Color(0xFF111217),
        indicatorColor: const Color(0xFF2B2247),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history),
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

// ==================== HOME ====================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController controller = TextEditingController();

  void showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> pasteText() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);

    if (!mounted) return;

    if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
      controller.text = data.text!;
      showMessage('Text pasted successfully.');
    } else {
      showMessage('Clipboard is empty.');
    }
  }

  void analyze() {
    if (controller.text.trim().isEmpty) {
      showMessage('First paste or type something.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnalysisScreen(
          input: controller.text.trim(),
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
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  AppLogo(size: 46),
                  SizedBox(width: 12),
                  Text(
                    'WHAT NOW AI',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),
              const Text(
                'Anything confusing?',
                style: TextStyle(
                  fontSize: 31,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Send it to WHAT NOW.',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF12141B),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white12,
                  ),
                ),
                child: TextField(
                  controller: controller,
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
                    child: InputButton(
                      icon: Icons.content_paste,
                      text: 'Paste',
                      onTap: pasteText,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputButton(
                      icon: Icons.photo_outlined,
                      text: 'Photo',
                      onTap: () {
                        showMessage('Photo feature coming next.');
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InputButton(
                      icon: Icons.attach_file,
                      text: 'File',
                      onTap: () {
                        showMessage('File feature coming next.');
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
                  onPressed: analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C5CFF),
                    foregroundColor: Colors.white,
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
              const SizedBox(height: 35),
              const Text(
                'TRY IT WITH',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white38,
                ),
              ),
              const SizedBox(height: 14),
              ExampleTile(
                icon: Icons.receipt_long_outlined,
                title: 'A bill or payment',
                subtitle: '“Do I need to pay this?”',
                onTap: () {
                  controller.text =
                      'Your payment of ₹4,999 is due by 25 September. Late payment may attract additional charges.';
                },
              ),
              ExampleTile(
                icon: Icons.work_outline,
                title: 'A job offer',
                subtitle: '“Is this offer safe?”',
                onTap: () {
                  controller.text =
                      'Congratulations! You have been selected for a work-from-home job. Pay ₹2,000 registration fee to start.';
                },
              ),
              ExampleTile(
                icon: Icons.warning_amber_outlined,
                title: 'A suspicious message',
                subtitle: '“What should I do?”',
                onTap: () {
                  controller.text =
                      'Your account will be blocked today. Click this link immediately and verify your details.';
                },
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'WHAT NOW AI • Version 1.0',
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 11,
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

// ==================== ANALYSIS ====================

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
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
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
            const SizedBox(height: 10),
            Text(
              input,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white54,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            const ResultCard(
              icon: Icons.info_outline,
              title: 'WHAT IS THIS?',
              text:
                  'This looks like information that requires your attention. Check the sender, details and any requested action.',
            ),
            const SizedBox(height: 12),
            Row(
              children: const [
                Expanded(
                  child: ResultCard(
                    icon: Icons.bolt,
                    title: 'URGENCY',
                    text: 'Medium',
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ResultCard(
                    icon: Icons.shield_outlined,
                    title: 'RISK',
                    text: 'Check',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const ResultCard(
              icon: Icons.event_outlined,
              title: 'DEADLINE',
              text:
                  'Look for the exact date or time in the original message.',
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF171321),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: const Color(0xFF7C5CFF).withOpacity(0.35),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'WHAT SHOULD I DO NOW?',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 18),
                  ActionStep(
                    number: '1',
                    text: 'Verify the sender and important details.',
                  ),
                  ActionStep(
                    number: '2',
                    text: 'Check the deadline before acting.',
                  ),
                  ActionStep(
                    number: '3',
                    text:
                        'Do not pay or share sensitive information until verified.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const IgnoreSection(),
            const SizedBox(height: 20),
            const Text(
              'NEXT 3 STEPS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white38,
              ),
            ),
            const SizedBox(height: 12),
            const NextStep(
              number: '01',
              title: 'VERIFY',
              text: 'Confirm that the information is genuine.',
            ),
            const NextStep(
              number: '02',
              title: 'DECIDE',
              text: 'Consider deadline, cost and possible risk.',
            ),
            const NextStep(
              number: '03',
              title: 'ACT',
              text: 'Take the appropriate next step.',
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF12141A),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DRAFT REPLY',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    '“Thanks for the information. I will verify the details and get back to you shortly.”',
                    style: TextStyle(
                      color: Colors.white60,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reminder feature coming next.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.alarm_outlined),
                    label: const Text('Remind'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share feature coming next.'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Share'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            const Center(
              child: Text(
                'AI results are informational. Verify important decisions.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white24,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== HISTORY ====================

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          HistoryTile(
            icon: Icons.receipt_long_outlined,
            title: 'Payment message',
          ),
          HistoryTile(
            icon: Icons.work_outline,
            title: 'Job offer',
          ),
          HistoryTile(
            icon: Icons.warning_amber_outlined,
            title: 'Suspicious message',
          ),
          SizedBox(height: 25),
          Center(
            child: Text(
              'Your future analyses will appear here.',
              style: TextStyle(
                color: Colors.white30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== SETTINGS ====================

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void message(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$text coming next.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF211A38),
                  Color(0xFF12131A),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                AppLogo(size: 58),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHAT NOW AI',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Send anything. Get clear actions.',
                        style: TextStyle(
                          color: Colors.white45,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SettingsTile(
            icon: Icons.notifications_none,
            title: 'Notifications',
            subtitle: 'Alerts and reminders',
            onTap: () => message(context, 'Notifications'),
          ),
          SettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy',
            subtitle: 'Control your information',
            onTap: () => message(context, 'Privacy'),
          ),
          SettingsTile(
            icon: Icons.language,
            title: 'Language',
            subtitle: 'English',
            onTap: () => message(context, 'Language'),
          ),
          SettingsTile(
            icon: Icons.star_outline,
            title: 'Premium',
            subtitle: 'Advanced WHAT NOW features',
            onTap: () => message(context, 'Premium'),
          ),
          SettingsTile(
            icon: Icons.help_outline,
            title: 'Help & feedback',
            subtitle: 'Get support',
            onTap: () => message(context, 'Help'),
          ),
          const SizedBox(height: 30),
          const Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: Colors.white24,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== LOGO ====================

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9B82FF),
            Color(0xFF6042D8),
          ],
        ),
      ),
      child: Icon(
        Icons.bolt_rounded,
        color: Colors.white,
        size: size * 0.58,
      ),
    );
  }
}

// ==================== INPUT BUTTON ====================

class InputButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const InputButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF15171F),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 21,
            ),
            const SizedBox(height: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== EXAMPLE TILE ====================

class ExampleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ExampleTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF111319),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white10,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF1B1830),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF9B82FF),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white30,
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== RESULT CARD ====================

class ResultCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const ResultCard({
    super.key,
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: const Color(0xFF9B82FF),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white60,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== ACTION STEP ====================

class ActionStep extends StatelessWidget {
  final String number;
  final String text;

  const ActionStep({
    super.key,
    required this.number,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 27,
            height: 27,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF7C5CFF),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white60,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== IGNORE SECTION ====================

class IgnoreSection extends StatefulWidget {
  const IgnoreSection({super.key});

  @override
  State<IgnoreSection> createState() => _IgnoreSectionState();
}

class _IgnoreSectionState extends State<IgnoreSection> {
  bool open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF181318),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.redAccent.withOpacity(0.20),
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              setState(() {
                open = !open;
              });
            },
            leading: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
            ),
            title: const Text(
              'WHAT IF I DO NOTHING?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            trailing: Icon(
              open
                  ? Icons.keyboard_arrow_up
                  : Icons.keyboard_arrow_down,
            ),
          ),
          if (open)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Text(
                'Ignoring an important message may result in missed deadlines, extra charges, loss of an opportunity or other consequences. Verify the exact terms before deciding.',
                style: TextStyle(
                  color: Colors.white54,
                  height: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ==================== NEXT STEP ====================

class NextStep extends StatelessWidget {
  final String number;
  final String title;
  final String text;

  const NextStep({
    super.key,
    required this.number,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF111319),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(
            number,
            style: const TextStyle(
              color: Color(0xFF9B82FF),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white45,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== HISTORY TILE ====================

class HistoryTile extends StatelessWidget {
  final IconData icon;
  final String title;

  const HistoryTile({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF12141A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF9B82FF),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Colors.white30,
          ),
        ],
      ),
    );
  }
}

// ==================== SETTINGS TILE ====================

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 5,
      ),
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFF15171F),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF9B82FF),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white30,
      ),
    );
  }
}
