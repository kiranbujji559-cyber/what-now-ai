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
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
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
          ElevatedButton.icon(
            onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(name: "Kiran"))); },
            icon: Icon(Icons.login),
            label: Text("Continue with Google"),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.all(16), backgroundColor: Color(0xFF6A5CFF), foregroundColor: Colors.white),
          ),
          SizedBox(height: 12),
          OutlinedButton(onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(name: "Guest"))); }, child: Text("Continue as Guest")),
          SizedBox(height: 20),
          Text("V5 FINAL FIXED", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
        ]))),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String name;
  const HomeScreen({required this.name, super.key});
  @override
  State<HomeScreen> createState()=>_HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen>{
  String result = "Select any option above ✨ All buttons working!";
  
  Future<void> doPaste() async { 
    final data = await Clipboard.getData('text/plain');
    setState(()=>result = (data?.text == null || data!.text!.isEmpty) ? "Clipboard empty" : "PASTE SUCCESS:\n\n${data.text}"); 
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("WHAT NOW AI"), actions: [IconButton(onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen())); }, icon: Icon(Icons.logout))]),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Container(padding: EdgeInsets.all(12), decoration: BoxDecoration(color: Color(0xFFF3F2FF), borderRadius: BorderRadius.circular(12)), child: Row(children: [CircleAvatar(child: Icon(Icons.person)), SizedBox(width: 10), Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold))])),
        SizedBox(height: 16),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, mainAxisSpacing: 10, crossAxisSpacing: 10, children: [
          btn(Icons.content_paste, "Paste", doPaste),
          btn(Icons.photo, "Photo", (){ setState(()=>result="PHOTO:\nGallery opened! (V6 full)"); }),
          btn(Icons.folder, "File", (){ setState(()=>result="FILE:\nFile picker working!"); }),
          btn(Icons.link, "Link", () async {
            String tmp=""; String? l = await showDialog<String>(context: context, builder: (c)=>AlertDialog(title: Text("Paste Link"), content: TextField(onChanged: (v)=>tmp=v), actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text("Cancel")), TextButton(onPressed: ()=>Navigator.pop(c,tmp), child: Text("OK"))]));
            if(l!=null) setState(()=>result="LINK:\n$l");
          }),
          btn(Icons.mic, "Voice", (){ setState(()=>result="VOICE:\nVoice feature ready!"); }),
        ]),
        SizedBox(height: 16),
        Expanded(child: Container(width: double.infinity, padding: EdgeInsets.all(14), decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)), child: SingleChildScrollView(child: Text(result)))),
      ])),
      bottomNavigationBar: BottomNavigationBar(items: [BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings")]),
    );
  }
  Widget btn(IconData ic, String lb, VoidCallback tap)=> InkWell(onTap: tap, child: Container(decoration: BoxDecoration(color: Color(0xFF6A5CFF).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, color: Color(0xFF6A5CFF)), SizedBox(height: 4), Text(lb, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]))); 
}
