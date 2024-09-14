import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/sign_up_view_model.dart'; // SignUpViewModel 파일 import
import '../viewModel/sign_in_view_model.dart';

class FirstScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // signUpViewModel과 signUpState를 각각 읽고, 상태 관리를 준비
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier); // SignUpViewModel에 접근
    final signUpState = ref.watch(signUpViewModelProvider); // 현재 상태를 감시
    final signInViewModel = ref.read(signinViewModelProvider.notifier);
    final signInState = ref.watch(signinViewModelProvider); // 상태를 감시

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0), // 화면 좌우 여백 설정
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // 화면 중앙에 배치
          crossAxisAlignment: CrossAxisAlignment.center, // 가로 중앙 정렬
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.3), // 화면 크기에 비례한 빈 공간
            Image.asset(
              'lib/img/point_icon.png', // 아이콘 이미지 경로
              height: 150, // 이미지 높이
              width: 150, // 이미지 너비
            ),
            SizedBox(height: 140), // 이미지 아래 빈 공간

            // '관리자' 선택 체크박스와 텍스트
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 수평 중앙 정렬
              children: [
                Checkbox(
                  value: signUpState.type == 'owner', // 'owner'일 때 체크됨
                  onChanged: (bool? value) {
                    // 체크박스 선택 시 호출되는 함수
                    signUpViewModel.setType(value ?? false); // 선택 여부에 따라 'owner' 또는 'customer'로 설정
                  },
                ),
                Expanded(
                  child: Text(
                    '管理者で会員登録やログインする場合はチェックをしてください。', // 체크박스 설명 텍스트
                    style: TextStyle(fontSize: 14), // 폰트 크기 설정
                  ),
                ),
              ],
            ),
            SizedBox(height: 40), // 체크박스 아래 빈 공간

            // '会員登録' 및 'ログイン' 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // 버튼들을 수평 중앙 정렬
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // '会員登録' 버튼 클릭 시 회원가입 페이지로 이동
                      Navigator.pushNamed(context, '/sign-up');
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13), // 버튼 안쪽 패딩
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // 버튼 모서리 둥글게 설정
                      ),
                      side: BorderSide(color: Colors.black, width: 2.0), // 검은색 테두리, 두께 2.0
                    ),
                    child: Text(
                      '会員登録', // 버튼 텍스트 '회원가입'
                      style: TextStyle(fontSize: 16, color: Colors.black), // 텍스트 스타일
                    ),
                  ),
                ),
                SizedBox(width: 16), // 버튼 간의 간격
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login'); // 로그인 페이지로 이동
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 13), // 버튼 안쪽 패딩
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25), // 버튼 모서리 둥글게 설정
                      ),
                      backgroundColor: Color(0xFF1D2538), // 네이비색 배경
                    ),
                    child: Text(
                      'ログイン', // 버튼 텍스트 '로그인'
                      style: TextStyle(fontSize: 16, color: Colors.white), // 텍스트 스타일
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 로그인 버튼 아래 빈 공간

            // 'Google'로 로그인 버튼
            // Google 로그인 버튼
            ElevatedButton.icon(
              onPressed: signInState.isLoading
                  ? null // 로딩 중일 때 버튼 비활성화
                  : () async {
                      // 관리자인지 여부를 체크박스 상태로 판단
                      final isOwner = signUpState.type == 'owner';
                      await signInViewModel.signInWithGoogle(context, isOwner: isOwner); // ViewModel 인스턴스를 통해 메서드 호출
                    },
              icon: Image.asset(
                'lib/img/google_logo.png',
                height: 24,
                width: 24,
              ),
              label: Text(
                'Googleを利用してログイン',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(horizontal: 87, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                side: BorderSide(color: Color.fromARGB(255, 220, 220, 220)),
              ),
            ),
            if (signInState.isLoading)
              CircularProgressIndicator(), // 로딩 중일 때 표시
            if (signInState.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  signInState.errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 10), // Google 로그인 버튼 아래 빈 공간

            // 'LINE'으로 로그인 버튼 (구현 예정)
            ElevatedButton.icon(
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
            Spacer(), // 아래로 빈 공간을 남기고 버튼을 중앙으로 밀어주는 역할
          ],
        ),
      ),
    );
  }
}