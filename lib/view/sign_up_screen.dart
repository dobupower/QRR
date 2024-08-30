import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewModel/sign_up_view_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ScrollController _scrollController = ScrollController(); // 스크롤 위치를 제어하기 위한 컨트롤러
  final FocusNode _nameFocusNode = FocusNode(); // '表示名' 입력 필드의 포커스를 관리하는 FocusNode
  final FocusNode _emailFocusNode = FocusNode(); // 'メールアドレス' 입력 필드의 포커스를 관리하는 FocusNode
  final FocusNode _passwordFocusNode = FocusNode(); // 'パスワード' 입력 필드의 포커스를 관리하는 FocusNode
  final FocusNode _confirmPasswordFocusNode = FocusNode(); // 'パスワード確認' 입력 필드의 포커스를 관리하는 FocusNode
  final _formKey = GlobalKey<FormState>(); // 폼의 상태를 관리하는 글로벌 키

  @override
  void initState() {
    super.initState();

    // 각 입력 필드에 포커스가 갈 때 스크롤 위치를 조정하도록 리스너 추가
    _nameFocusNode.addListener(() => _scrollToFocus(_nameFocusNode));
    _emailFocusNode.addListener(() => _scrollToFocus(_emailFocusNode));
    _passwordFocusNode.addListener(() => _scrollToFocus(_passwordFocusNode));
    _confirmPasswordFocusNode.addListener(() => _scrollToFocus(_confirmPasswordFocusNode));
  }

  // 입력 필드에 포커스가 갈 때 해당 필드가 화면에 잘 보이도록 스크롤을 이동
  void _scrollToFocus(FocusNode focusNode) {
    if (focusNode.hasFocus) {
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: Colors.grey,
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // 뒤로가기 버튼
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0, // 투명한 배경과 그림자 제거
          ),
          body: SingleChildScrollView(
            controller: _scrollController, // 스크롤 컨트롤러 연결
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey, // 폼의 상태를 관리하는 글로벌 키 연결
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '会員登録', // 회원가입 텍스트
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildTextField('表示名', 'あかばね', viewModel.nameController), // 이름 입력 필드 생성
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildEmailField('メールアドレス', 'Enter your email', viewModel), // 이메일 입력 필드 생성
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildPasswordField('パスワード', viewModel.passwordController, viewModel, true), // 비밀번호 입력 필드 생성
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  _buildPasswordField('パスワード確認', viewModel.confirmPasswordController, viewModel, false), // 비밀번호 확인 입력 필드 생성
                  SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                  Center(
                    child: ElevatedButton(
                      onPressed: viewModel.isFormValid
                          ? () async {
                              if (_formKey.currentState!.validate()) { // 폼의 상태가 유효한지 확인
                                debugPrint('Submit button pressed');
                                await viewModel.signUp(context); // 회원가입 시도
                              }
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1D2538),
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.of(context).size.width * 0.3,
                          vertical: MediaQuery.of(context).size.height * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'アカウント作成', // 'アカウント作成' 텍스트
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                  Center(
                    child: Text(
                      'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。', // 하단 약관 동의 문구
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.03,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // 일반 텍스트 필드 빌더
  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 라벨 텍스트
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          controller: controller, // 텍스트 컨트롤러 연결
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: hint, // 힌트 텍스트
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$labelを入力してください'; // 필드가 비어 있을 때 오류 메시지
            }
            return null;
          },
        ),
      ],
    );
  }

  // 이메일 필드 빌더
  Widget _buildEmailField(String label, String hint, SignUpViewModel viewModel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 라벨 텍스트
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          controller: viewModel.emailController, // 이메일 컨트롤러 연결
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: hint, // 힌트 텍스트
            errorText: viewModel.emailError, // 이메일 형식이 잘못된 경우 오류 메시지 표시
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            viewModel.validateEmail(value); // 이메일 유효성 검사
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$labelを入力してください'; // 필드가 비어 있을 때 오류 메시지
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return '正しいメールアドレスを入力してください。'; // 이메일 형식이 잘못된 경우 오류 메시지
            }
            return null;
          },
        ),
      ],
    );
  }

  // 비밀번호 필드 빌더
  Widget _buildPasswordField(String label, TextEditingController controller, SignUpViewModel viewModel, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label, // 라벨 텍스트
          style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.05),
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
        TextFormField(
          controller: controller, // 비밀번호 컨트롤러 연결
          obscureText: isPassword ? !viewModel.isPasswordVisible : !viewModel.isConfirmPasswordVisible, // 비밀번호 가시성 설정
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: '*********', // 힌트 텍스트
            suffixIcon: IconButton(
              icon: Icon(isPassword
                  ? (viewModel.isPasswordVisible ? Icons.visibility : Icons.visibility_off)
                  : (viewModel.isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off)),
              onPressed: () {
                if (isPassword) {
                  viewModel.togglePasswordVisibility(); // 비밀번호 표시/숨기기 토글
                } else {
                  viewModel.toggleConfirmPasswordVisibility(); // 비밀번호 확인 표시/숨기기 토글
                }
              },
            ),
            errorText: isPassword ? viewModel.passwordError : viewModel.confirmPasswordError, // 오류 메시지 표시
          ),
          onChanged: (value) {
            viewModel.validatePasswordFields(); // 비밀번호 유효성 검사
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return '$labelを入力してください'; // 필드가 비어 있을 때 오류 메시지
            }
            if (isPassword && value.length < 8) {
              return 'パスワードは8文字以上で入力してください。'; // 비밀번호가 8자리 미만일 때 오류 메시지
            }
            return null;
          },
        ),
      ],
    );
  }
}
