import 'package:flutter/material.dart';
import 'screens/signup_screen.dart'; // signup_screen.dart 파일을 임포트

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너를 숨김
      home: SignUpScreen(), // SignUpScreen을 홈 화면으로 설정
    );
  }
}
