import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import '../viewModel/sign_up_view_model.dart';
import '../viewModel/sign_in_view_model.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    // 초기화 시 컨트롤러 생성
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    // 위젯이 소멸될 때 컨트롤러도 메모리에서 해제
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signInViewModel = ref.read(signinViewModelProvider.notifier);
    final signInState = ref.watch(signinViewModelProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final signUpState = ref.watch(signUpViewModelProvider);
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: Text(
                  'ログイン',
                  style: TextStyle(
                    fontSize: screenHeight * 0.03,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Text(
                'E-mail',
                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.black),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                'Password',
                style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.black),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                controller: passwordController,
                obscureText: !signUpState.isPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.015),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      signUpState.isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      signUpViewModel.togglePasswordVisibility();
                    },
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // 비밀번호 복구 로직
                  },
                  child: Text(
                    'パスワードを忘れた方はこちら',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: screenHeight * 0.017,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('로그인에 실패했습니다: ${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    backgroundColor: Color(0xFF1D2538),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.03),
                    ),
                  ),
                  child: Text(
                    'ログイン',
                    style: TextStyle(
                      fontSize: screenHeight * 0.022,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.15),
              Center(
                child: Text(
                  'もしくはGoogleでログイン',
                  style: TextStyle(
                    fontSize: screenHeight * 0.02,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: ElevatedButton.icon(
                  onPressed: signInState.isLoading
                      ? null
                      : () async {
                          final isOwner = signUpState.type == 'owner';
                          await signInViewModel.signInWithGoogle(context, isOwner: isOwner);
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.03),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  icon: Image.asset(
                    'lib/img/google_logo.png',
                    height: screenHeight * 0.03,
                    width: screenHeight * 0.03,
                  ),
                  label: Text(
                    'Login with Google',
                    style: TextStyle(
                      fontSize: screenHeight * 0.02,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10), // Google 로그인 버튼 아래 빈 공간
              
              // 'LINE'으로 로그인 버튼 (구현 예정)
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Line 로그인 로직 추가 예정
                  },
                  icon: Image.asset(
                    'lib/img/line_logo.png', // Line 로고 이미지
                    height: 24, // 아이콘 높이
                    width: 24, // 아이콘 너비
                  ),
                  label: Text(
                    'LINEを利用してログイン', // 버튼 텍스트 'LINE을 이용해 로그인'
                    style: TextStyle(color: Colors.black), // 텍스트 스타일
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 버튼 배경색 흰색
                    foregroundColor: Colors.black, // 텍스트 및 아이콘 색상
                    padding: EdgeInsets.symmetric(horizontal: 92, vertical: 14), // 버튼 패딩
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25), // 버튼 모서리 둥글게 설정
                    ),
                    side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220)), // 회색 테두리
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // 추가된 빈 공간
            ],
          ),
        ),
      ),
    );
  }
}
