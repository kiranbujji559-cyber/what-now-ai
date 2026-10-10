import 'package:flutter/material.dart';

void main() => runApp(const WhatNowAIApp());

class WhatNowAIApp extends StatelessWidget {
  const WhatNowAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF0A0E1F),
        primaryColor: Color(0xFF6C5CE7),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainTabs()));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E1F), Color(0xFF1A1F3D), Color(0xFF0A0E1F)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF6C5CE7), Color(0xFFFF00FF)]),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: Color(0xFF6C5CE7).withOpacity(0.6), blurRadius: 30, spreadRadius: 5)],
              ),
              child: Icon(Icons.chat_bubble_rounded, size: 60, color: Colors.white),
            ),
            SizedBox(height: 30),
            RichText(text: TextSpan(children: [
              TextSpan(text: 'WHAT NOW ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              TextSpan(text: 'AI', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
            ])),
            SizedBox(height: 10),
            Text('Send anything.\nGet clear actions.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
            SizedBox(height: 40),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _typeIcon(Icons.message, Colors.green), _typeIcon(Icons.image, Colors.purple),
              _typeIcon(Icons.description, Colors.blue), _typeIcon(Icons.link, Colors.orange),
              _typeIcon(Icons.mic, Colors.pink),
            ]),
          ]),
        ),
      ),
    );
  }
  Widget _typeIcon(IconData icon, Color color) {
    return Container(margin: EdgeInsets.all(8), padding: EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12), border: Border.all(color: color)),
      child: Icon(icon, color: color, size: 20));
  }
}

class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 0;
  final screens = [HomeInputScreen(), HistoryScreen(), SettingsScreen()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index, onTap: (i) => setState(() => _index = i),
        backgroundColor: Color(0xFF12162E), selectedItemColor: Color(0xFF6C5CE7), unselectedItemColor: Colors.white54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
        ],
      ),
    );
  }
}

class HomeInputScreen extends StatelessWidget {
  HomeInputScreen({super.key});
  final examples = [
    {'title':'Suspicious message', 'sub':'Your account will be blocked today...', 'icon':Icons.warning_rounded, 'color':Colors.red},
    {'title':'Bill or payment', 'sub':'Electricity bill for tomorrow...', 'icon':Icons.receipt_rounded, 'color':Colors.green},
    {'title':'Job offer', 'sub':'You have been selected for a job...', 'icon':Icons.work_rounded, 'color':Colors.blue},
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF6C5CE7)]), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.smart_toy_rounded, color: Colors.white)),
            SizedBox(width: 10),
            Text('WHAT NOW AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Spacer(), Icon(Icons.notifications_none_rounded)
          ]),
          SizedBox(height: 20),
          Text('Anything confusing?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text('Send it to WHAT NOW.', style: TextStyle(color: Colors.white70)),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white10)),
            child: Column(children: [
              TextField(maxLines: 4, decoration: InputDecoration(hintText: 'Paste a message, bill, offer, email or anything...', hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none)),
              SizedBox(height: 15),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _actionBtn(Icons.content_paste_rounded, 'Paste'), _actionBtn(Icons.photo_rounded, 'Photo'),
                _actionBtn(Icons.description_rounded, 'File'), _actionBtn(Icons.link_rounded, 'Link'),
                _actionBtn(Icons.mic_rounded, 'Voice'),
              ]),
              SizedBox(height: 15),
              SizedBox(width: double.infinity, child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C5CE7), padding: EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen())),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.auto_awesome, size: 18), SizedBox(width: 8), Text('WHAT SHOULD I DO?', style: TextStyle(fontWeight: FontWeight.bold))]),
              )),
            ]),
          ),
          SizedBox(height: 20),
          Text('Try an example', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          ...examples.map((e) => Container(
            margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(14),
            decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: (e['color'] as Color).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(e['icon'] as IconData, color: e['color'] as Color, size: 20)),
              SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e['title'] as String, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(e['sub'] as String, style: TextStyle(color: Colors.white54, fontSize: 11), maxLines: 1),
              ])),
            ]),
          )),
        ]),
      ),
    );
  }
  Widget _actionBtn(IconData icon, String label) {
    return Column(children: [
      Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(10)), child: Icon(icon, size: 18)),
      SizedBox(height: 4), Text(label, style: TextStyle(fontSize: 10, color: Colors.white60))
    ]);
  }
}

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WHAT NOW AI'), backgroundColor: Color(0xFF0A0E1F)),
      body: SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [
          Icon(Icons.description, color: Colors.blue), SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Your electricity bill reminder', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('"Your electricity bill of ₹2,450 is due tomorrow. Pay immediately..."', style: TextStyle(color: Colors.white60, fontSize: 12)),
          ])),
        ])),
        SizedBox(height: 20),
        Text('✨ HERE\'S WHAT NOW ✨', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6C5CE7))),
        SizedBox(height: 12),
        _infoCard('WHAT IS THIS?', 'Electricity bill payment reminder.', Color(0xFF6C5CE7), Icons.info_outline),
        _infoCard('WHY IT MATTERS?', 'Avoid late fee and service disruption.', Color(0xFF00D4FF), Icons.bolt),
        _infoCard('WHAT SHOULD I DO?', 'Verify with official provider app/website and pay if genuine.', Color(0xFF00C853), Icons.check_circle),
        _infoCard('DEADLINE', 'Tomorrow', Color(0xFFFF9800), Icons.calendar_today),
        _infoCard('WHAT IF I DO NOTHING?', 'Late fee, disconnection possible.', Color(0xFFFF5252), Icons.warning),
        _infoCard('RISK CHECK', 'Be careful of fake links or payment scams.', Color(0xFFE040FB), Icons.shield),
        SizedBox(height: 20),
        Text('NEXT 3 STEPS', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Text('1  Verify bill details on official app/website.\n2  Check payment amount and due date.\n3  Complete payment if genuine.', style: TextStyle(color: Colors.white70)),
        SizedBox(height: 20),
        Row(children: [
          Expanded(child: ElevatedButton.icon(icon: Icon(Icons.copy, size: 16), label: Text('Copy Reply'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6C5CE7)), onPressed: () {},)),
          SizedBox(width: 10),
          Expanded(child: ElevatedButton.icon(icon: Icon(Icons.alarm, size: 16), label: Text('Set Reminder'), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2196F3)), onPressed: () {},)),
        ]),
      ])),
    );
  }
  Widget _infoCard(String title, String desc, Color color, IconData icon) {
    return Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(14), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))), child: Row(children: [Icon(icon, color: color, size: 20), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11)), SizedBox(height: 2), Text(desc, style: TextStyle(fontSize: 12, color: Colors.white))]))]));
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('History', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 10),
      TextField(decoration: InputDecoration(hintText: 'Search your history...', prefixIcon: Icon(Icons.search), filled: true, fillColor: Color(0xFF1E2340), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
      SizedBox(height: 15),
      Row(children: [Chip(label: Text('All', style: TextStyle(fontSize: 12)), backgroundColor: Color(0xFF6C5CE7)), SizedBox(width: 6), Chip(label: Text('Today', style: TextStyle(fontSize: 12)), backgroundColor: Color(0xFF1E2340)), SizedBox(width: 6), Chip(label: Text('Yesterday', style: TextStyle(fontSize: 12)), backgroundColor: Color(0xFF1E2340))]),
      SizedBox(height: 15),
      Expanded(child: ListView(children: [
        _histItem('Electricity bill', 'Bill reminder - ₹2,450', 'Today - 10:24 AM', Icons.image, Colors.green),
        _histItem('Job offer', 'Suspicious message', 'Today - 09:12 AM', Icons.image, Colors.purple),
        _histItem('Bank alert', 'Transaction declined', 'Today - 08:45 AM', Icons.email, Colors.blue),
      ])),
    ])));
  }
  Widget _histItem(String t, String s, String time, IconData icon, Color c) {
    return Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: c, size: 18)), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), Text(s, style: TextStyle(color: Colors.white54, fontSize: 11)), Text(time, style: TextStyle(color: Colors.white38, fontSize: 10))])), Icon(Icons.chevron_right, color: Colors.white38)]));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Padding(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Settings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      SizedBox(height: 20),
      Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 40, height: 40, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF6C5CE7)]), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.smart_toy)), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WHAT NOW AI', style: TextStyle(fontWeight: FontWeight.bold)), Text('v1.0.0', style: TextStyle(color: Colors.white54, fontSize: 12))])])),
      SizedBox(height: 20),
      _setTile(Icons.person, 'Account', 'Profile & preferences'),
      _setTile(Icons.notifications, 'Notifications', 'Reminders & alerts', hasSwitch: true),
      _setTile(Icons.language, 'Language', 'English'),
      _setTile(Icons.dark_mode, 'Appearance', 'Dark mode', hasSwitch: true, switchVal: true),
      _setTile(Icons.security, 'Privacy & Security', 'Your data is safe'),
      _setTile(Icons.help, 'Help & Support', 'FAQs and contact'),
      SizedBox(height: 10),
      Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6C5CE7), Color(0xFF9C27B0)]), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(Icons.star, color: Colors.amber), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Go Pro', style: TextStyle(fontWeight: FontWeight.bold)), Text('More analyses. Premium features.', style: TextStyle(fontSize: 11))])), Icon(Icons.chevron_right)])),
    ])));
  }
  Widget _setTile(IconData icon, String title, String sub, {bool hasSwitch = false, bool switchVal = false}) {
    return Container(margin: EdgeInsets.only(bottom: 10), padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(icon, size: 20, color: Colors.white70), SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)), Text(sub, style: TextStyle(fontSize: 11, color: Colors.white54))])), if (hasSwitch) Switch(value: switchVal, onChanged: (v) {}, activeColor: Color(0xFF6C5CE7)) else Icon(Icons.chevron_right, color: Colors.white38, size: 18)]));
  }
}
