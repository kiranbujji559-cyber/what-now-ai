// PASTE THIS FULL CODE - No Error - Full App
import 'package:flutter/material.dart';
void main()=>runApp(const WhatNowApp());
class WhatNowApp extends StatelessWidget{
const WhatNowApp({super.key});
@override Widget build(BuildContext c)=>MaterialApp(debugShowCheckedModeBanner:false,theme:ThemeData.dark().copyWith(scaffoldBackgroundColor:const Color(0xFF0A0E1F)),home:const Home());
}
class Home extends StatefulWidget{const Home({super.key});@override State<Home> createState()=>_H();}
class _H extends State<Home>{
final _t=TextEditingController();bool _show=false;String _what="",_why="",_do="",_risk="",_steps="",_reply="",_money="",_level="LOW",_title="";
void _analyze(){
String s=_t.text.toLowerCase();if(s.isEmpty)return;
setState((){
_show=true;
if(s.contains("job")||s.contains("fee")||s.contains("selected")){
_title="Job Offer - HIGH RISK";_what="Job offer asking upfront fee";_why="90% fee jobs are scams";_do="DO NOT PAY. Verify official site/LinkedIn, ask for stamped offer letter";_risk="Registration fee before joining = scam pattern";_level="HIGH";_money="Fee mentioned";_steps="1. Google company+reviews\n2. Check careers page\n3. Ask for official letter";_reply="Please share official offer letter & website";
}else if(s.contains("bill")||s.contains("₹")||s.contains("due")){
_title="Bill Reminder";_what="Electricity/Utility bill due";_why="Avoid late fee/disconnection";_do="Open official APEPDCL/app, verify bill, pay only there";_risk="Verify amount in official app";_level="MEDIUM";_money="Check amount in app";_steps="1. Open official app\n2. Verify consumer no\n3. Pay via official UPI";_reply="Will verify in official app";
}else{_title="Message Analysis";_what="Message needs verification";_why="May be important/risky";_do="Verify sender & official source";_risk="Check source";_level="LOW";_money="No money";_steps="1. Verify sender\n2. Check official link\n3. Act/ignore";_reply="Please share official link";}
});
}
Widget _card(String t,String v,Color c)=>Container(margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFF1A1F3A),borderRadius:BorderRadius.circular(16),border:Border.all(color:c.withOpacity(0.5))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:const TextStyle(fontWeight:FontWeight.bold,fontSize:12,color:Colors.white70)),const SizedBox(height:6),Text(v)]));
@override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(backgroundColor:const Color(0xFF0A0E1F),title:const Text("WHAT NOW AI - Turn confusion into clear actions")),body:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(children:[TextField(controller:_t,maxLines:4,decoration:InputDecoration(filled:true,fillColor:const Color(0xFF1A1F3A),hintText:"Paste bill, job, message...",border:OutlineInputBorder(borderRadius:BorderRadius.circular(16),borderSide:BorderSide.none))),const SizedBox(height:12),SizedBox(width:double.infinity,child:ElevatedButton(onPressed:_analyze,style:ElevatedButton.styleFrom(backgroundColor:const Color(0xFF7C4DFF),padding:const EdgeInsets.all(16),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30))),child:const Text("✨ WHAT SHOULD I DO?"))),if(_show)...[_card("WHAT IS THIS? - $_title",_what,Colors.purple),_card("WHY IT MATTERS?",_why,Colors.blue),_card("WHAT SHOULD I DO?",_do,Colors.green),_card("RISK • $_level",_risk,_level=="HIGH"?Colors.red:Colors.orange),_card("MONEY?",_money,Colors.teal),_card("NEXT 3 STEPS",_steps,Colors.white24),_card("DRAFT REPLY",_reply,Colors.white24)]])));
}
}
