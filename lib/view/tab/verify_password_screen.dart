import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'user/user_account_screen.dart';
import '../../services/auth_service.dart';

class VerifyPasswordScreen extends ConsumerStatefulWidget {
  @override
  _VerifyPasswordScreenState createState() => _VerifyPasswordScreenState();
}

class _VerifyPasswordScreenState extends ConsumerState<VerifyPasswordScreen> {
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose(); // 컨트롤러 해제
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            HeaderSection(screenHeight: screenHeight, screenWidth: screenWidth),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: screenHeight * 0.08),
                  InstructionSection(screenWidth: screenWidth),
                  SizedBox(height: screenHeight * 0.05),
                  PasswordInputSection(
                    passwordController: passwordController,
                    screenWidth: screenWidth,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  SubmitButtonSection(
                    passwordController: passwordController,
                    screenHeight: screenHeight,
                    screenWidth: screenWidth,
                    ref: ref,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HeaderSection extends StatelessWidget {
  final double screenHeight;
  final double screenWidth;

  const HeaderSection({
    required this.screenHeight,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: screenWidth * 0.05,
        top: screenHeight * 0.03,
      ),
      child: Text(
        'パスワード確認', // 일본어로 비밀번호 확인
        style: TextStyle(
          fontSize: screenWidth * 0.06,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class InstructionSection extends StatelessWidget {
  final double screenWidth;

  const InstructionSection({
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '現在のパスワードを入力してください',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenWidth * 0.05,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class PasswordInputSection extends StatelessWidget {
  final TextEditingController passwordController;
  final double screenWidth;

  const PasswordInputSection({
    required this.passwordController,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: '現在のパスワード',
        labelStyle: TextStyle(
          fontSize: screenWidth * 0.045,
          color: Colors.grey,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF4A6FA5),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: const Color(0xFF4A6FA5),
            width: 2,
          ),
        ),
      ),
    );
  }
}

class SubmitButtonSection extends StatelessWidget {
  final TextEditingController passwordController;
  final double screenHeight;
  final double screenWidth;
  final WidgetRef ref;

  const SubmitButtonSection({
    required this.passwordController,
    required this.screenHeight,
    required this.screenWidth,
    required this.ref,
  });

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          final password = passwordController.text;

          // 입력 필드가 비어 있는 경우 경고 메시지 표시
          if (password.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('パスワードを入力してください。'), // 비밀번호를 입력해 주세요.
                backgroundColor: Colors.red,
              ),
            );
            return;
          }
          
          // 비밀번호 인증 요청
          final isValid = await _authService.validatePassword(password);

          if (isValid) {
            // 성공 시 비밀번호 재설정 화면으로 이동
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('비밀번호 변경 이메일을 보냈습니다。'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            // 실패 시 에러 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('パスワードが一致しません。'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A6FA5),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.02,
            horizontal: screenWidth * 0.3,
          ),
        ),
        child: Text(
          '確認',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
