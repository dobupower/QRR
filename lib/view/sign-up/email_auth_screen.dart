import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/sign_up_view_model.dart'; // SignUpViewModel 가져오기
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// 이메일 인증 화면 클래스 (ConsumerWidget을 사용하여 Riverpod 상태를 감시)
class EmailAuthScreen extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 화면 크기 정보 가져오기
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;
    final localizations = AppLocalizations.of(context);

    // SignUpState 및 SignUpViewModel 상태를 감시
    final signUpState = ref.watch(signUpViewModelProvider); 
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        // 본문 내용
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  localizations?.emailAuthScreenAccount ?? '', // 'アカウント認証' = 계정 인증
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Center(
                child: Text(
                  ('${signUpState.emailController?.text ?? ''}') + (localizations?.emailAuthScreenCodeSend ?? '') + '\n' + (localizations?.emailAuthScreenCodeInput2 ?? ''),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: screenWidth * 0.038, color: Colors.black),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              Text(
                localizations?.emailAuthScreenCode ?? '', // '認証コード' = 인증 코드
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenHeight * 0.01),
              TextField(
                controller: signUpState.codeController ?? TextEditingController(), // null일 경우 빈 컨트롤러 생성
                decoration: InputDecoration(
                  hintText: localizations?.emailAuthScreenCodeInput1 ?? '', // '4桁コードを入力' = 4자리 코드를 입력
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
                keyboardType: TextInputType.number,
                maxLength: 4,
              ),
              Spacer(),
              Center(
                child: TextButton(
                  onPressed: () {
                    signUpViewModel.resendVerificationCode(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations?.emailAuthScreenCodeResend1?? '')),
                    );
                  },
                  child: Text(
                    localizations?.emailAuthScreenCodeResend2 ?? '', // 'コード再送する' = 코드 재전송
                    style: TextStyle(color: Colors.blue, fontSize: screenWidth * 0.04),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  width: screenWidth * 0.8, // 버튼 너비를 화면 너비의 80%로 고정
                  child: ElevatedButton(
                    onPressed: () async {
                      // 입력된 코드를 기반으로 인증 처리
                      final code = signUpState.codeController?.text ?? ''; // null 체크
                      if (code.isNotEmpty) {
                        await signUpViewModel.verifyCode(code, context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(localizations?.emailAuthScreenCodeInput2 ?? '')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1D2538),
                      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015), // 수직 패딩만 설정
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.07),
                      ),
                    ),
                    child: Text(
                      localizations?.emailAuthScreenAccount ?? '', // 'アカウント認証' = 계정 인증
                      style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
