import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SplashScreen()));
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Duration(milliseconds: 900))..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.95, end: 1.1).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    Future.delayed(Duration(seconds: 2), () {
      if(mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainTabs()));
    });
  }
  @override
  void dispose(){ _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF070B1F),
      body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ScaleTransition(scale: _scale, child: Container(width: 110, height: 110, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7B2FFF), Color(0xFFFF2D95)]), borderRadius: BorderRadius.circular(26), boxShadow: [BoxShadow(color: Color(0xFF7B2FFF).withOpacity(0.6), blurRadius: 30)]), child: Icon(Icons.chat_bubble_rounded, size: 55, color: Colors.white))),
        SizedBox(height: 20), Text("WHAT NOW AI", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
        SizedBox(height: 6), Text("Send anything. Get clear actions.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white70)),
      ])),
    );
  }
}

class MainTabs extends StatefulWidget { @override _MainTabsState createState() => _MainTabsState(); }
class _MainTabsState extends State<MainTabs> { int idx = 0; @override Widget build(BuildContext context) { return Scaffold(backgroundColor: Color(0xFF070B1F), body: [HomeScreen(), HistoryScreen(), SettingsScreen()][idx], bottomNavigationBar: BottomNavigationBar(currentIndex: idx, onTap: (i){setState(()=> idx=i);}, backgroundColor: Color(0xFF10152F), selectedItemColor: Color(0xFF7B5CFF), unselectedItemColor: Colors.white38, items: [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: "History"), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: "Settings")])); } }

// --- HOME, RESULT, HISTORY, SETTINGS --- (nee code same - touching work)
class HomeScreen extends StatefulWidget { @override _HomeScreenState createState() => _HomeScreenState(); }
class _HomeScreenState extends State<HomeScreen> {
  TextEditingController ctrl = TextEditingController();
  void analyse(){ if(ctrl.text.trim().isEmpty){ ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paste something first!"))); return; } Navigator.push(context, MaterialPageRoute(builder: (_) => ResultScreen(text: ctrl.text))); }
  void paste() async { var d = await Clipboard.getData("text/plain"); if(d!=null && d.text!=null) setState(()=> ctrl.text=d.text!); }
  @override Widget build(BuildContext context) => SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7B2FFF)]), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.chat_bubble_rounded, size: 18, color: Colors.white)), SizedBox(width: 8), Text("WHAT NOW AI", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Spacer(), GestureDetector(onTap: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Notifications")));}, child: Icon(Icons.notifications_none_rounded, color: Colors.white70))]),
    SizedBox(height: 20), Text("Anything confusing?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)), Text("Send it to WHAT NOW.", style: TextStyle(color: Colors.white60)), SizedBox(height: 16),
    Container(padding: EdgeInsets.all(14), decoration: BoxDecoration(color: Color(0xFF181E3D), borderRadius: BorderRadius.circular(16)), child: Column(children: [TextField(controller: ctrl, maxLines: 4, style: TextStyle(color: Colors.white, fontSize: 13), decoration: InputDecoration(hintText: "Paste a message, bill, offer, email or anything...", hintStyle: TextStyle(color: Colors.white30, fontSize: 12), border: InputBorder.none)), SizedBox(height: 12), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [b(Icons.content_paste_rounded,"Paste",paste), b(Icons.image_rounded,"Photo",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Photo picker")));}), b(Icons.description_rounded,"File",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("File picker")));}), b(Icons.link_rounded,"Link",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Paste link above")));}), b(Icons.mic_rounded,"Voice",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Voice - Future")));})]), SizedBox(height: 14), SizedBox(width: double.infinity, height: 46, child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7B5CFF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: analyse, icon: Icon(Icons.auto_awesome, size: 16), label: Text("WHAT SHOULD I DO?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))))])),
    SizedBox(height: 16), Text("Try an example", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)), SizedBox(height: 8),
    ex(Color(0xFFFF3D57),Icons.warning_rounded,"Suspicious message","Your account will be blocked...","Your account will be blocked today. Click here to verify!"),
    ex(Color(0xFF00C853),Icons.receipt_rounded,"Bill or payment","Electricity bill for tomorrow...","Your electricity bill of Rs 2450 is due tomorrow. Pay immediately."),
    ex(Color(0xFF448AFF),Icons.work_rounded,"Job offer","You have been selected...","You have been selected for a job. Pay Rs 5000 for registration."),
    ex(Color(0xFF00BCD4),Icons.email_rounded,"Agreement","Please review document...","Rental agreement for review. Monthly rent Rs 15000."),
    ex(Color(0xFFFF9800),Icons.shopping_bag_rounded,"Product","Best deal on product...","Best deal! iPhone 15 for Rs 20000 only! Limited!"),
  ])));
  Widget b(IconData ic,String lb,VoidCallback tap)=> GestureDetector(onTap: tap, child: Column(children: [Container(padding: EdgeInsets.all(9), decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(9)), child: Icon(ic,size: 16,color: Colors.white70)), SizedBox(height: 3), Text(lb, style: TextStyle(fontSize: 9,color: Colors.white54))]));
  Widget ex(Color c,IconData ic,String t,String sub,String fill)=> GestureDetector(onTap: (){setState(()=> ctrl.text=fill);}, child: Container(margin: EdgeInsets.only(bottom: 8), padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF181E3D), borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Icon(ic,color: c,size: 16)), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t,style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11)), Text(sub,style: TextStyle(color: Colors.white54,fontSize: 9))]))])));
}

class ResultScreen extends StatelessWidget { String text; ResultScreen({required this.text}); @override Widget build(BuildContext context)=> Scaffold(backgroundColor: Color(0xFF070B1F), appBar: AppBar(title: Text("WHAT NOW AI", style: TextStyle(fontSize: 15)), backgroundColor: Color(0xFF070B1F)), body: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF1E2340), borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(Icons.description,color: Colors.blue,size: 16), SizedBox(width: 8), Expanded(child: Text(text, style: TextStyle(color: Colors.white,fontSize: 11)))])),
  SizedBox(height: 14), Text("HERES WHAT NOW", style: TextStyle(color: Color(0xFF7B5CFF),fontWeight: FontWeight.bold,fontSize: 11)), SizedBox(height: 8),
  cd("WHAT IS THIS?","Electricity bill payment reminder.",Color(0xFF7C4DFF),Icons.info_outline),
  cd("WHY IT MATTERS?","Avoid late fee and service disruption.",Color(0xFF00E5FF),Icons.bolt),
  cd("WHAT SHOULD I DO?","Verify with official app and pay if genuine.",Color(0xFF00E676),Icons.check_circle),
  cd("DEADLINE","Tomorrow",Color(0xFFFF9800),Icons.calendar_today),
  cd("WHAT IF I DO NOTHING?","Late fee, disconnection possible.",Color(0xFFFF5252),Icons.warning_rounded),
  cd("RISK CHECK","Be careful of fake links.",Color(0xFFE040FB),Icons.shield),
  SizedBox(height: 12), Text("NEXT 3 STEPS", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12)), SizedBox(height: 4), Text("1 Verify bill on official app.\n2 Check amount and due date.\n3 Complete payment if genuine.", style: TextStyle(color: Colors.white70,fontSize: 11)),
  SizedBox(height: 16), Row(children: [Expanded(child: ElevatedButton.icon(icon: Icon(Icons.copy,size: 14), label: Text("Copy Reply",style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF7B5CFF)), onPressed: (){Clipboard.setData(ClipboardData(text: text)); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Copied!")));})), SizedBox(width: 8), Expanded(child: ElevatedButton.icon(icon: Icon(Icons.alarm,size: 14), label: Text("Set Reminder",style: TextStyle(fontSize: 11)), style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF2196F3)), onPressed: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Reminder set!")));}))])
]))); Widget cd(String t,String d,Color c,IconData ic)=> Container(margin: EdgeInsets.only(bottom: 7), padding: EdgeInsets.all(10), decoration: BoxDecoration(color: c.withOpacity(0.12),borderRadius: BorderRadius.circular(8),border: Border.all(color: c.withOpacity(0.25))), child: Row(children: [Container(padding: EdgeInsets.all(5), decoration: BoxDecoration(color: c.withOpacity(0.2),borderRadius: BorderRadius.circular(5)), child: Icon(ic,color: c,size: 14)), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t,style: TextStyle(color: c,fontWeight: FontWeight.bold,fontSize: 9)), SizedBox(height: 2), Text(d,style: TextStyle(color: Colors.white,fontSize: 10))]))]));
}

class HistoryScreen extends StatefulWidget { @override _HistoryScreenState createState()=> _HistoryScreenState(); }
class _HistoryScreenState extends State<HistoryScreen> { String search=""; @override Widget build(BuildContext context){ List<Map<String,dynamic>> items=[{"title":"Electricity bill","sub":"Bill reminder - Rs 2450","time":"Today - 10:24 AM","icon":Icons.image_rounded,"color":Color(0xFF00E676)}, {"title":"Job offer","sub":"Suspicious message","time":"Today - 09:12 AM","icon":Icons.work_rounded,"color":Color(0xFF7C4DFF)}, {"title":"Bank alert","sub":"Transaction declined","time":"Today - 08:45 AM","icon":Icons.email_rounded,"color":Color(0xFF2196F3)}, {"title":"Rental agreement","sub":"Document review","time":"Yesterday - 07:32 PM","icon":Icons.description_rounded,"color":Color(0xFFFF9800)}, {"title":"Flight ticket","sub":"Travel details","time":"Yesterday - 05:18 PM","icon":Icons.flight_rounded,"color":Color(0xFF00BCD4)}, {"title":"Product review","sub":"Shopping advice","time":"Yesterday - 02:41 PM","icon":Icons.shopping_bag_rounded,"color":Color(0xFFFF5252)},]; var filtered=items.where((e)=> e["title"].toString().toLowerCase().contains(search.toLowerCase())).toList(); return SafeArea(child: Padding(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("History", style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold)), SizedBox(height: 10), TextField(onChanged: (v){setState(()=> search=v);}, style: TextStyle(color: Colors.white,fontSize: 12), decoration: InputDecoration(hintText: "Search your history...",hintStyle: TextStyle(fontSize: 11,color: Colors.white38),prefixIcon: Icon(Icons.search,size: 16,color: Colors.white38),filled: true,fillColor: Color(0xFF1E2340),border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide.none),contentPadding: EdgeInsets.symmetric(vertical: 8))), SizedBox(height: 10), Expanded(child: ListView.builder(itemCount: filtered.length, itemBuilder: (_,i){var e=filtered[i]; return GestureDetector(onTap: (){Navigator.push(context, MaterialPageRoute(builder: (_)=> ResultScreen(text: e["sub"])));}, child: Container(margin: EdgeInsets.only(bottom: 7), padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF1E2340),borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(padding: EdgeInsets.all(7), decoration: BoxDecoration(color: (e["color"] as Color).withOpacity(0.2),borderRadius: BorderRadius.circular(7)), child: Icon(e["icon"] as IconData,color: e["color"] as Color,size: 16)), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e["title"],style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11)), Text(e["sub"],style: TextStyle(color: Colors.white54,fontSize: 9)), Text(e["time"],style: TextStyle(color: Colors.white38,fontSize: 8))])), Icon(Icons.chevron_right,color: Colors.white24,size: 14)])));}))]))); } }

class SettingsScreen extends StatefulWidget { @override _SettingsScreenState createState()=> _SettingsScreenState(); }
class _SettingsScreenState extends State<SettingsScreen> { bool notif=true; bool dark=true; @override Widget build(BuildContext context)=> SafeArea(child: SingleChildScrollView(padding: EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Settings", style: TextStyle(color: Colors.white,fontSize: 18,fontWeight: FontWeight.bold)), SizedBox(height: 12), Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF1E2340),borderRadius: BorderRadius.circular(10)), child: Row(children: [Container(width: 36,height: 36, decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7B5CFF)]),borderRadius: BorderRadius.circular(8)), child: Icon(Icons.chat_bubble_rounded,size: 18,color: Colors.white)), SizedBox(width: 10), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("WHAT NOW AI",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 12)), Text("v1.0.0",style: TextStyle(color: Colors.white54,fontSize: 10))])])), SizedBox(height: 8),
  tile(Icons.person_rounded,"Account","Profile & preferences",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Account")));}),
  tile(Icons.notifications_rounded,"Notifications","Reminders & alerts",null,isSwitch: true,val: notif,onChanged: (v){setState(()=> notif=v);}),
  tile(Icons.language_rounded,"Language","English",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("English")));}),
  tile(Icons.dark_mode_rounded,"Appearance","Dark mode",null,isSwitch: true,val: dark,onChanged: (v){setState(()=> dark=v);}),
  tile(Icons.security_rounded,"Privacy & Security","Your data is safe",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Privacy safe")));}),
  tile(Icons.help_rounded,"Help & Support","FAQs and contact",(){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Help")));}),
  SizedBox(height: 8), GestureDetector(onTap: (){ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Go Pro - Coming soon!")));}, child: Container(padding: EdgeInsets.all(10), decoration: BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF7B5CFF), Color(0xFFE040FB)]),borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(Icons.workspace_premium_rounded,color: Colors.amber,size: 18), SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Go Pro",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 11)), Text("More analyses. Premium features.",style: TextStyle(color: Colors.white70,fontSize: 9))])), Icon(Icons.chevron_right,size: 14,color: Colors.white)]))),
]))); Widget tile(IconData ic,String t,String sub,VoidCallback? tap,{bool isSwitch=false,bool val=false,Function(bool)? onChanged})=> GestureDetector(onTap: tap, child: Container(margin: EdgeInsets.only(bottom: 6), padding: EdgeInsets.all(10), decoration: BoxDecoration(color: Color(0xFF1E2340),borderRadius: BorderRadius.circular(9)), child: Row(children: [Icon(ic,size: 16,color: Colors.white70), SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t,style: TextStyle(color: Colors.white,fontSize: 11,fontWeight: FontWeight.w600)), Text(sub,style: TextStyle(fontSize: 9,color: Colors.white54))])), isSwitch? Switch(value: val,onChanged: onChanged,activeColor: Color(0xFF7B5CFF)): Icon(Icons.chevron_right,color: Colors.white24,size: 14)])));
                                                         }
