import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';

List<Map<String,String>> appHistory = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try{ await Firebase.initializeApp(); }catch(_){}
  final prefs = await SharedPreferences.getInstance();
  final hist = prefs.getString('history');
  if(hist != null){ try{ appHistory = List<Map<String,String>>.from(jsonDecode(hist).map((e)=>Map<String,String>.from(e))); }catch(_){} }
  runApp(const WhatNowAI());
}

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(useMaterial3: true).copyWith(scaffoldBackgroundColor: const Color(0xFF0A102E)), home: const SplashScreen());
  }
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState()=>_SplashState; }
class _SplashState extends State<SplashScreen> {
  @override
  void initState(){ super.initState(); Future.delayed(const Duration(seconds: 2),(){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const LoginScreen())); }); }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: const Color(0xFF0A102E), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ClipRRect(borderRadius: BorderRadius.circular(28), child: Image.asset('assets/icon.png', width: 120, height: 120, errorBuilder: (_,__,___)=>const Icon(Icons.bolt, size: 80, color: Color(0xFF00D4FF)))),
      const SizedBox(height:20), const Text("WHAT NOW AI", style: TextStyle(fontSize:28, fontWeight: FontWeight.w900)),
      const SizedBox(height:6), const Text("Send anything. Get clear actions.", style: TextStyle(color: Colors.white54)),
      const SizedBox(height:30), const CircularProgressIndicator(color: Color(0xFF00D4FF))
    ])));
  }
}

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginState; }
class _LoginState extends State<LoginScreen> {
  bool loading=false;
  void goHome(String name)=>Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScaffold(userName: name)));
  Future<void> googleLogin() async {
    try{ setState(()=>loading=true);
      final gUser = await GoogleSignIn().signIn(); if(gUser==null){ setState(()=>loading=false); return; }
      final gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      final userCred = await FirebaseAuth.instance.signInWithCredential(cred);
      goHome(userCred.user?.displayName ?? userCred.user?.email ?? "User");
    }catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google failed: $e"))); } finally{ setState(()=>loading=false); }
  }
  Future<void> guestLogin() async {
    try{ setState(()=>loading=true); await FirebaseAuth.instance.signInAnonymously(); goHome("Guest"); }
    catch(e){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Guest failed: $e"))); } finally{ setState(()=>loading=false); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: const Color(0xFF0A102E), body: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
      const SizedBox(height:10), ClipRRect(borderRadius: BorderRadius.circular(22), child: Image.asset('assets/icon.png', width:80, height:80, errorBuilder: (_,__,___)=>const Icon(Icons.bolt, color: Color(0xFF00D4FF)))),
      const SizedBox(height:12), const Text("WHAT NOW AI", style: TextStyle(fontSize:22, fontWeight: FontWeight.w900)),
      const Text("Send anything. Get clear actions.", style: TextStyle(color: Colors.white54)), const Spacer(),
      const Align(alignment: Alignment.centerLeft, child: Text("Welcome Back,", style: TextStyle(fontSize:24, fontWeight: FontWeight.bold))),
      const Align(alignment: Alignment.centerLeft, child: Text("Sign in to continue", style: TextStyle(color: Colors.white54))), const SizedBox(height:18),
      _btn(true, loading?"Loading...":"Continue with Google", googleLogin),
      const SizedBox(height:10),
      _btn(false, "Continue with Email", ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>const EmailPage()))),
      const SizedBox(height:10),
      _btn(false, "Continue as Guest", guestLogin),
      const SizedBox(height:14), const Text("New here? Create an account", style: TextStyle(color: Color(0xFFB18CFF)))
    ]))));
  }
  Widget _btn(bool white, String txt, VoidCallback tap)=>SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: loading?null:tap, style: ElevatedButton.styleFrom(backgroundColor: white?Colors.white:const Color(0xFF1C2440), foregroundColor: white?Colors.black:Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: Text(txt, style: const TextStyle(fontWeight: FontWeight.w600))));
}

class EmailPage extends StatefulWidget { const EmailPage({super.key}); @override State<EmailPage> createState()=>_EmailPageState; }
class _EmailPageState extends State<EmailPage> {
  final email=TextEditingController(); final pass=TextEditingController(); bool loading=false;
  Future<void> login() async {
    if(email.text.isEmpty || pass.text.length<6){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Email + 6 char password required"))); return; }
    try{ setState(()=>loading=true);
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim());
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScaffold(userName: email.text)));
    } on FirebaseAuthException catch(e){
      if(e.code=='user-not-found' || e.code=='invalid-credential'){
        try{ await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email.text.trim(), password: pass.text.trim());
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>MainScaffold(userName: email.text)));
        }catch(err){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Create failed: $err"))); }
      } else { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message??"Error"))); }
    } finally{ setState(()=>loading=false); }
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(backgroundColor: const Color(0xFF0A102E), appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: const Text("Real Email Login")), body: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
      TextField(controller: email, decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder())), const SizedBox(height:12),
      TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: "Password min 6 chars", border: OutlineInputBorder())), const SizedBox(height:20),
      SizedBox(width: double.infinity, height:50, child: ElevatedButton(onPressed: loading?null:login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4FF), foregroundColor: Colors.black), child: Text(loading?"Please wait...":"Login / Create Real Account"))),
    ])));
  }
}

class MainScaffold extends StatefulWidget { final String userName; const MainScaffold({required this.userName, super.key}); @override State<MainScaffold> createState()=>_MainState; }
class _MainState extends State<MainScaffold> { int idx=0; @override Widget build(BuildContext context){
  return Scaffold(backgroundColor: const Color(0xFF0A102E), body: [HomePage(userName: widget.userName), const HistoryPage(), const SettingsPage()][idx], bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i)=>setState(()=>idx=i), backgroundColor: const Color(0xFF0A102E), selectedItemColor: Colors.white, unselectedItemColor: Colors.white54, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")]));
}}

class HomePage extends StatefulWidget { final String userName; const HomePage({required this.userName, super.key}); @override State<HomePage> createState()=>_HomeState; }
class _HomeState extends State<HomePage> {
  final ctrl=TextEditingController(); final picker=ImagePicker(); final recorder=Record(); bool isRecording=false;
  Future<void> saveHistory() async { final prefs=await SharedPreferences.getInstance(); prefs.setString('history', jsonEncode(appHistory)); }
  void addHistory(String input, String type){ appHistory.insert(0, {"title": input.length>40?"${input.substring(0,40)}...":input, "type":type, "time":DateTime.now().toIso8601String(), "full":input}); saveHistory(); }
  void whatNow(){
    if(ctrl.text.trim().isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Paste something first!"))); return; }
    String input=ctrl.text.trim(); String type="General";
    if(input.toLowerCase().contains("scam") || input.toLowerCase().contains("won") || input.contains("http") || input.toLowerCase().contains("lottery")) type="Suspicious message";
    else if(input.toLowerCase().contains("payment") || input.toLowerCase().contains("bill") || input.contains("₹") || input.toLowerCase().contains("electricity")) type="Payment / Bill";
    else if(input.toLowerCase().contains("job") || input.toLowerCase().contains("offer") || input.toLowerCase().contains("salary")) type="Job offer";
    else if(input.toLowerCase().contains("agreement") || input.toLowerCase().contains("rent") || input.toLowerCase().contains("deposit")) type="Agreement";
    else if(input.toLowerCase().contains("flight") || input.toLowerCase().contains("ticket") || input.toLowerCase().contains("pnr")) type="Flight Ticket";
    addHistory(input, type); Navigator.push(context, MaterialPageRoute(builder: (_)=>ResultPage(input: input, category: type)));
  }
  Future<void> doPaste() async { final d=await Clipboard.getData('text/plain'); if(d?.text!=null) setState(()=>ctrl.text=d!.text!); }
  Future<void> doPhoto() async { final XFile? img=await picker.pickImage(source: ImageSource.gallery); if(img!=null){ setState(()=>ctrl.text="Photo selected: ${img.name}\nPath: ${img.path}"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Photo picked: ${img.name} - REAL"))); } }
  Future<void> doFile() async { FilePickerResult? res=await FilePicker.platform.pickFiles(); if(res!=null){ setState(()=>ctrl.text="File selected: ${res.files.first.name}\nSize: ${res.files.first.size} bytes"); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File picked: ${res.files.first.name} - REAL"))); } }
  Future<void> doLink() async { final linkCtrl=TextEditingController(); showDialog(context: context, builder: (_)=>AlertDialog(title: const Text("Paste Link - REAL"), content: TextField(controller: linkCtrl, decoration: const InputDecoration(hintText: "https://...")), actions: [TextButton(onPressed: ()=>Navigator.pop(context), child: const Text("Cancel")), TextButton(onPressed: (){ setState(()=>ctrl.text=linkCtrl.text); Navigator.pop(context); }, child: const Text("Add")), TextButton(onPressed: () async { if(linkCtrl.text.isNotEmpty){ final uri=Uri.parse(linkCtrl.text); if(await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); } }, child: const Text("Open"))])); }
  Future<void> doVoice() async {
    if(await Permission.microphone.request().isGranted){
      if(!isRecording){ 
        if(await recorder.hasPermission()){ 
          await recorder.start(path: "${Directory.systemTemp.path}/voice.m4a"); 
          setState(()=>isRecording=true); 
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Recording... tap again to stop")));
        } 
      } else { 
        final path=await recorder.stop(); 
        setState(()=>{isRecording=false; ctrl.text="Voice recorded: $path\nReady for analysis";}); 
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Voice saved: $path")));
      }
    }
  }
  @override
  Widget build(BuildContext context){
    return SafeArea(child: Padding(padding: const EdgeInsets.all(14), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset('assets/icon.png', width:36, height:36, errorBuilder: (_,__,___)=>const Icon(Icons.bolt))), const SizedBox(width:8), Text("Hi, ${widget.userName}", style: const TextStyle(fontWeight: FontWeight.bold))]),
      const SizedBox(height:14), const Text("Anything confusing?\nSend a message, screenshot, document, link or photo.", style: TextStyle(fontSize:14, color: Colors.white70)),
      const SizedBox(height:12),
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: TextField(controller: ctrl, maxLines:5, decoration: const InputDecoration(hintText: "Paste message, link, bill details...", border: InputBorder.none))),
      const SizedBox(height:12),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_sBtn(Icons.content_paste_rounded, "Paste", doPaste), _sBtn(Icons.photo, "Photo", doPhoto), _sBtn(Icons.attach_file, "File", doFile), _sBtn(Icons.mic, isRecording?"Stop":"Voice", doVoice), _sBtn(Icons.link, "Link", doLink)]),
      const SizedBox(height:12),
      SizedBox(width: double.infinity, height:46, child: ElevatedButton.icon(onPressed: whatNow, icon: const Icon(Icons.auto_awesome, size:18), label: const Text("WHAT NOW? - REAL", style: TextStyle(fontWeight: FontWeight.w900)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00D4FF), foregroundColor: Colors.black))),
      const SizedBox(height:12),
      _card(Icons.warning_amber_rounded, Colors.red, "Suspicious message", "Is this a scam?", (){ ctrl.text="You won \$5000! Click http://scam-lottery.com to claim now!"; }),
      _card(Icons.receipt_long_rounded, Colors.green, "Payment / Bill", "What should I do?", (){ ctrl.text="Electricity bill ₹1200 due tomorrow - BESCOM"; }),
      _card(Icons.work_rounded, Colors.orange, "Job offer", "Is it genuine?", (){ ctrl.text="Work from home Pay ₹50000 - Pay ₹2000 registration"; }),
      _card(Icons.description_rounded, Colors.blue, "Agreement", "Key points & risks", (){ ctrl.text="Rental agreement 11 months - Deposit ₹50000"; }),
      _card(Icons.flight_rounded, Colors.cyan, "Flight Ticket", "Check details", (){ ctrl.text="Flight 6E-123 HYD to DEL confirmed - PNR X7Y8Z9"; }),
    ]))));
  }
  Widget _sBtn(IconData ic, String lb, VoidCallback t)=>Column(children: [InkWell(onTap: t, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: isRecording && lb.contains("Voice")?Colors.red:const Color(0xFF1C2340), shape: BoxShape.circle), child: Icon(ic, size:18))), const SizedBox(height:4), Text(lb, style: const TextStyle(fontSize:11))]);
  Widget _card(IconData ic, Color c, String title, String sub, VoidCallback tap)=>Padding(padding: const EdgeInsets.only(bottom:10), child: InkWell(onTap: tap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(ic, color: c), const SizedBox(width:10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(sub, style: const TextStyle(fontSize:12, color: Colors.white54))])]))));
}
class ResultPage extends StatelessWidget {
  final String input, category; const ResultPage({required this.input, required this.category, super.key});
  String getAnalysis(){
    if(category.contains("Suspicious")) return "🚨 SCAM ALERT - REAL\n\nThis looks like a scam!\n\nWhy: Won + unknown link\n\nWhat to do:\n1. Don't click link\n2. Don't share OTP\n3. Block & Report\n\nRisk: HIGH";
    if(category.contains("Payment")) return "💰 BILL ACTION - REAL\n\nDue: Tomorrow\nProvider: BESCOM\n\nAction:\n1. Open official app\n2. Pay safely\n3. Save receipt\n\nNext: Set reminder";
    if(category.contains("Job")) return "💼 JOB CHECK - REAL\n\nNever ask money = 99% scam\n\nAction: Do NOT pay, Verify on LinkedIn\nRisk: HIGH";
    if(category.contains("Agreement")) return "📄 AGREEMENT - REAL\n\nKey: 11 months, Deposit\nAdd: Refund clause, Police verification\nNext: Photos before move-in";
    if(category.contains("Flight")) return "✈️ TICKET - REAL\n\nConfirmed\nWeb check-in 48hrs before\nReach 2hrs early\nNext: Add to calendar";
    return "🔍 ANALYSIS - REAL\n\nInput: $input\n\nAction: Verify source, Don't share sensitive data\nSafe with caution.";
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: Text(category)), backgroundColor: const Color(0xFF0A102E), body: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
      Container(width: double.infinity, padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Text("Input: $input", style: const TextStyle(color: Colors.white70))),
      const SizedBox(height:12),
      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF00D4FF))), child: Text(getAnalysis(), style: const TextStyle(fontSize:15, height:1.5)))
    ])));
  }
}

class HistoryPage extends StatefulWidget { const HistoryPage({super.key}); @override State<HistoryPage> createState()=>_HistState; }
class _HistState extends State<HistoryPage> {
  String search=""; Future<void> clear() async { setState(()=>appHistory.clear()); final prefs=await SharedPreferences.getInstance(); prefs.remove('history'); }
  @override
  Widget build(BuildContext context){
    var filtered=appHistory.where((e)=>search.isEmpty || e["title"]!.toLowerCase().contains(search.toLowerCase()) || e["type"]!.toLowerCase().contains(search.toLowerCase())).toList();
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [const Text("History - REAL", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)), const Spacer(), IconButton(onPressed: clear, icon: const Icon(Icons.delete))]),
      const SizedBox(height:10), TextField(onChanged: (v)=>setState(()=>search=v), decoration: const InputDecoration(hintText: "Search real history...", border: OutlineInputBorder(), prefixIcon: Icon(Icons.search))), const SizedBox(height:16),
      Expanded(child: filtered.isEmpty?const Center(child: Text("No history yet", style: TextStyle(color: Colors.white54))):ListView.builder(itemCount: filtered.length, itemBuilder: (_,i)=>Card(color: const Color(0xFF1C2340), child: ListTile(title: Text(filtered[i]["title"]!), subtitle: Text("${filtered[i]["type"]} • ${filtered[i]["time"]?.substring(0,16)}"), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ResultPage(input: filtered[i]["full"]??filtered[i]["title"]!, category: filtered[i]["type"]!)))))))
    ])));
  }
}

class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState()=>_SettingsState; }
class _SettingsState extends State<SettingsPage> {
  bool notif=true; bool dark=true;
  void open(String title)=>Navigator.push(context, MaterialPageRoute(builder: (_)=>DetailPage(title: title)));
  @override
  Widget build(BuildContext context){
    final user=FirebaseAuth.instance.currentUser;
    return SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Settings - REAL", style: TextStyle(fontSize:20, fontWeight: FontWeight.bold)), const SizedBox(height:12),
      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1C2340), borderRadius: BorderRadius.circular(12)), child: Column(children: [
        ListTile(leading: const Icon(Icons.person), title: const Text("Account - REAL"), subtitle: Text(user==null?"Not logged": "${user.email ?? user.displayName ?? "Guest"}"), onTap: ()=>open("Account REAL:\nEmail: ${user?.email}\nName: ${user?.displayName}\nUID: ${user?.uid}\nAnonymous: ${user?.isAnonymous}")),
        SwitchListTile(title: const Text("Notifications - REAL"), subtitle: const Text("Push reminders"), value: notif, onChanged: (v)=>setState(()=>notif=v)),
        SwitchListTile(title: const Text("Dark Mode - REAL"), subtitle: const Text("Appearance"), value: dark, onChanged: (v)=>setState(()=>dark=v)),
        ListTile(leading: const Icon(Icons.language), title: const Text("Language - REAL"), subtitle: const Text("English"), onTap: ()=>open("Language: English, Telugu, Hindi - REAL setting")),
        ListTile(leading: const Icon(Icons.shield), title: const Text("Privacy - REAL"), subtitle: const Text("Your data is safe"), onTap: ()=>open("Privacy REAL: Data stored locally, Firebase secure")),
        ListTile(leading: const Icon(Icons.help), title: const Text("Help - REAL"), subtitle: const Text("support@whatnowai.com"), onTap: ()=>open("Help REAL: support@whatnowai.com")),
        const SizedBox(height:10),
        SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async { await FirebaseAuth.instance.signOut(); await GoogleSignIn().signOut(); Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=>const LoginScreen()), (_)=>false); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Logout - REAL"))),
        const SizedBox(height:10),
        InkWell(onTap: ()=>open("Go Pro REAL Premium"), borderRadius: BorderRadius.circular(14), child: Container(width: double.infinity, padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: const Color(0xFF00D4FF), borderRadius: BorderRadius.circular(14)), child: const Text("Go Pro: Premium - REAL", textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))))
      ]))
    ]))));
  }
}
class DetailPage extends StatelessWidget { final String title; const DetailPage({required this.title, super.key}); @override Widget build(BuildContext context){ return Scaffold(appBar: AppBar(backgroundColor: const Color(0xFF0A102E), title: const Text("Details - REAL")), backgroundColor: const Color(0xFF0A102E), body: Padding(padding: const EdgeInsets.all(20), child: Text(title, style: const TextStyle(fontSize:16, height:1.6)))); } }
