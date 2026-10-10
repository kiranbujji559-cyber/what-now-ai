import 'package:flutter/material.dart';

void main() {
  runApp(const WhatNowAIApp());
}

class WhatNowAIApp extends StatelessWidget {
  const WhatNowAIApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('WHAT NOW AI',
            style: TextStyle(color: Colors.white, fontSize: 30)),
        ),
      ),
    );
  }
}
