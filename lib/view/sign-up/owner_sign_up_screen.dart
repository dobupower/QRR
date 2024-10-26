import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/owner_sign_up_view_model.dart'; // ViewModel 가져오기

class OwnerSignUpScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();  // 폼의 상태를 관리하기 위한 글로벌 키

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpState = ref.watch(ownersignUpViewModelProvider);  // StateNotifierProvider에서 상태 읽기
    final signUpViewModel = ref.read(ownersignUpViewModelProvider.notifier);  // StateNotifierProvider에서 ViewModel 가져오기

    // 화면 크기 계산을 위해 MediaQuery 사용
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return PopScope<Object?>(
      canPop: false, // 뒤로 가기 제스처 및 버튼을 막음
      onPopInvokedWithResult: (bool didPop, Object? result) {
        // 뒤로 가기 동작을 하지 않도록 막음 (아무 동작도 하지 않음)
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => Navigator.pop(context),  // 뒤로 가기 버튼
          ),
          backgroundColor: Colors.transparent,  // 앱바 투명 배경
          elevation: 0,  // 그림자 없애기
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(screenWidth * 0.04),  // 전체 화면 패딩 설정
          child: Form(
            key: _formKey,  // 폼 상태 관리
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    '会員登録',  // 타이틀
                    style: TextStyle(
                      fontSize: screenWidth * 0.06,  // 상대적인 글자 크기
                      fontWeight: FontWeight.bold,  // 굵은 글씨체
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // '店舗名' 텍스트 필드 빌드
                _buildTextField(
                  '店舗名',
                  '店舗名を入力してください',
                  signUpState.storeNameController,
                  screenWidth,
                  screenHeight,
                  signUpViewModel,
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 이메일 입력 필드
                _buildEmailField(
                  'メールアドレス',
                  signUpState.emailController,
                  screenWidth,
                  screenHeight,
                  signUpState,
                  signUpViewModel,
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 비밀번호 입력 필드
                _buildPasswordField(
                  'パスワード',
                  signUpState.passwordController,
                  screenWidth,
                  screenHeight,
                  signUpState,
                  signUpViewModel,
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 비밀번호 확인 필드
                _buildConfirmPasswordField(
                  'パスワード確認',
                  signUpState.confirmPasswordController,
                  screenWidth,
                  screenHeight,
                  signUpState,
                  signUpViewModel,
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 우편번호와 도도부현 (都道府県) 입력 필드
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        '郵便番号',
                        '郵便番号を入力してください',
                        signUpState.zipCodeController,
                        screenWidth,
                        screenHeight,
                        signUpViewModel,
                      ),
                    ),
                    SizedBox(width: screenWidth * 0.02),  // 우편번호와 도도부현 사이의 여백
                    Expanded(
                      child: _buildTextField(
                        '都道府県',
                        '都道府県を入力してください',
                        signUpState.stateController,
                        screenWidth,
                        screenHeight,
                        signUpViewModel,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 시/구/읍/면/동 입력 필드
                _buildTextField(
                  '市区町村',
                  '市区町村を入力してください',
                  signUpState.cityController,
                  screenWidth,
                  screenHeight,
                  signUpViewModel,
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 상세 주소 입력 필드
                _buildTextField(
                  '住所',
                  '住所を入力してください',
                  signUpState.addressController,
                  screenWidth,
                  screenHeight,
                  signUpViewModel,
                ),
                SizedBox(height: screenHeight * 0.02),  // 여백
                
                // 건물명/호실번호(선택사항) 입력 필드
                _buildTextField(
                  '建物名、部屋番号など(任意)',
                  '建物名、部屋番号などを入力してください',
                  signUpState.buildingController,
                  screenWidth,
                  screenHeight,
                  signUpViewModel,
                  isOptional: true,  // 선택 필드로 설정
                ),
                SizedBox(height: screenHeight * 0.1),  // 버튼 위에 공간 추가

                // 아카운트 생성 버튼
                Center(
                  child: ElevatedButton(
                    onPressed: signUpState.isFormValid
                        ? () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              _showLoadingDialog(context);  // 로딩 스피너 표시
                              signUpViewModel.signUp(context);  // 회원가입 로직 실행
                              await Future.delayed(Duration(seconds: 2));  // 2초 지연
                              Navigator.pop(context);  // 로딩 스피너 닫기
                            }
                          }
                        : null,  // 폼이 유효하지 않으면 버튼 비활성화
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signUpState.isFormValid
                          ? Color(0xFF1D2538)  // 유효할 때의 버튼 색상
                          : Colors.grey,  // 유효하지 않을 때의 버튼 색상
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.3,  // 버튼 가로 패딩
                        vertical: screenHeight * 0.01,  // 버튼 세로 패딩
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenHeight * 0.05),  // 버튼의 모서리를 화면 높이의 5%로 설정
                      ),
                    ),
                    child: Text(
                      'アカウント作成',  // 버튼 텍스트
                      style: TextStyle(
                        fontSize: screenWidth * 0.045,  // 버튼 글자 크기
                        color: Colors.white,  // 버튼 텍스트 색상
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),  // 하단 여백

                // 약관 및 정책 안내 텍스트
                Center(
                  child: Text(
                    'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: screenWidth * 0.03,  // 텍스트 크기
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 로딩 스피너 다이얼로그 표시 함수
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,  // 로딩 중 다이얼로그 외부를 클릭해도 닫히지 않도록 설정
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,  // 다이얼로그 배경 투명
          elevation: 0,  // 그림자 없음
          child: Center(
            child: CircularProgressIndicator(),  // 로딩 스피너 표시
          ),
        );
      },
    );
  }

  // 텍스트 필드를 빌드하는 함수
  Widget _buildTextField(
    String label,  // 필드의 라벨
    String hint,  // 힌트 텍스트
    TextEditingController controller,  // 텍스트 입력을 제어하는 컨트롤러
    double screenWidth,  // 화면 너비
    double screenHeight,  // 화면 높이
    OwnerSignUpViewModel signUpViewModel,  // ViewModel
    {bool isOptional = false} // 필수 필드인지 선택 필드인지 구분하는 플래그
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),  // 라벨 표시
        SizedBox(height: screenHeight * 0.01),  // 라벨과 입력 필드 사이 여백
        TextFormField(
          controller: controller,  // 입력 필드에 연결된 컨트롤러
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenHeight * 0.02),  // 입력 필드 테두리 모서리를 화면 높이의 2%로 설정
              borderSide: BorderSide(color: Colors.grey),  // 테두리 색상 설정
            ),
            hintText: hint,  // 힌트 텍스트 설정
          ),
          onChanged: (value) {
            if (!isOptional) {
              signUpViewModel.validateFields();  // 선택 필드가 아닌 경우 필드 검증 호출
            }
          },
        ),
      ],
    );
  }

  // 이메일 입력 필드를 빌드하는 함수
  Widget _buildEmailField(
    String label,
    TextEditingController controller,
    double screenWidth,
    double screenHeight,
    SignUpState signUpState,
    OwnerSignUpViewModel signUpViewModel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),  // 라벨 표시
        SizedBox(height: screenHeight * 0.01),  // 라벨과 입력 필드 사이 여백
        TextFormField(
          controller: controller,  // 이메일 입력 필드에 연결된 컨트롤러
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenHeight * 0.02),  // 입력 필드 테두리 둥글게 설정
              borderSide: BorderSide(
                color: signUpState.emailError != null ? Colors.red : Colors.grey,  // 에러가 있을 경우 빨간색 테두리
              ),
            ),
            hintText: 'メールアドレスを入力してください',  // 이메일 입력 필드의 힌트
            errorText: signUpState.emailError,  // 에러 메시지
          ),
          keyboardType: TextInputType.emailAddress,  // 이메일 입력 형식
          onChanged: (value) {
            signUpViewModel.validateEmail(value);  // 이메일 검증
          },
        ),
      ],
    );
  }

  // 비밀번호 입력 필드를 빌드하는 함수
  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    double screenWidth,
    double screenHeight,
    SignUpState signUpState,
    OwnerSignUpViewModel signUpViewModel,
  ) {
    final isVisible = signUpState.isPasswordVisible;  // 비밀번호 표시 여부

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),  // 라벨 표시
        SizedBox(height: screenHeight * 0.01),  // 라벨과 입력 필드 사이 여백
        TextFormField(
          controller: controller,  // 비밀번호 입력 필드에 연결된 컨트롤러
          obscureText: !isVisible,  // 비밀번호 가리기 설정
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenHeight * 0.02),  // 입력 필드 테두리 둥글게 설정
              borderSide: BorderSide(color: Colors.grey),  // 테두리 색상 설정
            ),
            hintText: '*********',  // 비밀번호 입력 필드의 힌트
            errorText: signUpState.passwordError,  // 에러 메시지
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),  // 비밀번호 표시/숨기기 아이콘
              onPressed: signUpViewModel.togglePasswordVisibility,  // 아이콘 클릭 시 비밀번호 표시 여부 토글
            ),
          ),
          onChanged: (value) {
            signUpViewModel.validatePassword(value);  // 비밀번호 검증
          },
        ),
      ],
    );
  }

  // 비밀번호 확인 입력 필드를 빌드하는 함수
  Widget _buildConfirmPasswordField(
    String label,
    TextEditingController controller,
    double screenWidth,
    double screenHeight,
    SignUpState signUpState,
    OwnerSignUpViewModel signUpViewModel,
  ) {
    final isVisible = signUpState.isConfirmPasswordVisible;  // 비밀번호 확인 표시 여부

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),  // 라벨 표시
        SizedBox(height: screenHeight * 0.01),  // 라벨과 입력 필드 사이 여백
        TextFormField(
          controller: controller,  // 비밀번호 확인 입력 필드에 연결된 컨트롤러
          obscureText: !isVisible,  // 비밀번호 가리기 설정
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenHeight * 0.02),  // 입력 필드 테두리 둥글게 설정
              borderSide: BorderSide(color: Colors.grey),  // 테두리 색상 설정
            ),
            hintText: '*********',  // 비밀번호 확인 필드의 힌트
            errorText: signUpState.confirmPasswordError,  // 에러 메시지
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),  // 비밀번호 표시/숨기기 아이콘
              onPressed: signUpViewModel.toggleConfirmPasswordVisibility,  // 아이콘 클릭 시 비밀번호 표시 여부 토글
            ),
          ),
          onChanged: (value) {
            signUpViewModel.validateConfirmPassword(value);  // 비밀번호 확인 검증
          },
        ),
      ],
    );
  }
}
