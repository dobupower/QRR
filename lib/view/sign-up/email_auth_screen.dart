import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/sign_up_view_model.dart'; // SignUpViewModel 가져오기
import '../../model/user_model.dart'; // User 모델 가져오기

// 이메일 인증 화면 클래스 (ConsumerWidget을 사용하여 Riverpod 상태를 감시)
class EmailAuthScreen extends ConsumerWidget {
  final User user; // 이메일 인증 대상인 사용자

  // 생성자에서 필수적으로 User 객체를 받아옴
  EmailAuthScreen({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 화면 크기 정보 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // SignUpState 및 SignUpViewModel 상태를 감시
    final signUpState = ref.watch(signUpViewModelProvider); 
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
        ),
        backgroundColor: Colors.transparent, // AppBar의 배경색 투명
        elevation: 0, // 그림자 제거
      ),
      // 본문 내용
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.05), // 화면 여백을 상대적으로 설정
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            // 중앙에 위치한 타이틀 텍스트
            Center(
              child: Text(
                'アカウント認証', // 'アカウント認証' = 계정 인증
                style: TextStyle(
                  fontSize: screenWidth * 0.07, // 폰트 크기를 상대적으로 설정
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // 간격을 상대적으로 설정
            // 사용자 이메일 정보와 안내 메시지
            Center(
              child: Text(
                '${user.email}に認証コードを送りました。\n認証コードを入力してください。', 
                // '認証コードを送りました。' = 인증 코드를 보냈습니다.
                textAlign: TextAlign.center, // 텍스트 가운데 정렬
                style: TextStyle(fontSize: screenWidth * 0.038, color: Colors.black), // 텍스트 크기를 상대적으로 설정
              ),
            ),
            SizedBox(height: screenHeight * 0.04), // 간격을 상대적으로 설정
            // 인증 코드 입력 필드 라벨
            Text(
              '認証コード', // '認証コード' = 인증 코드
              style: TextStyle(fontSize: screenWidth * 0.045), // 폰트 크기를 상대적으로 설정
            ),
            SizedBox(height: screenHeight * 0.01), // 간격을 상대적으로 설정
            // 인증 코드 입력 필드
            TextField(
              controller: signUpState.codeController, // 인증 코드 입력을 위한 컨트롤러
              decoration: InputDecoration(
                hintText: '4桁コードを入力', // '4桁コードを入力' = 4자리 코드를 입력
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.03), // 필드 테두리를 상대적으로 설정
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              keyboardType: TextInputType.number, // 숫자 입력만 가능하도록 설정
              maxLength: 4, // 최대 입력 길이 4자리로 설정
            ),
            Spacer(), // 화면 남은 공간 채우기 (필드와 버튼 사이 간격 유지)
            // 코드 재전송 버튼
            Center(
              child: TextButton(
                onPressed: () {
                  signUpViewModel.resendVerificationCode(); // 코드 재전송 함수 호출
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('新しいコードが送信されました。')), 
                    // '新しいコードが送信されました' = 새로운 코드가 전송되었습니다.
                  );
                },
                child: Text(
                  'コード再送する', // 'コード再送する' = 코드 재전송
                  style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.04), // 텍스트 크기를 상대적으로 설정
                ),
              ),
            ),
            // 인증 확인 버튼
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // 입력된 코드를 기반으로 인증 처리
                  await signUpViewModel.verifyCode(
                    signUpState.codeController.text, 
                    context, 
                    user
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1D2538), // 버튼 배경색 설정
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.3, vertical: screenHeight * 0.015), // 버튼 크기를 상대적으로 설정
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.07), // 버튼 모서리를 둥글게 상대적으로 설정
                  ),
                ),
                child: Text(
                  'アカウント認証', // 'アカウント認証' = 계정 인증
                  style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white), // 텍스트 크기를 상대적으로 설정
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05), // 마지막 간격을 상대적으로 설정
          ],
        ),
      ),
    );
  }
}
