import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const WhatNowAI());
class WhatNowAI extends StatelessWidget {
  const WhatNowAI({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WHAT NOW AI',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: const Color(0xFF080A1E)),
      home: const MainTabs(),
    );
  }
}
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}
class _MainTabsState extends State<MainTabs> {
  int idx = 0;
  List<Map<String,dynamic>> history = [];
  void addHistory(Map<String,dynamic> m){setState(()=>history.insert(0,m));}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080A1E),
      body: [HomeScreen(onAdd: addHistory), HistoryScreen(history: history), const SettingsScreen()][idx],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: Colors.white10))),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF0F1128),
          currentIndex: idx, selectedItemColor: const Color(0xFF8B5CF6), unselectedItemColor: Colors.grey,
          onTap: (i)=>setState(()=>idx=i),
          items: const [BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'), BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'History'), BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings')],
        ),
      ),
    );
  }
}
class HomeScreen extends StatefulWidget {
  final Function(Map<String,dynamic>) onAdd;
  const HomeScreen({super.key, required this.onAdd});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends State<HomeScreen> {
  final ctrl = TextEditingController();
  bool loading = false;
  Map<String,dynamic>? result;
  static const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  Future<void> askAI() async {
    if(ctrl.text.trim().isEmpty) return;
    setState(()=>loading=true);
    try{
      final prompt = 'You are WHAT NOW AI. User input: ${ctrl.text}. Return ONLY JSON: {"what_is":"short title","why_matters":"why important","what_should":"action","deadline":"time","if_nothing":"consequence","risk":"risk check","next_steps":["step1","step2","step3"]}. Language simple English + Telugu mix.';
      final res = await http.post(Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey'), headers: {'Content-Type':'application/json'}, body: jsonEncode({"contents":[{"parts":[{"text":prompt}]}], "generationConfig":{"responseMimeType":"application/json"}}));
      if(res.statusCode==200){
        final txt = jsonDecode(res.body)['candidates'][0]['content']['parts'][0]['text'];
        final j = jsonDecode(txt);
        setState(()=>result=j);
        widget.onAdd({"title":ctrl.text, "type":"bill", "time":"Today - ${TimeOfDay.now().format(context)}", "data":j});
      } else {
        setState(()=>result={"what_is":"API Error ${res.statusCode}","why_matters":"Check GEMINI_API_KEY in Secrets","what_should":"Add key and rebuild","deadline":"Now","if_nothing":"AI wont work","risk":"Set key","next_steps":["Go to GitHub Secrets","Add GEMINI_API_KEY","Rebuild"]});
      }
    }catch(e){
      setState(()=>result={"what_is":"Network Error","why_matters":e.toString(),"what_should":"Check internet","deadline":"Now","if_nothing":"Retry","risk":"Low","next_steps":["Check net","Restart","Ask again"]});
    }
    setState(()=>loading=false);
  }
  @override
  Widget build(BuildContext context) {
    if(result!=null) return ResultPage(data: result!, input: ctrl.text, onBack: ()=>setState(()=>result=null));
    return SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [Container(width:42,height:42,decoration:BoxDecoration(gradient: const LinearGradient(colors:[Color(0xFF00D9FF),Color(0xFF7C3AED)]),borderRadius: BorderRadius.circular(12)),child: const Icon(Icons.smart_toy_rounded,color:Colors.white)), const SizedBox(width:10), const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("WHAT NOW AI",style:TextStyle(fontWeight:FontWeight.bold,fontSize:16)),Text("Send anything. Get clear actions.",style:TextStyle(fontSize:11,color:Colors.grey))])]),
      const SizedBox(height:18),
      const Text("Anything confusing?",style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)), const Text("Send it to WHAT NOW.",style:TextStyle(color:Colors.grey)),
      const SizedBox(height:12),
      Container(decoration:BoxDecoration(color: const Color(0xFF151730),borderRadius:BorderRadius.circular(14),border:Border.all(color:Colors.white10)), child: TextField(controller: ctrl,maxLines:4,style:const TextStyle(color:Colors.white,fontSize:13),decoration: const InputDecoration(hintText:"Paste a message, bill, offer, email or anything...",hintStyle:TextStyle(color:Colors.grey,fontSize:12),border:InputBorder.none,contentPadding:EdgeInsets.all(14)))),
      const SizedBox(height:12),
      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[_b(Icons.content_paste_rounded,"Paste",Color(0xFF8B5CF6)),_b(Icons.image_rounded,"Photo",Color(0xFFA855F7)),_b(Icons.file_copy_rounded,"File",Color(0xFF3B82F6)),_b(Icons.link_rounded,"Link",Color(0xFFF59E0B)),_b(Icons.mic_rounded,"Voice",Color(0xFFEC4899))]),
      const SizedBox(height:14),
      SizedBox(width:double.infinity,height:48,child: ElevatedButton(onPressed:loading?null:askAI,style:ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(24))),child: loading?const SizedBox(width:20,height:20,child:CircularProgressIndicator(color:Colors.white,strokeWidth:2)):const Text("✨ WHAT SHOULD I DO?",style:TextStyle(fontWeight:FontWeight.bold,color:Colors.white)))),
      const SizedBox(height:18),
      const Text("Try an example",style:TextStyle(fontSize:11,color:Colors.grey)),
      const SizedBox(height:8),
      _ex(Icons.warning_amber_rounded,Colors.red,"Suspicious message","Your account will be blocked today..."),
      _ex(Icons.receipt_rounded,Colors.green,"Bill or payment","Electricity bill for tomorrow..."),
      _ex(Icons.work_rounded,Colors.purple,"Job offer","You have been selected for a job..."),
      _ex(Icons.description_rounded,Colors.blue,"Agreement","Please review the document..."),
      _ex(Icons.shopping_bag_rounded,Colors.orange,"Product","Best deal on this product..."),
    ])));
  }
  Widget _b(IconData ic,String l,Color c)=>Column(children:[Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:c.withOpacity(0.15),borderRadius:BorderRadius.circular(10),border:Border.all(color:c.withOpacity(0.3))),child:Icon(ic,size:18,color:c)),const SizedBox(height:4),Text(l,style:const TextStyle(fontSize:9,color:Colors.grey))]);
  Widget _ex(IconData ic,Color c,String t,String s)=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:const Color(0xFF151730),borderRadius:BorderRadius.circular(12)),child:Row(children:[Container(padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:c.withOpacity(0.2),borderRadius:BorderRadius.circular(8)),child:Icon(ic,size:16,color:c)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontSize:11,fontWeight:FontWeight.bold)),Text(s,style:const TextStyle(fontSize:9,color:Colors.grey),maxLines:1)]))]));
}
class ResultPage extends StatelessWidget {
  final Map<String,dynamic> data; final String input; final VoidCallback onBack;
  const ResultPage({super.key, required this.data, required this.input, required this.onBack});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[IconButton(onPressed:onBack,icon:const Icon(Icons.arrow_back)),const Text("WHAT NOW AI",style:TextStyle(fontWeight:FontWeight.bold))]),
      Container(margin:const EdgeInsets.symmetric(vertical:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF151730),borderRadius:BorderRadius.circular(12)),child:Row(children:[Container(padding:const EdgeInsets.all(8),decoration:BoxDecoration(color:Colors.blue.withOpacity(0.2),borderRadius:BorderRadius.circular(8)),child:const Icon(Icons.receipt,size:18,color:Colors.blue)),const SizedBox(width:8),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text("Your electricity bill reminder",style:TextStyle(fontSize:11,fontWeight:FontWeight.bold)),Text(input,maxLines:2,style:const TextStyle(fontSize:10,color:Colors.grey))]))])),
      const SizedBox(height:8),
      const Center(child:Text("✦ HERE'S WHAT NOW ✦",style:TextStyle(color:Color(0xFF8B5CF6),fontWeight:FontWeight.bold,fontSize:12))),
      const SizedBox(height:12),
      _c("WHAT IS THIS?",data['what_is']??"",Icons.info_outline,Color(0xFF8B5CF6)),
      _c("WHY IT MATTERS?",data['why_matters']??"",Icons.bolt_rounded,Color(0xFF3B82F6)),
      _c("WHAT SHOULD I DO?",data['what_should']??"",Icons.check_circle_rounded,Color(0xFF10B981)),
      _c("DEADLINE",data['deadline']??"",Icons.calendar_today_rounded,Color(0xFFF59E0B)),
      _c("WHAT IF I DO NOTHING?",data['if_nothing']??"",Icons.warning_rounded,Color(0xFFEF4444)),
      _c("RISK CHECK",data['risk']??"",Icons.shield_rounded,Color(0xFFEC4899)),
      const SizedBox(height:12),
      const Text("NEXT 3 STEPS",style:TextStyle(fontWeight:FontWeight.bold,fontSize:11)),
      const SizedBox(height:6),
     ...(data['next_steps'] as List? ?? []).asMap().entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:4),child:Text("${e.key+1} ${e.value}",style:const TextStyle(fontSize:11,color:Colors.white70)))),
      const SizedBox(height:16),
      Row(children:[Expanded(child:ElevatedButton.icon(onPressed:(){},icon:const Icon(Icons.copy,size:14),label:const Text("Copy Reply",style:TextStyle(fontSize:11)),style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF8B5CF6)))),const SizedBox(width:10),Expanded(child:ElevatedButton.icon(onPressed:(){},icon:const Icon(Icons.alarm,size:14),label:const Text("Set Reminder",style:TextStyle(fontSize:11)),style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF3B82F6))))]),
    ])));
  }
  Widget _c(String t,String d,IconData ic,Color c)=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(11),decoration:BoxDecoration(color:c.withOpacity(0.13),borderRadius:BorderRadius.circular(12),border:Border.all(color:c.withOpacity(0.25))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(padding:const EdgeInsets.all(5),decoration:BoxDecoration(color:c.withOpacity(0.2),shape:BoxShape.circle),child:Icon(ic,size:12,color:c)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:TextStyle(fontSize:9,fontWeight:FontWeight.bold,color:c)),const SizedBox(height:2),Text(d,style:const TextStyle(fontSize:11))]))]));
}
class HistoryScreen extends StatelessWidget {
  final List<Map<String,dynamic>> history;
  const HistoryScreen({super.key, required this.history});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text("History",style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:10),
      Container(padding:const EdgeInsets.symmetric(horizontal:12),decoration:BoxDecoration(color:const Color(0xFF151730),borderRadius:BorderRadius.circular(10)),child:const TextField(decoration:InputDecoration(hintText:"Search your history...",border:InputBorder.none,icon:Icon(Icons.search,color:Colors.grey,size:18),hintStyle:TextStyle(fontSize:12,color:Colors.grey)))),
      const SizedBox(height:12),
      Row(children:[_chip("All",true),_chip("Today",false),_chip("Yesterday",false),_chip("This Week",false)]),
      const SizedBox(height:14),
      if(history.isEmpty) const Expanded(child:Center(child:Text("No history yet - Ask something on Home",style:TextStyle(color:Colors.grey,fontSize:12))))
      else Expanded(child:ListView.builder(itemCount:history.length,itemBuilder:(c,i){
        final h=history[i]; return Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF151730),borderRadius:BorderRadius.circular(12)),child:Row(children:[Container(width:36,height:36,decoration:const BoxDecoration(color:Color(0xFF8B5CF6),shape:BoxShape.circle),child:const Icon(Icons.receipt,size:16)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(h['title'],maxLines:1,style:const TextStyle(fontSize:11,fontWeight:FontWeight.bold)),Text("${h['time']}",style:const TextStyle(fontSize:9,color:Colors.grey))]))]));
      }))
    ])));
  }
  Widget _chip(String t,bool sel)=>Container(margin:const EdgeInsets.only(right:6),padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),decoration:BoxDecoration(color:sel?const Color(0xFF8B5CF6):const Color(0xFF151730),borderRadius:BorderRadius.circular(16)),child:Text(t,style:TextStyle(fontSize:10,color:sel?Colors.white:Colors.grey)));
}
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SafeArea(child:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      const Text("Settings",style:TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:14),
      Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF151730),borderRadius:BorderRadius.circular(14)),child:Row(children:[Container(width:44,height:44,decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF00D9FF),Color(0xFF8B5CF6)]),borderRadius:BorderRadius.circular(10)),child:const Icon(Icons.smart_toy_rounded)),const SizedBox(width:10),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("WHAT NOW AI v1.0",style:TextStyle(fontWeight:FontWeight.bold,fontSize:13)),Text("REAL Gemini AI inside",style:TextStyle(fontSize:10,color:Colors.grey))])])),
      const SizedBox(height:12),
      _s(Icons.person_rounded,"Account","Profile & preferences"),
      _s(Icons.notifications_rounded,"Notifications","Reminders & alerts",hasSw:true),
      _s(Icons.language_rounded,"Language","English"),
      _s(Icons.dark_mode_rounded,"Appearance","Dark mode",hasSw:true,val:true),
      _s(Icons.lock_rounded,"Privacy & Security","Your data is safe"),
      _s(Icons.help_rounded,"Help & Support","FAQs and contact"),
      const SizedBox(height:12),
      Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF8B5CF6),Color(0xFFEC4899)]),borderRadius:BorderRadius.circular(14)),child:const Row(children:[Icon(Icons.star_rounded,color:Colors.yellow),SizedBox(width:8),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text("Go Pro",style:TextStyle(fontWeight:FontWeight.bold)),Text("More analysis, Premium features.",style:TextStyle(fontSize:10))])])),
    ])));
  }
  Widget _s(IconData ic,String t,String s,{bool hasSw=false,bool val=false})=>Container(margin:const EdgeInsets.only(bottom:8),padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:const Color(0xFF151730),borderRadius:BorderRadius.circular(12)),child:Row(children:[Icon(ic,size:18,color:Colors.grey),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontSize:12,fontWeight:FontWeight.w500)),Text(s,style:const TextStyle(fontSize:10,color:Colors.grey))])),if(hasSw) Switch(value:val,onChanged:(v){},activeColor:const Color(0xFF8B5CF6),materialTapTargetSize:MaterialTapTargetSize.shrinkWrap)]));
}
