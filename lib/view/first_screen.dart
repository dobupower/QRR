import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 파일 import
import '../viewModel/sign_in_view_model.dart';

class FirstScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier); // SignUpViewModel에 접근
    final signUpState = ref.watch(signUpViewModelProvider); // 현재 상태를 감시
    final signInViewModel = ref.read(signinViewModelProvider.notifier);
    final signInState = ref.watch(signinViewModelProvider); // 상태를 감시

    // 화면 크기를 기반으로 상대적인 크기 설정
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04), // 화면 너비의 4% 만큼 여백 설정
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 화면 중앙에 배치
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
          children: [
            SizedBox(height: screenHeight * 0.3), // 화면 높이의 30% 만큼 빈 공간
            Image.asset(
              'lib/img/point_icon.png', // 아이콘 이미지 경로
              height: screenHeight * 0.15, // 이미지 높이 화면 높이의 15%
              width: screenHeight * 0.15, // 이미지 너비 화면 높이의 15%
            ),
            SizedBox(height: screenHeight * 0.14), // 이미지 아래 빈 공간

            // '관리자' 선택 체크박스와 텍스트
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 수평 중앙 정렬
              children: [
                Checkbox(
                  value: signUpState.type == 'owner', // 'owner'일 때 체크됨
                  onChanged: (bool? value) {
                    if (value != null) {
                      final type = value ? 'owner' : 'customer';
                      signUpViewModel.setType(value); // 선택에 따라 'owner' 또는 'customer' 설정
                      signInViewModel.setType(type); // signInState에 설정
                    }
                  },
                ),
                Expanded(
                  child: Text(
                    '管理者で会員登録やログインする場合はチェックをしてください。', // 체크박스 설명 텍스트
                    style: TextStyle(fontSize: screenHeight * 0.017), // 폰트 크기 설정 (화면 높이의 1.7%)
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.04), // 체크박스 아래 빈 공간

            // '会員登録' 및 'ログイン' 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 수평 중앙 정렬
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // 체크박스 상태에 따라 다른 화면으로 이동
                      if (signUpState.type == 'owner') {
                        Navigator.pushNamed(context, '/owner-sign-up');
                      } else {
                        Navigator.pushNamed(context, '/sign-up');
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.013), // 버튼 안쪽 패딩
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025), // 버튼 모서리 둥글게 설정
                      ),
                      side: BorderSide(color: Colors.black, width: screenHeight * 0.002), // 검은색 테두리
                    ),
                    child: Text(
                      '会員登録', // 버튼 텍스트 '회원가입'
                      style: TextStyle(
                        fontSize: screenHeight * 0.02, // 폰트 크기 설정
                        color: Colors.black,
                      ), // 텍스트 스타일
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04), // 버튼 간의 간격
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // 로그인 페이지로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.013), // 버튼 안쪽 패딩
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.025), // 버튼 모서리 둥글게 설정
                      ),
                      backgroundColor: Color(0xFF1D2538), // 네이비색 배경
                    ),
                    child: Text(
                      'ログイン', // 버튼 텍스트 '로그인'
                      style: TextStyle(
                        fontSize: screenHeight * 0.02, // 폰트 크기 설정
                        color: Colors.white,
                      ), // 텍스트 스타일
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.02), // 로그인 버튼 아래 빈 공간

            // 'Google'로 로그인 버튼
            ElevatedButton.icon(
              onPressed: signInState.isLoading
                  ? null // 로딩 중일 때 버튼 비활성화
                  : () async {
                      final isOwner = signUpState.type == 'owner';
                      await signInViewModel.signInWithGoogle(context, isOwner: isOwner); // ViewModel 인스턴스를 통해 메서드 호출
                    },
              icon: Image.asset(
                'lib/img/google_logo.png',
                height: screenHeight * 0.025, // 아이콘 높이 화면 높이의 2.5%
                width: screenHeight * 0.025, // 아이콘 너비 화면 높이의 2.5%
              ),
              label: Text(
                'Googleを利用してログイン',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.2, vertical: screenHeight * 0.016), // 버튼 패딩
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.025), // 둥근 버튼
                ),
                side: BorderSide(color: Color.fromARGB(255, 220, 220, 220)), // 회색 테두리
              ),
            ),
            if (signInState.isLoading)
              CircularProgressIndicator(), // 로딩 중일 때 표시
            SizedBox(height: screenHeight * 0.01), // Google 로그인 버튼 아래 빈 공간

            // 'LINE'으로 로그인 버튼 (구현 예정)
            ElevatedButton.icon(
              onPressed: () {
                // Line 로그인 로직 추가 예정
              },
              icon: Image.asset(
                'lib/img/line_logo.png', // Line 로고 이미지
                height: screenHeight * 0.025, // 아이콘 높이 화면 높이의 2.5%
                width: screenHeight * 0.025, // 아이콘 너비 화면 높이의 2.5%
              ),
              label: Text(
                'LINEを利用してログイン', // 버튼 텍스트 'LINE을 이용해 로그인'
                style: TextStyle(color: Colors.black), // 텍스트 스타일
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // 버튼 배경색 흰색
                foregroundColor: Colors.black, // 텍스트 및 아이콘 색상
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.22, vertical: screenHeight * 0.016), // 버튼 패딩
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenHeight * 0.025), // 둥근 버튼
                ),
                side: BorderSide(color: const Color.fromARGB(255, 220, 220, 220)), // 회색 테두리
              ),
            ),
            Spacer(), // 아래로 빈 공간을 남기고 버튼을 중앙으로 밀어주는 역할
          ],
        ),
      ),
    );
  }
}
