import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

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
  final TextEditingController _controller = TextEditingController();
  bool _loading = false;
  Map<String, dynamic>? _result;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');

  Future<void> _askRealAI() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() { _loading = true; _result = null; });
    final prompt = 'You are WHAT NOW AI. User: "$text" Reply JSON ONLY: {"what_is_this":"2 lines","why_matters":"why","what_to_do":"1 line","deadline":"when","if_not_done":"what happens","risk_level":"Low/Medium/High","next_3_steps":["S1","S2","S3"],"friendly_reply":"4-5 lines Telugu-English mix"}';
    try {
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');
      final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({"contents": [{"parts": [{"text": prompt}]}]}));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        String aiText = data['candidates'][0]['content']['parts'][0]['text'];
        aiText = aiText.replaceAll('```json','').replaceAll('```','').trim();
        setState(() => _result = jsonDecode(aiText));
      } else {
        setState(() => _result = {"friendly_reply": "Error ${res.statusCode}", "risk_level":"High", "what_is_this":"Error", "why_matters":"API", "what_to_do":"Retry", "deadline":"Now", "if_not_done":"Fail", "next_3_steps":["Retry"]});
      }
    } catch (e) {
      setState(() => _result = {"friendly_reply": "Network $e", "risk_level":"High", "what_is_this":"Net Error", "why_matters":"Internet", "what_to_do":"Check net", "deadline":"Now", "if_not_done":"No result", "next_3_steps":["Check internet"]});
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img!= null) {
      _controller.text = "Image ${img.name} uploaded. What to do?";
      _askRealAI();
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool avail = await _speech.initialize();
      if (avail) {
        setState(() => _isListening = true);
        _speech.listen(onResult: (val) { setState(() { _controller.text = val.recognizedWords; }); });
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WHAT NOW AI ⚡'), actions: [
        IconButton(icon: const Icon(Icons.settings), onPressed: () {
          showDialog(context: context, builder: (c) => AlertDialog(
            title: const Text('Settings'), content: const Text('WHAT NOW AI v1.0\nPaste: Long press text field\nPhoto: Gallery works\nVoice: Mic works\nReal Gemini AI inside'),
            actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: const Text('OK'))],
          ));
        })
      ]),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          TextField(controller: _controller, maxLines: 3, decoration: const InputDecoration(hintText: 'Emaina pettu...', border: OutlineInputBorder())),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Photo'))),
            const SizedBox(width: 8),
            Expanded(child: ElevatedButton.icon(onPressed: _listen, icon: Icon(_isListening? Icons.mic_off : Icons.mic), label: Text(_isListening? 'Stop' : 'Voice'), style: ElevatedButton.styleFrom(backgroundColor: Colors.orange))),
          ]),
          const SizedBox(height: 8),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading? null : _askRealAI, style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding: const EdgeInsets.all(14)), child: _loading? const CircularProgressIndicator(color: Colors.white) : const Text('ASK REAL AI 🚀'))),
          const SizedBox(height: 12),
          if (_result!= null) Expanded(child: ListView(children: [
            Card(child: ListTile(title: const Text('WHAT IS THIS?', style: TextStyle(color: Colors.cyan, fontWeight: FontWeight.bold)), subtitle: Text(_result!['what_is_this']??''))),
            Card(child: ListTile(title: const Text('WHY MATTERS', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)), subtitle: Text(_result!['why_matters']??''))),
            Card(child: ListTile(title: const Text('WHAT TO DO', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)), subtitle: Text(_result!['what_to_do']??''))),
            Card(child: ListTile(title: Text('RISK: ${_result!['risk_level']??''}'), subtitle: Text(_result!['friendly_reply']??''))),
           ...(_result!['next_3_steps'] as List? ?? []).map((s) => Card(child: ListTile(leading: const Icon(Icons.check_circle, color: Colors.green), title: Text(s.toString())))),
          ])),
        ]),
      ),
    );
  }
}
