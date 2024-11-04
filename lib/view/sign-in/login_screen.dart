import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/sign_up_view_model.dart';
import '../../viewModel/sign_in_view_model.dart';

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
    
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

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
                  onPressed: signInState.isLoading
                      ? null
                      : () async {
                          await signInViewModel.handleLogin(
                            context,
                            emailController.text,
                            passwordController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    backgroundColor: Color(0xFF1D2538),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.03),
                    ),
                  ),
                  child: signInState.isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
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
                    padding: EdgeInsets.symmetric(horizontal: 24), // 버튼 패딩 설정
                  ),
                  icon: Image.asset(
                    'lib/img/google_logo.png',
                    height: screenHeight * 0.03,
                    width: screenHeight * 0.03,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Login with Google',
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        color: Colors.black,
                      ),
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
                    height: screenHeight * 0.03,
                    width: screenHeight * 0.03,
                  ),
                  label: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'LINEを利用してログイン', // 버튼 텍스트 'LINE을 이용해 로그인'
                      style: TextStyle(
                        fontSize: screenHeight * 0.02,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, // 버튼 배경색 흰색
                    foregroundColor: Colors.black, // 텍스트 및 아이콘 색상
                    minimumSize: Size(double.infinity, screenHeight * 0.06),
                    padding: EdgeInsets.symmetric(horizontal: 24), // 버튼 패딩 설정
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenHeight * 0.03), // 버튼 모서리 둥글게 설정
                      side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220)), // 회색 테두리
                    ),
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
