import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'view/first_screen.dart';
import 'view/sign_up_screen.dart';
import 'view/store_select_screen.dart';
import 'view/email_auth_screen.dart';
import 'viewModel/sign_up_view_model.dart';
import 'firebase_options.dart';  // 자동으로 생성된 Firebase 초기화 파일
import 'model/user_model.dart';

void main() async {
  // Flutter가 비동기 초기화 작업을 수행할 수 있도록 보장
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화. Firebase와 통신하기 전에 반드시 초기화가 필요합니다.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // 앱 시작
  runApp(MyApp());
}

// MyApp은 앱의 루트 위젯입니다.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // MultiProvider를 사용하여 앱 전체에서 사용될 여러 ViewModel을 제공
      providers: [
        // ChangeNotifierProvider는 SignUpViewModel을 제공하여 상태 변화를 감지하고 UI에 반영
        ChangeNotifierProvider(create: (_) => SignUpViewModel()),
      ],
      child: MaterialApp(
        // 앱의 타이틀
        title: 'Flutter Demo',
        // 앱의 테마 설정
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // 앱이 시작될 때 처음으로 표시될 라우트 지정
        initialRoute: '/',
        // 앱에서 사용할 라우트를 정의
        routes: {
          '/': (context) => FirstScreen(),            // 첫 화면
          '/sign-up': (context) => SignUpScreen(),    // 회원가입 화면
          '/store-selection': (context) => StoreSelectionScreen(),  // 매장 선택 화면
        },
        // 특정 상황에서 동적으로 라우트를 생성하기 위해 onGenerateRoute 사용
        onGenerateRoute: (settings) {
          // '/email-auth' 라우트가 호출되면 EmailAuthScreen을 표시
          if (settings.name == '/email-auth') {
            // 전달된 인자(argument)로 User 객체를 받아옴
            final user = settings.arguments as User;
            return MaterialPageRoute(
              builder: (context) => EmailAuthScreen(user: user),
            );
          }
          return null; // 해당하는 라우트가 없을 경우 null을 반환
        },
      ),
    );
  }
}
