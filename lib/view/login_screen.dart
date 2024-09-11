import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication 사용
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In 사용
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용
import 'home_screen.dart'; // HomeScreen 가져오기
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 파일 import

// LoginScreen 위젯 정의, ConsumerWidget을 사용하여 Riverpod의 상태 관리 사용
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 현재 signUpState와 signUpViewModel 가져오기
    final signUpState = ref.watch(signUpViewModelProvider); // SignUp 상태를 감시하여 변경 시 UI 업데이트
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier); // SignUpViewModel의 메서드 사용 가능

    // 이메일과 비밀번호를 입력받을 TextEditingController 생성
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey), // 뒤로 가기 버튼
          onPressed: () => Navigator.pop(context), // 누르면 이전 화면으로 돌아가기 허용
        ),
        backgroundColor: Colors.transparent, // 배경색을 투명하게 설정
        elevation: 0, // 그림자 제거
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0), // 좌우 32.0 간격 패딩 적용
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 모든 항목을 왼쪽 정렬
          children: [
            SizedBox(height: 40), // 위쪽에 40px 빈 공간
            Center(
              child: Text(
                'ログイン', // "로그인" 텍스트
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold, // 볼드체 적용
                  color: Colors.black, // 검은색 텍스트
                ),
              ),
            ),
            SizedBox(height: 40), // 텍스트와 입력 필드 사이에 40px 간격 적용
            
            // 이메일 입력 필드 레이블
            Text(
              'E-mail',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 8), // 이메일 입력 필드 위에 8px 간격 적용
            TextField(
              controller: emailController, // 이메일 입력 데이터를 받을 컨트롤러
              decoration: InputDecoration(
                hintText: 'Enter your email', // 입력 필드 안에 표시될 힌트 텍스트
                hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상을 회색으로 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // 입력 필드의 모서리를 둥글게 설정
                  borderSide: BorderSide(color: Colors.grey), // 테두리 색상을 회색으로 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // 비활성화 상태에서도 모서리 둥글게
                  borderSide: BorderSide(color: Colors.grey), // 비활성화 상태의 테두리 색상
                ),
              ),
            ),
            SizedBox(height: 16), // 이메일 필드와 비밀번호 필드 사이에 16px 간격 적용
            
            // 비밀번호 입력 필드 레이블
            Text(
              'Password',
              style: TextStyle(fontSize: 14, color: Colors.black),
            ),
            SizedBox(height: 8), // 비밀번호 입력 필드 위에 8px 간격 적용
            TextField(
              controller: passwordController, // 비밀번호 입력 데이터를 받을 컨트롤러
              obscureText: !signUpState.isPasswordVisible, // 비밀번호 가리기 설정 (SignUpState에 따라)
              decoration: InputDecoration(
                hintText: 'Enter your password', // 비밀번호 필드 안에 힌트 텍스트
                hintStyle: TextStyle(color: Colors.grey), // 힌트 텍스트 색상을 회색으로 설정
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // 입력 필드의 모서리를 둥글게 설정
                  borderSide: BorderSide(color: Colors.grey), // 테두리 색상을 회색으로 설정
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0), // 비활성화 상태에서도 모서리 둥글게
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
            SizedBox(height: 8), // 비밀번호 입력 필드 아래에 8px 간격 적용
            
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
                    fontSize: 12, // 작은 글씨 크기
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // 비밀번호 버튼 아래 16px 간격 적용
            
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
                  minimumSize: Size(double.infinity, 48), // 버튼 너비를 가득 채우고 높이 48px
                  backgroundColor: Color(0xFF1D2538), // 버튼 배경색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // 버튼 모서리 둥글게 설정
                  ),
                ),
                child: Text(
                  'ログイン',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white, // 텍스트 색상 흰색
                  ),
                ),
              ),
            ),
            SizedBox(height: 32), // 로그인 버튼 아래에 32px 간격 적용
            
            // '또는 Google로 로그인' 텍스트
            Center(
              child: Text(
                'もしくはGoogleでログイン',
                style: TextStyle(
                  fontSize: 15, // 글씨 크기
                  color: Colors.black, // 검정색 텍스트
                ),
              ),
            ),
            SizedBox(height: 16), // Google 로그인 버튼 위에 16px 간격 적용
            
            // Google 로그인 버튼
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    final googleUser = await GoogleSignIn().signIn(); // Google 로그인 요청
                    if (googleUser == null) return; // 로그인 취소 시 처리 없음

                    final googleAuth = await googleUser.authentication; // Google 인증 정보 요청
                    final googleEmail = googleUser.email;

                    // Firestore에서 사용자가 이메일로 등록되어 있는지 확인
                    final querySnapshot = await FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: googleEmail)
                      .get();

                  if (querySnapshot.docs.isNotEmpty) {
                    // 이미 존재할 경우 authType 체크
                    final existingUser = querySnapshot.docs.first;
                    final authType = existingUser['authType'];

                    if (authType != 'google') {
                      // Google이 아닌 로그인 방식일 경우 로그아웃 처리 및 로그인 취소
                      await GoogleSignIn().signOut(); // Google 로그아웃
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('다른 로그인 방식으로 로그인해주세요.')),
                      );
                      return;
                    }
                  }

                    // authType이 'google'인 경우나 처음 등록되는 경우만 Firebase로 로그인
                  final credential = GoogleAuthProvider.credential(
                    accessToken: googleAuth.accessToken,
                    idToken: googleAuth.idToken,
                  );

                  // Firebase로 인증 정보 전달하여 로그인 처리
                  final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
                  final user = userCredential.user;

                  if (user != null) {
                    if (querySnapshot.docs.isEmpty) {
                      // Firestore에 사용자가 없으면 새로 생성
                      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
                        'uid': user.uid,
                        'email': user.email,
                        'name': user.displayName ?? 'Anonymous',
                        'points': 0,
                        'profilePicUrl': user.photoURL,
                        'pubId': null,
                        'type': signUpState.type == 'owner' ? 'owner' : 'customer',
                        'authType': 'google', // Google로 로그인했음을 저장
                      });
                    }

                    // 로그인 성공 시 HomeScreen으로 이동
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomeScreen()), // HomeScreen으로 이동
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Google 로그인에 실패했습니다.')),
                  );
                }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48), // 버튼 너비를 가득 채우고 높이 48px
                  backgroundColor: Colors.white, // 배경색 흰색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // 버튼 모서리 둥글게 설정
                    side: BorderSide(color: Colors.grey[300]!), // 테두리 색상 회색
                  ),
                ),
                icon: Image.asset(
                  'lib/img/google_logo.png', // Google 로고 이미지
                  height: 24, // 로고 높이
                  width: 24, // 로고 너비
                ),
                label: Text(
                  'Login with Google',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black, // 검정색 텍스트
                  ),
                ),
              ),
            ),
            SizedBox(height: 16), // Google 로그인 버튼 아래 16px 간격 적용
            
            // Line 로그인 버튼 (추후 구현 예정)
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Line 로그인 로직 추가 예정
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48), // 버튼 너비를 가득 채우고 높이 48px
                  backgroundColor: Colors.white, // 배경색 흰색
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24), // 모서리 둥글게 설정
                    side: BorderSide(color: Colors.grey[300]!), // 테두리 색상 회색
                  ),
                ),
                icon: Image.asset(
                  'lib/img/line_logo.png', // Line 로고 이미지
                  height: 24, // 로고 높이
                  width: 24, // 로고 너비
                ),
                label: Text(
                  'Login with LINE',
                  style: TextStyle(
                    fontSize: 16,
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
