import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/owner_sign_up_view_model.dart';
import 'photo_upload_screen.dart'; // photo_upload_screen을 임포트
import '../../model/owner_signup_state_model.dart';

class OwnerSignUpScreen extends ConsumerStatefulWidget {
  @override
  _OwnerSignUpScreenState createState() => _OwnerSignUpScreenState();
}

class _OwnerSignUpScreenState extends ConsumerState<OwnerSignUpScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 상태를 watch하여 변경 시 UI가 리빌드되도록 함
    final signUpState = ref.watch(ownerSignUpViewModelProvider);
    // ViewModel을 read하여 상태 변경을 수행
    final signUpViewModel = ref.read(ownerSignUpViewModelProvider.notifier);

    // 회원가입 성공 시 photo_upload_screen으로 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (signUpState.signUpSuccess) {
        print('Navigating to PhotoUploadScreen'); // 디버그 로그 추가
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoUploadScreen(),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('アカウント作成が完了しました。写真をアップロードしてください。')),
        );
        signUpViewModel.resetSignUpSuccess();
      }

      if (signUpState.signUpError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(signUpState.signUpError!)),
        );
        signUpViewModel.resetSignUpError();
      }
    });

    // 화면 크기 계산을 위해 MediaQuery 사용
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context), // 뒤로 가기 버튼
        ),
        backgroundColor: Colors.transparent, // 앱바 투명 배경
        elevation: 0, // 그림자 없애기
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // 전체 화면 패딩 설정
        child: Form(
          key: _formKey, // 폼 상태 관리
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  '会員登録', // 타이틀
                  style: TextStyle(
                    fontSize: screenWidth * 0.06, // 상대적인 글자 크기
                    fontWeight: FontWeight.bold, // 굵은 글씨체
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // '店舗名' 텍스트 필드 빌드
              _buildTextField(
                label: '店舗名',
                hint: '店舗名を入力してください',
                screenWidth: screenWidth,
                onChanged: signUpViewModel.updateStoreName,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '店舗名を入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 이메일 입력 필드
              _buildEmailField(
                screenWidth: screenWidth,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 비밀번호 입력 필드
              _buildPasswordField(
                label: 'パスワード',
                screenWidth: screenWidth,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 비밀번호 확인 필드
              _buildConfirmPasswordField(
                label: 'パスワード確認',
                screenWidth: screenWidth,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 우편번호와 도도부현 (都道府県) 입력 필드
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      label: '郵便番号',
                      hint: '郵便番号を入力してください',
                      screenWidth: screenWidth,
                      onChanged: signUpViewModel.updateZipCode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '郵便番号を入力してください';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.02), // 우편번호와 도도부현 사이의 여백
                  Expanded(
                    child: _buildTextField(
                      label: '都道府県',
                      hint: '都道府県を入力してください',
                      screenWidth: screenWidth,
                      onChanged: signUpViewModel.updateState,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '都道府県を入力してください';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 시/구/읍/면/동 입력 필드
              _buildTextField(
                label: '市区町村',
                hint: '市区町村を入力してください',
                screenWidth: screenWidth,
                onChanged: signUpViewModel.updateCity,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '市区町村を入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 상세 주소 입력 필드
              _buildTextField(
                label: '住所',
                hint: '住所を入力してください',
                screenWidth: screenWidth,
                onChanged: signUpViewModel.updateAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '住所を入力してください';
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02), // 여백

              // 건물명/호실번호(선택사항) 입력 필드
              _buildTextField(
                label: '建物名、部屋番号など(任意)',
                hint: '建物名、部屋番号などを入力してください',
                screenWidth: screenWidth,
                onChanged: signUpViewModel.updateBuilding,
                isOptional: true, // 선택 필드로 설정
              ),
              SizedBox(height: screenHeight * 0.1), // 버튼 위에 공간 추가

              // 아카운트 생성 버튼
              Center(
                child: ElevatedButton(
                  onPressed: signUpState.isFormValid
                      ? () async {
                          if (_formKey.currentState?.validate() ?? false) {
                            await signUpViewModel.signUp(); // 회원가입 로직 실행
                          }
                        }
                      : null, // 폼이 유효하지 않으면 버튼 비활성화
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signUpState.isFormValid
                        ? Color(0xFF1D2538) // 유효할 때의 버튼 색상
                        : Colors.grey, // 유효하지 않을 때의 버튼 색상
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.3, // 버튼 가로 패딩
                      vertical: screenHeight * 0.01, // 버튼 세로 패딩
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(50), // 버튼의 모서리 둥글게 설정
                    ),
                  ),
                  child: Text(
                    'アカウント作成', // 버튼 텍스트
                    style: TextStyle(
                      fontSize: screenWidth * 0.045, // 버튼 글자 크기
                      color: Colors.white, // 버튼 텍스트 색상
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02), // 하단 여백

              // 약관 및 정책 안내 텍스트
              Center(
                child: Text(
                  'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: screenWidth * 0.03, // 텍스트 크기
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 텍스트 필드를 빌드하는 함수
  Widget _buildTextField({
    required String label,
    required String hint,
    required double screenWidth,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(color: Colors.grey),
            ),
            hintText: hint,
          ),
          validator: validator ??
              (value) {
                if (!isOptional && (value == null || value.isEmpty)) {
                  return '$labelを入力してください';
                }
                return null;
              },
          onChanged: (value) {
            onChanged(value);
          },
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }

  // 이메일 입력 필드를 빌드하는 함수
  Widget _buildEmailField({
    required double screenWidth,
    required OwnerSignUpState signUpState,
    required OwnerSignUpViewModel signUpViewModel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('メールアドレス', style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: 10),
        TextFormField(
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: signUpState.emailError != null ? Colors.red : Colors.grey,
              ),
            ),
            hintText: 'メールアドレスを入力してください',
            errorText: signUpState.emailError,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) {
            signUpViewModel.updateEmail(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'メールアドレスを入力してください';
            }
            if (signUpState.emailError != null) {
              return signUpState.emailError;
            }
            return null;
          },
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }

  // 비밀번호 입력 필드를 빌드하는 함수
  Widget _buildPasswordField({
    required String label,
    required double screenWidth,
    required OwnerSignUpState signUpState,
    required OwnerSignUpViewModel signUpViewModel,
  }) {
    final isVisible = signUpState.isPasswordVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: 10),
        TextFormField(
          obscureText: !isVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: signUpState.passwordError != null ? Colors.red : Colors.grey,
              ),
            ),
            hintText: '*********',
            errorText: signUpState.passwordError,
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: signUpViewModel.togglePasswordVisibility,
            ),
          ),
          onChanged: (value) {
            signUpViewModel.updatePassword(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'パスワードを入力してください';
            }
            if (signUpState.passwordError != null) {
              return signUpState.passwordError;
            }
            return null;
          },
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }

  // 비밀번호 확인 입력 필드를 빌드하는 함수
  Widget _buildConfirmPasswordField({
    required String label,
    required double screenWidth,
    required OwnerSignUpState signUpState,
    required OwnerSignUpViewModel signUpViewModel,
  }) {
    final isVisible = signUpState.isConfirmPasswordVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: 10),
        TextFormField(
          obscureText: !isVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: signUpState.confirmPasswordError != null
                    ? Colors.red
                    : Colors.grey,
              ),
            ),
            hintText: '*********',
            errorText: signUpState.confirmPasswordError,
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: signUpViewModel.toggleConfirmPasswordVisibility,
            ),
          ),
          onChanged: (value) {
            signUpViewModel.updateConfirmPassword(value);
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'パスワード確認を入力してください';
            }
            if (signUpState.confirmPasswordError != null) {
              return signUpState.confirmPasswordError;
            }
            return null;
          },
          autocorrect: false,
          enableSuggestions: false,
        ),
      ],
    );
  }
}
