import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:shared_preferences/shared_preferences.dart';

const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
List<Map<String, String>> appHistory = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('what_now_history');
  if (raw != null) appHistory = (jsonDecode(raw) as List).map((e) => Map<String, String>.from(e)).toList();
  runApp(const WhatNowAI());
}

Future<void> saveHist() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('what_now_history', jsonEncode(appHistory));
}

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xFF0A102E)),
    home: const SplashScreen(),
  );
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashState();
}
class _SplashState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A102E),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/icon.png', width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 120, height: 120, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFFB026FF)]), borderRadius: BorderRadius.circular(28)), child: const Icon(Icons.smart_toy_rounded, size: 60, color: Colors.white)))),
      const SizedBox(height: 20),
      const Text("WHAT NOW AI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text("Send anything. Get clear actions.", style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 30),
      const CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 3),
    ])),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  void goHome(BuildContext c, String name) => Navigator.pushReplacement(c, MaterialPageRoute(builder: (_) => MainScaffold(userName: name)));
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A102E),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 10),
      ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/icon.png', width: 80, height: 80, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 80, height: 80, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFFB026FF)]), borderRadius: BorderRadius.circular(22)), child: const Icon(Icons.smart_toy_rounded, color: Colors.white)))),
      const SizedBox(height: 12),
      const Text("WHAT NOW AI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
      const Spacer(),
      const Align(alignment: Alignment.centerLeft, child: Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      const Align(alignment: Alignment.centerLeft, child: Text("Sign in to continue", style: TextStyle(color: Colors.white54))),
      const SizedBox(height: 18),
      _btn(true, "Continue with Google", () => goHome(context, "Kiran Bujji")),
      const SizedBox(height: 10),
      _btn(false, "Continue with Email", () => goHome(context, "Kiran Bujji")),
      const SizedBox(height: 10),
      _btn(false, "Continue as Guest", () => goHome(context, "Guest")),
      const SizedBox(height: 14),
      const Text("New here? Create an account", style: TextStyle(color: Color(0xFFB18CFF), fontSize: 13)),
    ]))),
  );
  Widget _btn(bool w, String t, VoidCallback tap) => SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: tap, style: ElevatedButton.styleFrom(backgroundColor: w ? Colors.white : const Color(0xFF1C2340), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))), child: Text(t, style: TextStyle(color: w ? Colors.black : Colors.white, fontWeight: FontWeight.w600))));
}

class MainScaffold extends StatefulWidget {
  final String userName;
  const MainScaffold({required this.userName, super.key});
  @override
  State<MainScaffold> createState() => _MainState();
}
class _MainState extends State<MainScaffold> {
  int idx = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A102E),
    body: [HomePage(userName: widget.userName), const HistoryPage(), SettingsPage(userName: widget.userName)][idx],
    bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i) => setState(() => idx = i), backgroundColor: const Color(0xFF111940), selectedItemColor: const Color(0xFF00D4FF), unselectedItemColor: Colors.white38, items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"),
      BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings")
    ]),
  );
}
class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({required this.userName, super.key});
  @override
  State<HomePage> createState() => _HomeState();
}
class _HomeState extends State<HomePage> {
  final ctrl = TextEditingController();
  File? file;
  String? fileName, mime, cat = "General";
  bool listening = false;
  final stt.SpeechToText speech = stt.SpeechToText();

  Future<void> doPaste() async {
    final d = await Clipboard.getData('text/plain');
    if (d?.text != null && d!.text!.isNotEmpty) setState(() => ctrl.text = d.text!);
  }

  Future<void> pickPhoto() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (img != null) setState(() { file = File(img.path); fileName = img.name; mime = "image/jpeg"; });
  }

  Future<void> pickDoc() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'txt', 'jpg', 'png']);
    if (res != null && res.files.single.path != null) {
      final ext = res.files.single.extension?.toLowerCase() ?? 'pdf';
      setState(() { file = File(res.files.single.path!); fileName = res.files.single.name; mime = ext == 'pdf' ? 'application/pdf' : 'image/jpeg'; });
    }
  }

  Future<void> toggleVoice() async {
    if (!listening) {
      if (await speech.initialize()) {
        setState(() => listening = true);
        speech.listen(onResult: (v) => setState(() => ctrl.text = v.recognizedWords));
      }
    } else {
      setState(() => listening = false);
      speech.stop();
    }
  }

  void whatNow() {
    if (ctrl.text.trim().isEmpty && file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Type, paste, or attach a file first!")));
      return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => ResultPage(input: ctrl.text.trim().isEmpty ? "Analyze $fileName" : ctrl.text.trim(), category: cat!, file: file, mimeType: mime)));
  }

  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/icon.png', width: 36, height: 36, fit: BoxFit.cover, errorBuilder: (c, e, s) => Container(width: 36, height: 36, color: Colors.blue, child: const Icon(Icons.smart_toy_rounded, size: 20)))),
      const SizedBox(width: 8),
      const Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      const Spacer(),
      if (cat != "General") Chip(label: Text(cat!, style: const TextStyle(fontSize: 11)), onDeleted: () => setState(() => cat = "General"))
    ]),
    const SizedBox(height: 14),
    const Text("Anything confusing?\nSend a message, screenshot,\ndocument, link or photo.", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, height: 1.3)),
    const SizedBox(height: 12),
    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(16)), child: Column(children: [
      TextField(controller: ctrl, maxLines: 4, decoration: const InputDecoration(hintText: "Paste or type here...", hintStyle: TextStyle(color: Colors.white38), border: InputBorder.none)),
      if (fileName != null) Row(children: [const Icon(Icons.attach_file, size: 16, color: Color(0xFF00D4FF)), const SizedBox(width: 6), Expanded(child: Text(fileName!, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))), GestureDetector(onTap: () => setState(() { file = null; fileName = null; }), child: const Icon(Icons.close, size: 16, color: Colors.red))]),
      Align(alignment: Alignment.centerRight, child: IconButton(icon: const Icon(Icons.send_rounded, color: Colors.white70), onPressed: whatNow))
    ])),
    const SizedBox(height: 12),
    Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _sBtn(Icons.content_paste_rounded, "Paste", doPaste),
      _sBtn(Icons.photo_outlined, "Photo", pickPhoto),
      _sBtn(Icons.folder_outlined, "File", pickDoc),
      _sBtn(Icons.link_rounded, "Link", () { setState(() => cat = "Link Check"); doPaste(); }),
      _sBtn(listening ? Icons.mic : Icons.mic_none_rounded, "Voice", toggleVoice, act: listening),
    ]),
    const SizedBox(height: 12),
    SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1EC8FF), foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))), icon: const Icon(Icons.auto_awesome, size: 20), label: const Text("WHAT NOW", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), onPressed: whatNow)),
    const SizedBox(height: 14),
    _card(Icons.warning_amber_rounded, Colors.red, "Suspicious message", "Is this a scam? (Scam Shield)", () => setState(() => cat = "Scam Shield")),
    _card(Icons.receipt_long_rounded, Colors.green, "Payment / Bill", "What should I do?", () => setState(() => cat = "Payment / Bill")),
    _card(Icons.work_rounded, Colors.orange, "Job offer", "Is it genuine?", () => setState(() => cat = "Job offer")),
    _card(Icons.description_rounded, Colors.blue, "Agreement", "Key points & risks", () => setState(() => cat = "Agreement")),
  ]))));

  Widget _sBtn(IconData ic, String lb, VoidCallback t, {bool act = false}) => Column(children: [
    InkWell(onTap: t, borderRadius: BorderRadius.circular(14), child: Container(width: 52, height: 52, decoration: BoxDecoration(color: act ? Colors.red.withOpacity(0.3) : const Color(0xFF1C2340), borderRadius: BorderRadius.circular(14)), child: Icon(ic, color: act ? Colors.red : Colors.white70))),
    const SizedBox(height: 4),
    Text(lb, style: const TextStyle(fontSize: 11, color: Colors.white70))
  ]);

  Widget _card(IconData ic, Color c, String t, String sub, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 10), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(14), child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(14)), child: Row(children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(ic, color: c, size: 22)),
    const SizedBox(width: 14),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12))])
  ]))));
}

class ResultPage extends StatefulWidget {
  final String input, category;
  final File? file;
  final String? mimeType;
  const ResultPage({required this.input, required this.category, this.file, this.mimeType, super.key});
  @override
  State<ResultPage> createState() => _ResState();
}
class _ResState extends State<ResultPage> {
  bool load = true;
  String resText = "";
  @override
  void initState() { super.initState(); runAI(); }

  Future<void> runAI() async {
    if (geminiApiKey.isEmpty) { setState(() { load = false; resText = "API Key Missing in GitHub Secrets!"; }); return; }
    try {
      final prompt = "You are WHAT NOW AI (with Scam Shield). Category: ${widget.category}. Analyze this and reply clearly with:\n1. 🔍 WHAT THIS IS\n2. 🛡️ RISK & SAFETY CHECK (Safe / Caution / Scam)\n3. ✅ WHAT TO DO NOW (1, 2, 3 steps)\n\nInput: ${widget.input}";
      List<Map<String, dynamic>> parts = [{"text": prompt}];
      if (widget.file != null && widget.mimeType != null) {
        parts.add({"inline_data": {"mime_type": widget.mimeType, "data": base64Encode(await widget.file!.readAsBytes())}});
      }
      final r = await http.post(
        Uri.parse("https://googleapis.com"),
        headers: {"Content-Type": "application/json", "x-goog-api-key": geminiApiKey},
        body: jsonEncode({"contents": [{"parts": parts}]}),
      );
      if (r.statusCode == 200) {
        final d = jsonDecode(r.body);
        final txt = d['candidates']['content']['parts']['text'];
        setState(() { resText = txt; load = false; });
        appHistory.insert(0, {"title": widget.input.length > 40 ? "${widget.input.substring(0, 40)}..." : widget.input, "type": widget.category, "time": DateTime.now().toString().substring(0, 16), "content": txt});
        await saveHist();
      } else {
        setState(() { load = false; resText = "AI Error (${r.statusCode}): ${r.body}"; });
      }
    } catch (e) { setState(() { load = false; resText = "Error: $e"; }); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: Text(widget.category, style: const TextStyle(fontSize: 16))),
    backgroundColor: const Color(0xFF0A102E),
    body: Padding(padding: const EdgeInsets.all(16), child: load ? const Center(child: CircularProgressIndicator(color: Color(0xFF00D4FF))) : SingleChildScrollView(child: Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(16)), child: SelectableText(resText, style: const TextStyle(fontSize: 15, height: 1.5))))),
  );
}

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistState();
}
class _HistState extends State<HistoryPage> {
  String s = "";
  @override
  Widget build(BuildContext context) {
    final list = appHistory.where((e) => s.isEmpty || e["title"]!.toLowerCase().contains(s.toLowerCase())).toList();
return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
const Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
TextField(onChanged: (v) => setState(() => s = v), decoration: InputDecoration(hintText: "Search history...", filled: true, fillColor: const Color(0xFF1C2340), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
const SizedBox(height: 16),
Expanded(child: list.isEmpty ? const Center(child: Text("No history yet", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: list.length, itemBuilder: (c, i) => Card(color: const Color(0xFF1C2340), child: ListTile(title: Text(list[i]["title"]!, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text("${list[i]["type"]} • ${list[i]["time"]}", style: const TextStyle(color: Colors.white54, fontSize: 12)), onTap: () => showDialog(context: context, builder: (_) => AlertDialog(backgroundColor: const Color(0xFF1C2340), title: Text(list[i]["type"]!), content: SingleChildScrollView(child: Text(list[i]["content"]!))))))))
])));
}
}
class SettingsPage extends StatelessWidget {
final String userName;
const SettingsPage({required this.userName, super.key});
void open(BuildContext c, String t, String m) => Navigator.push(c, MaterialPageRoute(builder: (_) => Scaffold(backgroundColor: const Color(0xFF0A102E), appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: Text(t)), body: Padding(padding: const EdgeInsets.all(16), child: Text(m, style: const TextStyle(fontSize: 15, height: 1.5))))));
@override
Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
const SizedBox(height: 12),
_tile(Icons.person_rounded, "Account", "Manage profile", () => open(context, "Account", "User: $userName\nStatus: Active")),
_tile(Icons.shield_rounded, "Privacy & Security", "Your data is safe", () => open(context, "Privacy", "Your data is analyzed securely via encrypted AI and stored locally.")),
_tile(Icons.help_rounded, "Help & Support", "Get help", () => open(context, "Support", "Contact: support@whatnowai.com")),
const SizedBox(height: 12),
InkWell(onTap: () => open(context, "Go Pro", "Unlock unlimited PDF analysis & priority Scam Shield!"), child: Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7B2CBF), Color(0xFF9D4EDD)]), borderRadius: BorderRadius.circular(14)), child: const Row(children: [Icon(Icons.workspace_premium, color: Colors.amber), SizedBox(width: 10), Text("Go Pro - Premium benefits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))]))),
]))));
Widget _tile(IconData ic, String t, String sub, VoidCallback tap) => Padding(padding: const EdgeInsets.only(bottom: 8), child: ListTile(onTap: tap, tileColor: const Color(0xFF1C2340), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), leading: Icon(ic, color: Colors.white70), title: Text(t, style: const TextStyle(fontSize: 14)), subtitle: Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)), trailing: const Icon(Icons.chevron_right, color: Colors.white38)));
}
