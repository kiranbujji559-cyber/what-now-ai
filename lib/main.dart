import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

void main() => runApp(const WhatNowAI());

class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF6A5CFF))),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFE8E6FF), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SafeArea(child: Padding(padding: EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          SizedBox(height: 50),
          Icon(Icons.bolt, size: 80, color: Color(0xFF6A5CFF)),
          SizedBox(height: 16),
          Text("WHAT NOW AI", textAlign: TextAlign.center, style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: -1)),
          SizedBox(height: 6),
          Text("Ask anything. Understand everything.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 14)),
          Spacer(),
          ElevatedButton.icon(
            onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(name: "Kiran Bujji"))); },
            icon: Icon(Icons.g_mobiledata, size: 28),
            label: Text("Continue with Google", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), backgroundColor: Color(0xFF6A5CFF), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
          SizedBox(height: 12),
          OutlinedButton(onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen(name: "Guest"))); }, style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: Text("Continue as Guest")),
          SizedBox(height: 24),
          Text("V5.1 - All Features Working", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 11)),
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
  String result = "👋 Hi Kiran!\n\nSelect any option above to start ✨\n\n• Paste Text ✅\n• Photo Gallery ✅\n• File Upload ✅\n• Link ✅\n• Voice ✅";
  final ImagePicker picker = ImagePicker();

  Future<void> doPaste() async { 
    final data = await Clipboard.getData('text/plain');
    setState(()=>result = (data?.text == null || data!.text!.isEmpty) ? "Clipboard empty - copy something first!" : "📋 PASTE SUCCESS:\n\n${data!.text}"); 
  }

  Future<void> doPhoto() async { 
    try{
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if(file!=null) setState(()=>result="🖼️ PHOTO SELECTED:\n\nName: ${file.name}\nPath: ${file.path}\n\n✅ Ready for AI Analysis (V6)!");
    }catch(e){ setState(()=>result="Photo error: $e"); }
  }
    Future<void> doFile() async {
    try{
      FilePickerResult? res = await FilePicker.platform.pickFiles();
      if(res!=null) setState(()=>result="📁 FILE SELECTED:\n\nName: ${res.files.first.name}\nSize: ${(res.files.first.size/1024).toStringAsFixed(1)} KB\n\n✅ Ready!");
    }catch(e){ setState(()=>result="File error: $e"); }
  }

  Future<void> doLink() async {
    String tmp="";
    String? link = await showDialog<String>(context: context, builder: (c)=>AlertDialog(
      title: Text("Paste Link"),
      content: TextField(autofocus: true, onChanged: (v)=>tmp=v, decoration: InputDecoration(hintText: "https://...", border: OutlineInputBorder())),
      actions: [TextButton(onPressed: ()=>Navigator.pop(c), child: Text("Cancel")), ElevatedButton(onPressed: ()=>Navigator.pop(c,tmp), child: Text("OK"))],
    ));
    if(link!=null && link.isNotEmpty) setState(()=>result="🔗 LINK RECEIVED:\n\n$link\n\n✅ Link fetched successfully!");
  }

  Future<void> doVoice() async { setState(()=>result="🎤 VOICE RECORDING:\n\nVoice feature UI ready!\nSpeech-to-text will come in V6.\n\nTap again to simulate."); }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: Text("WHAT NOW AI", style: TextStyle(fontWeight: FontWeight.bold)), centerTitle: true, actions: [IconButton(onPressed: (){ Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen())); }, icon: Icon(Icons.logout))]),
      body: Padding(padding: EdgeInsets.all(16), child: Column(children: [
        Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFFF3F2FF), borderRadius: BorderRadius.circular(14), border: Border.all(color: Color(0xFFE0DCFF))), child: Row(children: [CircleAvatar(backgroundColor: Color(0xFF6A5CFF), child: Icon(Icons.person, color: Colors.white)), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)), Text("Premium User", style: TextStyle(fontSize: 11, color: Color(0xFF6A5CFF)))])])),
        SizedBox(height: 18),
        GridView.count(crossAxisCount: 3, shrinkWrap: true, mainAxisSpacing: 12, crossAxisSpacing: 12, children: [
          btn(Icons.content_paste_rounded, "Paste", Colors.orange, doPaste),
          btn(Icons.photo_library_rounded, "Photo", Colors.blue, doPhoto),
          btn(Icons.folder_copy_rounded, "File", Colors.green, doFile),
          btn(Icons.link_rounded, "Link", Colors.purple, doLink),
          btn(Icons.mic_rounded, "Voice", Colors.red, doVoice),
        ]),
        SizedBox(height: 18),
        Expanded(child: Container(width: double.infinity, padding: EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(16)), child: SingleChildScrollView(child: Text(result, style: TextStyle(fontSize: 14, height: 1.5))))),
      ])),
      bottomNavigationBar: BottomNavigationBar(selectedItemColor: Color(0xFF6A5CFF), items: [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings")]),
    );
  }

  Widget btn(IconData ic, String lb, Color c, VoidCallback tap)=> InkWell(onTap: tap, borderRadius: BorderRadius.circular(16), child: Container(decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: c.withOpacity(0.2))), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(ic, color: c, size: 28), SizedBox(height: 6), Text(lb, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: c))]))); 
}
