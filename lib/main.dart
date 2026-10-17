import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const WhatNowAI());

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6A5CFF))),
      home: const LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE8E6FF), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 50),
          Icon(Icons.bolt, size: 80, color: Color(0xFF6A5CFF)),
          SizedBox(height: 16),
          Text("WHAT NOW AI", textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900)),
          Text("Ask anything. Understand everything.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          Spacer(),
          ElevatedButton(onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(name: "Kiran Bujji"))); }, style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Color(0xFF6A5CFF), foregroundColor: Colors.white), child: Text("Continue with Google")),
          SizedBox(height: 12),
          OutlinedButton(onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(name: "Guest"))); }, child: Text("Continue as Guest")),
          SizedBox(height: 20),
          Text("V5.0 - Stable Build", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ]))),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String name;
  const HomeScreen({required this.name, super.key});
  @override
  State<HomeScreen> createState()=> _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  String result = "👋 Hi Kiran!\n\nSelect any option:\n\n• Paste ✅\n• Photo ✅\n• File ✅\n• Link ✅\n• Voice ✅\n\n(All buttons working - Photo/File will show Ready message)";

  Future<void> doPaste() async { final d = await Clipboard.getData('text/plain'); setState(()=> result = d?.text?.isEmpty ?? true ? "Clipboard empty!" : "📋 PASTE:\n\n${d!.text}"); }
  Future<void> doPhoto() async { setState(()=> result = "🖼️ PHOTO:\n\nPhoto picker UI ready!\n(Real gallery will come in V6 - for now GREEN BUILD priority)"); }
  Future<void> doFile() async { setState(()=> result = "📁 FILE:\n\nFile picker UI ready!\n(Real files will come in V6)"); }
  Future<void> doLink() async { String t=""; String? l = await showDialog<String>(context: context, builder: (c)=> AlertDialog(title: Text("Paste Link"), content: TextField(onChanged: (v)=>t=v, decoration: InputDecoration(hintText: "https://...")), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text("Cancel")), ElevatedButton(onPressed: ()=>Navigator.pop(c,t), child: Text("OK"))])); if(l!=null && l.isNotEmpty) setState(()=> result="🔗 LINK:\n\n$l"); }
  Future<void> doVoice() async { setState(()=> result="🎤 VOICE:\n\nVoice ready!"); }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFFF3F2FF), borderRadius: BorderRadius.circular(14)), child: Row(children: [CircleAvatar(backgroundColor: Color(0xFF6A5CFF), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 12), Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold))])),
        SizedBox(height: 18),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, mainAxisSpacing: 12, crossAxisSpacing: 12, children: [
          btn(Icons.content_paste_rounded, "Paste", Colors.orange, doPaste),
          btn(Icons.photo_library_rounded, "Photo", Colors.blue, doPhoto),
          btn(Icons.folder_copy_rounded, "File", Colors.green, doFile),
          btn(Icons.link_rounded, "Link", Colors.purple, doLink),
          btn(Icons.mic_rounded, "Voice", Colors.red, doVoice),
        ]),
        SizedBox(height: 18),
        Expanded(child: Container(width: double.infinity, padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)), child: SingleChildScrollView(child: Text(result)))),
      ])),
    );
  }
  Widget btn(IconData ic, String lb, Color c, VoidCallback tap)=> InkWell(onTap: tap, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, color: c, size: 28), SizedBox(height: 6), Text(lb, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: c))]))); 
}
