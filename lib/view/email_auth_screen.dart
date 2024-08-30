import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/sign_up_view_model.dart';
import '../model/user_model.dart';

class EmailAuthScreen extends StatelessWidget {
  final User user; // 사용자 정보를 담고 있는 User 객체

  EmailAuthScreen({required this.user});

  final _codeController = TextEditingController(); // 인증 코드를 입력받을 텍스트 컨트롤러

  @override
  Widget build(BuildContext context) {
    final signUpViewModel = Provider.of<SignUpViewModel>(context, listen: false); // SignUpViewModel을 제공받아 사용

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () {
            Navigator.pop(context); // 뒤로가기 버튼 클릭 시 이전 화면으로 이동
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'アカウント認証', // "アカウント認証" (계정 인증) 제목 표시
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: Text(
                '${user.email}に認証コードを送りました。\n認証コードを入力してください。', // 사용자의 이메일 주소로 인증 코드가 전송되었음을 안내
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 32),
            Text(
              '認証コード', // "認証コード" (인증 코드) 라벨 표시
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            TextField(
              controller: _codeController, // 인증 코드를 입력받는 필드
              decoration: InputDecoration(
                hintText: '4桁コードを入力', // "4桁コードを入力" (4자리 코드를 입력) 힌트 텍스트
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              keyboardType: TextInputType.number, // 숫자만 입력받도록 설정
              maxLength: 4, // 최대 4자리까지만 입력 가능
            ),
            Spacer(), // 남은 공간을 채우기 위한 위젯
            Center(
              child: TextButton(
                onPressed: () {
                  signUpViewModel.resendVerificationCode(); // 인증 코드 재전송 요청
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('新しいコードが送信されました。')), // "新しいコードが送信されました。" (새로운 코드가 전송되었습니다) 안내 메시지
                  );
                },
                child: Text(
                  'コード再送する', // "コード再送する" (코드 재전송) 버튼 텍스트
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (signUpViewModel.verifyCode(_codeController.text)) {
                    // 인증 코드가 올바른 경우 Firestore에 사용자 정보를 저장
                    signUpViewModel.onEmailVerified(context, user);
                  } else {
                    // 인증 코드가 틀린 경우 오류 메시지 표시
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('認証コードが正しくありません。')), // "認証コードが正しくありません。" (인증 코드가 올바르지 않습니다) 오류 메시지
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D2538), // 버튼 배경색 설정
                  padding: EdgeInsets.symmetric(horizontal: 120, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: Text(
                  'アカウント認証', // "アカウント認証" (계정 인증) 버튼 텍스트
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
