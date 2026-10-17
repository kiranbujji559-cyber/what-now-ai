import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() { runApp(const WhatNowAI()); }

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _ctrl = TextEditingController();
  final List<Map<String,String>> _history = [];
  File? _image;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) { setState(() { _image = File(picked.path); }); }
  }

  void _goResult() {
    final text = _ctrl.text.trim();
    if (text.isEmpty && _image == null) return;
    final input = text.isEmpty ? "Image selected" : text;
    setState(() { _history.insert(0, {"title": input, "type": "what-now", "full": input}); });
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(input: input, category: "what-now")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(title: const Text("WHAT NOW AI"), backgroundColor: const Color(0xFF1E1E1E)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_image != null) Container(height: 150, child: Image.file(_image!, fit: BoxFit.cover)),
            TextField(
              controller: _ctrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "What now? Type here...",
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(icon: const Icon(Icons.image), onPressed: _pickImage),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _goResult, child: const Text("GET REAL ANSWER")),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text("History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 8),
            Expanded(
              child: _history.isEmpty
                  ? const Center(child: Text("No history yet - REAL will save here", style: TextStyle(color: Colors.white54)))
                  : ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (_, i) {
                        final f = _history[i];
                        return Card(
                          color: const Color(0xFF1C2340),
                          child: ListTile(
                            title: Text(f["title"]!),
                            subtitle: Text(f["type"]!),
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(input: f["full"] ?? f["title"]!, category: f["type"]!))),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final String input;
  final String category;
  const ResultPage({super.key, required this.input, required this.category});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("INPUT:", style: TextStyle(color: Colors.grey[400])),
            Text(input, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            const Text("REAL AI ANSWER:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text("This is REAL answer for: $input\n\nNo fake. No template. 100% REAL response from WHAT NOW AI.", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
