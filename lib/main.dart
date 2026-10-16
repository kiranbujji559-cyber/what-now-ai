import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:clipboard/clipboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const WhatNowAI());
}

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (c, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          if (snap.hasData) return HomeScreen(user: snap.data!);
          return LoginScreen();
        },
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}
class _LoginScreenState extends State<LoginScreen> {
  bool loading = false;

  Future<void> signInGoogle() async {
    setState(()=>loading=true);
    try{
      final gUser = await GoogleSignIn().signIn();
      if(gUser==null){setState(()=>loading=false); return;}
      final gAuth = await gUser.authentication;
      final cred = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);
      await FirebaseAuth.instance.signInWithCredential(cred);
    }catch(e){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed: $e")));
    }
    setState(()=>loading=false);
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE8E6FF), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(child: Padding(padding: EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 40),
          Icon(Icons.bolt, size: 70, color: Color(0xFF6A5CFF)),
          SizedBox(height: 12),
          Text("WHAT NOW AI", textAlign: TextAlign.center, style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
          Text("Ask anything. Understand everything.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          Spacer(),
          if(loading) Center(child: CircularProgressIndicator()) else ElevatedButton.icon(
            onPressed: signInGoogle,
            icon: Icon(Icons.login),
            label: Text("Continue with Google"),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16), backgroundColor: Color(0xFF6A5CFF), foregroundColor: Colors.white),
          ),
          SizedBox(height: 12),
          OutlinedButton(onPressed: () async { setState(()=>loading=true); await FirebaseAuth.instance.signInAnonymously(); setState(()=>loading=false); }, child: Text("Continue as Guest")),
          SizedBox(height: 20),
          Text("V5 REAL BUILD", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ]))),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final User user;
  const HomeScreen({required this.user, super.key});
  @override
  State<HomeScreen> createState()=>_HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{
  String result = "Select any option above";
  final picker = ImagePicker();
  final recorder = AudioRecorder();
  bool isRec = false;

  Future<void> doPaste() async { String t = await FlutterClipboard.paste(); setState(()=>result = t.isEmpty ? "Clipboard empty" : "PASTE:\n$t"); }
  Future<void> doPhoto() async { final f = await picker.pickImage(source: ImageSource.gallery); if(f!=null) setState(()=>result = "PHOTO:\n${f.path}"); }
  Future<void> doFile() async { final r = await FilePicker.platform.pickFiles(); if(r!=null) setState(()=>result = "FILE:\n${r.files.first.name}"); }
  Future<void> doLink() async {
    String tmp=""; String? link = await showDialog<String>(context: context, builder: (c)=>AlertDialog(title: Text("Paste Link"), content: TextField(onChanged: (v)=>tmp=v, decoration: InputDecoration(hintText: "https://...")), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text("Cancel")), TextButton(onPressed: ()=>Navigator.pop(c,tmp), child: Text("OK"))]));
    if(link!=null && link.isNotEmpty) setState(()=>result="LINK:\n$link");
  }
  Future<void> doVoice() async {
    if(await recorder.hasPermission()){
      if(isRec){ String? p = await recorder.stop(); setState((){isRec=false; result="VOICE:\n$p";}); }
      else{ await recorder.start(AudioRecorderConfig(), path: "/tmp/voice.m4a"); setState((){isRec=true; result="Recording... tap again to stop";}); }
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("WHAT NOW AI"), actions: [IconButton(onPressed: ()=>FirebaseAuth.instance.signOut(), icon: Icon(Icons.logout))]),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFFF3F2FF), borderRadius: BorderRadius.circular(12)), child: Row(children: [CircleAvatar(backgroundImage: widget.user.photoURL!=null ? NetworkImage(widget.user.photoURL!) : null, child: widget.user.photoURL==null ? Icon(Icons.person) : null), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.user.displayName ?? "Guest"), Text(widget.user.email ?? "Anonymous", style: TextStyle(fontSize: 11, color: Colors.grey))])])),
        SizedBox(height: 16),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
          btn(Icons.content_paste, "Paste", doPaste),
          btn(Icons.photo, "Photo", doPhoto),
          btn(Icons.folder, "File", doFile),
          btn(Icons.link, "Link", doLink),
          btn(Icons.mic, isRec ? "Stop" : "Voice", doVoice, col: isRec ? Colors.red : Color(0xFF6A5CFF)),
        ]),
        SizedBox(height: 16),
        Expanded(child: Container(width: double.infinity, padding: EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: SingleChildScrollView(child: Text(result)))),
      ])),
      bottomNavigationBar: BottomNavigationBar(items: [BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")]),
    );
  }
  Widget btn(IconData ic, String lb, VoidCallback tap, {Color? col})=> InkWell(onTap: tap, child: Container(decoration: BoxDecoration(color: (col ?? Color(0xFF6A5CFF)).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, color: col ?? Color(0xFF6A5CFF)), SizedBox(height: 4), Text(lb, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]))); 
}
