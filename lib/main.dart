import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const WhatNowAIApp());

class WhatNowAIApp extends StatelessWidget {
  const WhatNowAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF050A1F),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;
  final pages = const [HomeScreen(), HistoryScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter, radius: 1.2,
            colors: [Color(0xFF1A237E), Color(0xFF050A1F)],
          ),
        ),
        child: pages[_index],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F1433),
          boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.3), blurRadius: 20)],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFF00E5FF),
          unselectedItemColor: Colors.white38,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final _ctrl = TextEditingController();
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _scale = Tween<double>(begin: 1, end: 1.15).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose(){ _pulse.dispose(); _ctrl.dispose(); super.dispose(); }

  void _analyze(){
    if(_ctrl.text.trim().isEmpty) return;
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(text: _ctrl.text)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP LOGO WITH 3D GLOW
            Row(
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF8B5CF6), Color(0xFFFF00FF)]),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF00D4FF).withOpacity(0.6), blurRadius: 20, spreadRadius: 2),
                        BoxShadow(color: const Color(0xFFFF00FF).withOpacity(0.4), blurRadius: 30, spreadRadius: 1),
                      ],
                    ),
                    child: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 28),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('WHAT NOW AI', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 1, shadows: [Shadow(color: Colors.blue, blurRadius: 10)])),
                  Text('Send anything. Get clear actions.', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ]),
              ],
            ),
            const SizedBox(height: 8),
            Align(alignment: Alignment.centerRight, child: Text('Less Confusion.\nMore Action.', style: TextStyle(color: Colors.pinkAccent.shade100, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, shadows: const [Shadow(color: Colors.pink, blurRadius: 10)]), textAlign: TextAlign.right)),

            const SizedBox(height: 18),
            // TOP ICONS ROW
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _topIcon(Icons.message_rounded, 'Messages\n(WhatsApp, SMS, etc.)', Colors.green),
                _topIcon(Icons.image_rounded, 'Screenshots\n(Images & Photos)', Colors.purple),
                _topIcon(Icons.description_rounded, 'Documents\n(PDF, Bills, etc.)', Colors.blue),
                _topIcon(Icons.link_rounded, 'Links\n(Websites, Offers, etc.)', Colors.orange),
                _topIcon(Icons.mic_rounded, 'Voice\n(Future Update)', Colors.pink),
              ],
            ),
            const SizedBox(height: 22),
            const Text('Anything confusing?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const Text('Send it to WHAT NOW.', style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 14),

            // INPUT BOX WITH NEON BORDER
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF8B5CF6)]),
                boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 15)],
              ),
              padding: const EdgeInsets.all(1.5),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFF121836), borderRadius: BorderRadius.circular(16)),
                child: TextField(
                  controller: _ctrl,
                  maxLines: 4,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    hintText: 'Paste a message, bill, offer, email or anything...',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _actionChip(Icons.content_paste_rounded, 'Paste'),
                _actionChip(Icons.photo_rounded, 'Photo'),
                _actionChip(Icons.file_present_rounded, 'File'),
                _actionChip(Icons.link_rounded, 'Link'),
                _actionChip(Icons.mic_rounded, 'Voice'),
              ],
            ),
            const SizedBox(height: 16),

            // MAIN BUTTON WITH ANIMATED GLOW
            Container(
              width: double.infinity, height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)]),
                boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.6), blurRadius: 20, offset: const Offset(0, 4))],
              ),
              child: ElevatedButton.icon(
                onPressed: _analyze,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                icon: const Icon(Icons.auto_awesome, color: Colors.white),
                label: const Text('WHAT SHOULD I DO?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 22),
            const Text('Try an example', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white70)),
            const SizedBox(height: 10),
            _example(Icons.warning_amber_rounded, const Color(0xFFEF4444), 'Suspicious message', 'Your account will be blocked today...', 'Your account will be blocked today. Click here to verify.'),
            _example(Icons.receipt_long_rounded, const Color(0xFF22C55E), 'Bill or payment', 'Electricity bill for tomorrow...', 'Your electricity bill of ₹2,450 is due tomorrow. Pay immediately to avoid disconnection.'),
            _example(Icons.work_rounded, const Color(0xFF8B5CF6), 'Job offer', 'You have been selected for a job...', 'Dear Customer, Your application is ready for the next step. A few documents are still required.'),
            _example(Icons.description_rounded, const Color(0xFF3B82F6), 'Agreement', 'Please review the document...', 'Please review the rental agreement document attached.'),
            _example(Icons.shopping_bag_rounded, const Color(0xFFF59E0B), 'Product', 'Best deal on this product...', 'Best deal on this product - 50% off today only!'),
          ],
        ),
      ),
    );
  }

  Widget _topIcon(IconData icon, String label, Color c){
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: c.withOpacity(0.2), shape: BoxShape.circle, border: Border.all(color: c.withOpacity(0.5)), boxShadow: [BoxShadow(color: c.withOpacity(0.4), blurRadius: 12)]),
        child: Icon(icon, color: c, size: 18),
      ),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 7, color: Colors.white60), textAlign: TextAlign.center),
    ]);
  }

  Widget _actionChip(IconData icon, String label){
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2040),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6)],
      ),
      child: Column(children: [Icon(icon, size: 18, color: Colors.white70), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 9, color: Colors.white70))]),
    );
  }

  Widget _example(IconData icon, Color color, String title, String sub, String fill){
    return InkWell(
      onTap: ()=> setState(()=> _ctrl.text = fill),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF121836),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12)],
        ),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 11), overflow: TextOverflow.ellipsis),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white24),
        ]),
      ),
    );
  }
}

class ResultScreen extends StatelessWidget {
  final String text;
  const ResultScreen({super.key, required this.text});
  @override
  Widget build(BuildContext context) {
    final isBill = text.toLowerCase().contains('bill') || text.toLowerCase().contains('₹2,450');
    final isScam = text.toLowerCase().contains('blocked');
    return Scaffold(
      appBar: AppBar(title: const Text('WHAT NOW AI', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: const Color(0xFF0F1433), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F1433), Color(0xFF050A1F)])),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Container(padding: const EdgeInsets.all(2), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Colors.cyan, Colors.purple])), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF121836), borderRadius: BorderRadius.circular(12)), child: Text(text, style: const TextStyle(color: Colors.white70)))),
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3))), child: const Text('✦ HERE\'S WHAT NOW ✦', style: TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.w900, fontSize: 12))),
            const SizedBox(height: 14),
            _neonCard(Icons.info_outline_rounded, 'WHAT IS THIS?', isBill ? 'Electricity bill payment reminder.' : isScam ? 'Suspicious account blocked message' : 'General Message', const Color(0xFF8B5CF6)),
            _neonCard(Icons.bolt_rounded, 'WHY IT MATTERS?', isBill ? 'Avoid late fee and service disruption.' : 'May be important or risky', const Color(0xFF3B82F6)),
            _neonCard(Icons.check_circle_rounded, 'WHAT SHOULD I DO?', isBill ? 'Verify with official provider app/website and pay if genuine.' : 'Verify sender and official source', const Color(0xFF22C55E)),
            _neonCard(Icons.calendar_today_rounded, 'DEADLINE', isBill ? 'Tomorrow' : 'Check source carefully', const Color(0xFFF59E0B)),
            _neonCard(Icons.warning_rounded, 'WHAT IF I DO NOTHING?', isBill ? 'Late fee, disconnection possible.' : 'You may miss important info', const Color(0xFFEF4444)),
            _neonCard(Icons.shield_rounded, 'RISK CHECK', isScam ? 'High risk - Fake link!' : 'Low risk - Check source carefully', const Color(0xFFEC4899)),
            const SizedBox(height: 12),
            const Align(alignment: Alignment.centerLeft, child: Text('NEXT 3 STEPS', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1))),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF121836), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('1  Verify bill details on official app/website.', style: TextStyle(fontSize: 13)), SizedBox(height: 4), Text('2  Check payment amount and due date.', style: TextStyle(fontSize: 13)), SizedBox(height: 4), Text('3  Complete payment if genuine.', style: TextStyle(fontSize: 13))]) ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF6366F1)]), boxShadow: [BoxShadow(color: const Color(0xFF8B5CF6).withOpacity(0.4), blurRadius: 12)]), child: ElevatedButton.icon(onPressed: (){ Clipboard.setData(ClipboardData(text: 'Thanks, please share official link')); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'))); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: const Icon(Icons.copy_rounded, size: 18), label: const Text('Copy Reply')))),
              const SizedBox(width: 10),
              Expanded(child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF2563EB)]), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.4), blurRadius: 12)]), child: ElevatedButton.icon(onPressed: (){}, style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), icon: const Icon(Icons.alarm_rounded, size: 18), label: const Text('Set Reminder')))),
            ])
          ]),
        ),
      ),
    );
  }
  Widget _neonCard(IconData icon, String title, String desc, Color color){
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121836),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.35)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.25), blurRadius: 16, spreadRadius: 0)],
      ),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8)),
          const SizedBox(height: 3),
          Text(desc, style: const TextStyle(fontSize: 13, color: Colors.white)),
        ])),
      ]),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('History', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          Container(decoration: BoxDecoration(color: const Color(0xFF121836), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white12)), child: const TextField(decoration: InputDecoration(hintText: 'Search your history...', hintStyle: TextStyle(color: Colors.white38), prefixIcon: Icon(Icons.search_rounded, color: Colors.white38), border: InputBorder.none, contentPadding: EdgeInsets.all(14)))),
          const SizedBox(height: 10),
          Row(children: [
            _filter('All', true), const SizedBox(width: 6),
            _filter('Today', false), const SizedBox(width: 6),
            _filter('Yesterday', false), const SizedBox(width: 6),
            _filter('This Week', false),
          ]),
          const SizedBox(height: 16),
          Expanded(child: ListView(children: [
            _hItem(Icons.receipt_long_rounded, const Color(0xFF22C55E), 'Electricity bill', 'Bill reminder - ₹2,450', 'Today - 10:24 AM'),
            _hItem(Icons.work_rounded, const Color(0xFF8B5CF6), 'Job offer', 'Suspicious message', 'Today - 09:12 AM'),
            _hItem(Icons.account_balance_rounded, const Color(0xFF3B82F6), 'Bank alert', 'Transaction declined', 'Today - 08:45 AM'),
            _hItem(Icons.description_rounded, const Color
