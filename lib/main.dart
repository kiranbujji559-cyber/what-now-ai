import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
List<Map<String, String>> appHistory = [];
String appLanguage = "English";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { await Firebase.initializeApp(); } catch (_) {}
  final prefs = await SharedPreferences.getInstance();
  final raw = prefs.getString('what_now_history');
  if (raw != null) appHistory = (jsonDecode(raw) as List).map((e) => Map<String, String>.from(e)).toList();
  appLanguage = prefs.getString('app_lang') ?? "English";
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
      if (!mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScaffold(userName: user.displayName ?? user.email ?? "User")));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    });
  }
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A102E),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/icon.png', width: 120, height: 120, fit: BoxFit.cover)),
      const SizedBox(height: 20),
      const Text("WHAT NOW AI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      const Text("Send anything. Get clear actions.", style: TextStyle(color: Colors.white54)),
      const SizedBox(height: 30),
      const CircularProgressIndicator(color: Color(0xFF00D4FF), strokeWidth: 3),
    ])),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}
class _LoginState extends State<LoginScreen> {
  bool loading = false;

  Future<void> googleSignIn() async {
    setState(() => loading = true);
    try {
      final gUser = await GoogleSignIn().signIn();
      if (gUser == null) { setState(() => loading = false); return; }
      final gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      final res = await FirebaseAuth.instance.signInWithCredential(cred);
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScaffold(userName: res.user?.displayName ?? "Google User")));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google Sign-In: $e")));
    }
    if (mounted) setState(() => loading = false);
  }

  void showEmailDialog() {
    final emailC = TextEditingController();
    final passC = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF1C2340),
      title: const Text("Sign in / Register with Email"),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: emailC, decoration: const InputDecoration(hintText: "Email")),
        const SizedBox(height: 8),
        TextField(controller: passC, obscureText: true, decoration: const InputDecoration(hintText: "Password (min 6 chars)")),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: () async {
          Navigator.pop(context);
          setState(() => loading = true);
          try {
            final res = await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailC.text.trim(), password: passC.text.trim());
            if (!mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScaffold(userName: res.user?.email ?? "User")));
          } catch (_) {
            try {
              final res = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailC.text.trim(), password: passC.text.trim());
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainScaffold(userName: res.user?.email ?? "User")));
            } catch (e2) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e2")));
            }
          }
          if (mounted) setState(() => loading = false);
        }, child: const Text("Continue")),
      ],
    ));
  }

  Future<void> guestSignIn() async {
    setState(() => loading = true);
    try { await FirebaseAuth.instance.signInAnonymously(); } catch (_) {}
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScaffold(userName: "Guest User")));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0A102E),
    body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height: 10),
      ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/icon.png', width: 80, height: 80, fit: BoxFit.cover)),
      const SizedBox(height: 12),
      const Text("WHAT NOW AI", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
      const Text("Send anything.\nGet clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 13)),
      const Spacer(),
      const Align(alignment: Alignment.centerLeft, child: Text("Welcome Back!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
      const Align(alignment: Alignment.centerLeft, child: Text("Sign in to continue", style: TextStyle(color: Colors.white54))),
      const SizedBox(height: 18),
      if (loading) const CircularProgressIndicator(color: Color(0xFF00D4FF)) else ...[
        _btn(true, "Continue with Google", googleSignIn),
        const SizedBox(height: 10),
        _btn(false, "Continue with Email", showEmailDialog),
        const SizedBox(height: 10),
        _btn(false, "Continue as Guest", guestSignIn),
      ],
      const SizedBox(height: 14),
      GestureDetector(onTap: showEmailDialog, child: const Text("New here? Create an account", style: TextStyle(color: Color(0xFFB18CFF), fontSize: 13))),
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
      var status = await Permission.microphone.request();
      if (!status.isGranted) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Microphone permission required!")));
        return;
      }
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
      ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/icon.png', width: 36, height: 36, fit: BoxFit.cover)),
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
    _card(Icons.flight_takeoff_rounded, Colors.purpleAccent, "Flight / Ticket / Other", "Check status & rules", () => setState(() => cat = "Ticket / General")),
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
    if (geminiApiKey.isEmpty) { setState(() { load = false; resText = "⚠️ API Key Missing! Add GEMINI_API_KEY in GitHub Secrets."; }); return; }
    try {
      final prompt = "You are WHAT NOW AI (with Scam Shield). Reply in $appLanguage language. Category: ${widget.category}. Analyze this and give:\n1. 🔍 WHAT THIS IS\n2. 🛡️ RISK & SAFETY CHECK (Safe / Caution / Scam)\n3. ✅ WHAT TO DO NOW (1, 2, 3 steps)\n\nInput: ${widget.input}";
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
        final txt = d['candidates'][0]['content']['parts'][0]['text'];
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
State createState() => _HistState();
}
class HistState extends State {
String s = "";
@override
Widget build(BuildContext context) {
final list = appHistory.where((e) => s.isEmpty || e["title"]!.toLowerCase().contains(s.toLowerCase())).toList();
return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
const Text("History", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
const SizedBox(height: 10),
TextField(onChanged: (v) => setState(() => s = v), decoration: InputDecoration(hintText: "Search history...", filled: true, fillColor: const Color(0xFF1C2340), border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none))),
const SizedBox(height: 16),
Expanded(child: list.isEmpty ? const Center(child: Text("No history yet", style: TextStyle(color: Colors.white54))) : ListView.builder(itemCount: list.length, itemBuilder: (c, i) => Card(color: const Color(0xFF1C2340), child: ListTile(title: Text(list[i]["title"]!, maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text("${list[i]["type"]} • ${list[i]["time"]}", style: const TextStyle(color: Colors.white54, fontSize: 12)), onTap: () => showDialog(context: context, builder: () => AlertDialog(backgroundColor: const Color(0xFF1C2340), title: Text(list[i]["type"]!), content: SingleChildScrollView(child: Text(list[i]["content"]!))))))))
])));
}
}
class SettingsPage extends StatefulWidget {
final String userName;
const SettingsPage({required this.userName, super.key});
@override
State createState() => _SetState();
}
class SettingsPage extends StatefulWidget {
  final String userName;
  const SettingsPage({required this.userName, super.key});
  @override
  State<SettingsPage> createState() => _SetState();
}

class _SetState extends State<SettingsPage> {
  bool notif = true;

  void open(String t, String m) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: const Color(0xFF0A102E),
          appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: Text(t)),
          body: Padding(padding: const EdgeInsets.all(16), child: Text(m, style: const TextStyle(fontSize: 15, height: 1.5))),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Settings", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.asset('assets/icon.png', width: 44, height: 44)),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("v1.0 Real AI App", style: TextStyle(color: Colors.white54, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _tile(Icons.person_rounded, "Account", "Manage your profile", () => open("Account", "Logged in as: ${widget.userName}\nStatus: Verified")),
              _tile(Icons.notifications_rounded, "Notifications", notif ? "Reminders & alerts: ON" : "Alerts: OFF", () => setState(() => notif = !notif)),
              _tile(Icons.dark_mode_rounded, "Appearance", "Dark mode", () => open("Appearance", "Dark Mode is active.")),
              _tile(Icons.language_rounded, "Language", appLanguage, () async {
                final next = appLanguage == "English" ? "Telugu" : (appLanguage == "Telugu" ? "Hindi" : "English");
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('app_lang', next);
                setState(() => appLanguage = next);
              }),
              _tile(Icons.shield_rounded, "Privacy & Security", "Your data is safe", () => open("Privacy & Security", "Your data is analyzed securely via encrypted AI and stored locally.")),
              _tile(Icons.help_rounded, "Help & Support", "Get help", () => open("Help & Support", "Contact: support@whatnowai.com")),
              const SizedBox(height: 12),
              InkWell(
                onTap: () => open("Go Pro", "Unlock unlimited PDF analysis & priority Scam Shield!"),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF7B2CBF), Color(0xFF9D4EDD)]), borderRadius: BorderRadius.circular(14)),
                  child: const Row(
                    children: [
                      Icon(Icons.workspace_premium, color: Colors.amber),
                      SizedBox(width: 10),
                      Text("Go Pro - Premium benefits", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(IconData ic, String t, String sub, VoidCallback tap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: tap,
        tileColor: const Color(0xFF1C2340),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(ic, color: Colors.white70),
        title: Text(t, style: const TextStyle(fontSize: 14)),
        subtitle: Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38),
      ),
    );
  }
}
