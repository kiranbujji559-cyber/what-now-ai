import 'package:flutter/material.dart';

void main() => runApp(const WhatNowApp());

class WhatNowApp extends StatelessWidget {
  const WhatNowApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E1F),
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _H();
}

class _H extends State<Home> {
  final _t = TextEditingController();
  bool _show = false;
  String _what = "", _why = "", _do = "", _risk = "";
  String _steps = "", _reply = "", _money = "";
  String _level = "LOW", _title = "";

  void _analyze() {
    String s = _t.text.toLowerCase();
    if (s.isEmpty) return;
    setState(() {
      _show = true;
      if (s.contains("job") || s.contains("fee") || s.contains("selected")) {
        _title = "Job Offer - HIGH RISK";
        _what = "Job offer asking upfront fee";
        _why = "90% fee jobs are scams in India";
        _do = "DO NOT PAY. Verify on official website, LinkedIn, ask for stamped offer letter";
        _risk = "Registration fee before joining = scam pattern";
        _level = "HIGH";
        _money = "Fee mentioned - Don't pay now";
        _steps = "1. Google company + reviews\n2. Check official careers page\n3. Ask for official letter";
        _reply = "Please share official offer letter and company website";
      } else if (s.contains("bill") || s.contains("due") || s.contains("electricity")) {
        _title = "Bill Reminder";
        _what = "Electricity / Utility bill due";
        _why = "Avoid late fee and disconnection if genuine";
        _do = "Open official APEPDCL or provider app, verify amount, pay only there";
        _risk = "Verify amount in official app before paying";
        _level = "MEDIUM";
        _money = "Amount: verify in app";
        _steps = "1. Open official provider app\n2. Verify consumer number\n3. Pay via UPI";
        _reply = "Noted. Will verify and pay via official app";
      } else {
        _title = "General Message";
        _what = "Message needs verification";
        _why = "May be important or risky";
        _do = "Verify sender and official source";
        _risk = "Check source carefully";
        _level = "LOW";
        _money = "No money mentioned";
        _steps = "1. Verify sender\n2. Check official link\n3. Act or ignore";
        _reply = "Thanks, please share official link";
      }
    });
  }

  Widget _card(String t, String v, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(v, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E1F),
        title: const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _t,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1A1F3A),
                hintText: "Paste bill, job offer, message...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _analyze,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C4DFF),
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("WHAT SHOULD I DO?", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            if (_show) ...[
              const SizedBox(height: 20),
              const Text("HERE'S WHAT NOW", style: TextStyle(color: Color(0xFF7C4DFF), fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _card("WHAT IS THIS? - $_title", _what, Colors.purple),
              _card("WHY IT MATTERS?", _why, Colors.blue),
              _card("WHAT SHOULD I DO?", _do, Colors.green),
              _card("RISK - $_level", _risk, _level == "HIGH" ? Colors.red : Colors.orange),
              _card("MONEY?", _money, Colors.teal),
              _card("NEXT 3 STEPS", _steps, Colors.white24),
              _card("DRAFT REPLY", _reply, Colors.white24),
            ]
          ],
        ),
      ),
    );
  }
}



