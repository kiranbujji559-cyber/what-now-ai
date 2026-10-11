import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const WhatNowAI());

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  static const _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<void> _askRealAI() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    if (_apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Key not in build - workflow fix needed')));
      return;
    }
    setState(() { _loading = true; _result = null; });
    final prompt = 'You are WHAT NOW AI friendly Telugu-English best friend. User: "$text" Reply JSON ONLY: {"what_is_this":"simple 2 lines","why_matters":"why matters","what_to_do":"1 line action","deadline":"when","if_not_done":"if ignore","risk_level":"Low/Medium/High","next_3_steps":["s1","s2","s3"],"friendly_reply":"4-5 lines friendly Telugu-English"}';
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');
      final res = await http.post(url, headers: {'Content-Type':'application/json'}, body: jsonEncode({"contents":[{"parts":[{"text":prompt}]}]}));
      if (res.statusCode == 200) {
        var d = jsonDecode(res.body);
        String t = d['candidates'][0]['content']['parts'][0]['text'];
        t = t.replaceAll('```json','').replaceAll('```','').trim();
        setState(()=> _result = jsonDecode(t));
      } else {
        setState(()=> _result = {"friendly_reply":"Error ${res.statusCode}","risk_level":"High","what_is_this":res.body});
      }
    } catch (e) {
      setState(()=> _result = {"friendly_reply":"Network error $e","risk_level":"High"});
    }
    setState(()=> _loading = false);
  }

  Widget _card(String title, String value, Color c) {
    return Card(color: const Color(0xFF1E1E1E), margin: const EdgeInsets.symmetric(vertical:5),
      child: ListTile(title: Text(title, style: TextStyle(color: c, fontWeight: FontWeight.bold)), subtitle: Text(value, style: const TextStyle(color: Colors.white))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WHAT NOW AI - REAL AI'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(controller: _controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Emaina cheppu... bill, tension, job...', border: OutlineInputBorder())),
            const SizedBox(height:10),
            SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading? null : _askRealAI, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.all(14)), child: _loading? const CircularProgressIndicator(color: Colors.white) : const Text('ASK REAL AI 🚀'))),
            const SizedBox(height:12),
            if (_result!=null) Expanded(child: ListView(children: [
                  _card('WHAT IS THIS?', _result!['what_is_this']??'', Colors.cyan),
                  _card('WHY MATTERS', _result!['why_matters']??'', Colors.orange),
                  _card('WHAT TO DO', _result!['what_to_do']??'', Colors.green),
                  _card('DEADLINE', _result!['deadline']??'ASAP', Colors.yellow),
                  _card('IF IGNORE', _result!['if_not_done']??'', Colors.redAccent),
                  _card('AI FRIEND SAYS (${_result!['risk_level']??''})', _result!['friendly_reply']??'', Colors.white),
                  const SizedBox(height:8),
                  const Text('NEXT 3 STEPS:', style: TextStyle(fontWeight: FontWeight.bold)),
                 ...((_result!['next_3_steps'] as List?)?? []).map((s) => Card(child: ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text(s.toString())))),
                ])),
            if (_result==null &&!_loading) const Expanded(child: Center(child: Text('REAL Gemini AI inside ⚡\nNuvu em pettina clear ga chepthundi', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)))),
          ],
        ),
      ),
    );
  }
}
