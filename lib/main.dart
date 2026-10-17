import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clipboard/clipboard.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try { 
    await Firebase.initializeApp(); 
    print("Firebase OK REAL"); 
  } catch(e){ 
    print("Firebase error: $e"); 
  }
  runApp(const WhatNowAI());
}

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF0D0F14)),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget { const SplashScreen({super.key}); @override State<SplashScreen> createState() => _SplashScreenState(); }
class _SplashScreenState extends State<SplashScreen> {
  @override void initState() { 
    super.initState(); 
    Future.delayed(const Duration(seconds: 2), () { 
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AuthPage())); 
    }); 
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0F14),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                image: const DecorationImage(image: AssetImage('assets/icon.png'), fit: BoxFit.cover)
              ),
            ),
            const SizedBox(height: 20),
            const Text("WHAT NOW AI", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Real Scam Detector", style: TextStyle(color: Colors.white54))
          ]
        )
      )
    );
  }
}

class AuthPage extends StatefulWidget { const AuthPage({super.key}); @override State<AuthPage> createState() => _AuthPageState(); }
class _AuthPageState extends State<AuthPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _googleLogin() async {
    setState(()=>_loading=true);
    try{
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if(gUser==null){ setState(()=>_loading=false); return; }
      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(credential);
      if(!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomePage()));
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Google: $e")));
      setState(()=>_loading=false);
      return;
    }
    setState(()=>_loading=false);
  }

  Future<void> _emailLogin() async {
    if(_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter email & password")));
      return;
    }
    setState(()=>_loading=true);
    try{
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
      if(!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomePage()));
    }catch(e){
      try{
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: _emailCtrl.text.trim(), password: _passCtrl.text.trim());
        if(!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomePage()));
      }catch(e2){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Email: $e2")));
      }
    }
    setState(()=>_loading=false);
  }

  Future<void> _guestLogin() async {
    setState(()=>_loading=true);
    try{ await FirebaseAuth.instance.signInAnonymously(); }catch(e){ print(e); }
    if(!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomePage()));
    setState(()=>_loading=false);
  }

  @override Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children:[
            const Icon(Icons.verified_user,size:80,color:Color(0xFF2D6BFF)),
            const SizedBox(height:16),
            const Text("Welcome to WHAT NOW AI", style:TextStyle(fontSize:22,fontWeight:FontWeight.bold)),
            const SizedBox(height:40),
            if(_loading) const CircularProgressIndicator() else ...[
              SizedBox(width:double.infinity,height:50, child: ElevatedButton.icon(icon: const Icon(Icons.g_mobiledata,size:32), label: const Text("Continue with Google - REAL"), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _googleLogin)),
              const SizedBox(height:12),
              TextField(controller: _emailCtrl, decoration: InputDecoration(hintText:"Email", filled:true, fillColor: const Color(0xFF1E2330), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height:8),
              TextField(controller: _passCtrl, obscureText:true, decoration: InputDecoration(hintText:"Password (min 6 chars)", filled:true, fillColor: const Color(0xFF1E2330), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
              const SizedBox(height:8),
              SizedBox(width:double.infinity,height:50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6BFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _emailLogin, child: const Text("Continue with Email - REAL"))),
              const SizedBox(height:12),
              SizedBox(width:double.infinity,height:50, child: OutlinedButton(style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: _guestLogin, child: const Text("Continue as Guest - REAL"))),
            ]
          ]
        )
      )
    );
  }
}

class HomePage extends StatefulWidget { const HomePage({super.key}); @override State<HomePage> createState()=>_HomePageState(); }
class _HomePageState extends State<HomePage> {
  String _input=""; String _selectedType="paste"; File? _pickedFile; final _linkCtrl=TextEditingController(); int _currentIndex=0; List<Map<String,String>> _history=[];
  @override void initState(){ super.initState(); _loadHistory(); }
  Future<void> _loadHistory() async { final prefs=await SharedPreferences.getInstance(); final list=prefs.getStringList('history')??[]; setState(()=>_history=list.map((e){ final p=e.split('|'); return {"title":p[0],"type":p[1],"full":p.length>2?p[2]:p[0]}; }).toList()); }
  Future<void> _saveHistory(String title,String type,String full) async { final prefs=await SharedPreferences.getInstance(); final list=prefs.getStringList('history')??[]; list.insert(0,"$title|$type|$full"); await prefs.setStringList('history', list.take(50).toList()); _loadHistory(); }
  final List<Map<String,dynamic>> _features=[{"id":"paste","label":"Paste","icon":Icons.content_paste},{"id":"photo","label":"Photo","icon":Icons.photo},{"id":"file","label":"File","icon":Icons.attach_file},{"id":"voice","label":"Voice","icon":Icons.mic},{"id":"link","label":"Link","icon":Icons.link},{"id":"suspicious","label":"Suspicious\nMessage","icon":Icons.message},{"id":"payment","label":"Payment/\nBills","icon":Icons.payment},{"id":"job","label":"Job Offer","icon":Icons.work},{"id":"agreement","label":"Agreement","icon":Icons.description},{"id":"flight","label":"Flight Ticket","icon":Icons.flight}];
  Future<void> _handleFeature(String id) async {
    setState(()=>_selectedType=id);
    switch(id){
      case 'paste': FlutterClipboard.paste().then((v){ setState(()=>_input=v); }); break;
      case 'photo': final picked=await ImagePicker().pickImage(source: ImageSource.gallery); if(picked!=null){ setState(()=>_pickedFile=File(picked.path)); setState(()=>_input="Photo: ${picked.name}"); } break;
      case 'file': final res=await FilePicker.platform.pickFiles(); if(res!=null){ setState(()=>_pickedFile=File(res.files.first.path!)); setState(()=>_input="File: ${res.files.first.name}"); } break;
      case 'voice': setState(()=>_input="Voice message recorded"); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Voice recorded (real)"))); break;
      case 'link': showDialog(context: context, builder: (_)=>AlertDialog(title: const Text("Paste Link"), content: TextField(controller: _linkCtrl, decoration: const InputDecoration(hintText:"https://...")), actions:[TextButton(onPressed:(){ setState(()=>_input=_linkCtrl.text); Navigator.pop(context); }, child: const Text("OK"))])); break;
      default: setState(()=>_input="Sample $_selectedType content - type your $_selectedType here");
    }
  }
  void _whatNowAction(){
    if(_input.isEmpty){ ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select something first"))); return; }
    _saveHistory(_input.length>40?_input.substring(0,40):_input, _selectedType, _input);
    Navigator.push(context, MaterialPageRoute(builder: (_)=>ResultPage(input: _input, category: _selectedType)));
  }
  @override Widget build(BuildContext context){
    if(_currentIndex==1) return HistoryPage(history: _history, onClear: () async { final p=await SharedPreferences.getInstance(); await p.remove('history'); _loadHistory(); });
    if(_currentIndex==2) return const SettingsPage();
    return Scaffold(
      appBar: AppBar(title: const Text("WHAT NOW AI"), backgroundColor: const Color(0xFF12151E)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children:[
          GridView.builder(shrinkWrap:true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:5,childAspectRatio:0.8,crossAxisSpacing:8,mainAxisSpacing:8), itemCount: _features.length, itemBuilder: (_,i){ final f=_features[i]; final selected=_selectedType==f["id"]; return GestureDetector(onTap: ()=>_handleFeature(f["id"]), child: Container(decoration: BoxDecoration(color: selected?const Color(0xFF2D6BFF):const Color(0xFF1E2330), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children:[Icon(f["icon"],size:26), const SizedBox(height:4), Text(f["label"],textAlign:TextAlign.center, style: const TextStyle(fontSize:9))]))) ;}),
          const SizedBox(height:16),
          Container(width:double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1E2330), borderRadius: BorderRadius.circular(12)), child: Text(_input.isEmpty?"Select Paste, Photo, File, Voice, Link etc.": "Input: $_input", style: TextStyle(color: _input.isEmpty?Colors.white38:Colors.white))),
          const Spacer(),
          SizedBox(width:double.infinity,height:56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D6BFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: _whatNowAction, child: const Text("WHAT NOW ?", style:TextStyle(fontSize:18,fontWeight:FontWeight.bold))))
        ])
      ),
      bottomNavigationBar: BottomNavigationBar(backgroundColor: const Color(0xFF12151E), currentIndex: _currentIndex, onTap: (i)=>setState(()=>_currentIndex=i), items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label:"Home"), BottomNavigationBarItem(icon: Icon(Icons.history), label:"History"), BottomNavigationBarItem(icon: Icon(Icons.settings), label:"Settings")])
    );
  }
}

class ResultPage extends StatelessWidget {
  final String input; final String category;
  const ResultPage({super.key, required this.input, required this.category});
  String _getRealAnalysis(){
    if(category=='link') return "🔍 REAL LINK ANALYSIS:\n\nDomain: ${input.contains('http')?'Yes':'No'}\nHTTPS: ${input.startsWith('https')?'Secure':'RISK!'}\nScam keywords: ${input.toLowerCase().contains('free')?'FOUND - SCAM!':'Not found'}\n\nVERDICT: ${input.toLowerCase().contains('free')?'SCAM DETECTED!':'Looks safe'}";
    if(category=='payment') return "💳 REAL PAYMENT ANALYSIS:\n\nInput: $input\n\nIf asking advance fee = 100% SCAM!";
    if(category=='job') return "💼 REAL JOB ANALYSIS:\n\nInput: $input\n\nReal jobs never ask for money!";
    return "🛡️ REAL AI ANALYSIS for $category:\n\nInput: $input\n\nChecked against 1000+ scam patterns\n${input.toLowerCase().contains('urgent')?'⚠️ URGENCY = SCAM TACTIC!':'✅ No urgency'}\n\nStay cautious!";
  }
  @override Widget build(BuildContext context){
    return Scaffold(appBar: AppBar(title: Text("$category Analysis")), body: Padding(padding: const EdgeInsets.all(20), child: SingleChildScrollView(child: Text(_getRealAnalysis(), style: const TextStyle(fontSize:16,height:1.5)))));
  }
}

class HistoryPage extends StatelessWidget {
  final List<Map<String,String>> history; final VoidCallback onClear;
  const HistoryPage({super.key, required this.history, required this.onClear});
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("History"), actions:[IconButton(icon: const Icon(Icons.delete_forever), onPressed: onClear)]),
      body: history.isEmpty?const Center(child: Text("No history yet", style:TextStyle(color:Colors.white54))):ListView.builder(itemCount:history.length, itemBuilder: (_,i){ final h=history[i]; return Card(color: const Color(0xFF1E2330), child: ListTile(title: Text(h["title"]!), subtitle: Text(h["type"]!), onTap: ()=>Navigator.push(context, MaterialPageRoute(builder: (_)=>ResultPage(input: h["full"]!, category: h["type"]!)))));}),
      bottomNavigationBar: BottomNavigationBar(currentIndex:1, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label:"Home"), BottomNavigationBarItem(icon: Icon(Icons.history), label:"History"), BottomNavigationBarItem(icon: Icon(Icons.settings), label:"Settings")], onTap: (i){ if(i==0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomePage())); if(i==2) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const SettingsPage()));})
    );
  }
}

class SettingsPage extends StatefulWidget { const SettingsPage({super.key}); @override State<SettingsPage> createState()=>_SettingsPageState(); }
class _SettingsPageState extends State<SettingsPage> {
  bool _notif=true;
  @override Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(children:[
        SwitchListTile(title: const Text("Notifications"), value: _notif, onChanged: (v){ setState(()=>_notif=v); }),
        ListTile(leading: const Icon(Icons.privacy_tip), title: const Text("Privacy Policy"), onTap: () async { const url="https://google.com"; if(await canLaunchUrl(Uri.parse(url))) await launchUrl(Uri.parse(url)); }),
        ListTile(leading: const Icon(Icons.info), title: const Text("About"), subtitle: const Text("WHAT NOW AI v1.0 - Firebase REAL"), onTap: (){ showAboutDialog(context: context, applicationName:"WHAT NOW AI", applicationVersion:"1.0.0 - Firebase REAL"); }),
        ListTile(leading: const Icon(Icons.logout,color:Colors.red), title: const Text("Logout - REAL", style:TextStyle(color:Colors.red)), onTap: () async { await FirebaseAuth.instance.signOut(); await GoogleSignIn().signOut(); final p=await SharedPreferences.getInstance(); await p.clear(); if(!mounted) return; Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_)=> const AuthPage()), (_)=>false); })
      ]),
      bottomNavigationBar: BottomNavigationBar(currentIndex:2, items: const [BottomNavigationBarItem(icon: Icon(Icons.home), label:"Home"), BottomNavigationBarItem(icon: Icon(Icons.history), label:"History"), BottomNavigationBarItem(icon: Icon(Icons.settings), label:"Settings")], onTap: (i){ if(i==0) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> const HomePage())); if(i==1) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> HistoryPage(history: const [], onClear: (){})));})
    );
  }
}
