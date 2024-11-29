// owner_email_auth_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/owner_sign_up_view_model.dart';

class OwnerEmailAuthScreen extends ConsumerStatefulWidget {
  @override
  _OwnerEmailAuthScreenState createState() => _OwnerEmailAuthScreenState();
}

class _OwnerEmailAuthScreenState extends ConsumerState<OwnerEmailAuthScreen> {
  final TextEditingController _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(ownerSignUpViewModelProvider);
    final signUpViewModel = ref.read(ownerSignUpViewModelProvider.notifier);

    // 인증 성공 시 초기 화면으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (signUpState.verificationSuccess) {
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アカウント登録が完了しました。')),
        );
        signUpViewModel.resetVerificationSuccess();
      }

      if (signUpState.verificationErrorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signUpState.verificationErrorMessage!)),
        );
        signUpViewModel.resetVerificationError();
      }

      if (signUpState.resendCodeSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('新しいコードが送信されました。')),
        );
        signUpViewModel.resetResendCodeSuccess();
      }

      if (signUpState.resendCodeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signUpState.resendCodeError!)),
        );
        signUpViewModel.resetResendCodeError();
      }
    });

    // 화면 크기 정보 가져오기
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final owner = signUpState.owner;

    return WillPopScope(
      onWillPop: () async => false, // 뒤로 가기 방지
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
          ),
          backgroundColor: Colors.transparent, // AppBar의 배경색 투명
          elevation: 0, // 그림자 제거
        ),
        body: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05), // 화면 여백을 상대적으로 설정
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
            children: [
              Center(
                child: Text(
                  'アカウント認証', // 타이틀
                  style: TextStyle(
                    fontSize: screenWidth * 0.07,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // 간격

              Center(
                child: Text(
                  '${owner?.email ?? ''}に認証コードを送りました。\n認証コードを入力してください。',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: screenWidth * 0.038, color: Colors.black),
                ),
              ),
              SizedBox(height: screenHeight * 0.04), // 간격

              Text(
                '認証コード',
                style: TextStyle(fontSize: screenWidth * 0.045),
              ),
              SizedBox(height: screenHeight * 0.01), // 간격

              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  hintText: '4桁コードを入力',
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
                    signUpViewModel.resendVerificationCode();
                  },
                  child: Text(
                    'コード再送する',
                    style:
                        TextStyle(color: Colors.blue, fontSize: screenWidth * 0.04),
                  ),
                ),
              ),

              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await signUpViewModel.verifyCode(_codeController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1D2538),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.3,
                      vertical: screenHeight * 0.015,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(screenWidth * 0.07),
                    ),
                  ),
                  child: Text(
                    'アカウント認証',
                    style: TextStyle(
                        fontSize: screenWidth * 0.045, color: Colors.white),
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
