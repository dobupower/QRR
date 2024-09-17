import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 사용
import 'home_screen.dart'; // HomeScreen 가져오기
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 파일 import
import '../viewModel/sign_in_view_model.dart'; // SignInViewModel 파일 import

// LoginScreen 위젯 정의, ConsumerWidget을 사용하여 Riverpod의 상태 관리 사용
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    final signInViewModel = ref.read(signinViewModelProvider.notifier);
    final signInState = ref.watch(signinViewModelProvider); // 상태를 감시
    // 화면의 크기 정보
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 현재 signUpState와 signUpViewModel 가져오기
    final signUpState = ref.watch(signUpViewModelProvider); // SignUp 상태를 감시하여 변경 시 UI 업데이트
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier); // SignUpViewModel의 메서드 사용 가능

    // 이메일과 비밀번호를 입력받을 TextEditingController 생성
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      // AppBar 정의 (상단바)
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey), // 뒤로 가기 버튼
          onPressed: () => Navigator.pop(context), // 누르면 이전 화면으로 돌아가기 허용
        ),
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정
        elevation: 0, // 그림자 제거
      ),

      // 화면 전체 레이아웃 설정
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 화면 너비의 8% 패딩 적용
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 모든 항목을 왼쪽 정렬
          children: [
            SizedBox(height: screenHeight * 0.02), // 위쪽에 화면 높이의 5% 간격 적용
            Center(
              child: Text(
                'ログイン', // "로그인" 텍스트
                style: TextStyle(
                  fontSize: screenHeight * 0.03, // 화면 높이의 3% 크기
                  fontWeight: FontWeight.bold, // 볼드체 적용
                  color: Colors.black, // 검은색 텍스트
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03), // 텍스트와 입력 필드 사이에 화면 높이의 5% 간격 적용

            // 이메일 입력 필드 레이블
            Text(
              'E-mail',
              style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.black),
            ),
            SizedBox(height: screenHeight * 0.01), // 이메일 입력 필드 위에 화면 높이의 1% 간격 적용
            TextField(
              controller: emailController, // 이메일 입력 데이터를 받을 컨트롤러
              decoration: InputDecoration(
                hintText: 'Enter your email', // 입력 필드 안에 표시될 힌트 텍스트
                hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상을 회색으로 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // 모서리를 화면 높이의 1.5%만큼 둥글게 설정
                  borderSide: BorderSide(color: Colors.grey), // 테두리 색상을 회색으로 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // 비활성화 상태에서도 모서리 둥글게
                  borderSide: BorderSide(color: Colors.grey), // 비활성화 상태의 테두리 색상
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 이메일 필드와 비밀번호 필드 사이에 화면 높이의 2% 간격 적용

            // 비밀번호 입력 필드 레이블
            Text(
              'Password',
              style: TextStyle(fontSize: screenHeight * 0.02, color: Colors.black),
            ),
            SizedBox(height: screenHeight * 0.01), // 비밀번호 입력 필드 위에 화면 높이의 1% 간격 적용
            TextField(
              controller: passwordController, // 비밀번호 입력 데이터를 받을 컨트롤러
              obscureText: !signUpState.isPasswordVisible, // 비밀번호 가리기 설정 (SignUpState에 따라)
              decoration: InputDecoration(
                hintText: 'Enter your password', // 비밀번호 필드 안에 힌트 텍스트
                hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상을 회색으로 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // 모서리를 둥글게 설정
                  borderSide: BorderSide(color: Colors.grey), // 테두리 색상을 회색으로 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.015), // 비활성화 상태에서도 모서리 둥글게
                  borderSide: BorderSide(color: Colors.grey), // 비활성화 상태의 테두리 색상
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    signUpState.isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    // 비밀번호 가림 버튼 클릭 시 상태 변경
                    signUpViewModel.togglePasswordVisibility();
                  },
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.01), // 비밀번호 입력 필드 아래에 1% 간격 적용

            // 비밀번호를 잊었을 때를 위한 텍스트 버튼
            Align(
              alignment: Alignment.centerRight, // 오른쪽 정렬
              child: TextButton(
                onPressed: () {
                  // 비밀번호 찾기 버튼 로직 (추후 구현)
                },
                child: Text(
                  'パスワードを忘れた方はこちら',
                  style: TextStyle(
                    color: Colors.blue, // 파란색 텍스트
                    fontSize: screenHeight * 0.017, // 작은 글씨 크기 설정
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 비밀번호 버튼 아래 2% 간격 적용

            // 로그인 버튼
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Firebase Authentication 로그인 처리
                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                      email: emailController.text.trim(), // 이메일 텍스트
                      password: passwordController.text.trim(), // 비밀번호 텍스트
                    );

                    // 로그인 성공 시 HomeScreen으로 이동 (뒤로 가기 버튼 없이)
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()), // HomeScreen으로 이동
                    );
                  } catch (e) {
                    // 로그인 실패 시 에러 메시지 출력
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('로그인에 실패했습니다: ${e.toString()}')),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, screenHeight * 0.06), // 버튼 높이 설정
                  backgroundColor: Color(0xFF1D2538), // 버튼 배경색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.03), // 버튼 모서리 둥글게 설정
                  ),
                ),
                child: Text(
                  'ログイン',
                  style: TextStyle(
                    fontSize: screenHeight * 0.022, // 텍스트 크기 설정
                    color: Colors.white, // 텍스트 색상 흰색
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.15), // 로그인 버튼 아래에 5% 간격 적용

            // '또는 Google로 로그인' 텍스트
            Center(
              child: Text(
                'もしくはGoogleでログイン',
                style: TextStyle(
                  fontSize: screenHeight * 0.02, // 글씨 크기 설정
                  color: Colors.black, // 검정색 텍스트
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Google 로그인 버튼 위에 2% 간격 적용

            // Google 로그인 버튼
            Center(
              child: ElevatedButton.icon(
                onPressed: signInState.isLoading
                  ? null // 로딩 중일 때 버튼 비활성화
                  : () async {
                      final isOwner = signUpState.type == 'owner';
                      await signInViewModel.signInWithGoogle(context, isOwner: isOwner); // ViewModel 인스턴스를 통해 메서드 호출
                    },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, screenHeight * 0.06), // 버튼 높이 설정
                  backgroundColor: Colors.white, // 배경색 흰색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.03), // 버튼 모서리 둥글게 설정
                    side: BorderSide(color: Colors.grey[300]!), // 테두리 색상 회색
                  ),
                ),
                icon: Image.asset(
                  'lib/img/google_logo.png', // Google 로고 이미지
                  height: screenHeight * 0.03, // 로고 높이 설정
                  width: screenHeight * 0.03, // 로고 너비 설정
                ),
                label: Text(
                  'Login with Google',
                  style: TextStyle(
                    fontSize: screenHeight * 0.02, // 텍스트 크기 설정
                    color: Colors.black, // 검정색 텍스트
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Google 로그인 버튼 아래 2% 간격 적용

            // Line 로그인 버튼 (추후 구현 예정)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Line 로그인 로직 추가 예정
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, screenHeight * 0.06), // 버튼 높이 설정
                  backgroundColor: Colors.white, // 배경색 흰색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenHeight * 0.03), // 모서리 둥글게 설정
                    side: BorderSide(color: Colors.grey[300]!), // 테두리 색상 회색
                  ),
                ),
                icon: Image.asset(
                  'lib/img/line_logo.png', // Line 로고 이미지
                  height: screenHeight * 0.03, // 로고 높이 설정
                  width: screenHeight * 0.03, // 로고 너비 설정
                ),
                label: Text(
                  'Login with LINE',
                  style: TextStyle(
                    fontSize: screenHeight * 0.02, // 텍스트 크기 설정
                    color: Colors.black, // 검정색 텍스트
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
