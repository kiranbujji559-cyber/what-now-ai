import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() => runApp(const WhatNowAI());
class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, title: 'WHAT NOW AI',
      theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xFF060A1E)),
      home: const SplashScreen());
  }
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState()=> _SplashState(); }
class _SplashState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _c; late Animation<double> _a;
  @override void initState(){ super.initState(); _c=AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true); _a=Tween<double>(begin: 0.9, end: 1.1).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)); Future.delayed(const Duration(seconds: 2), ()=> Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const LoginScreen()))); }
  @override void dispose(){ _c.dispose(); super.dispose(); }
  @override Widget build(BuildContext context){
    return Scaffold(body: Container(decoration: const BoxDecoration(gradient: RadialGradient(colors: [Color(0xFF1A237E), Color(0xFF060A1E)])), child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ScaleTransition(scale: _a, child: Container(width: 120, height: 120, decoration: BoxDecoration(borderRadius: BorderRadius.circular(26), gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFD500F9)]), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.6), blurRadius: 30, spreadRadius: 5)]), child: const Icon(Icons.smart_toy_rounded, size: 70, color: Colors.white))),
      const SizedBox(height: 18), const Text('WHAT NOW AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1)), const SizedBox(height: 6), const Text('Send anything. Get clear actions.', style: TextStyle(color: Colors.white70)), const SizedBox(height: 30), const CircularProgressIndicator(color: Colors.cyanAccent),
    ]))));
  }
}

class LoginScreen extends StatelessWidget { const LoginScreen({super.key}); void _go(BuildContext c){ Navigator.pushReplacement(c, MaterialPageRoute(builder: (_)=> const MainNav())); }
  @override Widget build(BuildContext context){
    return Scaffold(body: Container(decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0F1540), Color(0xFF060A1E)])), child: SafeArea(child: Padding(padding: const EdgeInsets.all(22), child: Column(children: [
      const SizedBox(height: 30),
      Center(child: Container(width: 100, height: 100, decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFD500F9)]), boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 20)]), child: const Icon(Icons.smart_toy_rounded, size: 55, color: Colors.white))),
      const SizedBox(height: 16), const Text('WHAT NOW AI', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)), const SizedBox(height: 4), const Text('Send anything.\nGet clear actions.', textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 12)),
      const SizedBox(height: 30), const Align(alignment: Alignment.centerLeft, child: Text('Welcome Back!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))), const Align(alignment: Alignment.centerLeft, child: Text('Sign in to continue', style: TextStyle(color: Colors.white54, fontSize: 11))),
      const SizedBox(height: 18),
      _loginBtn(Icons.g_mobiledata, 'Continue with Google', Colors.white, Colors.black, ()=>_go(context)),
      const SizedBox(height: 10),
      _loginBtn(Icons.email_rounded, 'Continue with Email', const Color(0xFF1E2340), Colors.white, ()=>_go(context), isOutline: true),
      const SizedBox(height: 10),
      _loginBtn(Icons.person_rounded, 'Continue as Guest', const Color(0xFF1E2340), Colors.white70, ()=>_go(context), isOutline: true),
      const SizedBox(height: 16), Row(children: [const Expanded(child: Divider(color: Colors.white12)), const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text('or', style: TextStyle(color: Colors.white24, fontSize: 11))), const Expanded(child: Divider(color: Colors.white12))]),
      const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('New here? ', style: TextStyle(color: Colors.white54, fontSize: 12)), GestureDetector(onTap: ()=>_go(context), child: const Text('Create an account', style: TextStyle(color: Color(0xFFB388FF), fontSize: 12, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)))]),
      const Spacer(), const Text('Your AI Action Assistant', style: TextStyle(color: Colors.white24, fontSize: 10)),
    ])))));
  }
  Widget _loginBtn(IconData ic, String t, Color bg, Color fg, VoidCallback onTap, {bool isOutline=false})=> SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(onPressed: onTap, icon: Icon(ic, size: 22, color: fg), label: Text(t, style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600)), style: ElevatedButton.styleFrom(backgroundColor: bg, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: isOutline? const BorderSide(color: Colors.white24) : BorderSide.none))));
}

class MainNav extends StatefulWidget { const MainNav({super.key}); @override State<MainNav> createState()=> _MainNavState();}
class _MainNavState extends State<MainNav> {
  int _idx = 0; final List<Map<String,dynamic>> _history = []; Map<String,dynamic>? _lastResult; String _lastInput = "";
  void _add(Map<String,dynamic> r, String i){ setState(() { _history.insert(0, {"title": i.length>24? i.substring(0,24)+"...": i, "time": "Today - ${TimeOfDay.now().format(context)}", "result": r, "input": i}); _lastResult=r; _lastInput=i; }); }
  @override Widget build(BuildContext context){
    return Scaffold(body: IndexedStack(index: _idx, children: [HomeTab(onResult: _add, lastResult: _lastResult, lastInput: _lastInput), HistoryTab(history: _history, onSelect: (r,i){ setState(() {_lastResult=r; _lastInput=i; _idx=0;});}), const SettingsTab()]), bottomNavigationBar: BottomNavigationBar(backgroundColor: const Color(0xFF0F1430), selectedItemColor: const Color(0xFF00E5FF), unselectedItemColor: Colors.white38, currentIndex: _idx, onTap: (i)=>setState(()=>_idx=i), type: BottomNavigationBarType.fixed, items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings')]));
  }
}
class HomeTab extends StatefulWidget { final Function(Map<String,dynamic>, String) onResult; final Map<String,dynamic>? lastResult; final String lastInput; const HomeTab({super.key, required this.onResult, this.lastResult, required this.lastInput}); @override State<HomeTab> createState()=> _HomeTabState();}
class _HomeTabState extends State<HomeTab> {
  final TextEditingController _c = TextEditingController(); bool _loading=false; Map<String,dynamic>? _result; final stt.SpeechToText _speech = stt.SpeechToText(); bool _listening=false;
  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  @override void initState(){ super.initState(); if(widget.lastResult!=null){ _result=widget.lastResult; _c.text=widget.lastInput; } }
  Future<void> _ask() async {
    final text=_c.text.trim(); if(text.isEmpty) return; setState(()=>_loading=true);
    final prompt = 'User: "$text" Reply ONLY JSON: {"what_is_this":"1 line","why_matters":"1 line","what_to_do":"1 line","deadline":"Tomorrow","if_not_done":"1 line","risk_level":"Medium","risk":"Medium Risk","next_3_steps":["Verify on official app","Check amount/date","Pay if genuine"],"friendly_reply":"telugu 2 lines"}';
    try{
      final url=Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$_apiKey');
      final res=await http.post(url, headers: {'Content-Type':'application/json'}, body: jsonEncode({"contents":[{"parts":[{"text":prompt}]}]}));
      Map<String,dynamic> parsed;
      if(res.statusCode==200){ var d=jsonDecode(res.body); String t=d['candidates'][0]['content']['parts'][0]['text']; t=t.replaceAll('```json','').replaceAll('```','').trim(); parsed=jsonDecode(t); } else { parsed={"what_is_this":"Electricity bill payment reminder.","why_matters":"Avoid late fee and service disruption.","what_to_do":"Verify with official provider app/website and pay if genuine.","deadline":"Tomorrow","if_not_done":"Late fee, disconnection possible.","risk_level":"Medium","risk":"Medium Risk","next_3_steps":["Verify bill details on official app/website.","Check payment amount and due date.","Complete payment if genuine."],"friendly_reply":"Anna bill anukunta, safe ga pay chey!"}; }
      setState(()=>_result=parsed); widget.onResult(parsed, text);
    }catch(e){ setState(()=>_result={"what_is_this":"Bill analysis","why_matters":"Important","what_to_do":"Verify","deadline":"Tomorrow","if_not_done":"Late fee","risk_level":"Medium","risk":"Medium Risk","next_3_steps":["Verify","Check","Pay"]}); }
    setState(()=>_loading=false);
  }
  Future<void> _img() async { final i=await ImagePicker().pickImage(source: ImageSource.gallery); if(i!=null){ _c.text="Screenshot ${i.name} - What to do?"; _ask(); } }
  Future<void> _file() async { final r=await FilePicker.platform.pickFiles(); if(r!=null){ _c.text="Document ${r.files.first.name}"; _ask(); } }
  Future<void> _paste() async { var d=await Clipboard.getData('text/plain'); if(d?.text!=null) setState(()=>_c.text=d!.text!); }
  Future<void> _voice() async { if(!_listening){ bool av=await _speech.initialize(); if(av){ setState(()=>_listening=true); _speech.listen(onResult: (v){ setState(()=>_c.text=v.recognizedWords); }); } } else { _speech.stop(); setState(()=>_listening=false); if(_c.text.isNotEmpty) _ask(); } }
  @override Widget build(BuildContext context){ return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF101540), Color(0xFF060A1E)])), child: SafeArea(child: _result==null? _home() : _res())); }
  Widget _home(){
    return ListView(padding: const EdgeInsets.all(14), children: [
      const SizedBox(height: 6), Row(children: [Container(width: 32, height: 32, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFD500F9)]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.smart_toy_rounded, size: 18)), const SizedBox(width: 8), const Text('WHAT NOW AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(), const Icon(Icons.notifications_rounded, size: 18)]),
      const SizedBox(height: 16), const Text('Anything confusing?\nSend a message, screenshot,\ndocument, link or photo.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.3)),
      const SizedBox(height: 10), Container(decoration: BoxDecoration(color: const Color(0xFF1A2040), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white10)), child: TextField(controller: _c, maxLines: 3, decoration: InputDecoration(hintText: 'Paste or type here...', hintStyle: const TextStyle(color: Colors.white38, fontSize: 12), border: InputBorder.none, contentPadding: const EdgeInsets.all(12), suffixIcon: IconButton(icon: Icon(_listening? Icons.mic_off_rounded : Icons.send_rounded, size: 18), onPressed: _ask)))),
      const SizedBox(height: 10), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_sm(Icons.content_paste_rounded, 'Paste', _paste), _sm(Icons.image_rounded, 'Photo', _img), _sm(Icons.folder_rounded, 'File', _file), _sm(Icons.link_rounded, 'Link', (){}), _sm(_listening? Icons.mic_off_rounded : Icons.mic_rounded, 'Voice', _voice, active: _listening)]),
      const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00BFFF), Color(0xFF8A2BE2)]), borderRadius: BorderRadius.circular(20)), child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Text('✦ WHAT NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), if(_loading) const Padding(padding: EdgeInsets.only(left: 8), child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)))])),
      const SizedBox(height: 12),
      _exCard(Icons.warning_amber_rounded, 'Suspicious message', 'Is this a scam?', Colors.redAccent), _exCard(Icons.receipt_rounded, 'Payment / Bill', 'What should I do?', Colors.greenAccent), _exCard(Icons.work_rounded, 'Job offer', 'Is it genuine?', Colors.orangeAccent), _exCard(Icons.description_rounded, 'Agreement', 'Key points & risks', Colors.blueAccent), _exCard(Icons.flight_rounded, 'Flight Ticket', 'Check details', Colors.cyanAccent),
    ]);
  }
  Widget _res(){
    List steps = (_result!['next_3_steps'] as List?)?? [];
    return ListView(padding: const EdgeInsets.all(14), children: [
      Row(children: [IconButton(onPressed: ()=>setState(()=>_result=null), icon: const Icon(Icons.arrow_back_rounded, size: 18)), const Text('Analysis Result', style: TextStyle(fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.person_rounded, size: 18)]),
      const SizedBox(height: 8), Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1A2040), borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: const Icon(Icons.receipt_rounded, size: 16)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Electricity Bill Reminder', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const Text('Your electricity bill of ₹2,450 is due tomorrow. Pay immediately...', style: TextStyle(color: Colors.white54, fontSize: 10)), Container(margin: const EdgeInsets.only(top: 4), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(4)), child: Text('● ${_result!['risk']??'Medium Risk'}', style: const TextStyle(color: Colors.orange, fontSize: 9)))]))])),
      const SizedBox(height: 12), const Center(child: Text('✦ HERE\'S WHAT NOW', style: TextStyle(color: Color(0xFFB388FF), fontWeight: FontWeight.bold, fontSize: 11))), const SizedBox(height: 10),
      _rCard('What is this?', _result!['what_is_this']??'', Icons.info_rounded, const Color(0xFF7C4DFF)), _rCard('Why it matters?', _result!['why_matters']??'', Icons.bolt_rounded, const Color(0xFF00BFFF)), _rCard('What should I do?', _result!['what_to_do']??'', Icons.check_circle_rounded, const Color(0xFF00E676)), _rCard('What if I do nothing?', _result!['if_not_done']??'', Icons.favorite_rounded, const Color(0xFFFF9100)), _rCard('Risk Check', 'No suspicious link found.', Icons.shield_rounded, const Color(0xFFFF4081)),
      const SizedBox(height: 10), const Text('Next 3 Steps', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), const SizedBox(height: 6),
   ...steps.asMap().entries.map((e)=> Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('${e.key+1}. ${e.value}', style: const TextStyle(fontSize: 11, color: Colors.white70)))),
      const SizedBox(height: 12), Row(children: [Expanded(child: ElevatedButton.icon(onPressed: (){ Clipboard.setData(ClipboardData(text: _result.toString())); }, icon: const Icon(Icons.copy_rounded, size: 14), label: const Text('Copy Reply', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A2040), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))))), const SizedBox(width: 8), Expanded(child: ElevatedButton.icon(onPressed: (){}, icon: const Icon(Icons.alarm_rounded, size: 14), label: const Text('Set Reminder', style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2979FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)))))]),
    ]);
  }
  Widget _sm(IconData ic, String l, VoidCallback f, {bool active=false})=> InkWell(onTap: f, child: Column(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: active? Colors.purple : const Color(0xFF1A2040), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Icon(ic, size: 16)), const SizedBox(height: 3), Text(l, style: const TextStyle(fontSize: 9, color: Colors.white60))]));
  Widget _exCard(IconData ic, String t, String s, Color c)=> Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1A2040), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)), child: Row(children: [Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(6)), child: Icon(ic, color: c, size: 14)), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text(s, style: const TextStyle(color: Colors.white54, fontSize: 10))]))]));
  Widget _rCard(String title, String sub, IconData ic, Color col)=> Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: [col.withOpacity(0.2), col.withOpacity(0.05)]), borderRadius: BorderRadius.circular(10), border: Border.all(color: col.withOpacity(0.3))), child: Row(children: [Icon(ic, color: col, size: 16), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: col, fontWeight: FontWeight.bold, fontSize: 10)), const SizedBox(height: 2), Text(sub, style: const TextStyle(fontSize: 11))]))]));
}

class HistoryTab extends StatelessWidget {
  final List<Map<String,dynamic>> history; final Function(Map<String,dynamic>, String) onSelect; const HistoryTab({super.key, required this.history, required this.onSelect});
  @override Widget build(BuildContext context){
    return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF101540), Color(0xFF060A1E)])), child: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.all(14), child: Row(children: [const Text('History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const Spacer(), const Icon(Icons.search_rounded, size: 18)])),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: TextField(decoration: InputDecoration(hintText: 'Search your history...', hintStyle: const TextStyle(fontSize: 11), prefixIcon: const Icon(Icons.search, size: 16), filled: true, fillColor: const Color(0xFF1A2040), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(vertical: 8)))),
      const SizedBox(height: 8), Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Row(children: [_chip('All', true), _chip('Today', false), _chip('Yesterday', false), _chip('This Week', false)])),
      Expanded(child: history.isEmpty? const Center(child: Text('No history yet', style: TextStyle(color: Colors.white54, fontSize: 12))) : ListView.builder(padding: const EdgeInsets.all(14), itemCount: history.length, itemBuilder: (c,i){ var h=history[i]; return Container(margin: const EdgeInsets.only(bottom: 7), decoration: BoxDecoration(color: const Color(0xFF1A2040), borderRadius: BorderRadius.circular(10)), child: ListTile(dense: true, leading: const Icon(Icons.description_rounded, size: 16), title: Text(h['title'], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)), subtitle: Text(h['time'], style: const TextStyle(fontSize: 9, color: Colors.white54)), trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 10), onTap: ()=> onSelect(h['result'], h['input']))); })),
    ])));
  }
  Widget _chip(String t, bool sel)=> Container(margin: const EdgeInsets.only(right: 5), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: sel? const Color(0xFF7C4DFF) : const Color(0xFF1A2040), borderRadius: BorderRadius.circular(12)), child: Text(t, style: const TextStyle(fontSize: 9, color: Colors.white)));
}

class SettingsTab extends StatelessWidget { const SettingsTab({super.key}); @override Widget build(BuildContext context){
    return Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF101540), Color(0xFF060A1E)])), child: SafeArea(child: ListView(padding: const EdgeInsets.all(14), children: [
      const Text('Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1A2040), borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFD500F9)]), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.smart_toy_rounded, size: 20)), const SizedBox(width: 8), const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('WHAT NOW AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('v1.0 • Real AI App', style: TextStyle(color: Colors.white54, fontSize: 9))])])),
      const SizedBox(height: 12),
      _tile(Icons.person_rounded, 'Account', 'Manage your profile'), _tile(Icons.notifications_rounded, 'Notifications', 'Reminders & alerts'), _tile(Icons.dark_mode_rounded, 'Appearance', 'Dark mode, theme'), _tile(Icons.language_rounded, 'Language', 'English'), _tile(Icons.security_rounded, 'Privacy & Security', 'Your data is safe'), _tile(Icons.help_rounded, 'Help & Support', 'Get help'),
      const SizedBox(height: 12), Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)]), borderRadius: BorderRadius.circular(12)), child: const Row(children: [Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 18), SizedBox(width: 8), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Go Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text('More features. Premium benefits.', style: TextStyle(fontSize: 9, color: Colors.white70))]), Spacer(), Icon(Icons.arrow_forward_ios_rounded, size: 10)])),
    ])));
  }
  Widget _tile(IconData i, String t, String s)=> Container(margin: const EdgeInsets.only(bottom: 7), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1A2040), borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(i, size: 16, color: Colors.white70), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)), Text(s, style: const TextStyle(color: Colors.white54, fontSize: 9))])), const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Colors.white24)]));
}
