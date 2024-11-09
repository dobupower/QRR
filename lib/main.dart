import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase Core 패키지 가져오기
import 'view/first_screen.dart'; // FirstScreen 가져오기
import 'view/sign-up/sign_up_screen.dart'; // SignUpScreen 가져오기
import 'view/sign-up/store_select_screen.dart'; // StoreSelectionScreen 가져오기
import 'view/sign-up/email_auth_screen.dart'; // EmailAuthScreen 가져오기
import 'view/tab/owner/owner_home_screen.dart'; // HomeScreen 가져오기
import 'view/tab/user/user_home_screen.dart';
import 'model/user_model.dart'; // User 모델 가져오기
import 'view/sign-in/login_screen.dart'; // LoginScreen 가져오기
import 'view/sign-up/owner_sign_up_screen.dart'; // OwnerSignUpScreen 가져오기
import 'services/preferences_manager.dart'; // 싱글톤 PreferencesManager 가져오기
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 메인 함수, Firebase 초기화
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // 위젯 바인딩 초기화 (비동기 호출 전 필요)
  await Firebase.initializeApp(); // Firebase 앱 초기화
  await PreferencesManager.instance.init(); // PreferencesManager 초기화
  await dotenv.load(fileName: ".env"); // dotenv 초기화
  
  // ProviderScope는 Riverpod 상태 관리를 위한 최상위 위젯
  runApp(ProviderScope(child: MyApp()));
}

// MyApp 클래스, Flutter 앱의 진입점
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder(
        future: _getLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error loading app')),
            );
          }

          // 로그인 여부에 따라 초기 화면을 다르게 설정
          if (snapshot.data == 'user') {
            // 만약 email이 저장되어 있으면 user-home으로 이동
            return UserHomeScreen();
          } else if (snapshot.data == 'owner') {
            // 그렇지 않으면 owner-home으로 이동
            return OwnerHomeScreen();
          } else {
            // 그렇지 않으면 FirstScreen으로 이동
            return FirstScreen();
          }
        },
      ),
      title: 'Flutter Demo', // 앱의 제목
      theme: ThemeData(
        primarySwatch: Colors.blue, // 기본 색상 테마 설정
        visualDensity: VisualDensity.adaptivePlatformDensity, // 플랫폼에 맞는 밀도 설정
      ),
      initialRoute: '/', // 첫 화면을 루트('/')로 설정
      routes: {
        '/first': (context) => FirstScreen(), // 루트 경로에서 FirstScreen 표시
        '/sign-up': (context) => SignUpScreen(), // '/sign-up' 경로에서 SignUpScreen 표시
        '/store-selection': (context) => StoreSelectionScreen(), // '/store-selection' 경로에서 StoreSelectionScreen 표시
        '/login': (context) => LoginScreen(), // 로그인 화면 경로 추가
        '/owner-home': (context) => OwnerHomeScreen(), // HomeScreen 추가
        '/owner-sign-up': (context) => OwnerSignUpScreen(), // OwnerSignUpScreen 추가
        '/user-home': (context) => UserHomeScreen(),
      },
      // 동적 경로 생성, 이메일 인증 화면
      onGenerateRoute: (settings) {
        if (settings.name == '/email-auth') {
          final user = settings.arguments as User?; // 전달된 User 객체를 받음
          if (user != null) {
            return MaterialPageRoute(
              builder: (context) => EmailAuthScreen(user: user), // User가 있으면 EmailAuthScreen으로 이동
            );
          } else {
            return MaterialPageRoute(
              builder: (context) => FirstScreen(), // User가 없으면 FirstScreen으로 이동
            );
          }
        }
        return null; // 해당 경로가 없으면 null 반환
      },
      // 알 수 없는 경로 처리
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => FirstScreen(), // 잘못된 경로일 경우 FirstScreen으로 이동
        );
      },
    );
  }

  // PreferencesManager를 통해 로그인 상태를 가져오는 함수
  Future<String?> _getLoginStatus() async {
    // 'type' 정보를 가져옴
    return PreferencesManager.instance.getType();
  }
}