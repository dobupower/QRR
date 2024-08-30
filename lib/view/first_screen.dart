import 'package:flutter/material.dart';

// 앱 시작 화면을 나타내는 FirstScreen 위젯
class FirstScreen extends StatefulWidget {
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

// FirstScreen의 상태를 관리하는 클래스
class _FirstScreenState extends State<FirstScreen> {
  // 관리자 모드 선택 여부를 나타내는 변수
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 화면의 주요 내용을 구성하는 부분
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Column의 자식 위젯을 수직 방향으로 중앙에 정렬
          mainAxisAlignment: MainAxisAlignment.center,
          // 자식 위젯을 수평 방향으로도 중앙에 정렬
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(), // 화면 상단에 여백 추가
            Icon(Icons.credit_card, size: 100), // 큰 아이콘 표시
            SizedBox(height: 40), // 아이콘과 아래 내용 사이에 여백 추가

            // 체크박스와 설명 텍스트를 함께 표시
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  value: isChecked, // 체크박스의 현재 상태
                  onChanged: (bool? value) {
                    setState(() {
                      isChecked = value!; // 체크박스 상태를 변경
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    '管理者で会員登録やログインする場合はチェックをしてください。',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20), // 체크박스와 버튼 사이에 여백 추가

            // 회원 등록 및 로그인 버튼을 나란히 배치
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // 회원가입 버튼 클릭 시 SignUpScreen으로 이동
                    Navigator.pushNamed(context, '/sign-up');
                  },
                  child: Text('会員登録'),
                ),
                SizedBox(width: 16), // 버튼 사이에 여백 추가
                ElevatedButton(
                  onPressed: () {},
                  child: Text('ログイン'),
                ),
              ],
            ),
            SizedBox(height: 20), // 버튼과 소셜 로그인 버튼 사이에 여백 추가

            // Google 로그인 버튼
            ElevatedButton.icon(
              onPressed: () {
                // Google 로그인 로직 추가 예정
              },
              icon: Image.asset(
                'lib/img/google_logo.png', // Google 로고 이미지 경로
                height: 24,
                width: 24,
              ),
              label: Text('Googleを利用してログイン'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.black),
              ),
            ),
            SizedBox(height: 10), // Google 로그인 버튼과 Line 로그인 버튼 사이에 여백 추가

            // Line 로그인 버튼
            ElevatedButton.icon(
              onPressed: () {
                // Line 로그인 로직 추가 예정
              },
              icon: Image.asset(
                'lib/img/line_logo.png', // Line 로고 이미지 경로
                height: 24,
                width: 24,
              ),
              label: Text('LINEを利用してログイン'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.black),
              ),
            ),
            Spacer(), // 화면 하단에 여백 추가
          ],
        ),
      ),
    );
  }
}
