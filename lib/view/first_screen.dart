import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 파일 import
import '../viewModel/sign_in_view_model.dart'; // SignInViewModel 파일 import
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // 로컬라이제이션 import

class FirstScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier); // SignUpViewModel 접근
    final signUpState = ref.watch(signUpViewModelProvider); // 현재 signUp 상태 감시
    final signInViewModel = ref.read(signinViewModelProvider.notifier); // SignInViewModel 접근
    final signInState = ref.watch(signinViewModelProvider); // 현재 signIn 상태 감시

    // 로컬라이제이션
    final localizations = AppLocalizations.of(context);

    // 화면 크기를 기반으로 상대적인 크기 설정
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    // 공통 스타일 정의
    final buttonPadding = EdgeInsets.symmetric(vertical: screenHeight * 0.013); // 버튼 패딩
    final buttonBorderRadius = BorderRadius.circular(screenHeight * 0.025); // 버튼 테두리 둥글기
    final iconSize = screenHeight * 0.025; // 아이콘 크기

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 화면 좌우 여백
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
          children: [
            SizedBox(height: screenHeight * 0.3), // 화면 상단 빈 공간
            Image.asset(
              'lib/img/point_icon.png', // 아이콘 이미지 경로
              height: screenHeight * 0.15, // 이미지 높이
              width: screenHeight * 0.15, // 이미지 너비
            ),
            SizedBox(height: screenHeight * 0.14), // 이미지 아래 빈 공간

            // '관리자' 선택 체크박스와 설명 텍스트
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 수평 중앙 정렬
              children: [
                Checkbox(
                  value: signUpState.type == 'owners', // 'owner'일 때 체크
                  onChanged: (bool? value) {
                    if (value != null) {
                      final type = value ? 'owners' : 'customer'; // 체크에 따라 'owners' 또는 'customer' 설정
                      signUpViewModel.setType(value); // signUpViewModel에 설정
                      signInViewModel.setType(type); // signInViewModel에 설정
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    localizations?.firstScreenAdminCheckDescription ?? '', // 관리자 체크 설명
                    style: TextStyle(fontSize: screenHeight * 0.017), // 텍스트 크기
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04), // 체크박스 아래 빈 공간

            // '회원가입' 및 '로그인' 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 버튼 수평 중앙 정렬
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 체크박스 상태에 따라 다른 화면으로 이동
                      if (signUpState.type == 'owners') {
                        Navigator.pushNamed(context, '/owner-sign-up'); // 관리자 회원가입 화면
                      } else {
                        Navigator.pushNamed(context, '/sign-up'); // 일반 회원가입 화면
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: buttonPadding, // 버튼 패딩
                      shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius), // 둥근 테두리
                      side: BorderSide(color: Colors.black, width: screenHeight * 0.002), // 검은 테두리
                    ),
                    child: Text(
                      localizations?.firstScreenSignUp ?? '', // '会員登録' 텍스트
                      style: TextStyle(
                        fontSize: screenHeight * 0.02, // 텍스트 크기
                        color: Colors.black, // 텍스트 색상
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04), // 버튼 간 간격
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // 로그인 화면으로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      padding: buttonPadding, // 버튼 패딩
                      shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius), // 둥근 테두리
                      backgroundColor: const Color(0xFF1D2538), // 버튼 배경색
                    ),
                    child: Text(
                      localizations?.firstScreenLogin ?? '', // 'ログイン' 텍스트
                      style: TextStyle(
                        fontSize: screenHeight * 0.02, // 텍스트 크기
                        color: Colors.white, // 텍스트 색상
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // 버튼 아래 빈 공간

            // Google 로그인 버튼
            ElevatedButton.icon(
              onPressed: signInState.isLoading
                  ? null // 로딩 중일 때 버튼 비활성화
                  : () async {
                      await signInViewModel.signInWithGoogle(context); // Google 로그인 호출
                    },
              icon: Image.asset(
                'lib/img/google_logo.png', // Google 로고 이미지 경로
                height: iconSize, // 아이콘 높이
                width: iconSize, // 아이콘 너비
              ),
              label: Text(
                localizations?.firstScreenGoogleLogin ?? '', // Google 로그인 텍스트
                style: TextStyle(color: Colors.black), // 텍스트 색상
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색
                foregroundColor: Colors.black, // 텍스트 및 아이콘 색상
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: screenHeight * 0.016), // 버튼 패딩
                shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius), // 둥근 버튼
                side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220)), // 회색 테두리
              ),
            ),
            if (signInState.isLoading)
              const CircularProgressIndicator(), // 로딩 중 표시
            SizedBox(height: screenHeight * 0.01), // Google 버튼 아래 빈 공간

            // LINE 로그인 버튼
            ElevatedButton.icon(
              onPressed: signInState.isLoading
                  ? null // 로딩 중일 때 버튼 비활성화
                  : () async {
                      await signInViewModel.signInWithLine(context); // LINE 로그인 호출
                    },
              icon: Image.asset(
                'lib/img/line_logo.png', // Line 로고 이미지 경로
                height: iconSize, // 아이콘 높이
                width: iconSize, // 아이콘 너비
              ),
              label: Text(
                localizations?.firstScreenLineLogin ?? '', // LINE 로그인 텍스트
                style: TextStyle(color: Colors.black), // 텍스트 색상
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색
                foregroundColor: Colors.black, // 텍스트 및 아이콘 색상
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.22, vertical: screenHeight * 0.016), // 버튼 패딩
                shape: RoundedRectangleBorder(borderRadius: buttonBorderRadius), // 둥근 버튼
                side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220)), // 회색 테두리
              ),
            ),
            Spacer(), // 아래로 빈 공간 남기기
          ],
        ),
      ),
    );
  }
}
