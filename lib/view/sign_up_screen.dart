import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewModel/sign_up_view_model.dart'; // 회원가입 ViewModel 가져오기

class SignUpScreen extends ConsumerWidget {
  // FormState를 관리하기 위한 GlobalKey
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 화면 크기 정보 가져오기
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    // 현재 상태와 ViewModel 가져오기
    final signUpState = ref.watch(signUpViewModelProvider);
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
        ),
        backgroundColor: Colors.transparent,
        elevation: 0, // 투명 배경과 그림자 제거
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // 화면의 4%를 패딩으로 설정
        child: Form(
          key: _formKey, // FormState를 사용하여 유효성 검사
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, screenWidth), // 회원가입 화면의 제목
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(
                '表示名', // 표시명 (이름)
                'あかばね', // 힌트 텍스트
                signUpState.nameController, // 이름 입력 필드의 컨트롤러
                context,
                screenWidth, // 화면 너비 전달
                screenHeight, // 화면 높이 전달
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildEmailField(
                'メールアドレス', // 이메일 레이블
                'Enter your email', // 이메일 입력 필드 힌트
                signUpState.emailController,
                context,
                signUpState, // 상태 전달
                signUpViewModel, // ViewModel 전달
                screenWidth,
                screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildPasswordField(
                'パスワード', // 비밀번호 레이블
                signUpState.passwordController,
                true, // 비밀번호 필드임을 알림
                context,
                signUpViewModel,
                signUpState,
                screenWidth,
                screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildConfirmPasswordField(
                'パスワード確認', // 비밀번호 확인 레이블
                signUpState.confirmPasswordController,
                context,
                signUpViewModel,
                signUpState,
                screenWidth,
                screenHeight,
              ),
              SizedBox(height: screenHeight * 0.1),
              _buildSubmitButton(context, signUpState, signUpViewModel, screenWidth, screenHeight), // 제출 버튼
              SizedBox(height: screenHeight * 0.02),
              _buildFooterText(context, screenWidth), // 하단 안내문구
            ],
          ),
        ),
      ),
    );
  }

  // 헤더 빌더 (회원가입 타이틀 표시)
  Widget _buildHeader(BuildContext context, double screenWidth) {
    return Center(
      child: Text(
        '会員登録', // 회원가입 제목
        style: TextStyle(
          fontSize: screenWidth * 0.06, // 화면 너비의 6%로 설정
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // 일반 텍스트 필드 빌더 (표시명 입력)
  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller,
    BuildContext context,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 레이블 텍스트
          style: TextStyle(fontSize: screenWidth * 0.05), // 화면 너비의 5%로 설정
        ),
        SizedBox(height: screenHeight * 0.01), // 화면 높이의 1%를 빈 공간으로 설정
        TextFormField(
          controller: controller, // 입력 컨트롤러
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0), // 모서리 둥글게
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: hint, // 힌트 텍스트
          ),
        ),
      ],
    );
  }

  // 이메일 입력 필드 빌더
  Widget _buildEmailField(
    String label,
    String hint,
    TextEditingController controller,
    BuildContext context,
    SignUpState signUpState,
    SignUpViewModel signUpViewModel,
    double screenWidth,
    double screenHeight,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 이메일 레이블
          style: TextStyle(fontSize: screenWidth * 0.05), // 화면 너비의 5%로 설정
        ),
        SizedBox(height: screenHeight * 0.01), // 화면 높이의 1% 빈 공간
        TextFormField(
          controller: controller, // 이메일 입력 컨트롤러
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: signUpState.emailError != null ? Colors.red : Colors.grey, // 에러가 있으면 빨간 테두리
              ),
            ),
            hintText: hint, // 힌트 텍스트
            errorText: signUpState.emailError, // 이메일 에러 메시지
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            signUpViewModel.validateEmail(value); // 이메일 유효성 검사 호출
          },
        ),
      ],
    );
  }

  // 비밀번호 입력 필드 빌더
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isPassword,
    BuildContext context,
    SignUpViewModel signUpViewModel,
    SignUpState signUpState,
    double screenWidth,
    double screenHeight,
  ) {
    final bool isVisible = signUpState.isPasswordVisible; // 비밀번호 가시성 상태

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 비밀번호 레이블
          style: TextStyle(fontSize: screenWidth * 0.05), // 화면 너비의 5%로 설정
        ),
        SizedBox(height: screenHeight * 0.01), // 화면 높이의 1% 빈 공간
        TextFormField(
          controller: controller, // 비밀번호 입력 컨트롤러
          obscureText: !isVisible, // 비밀번호 감추기 설정
          onChanged: (value) {
            signUpViewModel.validatePassword(value); // 비밀번호 유효성 검사 호출
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: '*********', // 비밀번호 입력 힌트
            errorText: signUpState.passwordError, // 비밀번호 에러 메시지
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off, // 눈 아이콘 변경
              ),
              onPressed: () {
                signUpViewModel.togglePasswordVisibility(); // 비밀번호 가시성 토글
              },
            ),
          ),
        ),
      ],
    );
  }

  // 비밀번호 확인 필드 빌더
  Widget _buildConfirmPasswordField(
    String label,
    TextEditingController controller,
    BuildContext context,
    SignUpViewModel signUpViewModel,
    SignUpState signUpState,
    double screenWidth,
    double screenHeight,
  ) {
    final bool isVisible = signUpState.isConfirmPasswordVisible; // 비밀번호 확인 가시성

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 비밀번호 확인 레이블
          style: TextStyle(fontSize: screenWidth * 0.05), // 화면 너비의 5%로 설정
        ),
        SizedBox(height: screenHeight * 0.01), // 화면 높이의 1% 빈 공간
        TextFormField(
          controller: controller, // 비밀번호 확인 입력 컨트롤러
          obscureText: !isVisible, // 비밀번호 확인 감추기 설정
          onChanged: (value) {
            signUpViewModel.validateConfirmPassword(value); // 비밀번호 확인 유효성 검사 호출
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: '*********', // 비밀번호 확인 입력 힌트
            errorText: signUpState.confirmPasswordError, // 비밀번호 확인 에러 메시지
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off, // 눈 아이콘 변경
              ),
              onPressed: () {
                signUpViewModel.toggleConfirmPasswordVisibility(); // 비밀번호 확인 가시성 토글
              },
            ),
          ),
        ),
      ],
    );
  }

  // 제출 버튼 빌더
  Widget _buildSubmitButton(
    BuildContext context,
    SignUpState signUpState,
    SignUpViewModel signUpViewModel,
    double screenWidth,
    double screenHeight,
  ) {
    return Center(
      child: ElevatedButton(
        onPressed: signUpState.isFormValid
            ? () {
                if (_formKey.currentState?.validate() ?? false) {
                  signUpViewModel.signUp(context); // 폼이 유효하면 회원가입 로직 실행
                }
              }
            : null, // 유효하지 않으면 비활성화
        style: ElevatedButton.styleFrom(
          backgroundColor: signUpState.isFormValid ? Color(0xFF1D2538) : Colors.grey,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.3, // 화면 너비의 30%로 패딩 설정
            vertical: screenHeight * 0.01, // 화면 높이의 1%로 패딩 설정
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          'アカウント作成', // 계정 생성 버튼
          style: TextStyle(
            fontSize: screenWidth * 0.045, // 화면 너비의 4.5%로 텍스트 크기 설정
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // 푸터 텍스트 빌더
  Widget _buildFooterText(BuildContext context, double screenWidth) {
    return Center(
      child: Text(
        'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenWidth * 0.03, // 화면 너비의 3%로 텍스트 크기 설정
          color: Colors.black,
        ),
      ),
    );
  }
}
