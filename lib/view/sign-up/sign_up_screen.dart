import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/sign_up_view_model.dart';
import '../../model/signup_state_model.dart';

class SignUpScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final signUpState = ref.watch(signUpViewModelProvider);
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(screenWidth),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(
                label: '表示名',
                hint: 'あかばね',
                controller: signUpState.nameController,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildEmailField(
                label: 'メールアドレス',
                hint: 'Enter your email',
                controller: signUpState.emailController,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildPasswordField(
                label: 'パスワード',
                controller: signUpState.passwordController,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
                isConfirmField: false,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildPasswordField(
                label: 'パスワード確認',
                controller: signUpState.confirmPasswordController,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
                isConfirmField: true,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.1),
              _buildSubmitButton(context, signUpState, signUpViewModel, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
              _buildFooterText(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Center(
      child: Text(
        '会員登録',
        style: TextStyle(fontSize: screenWidth * 0.06, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: screenHeight * 0.01),
        TextFormField(
          controller: controller ?? TextEditingController(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            hintText: hint,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField({
    required String label,
    required String hint,
    required TextEditingController? controller,
    required SignUpState signUpState,
    required SignUpViewModel signUpViewModel,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: screenHeight * 0.01),
        TextFormField(
          controller: controller ?? TextEditingController(),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            hintText: hint,
            errorText: signUpState.emailError,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => signUpViewModel.validateEmail(value),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController? controller,
    required SignUpState signUpState,
    required SignUpViewModel signUpViewModel,
    required bool isConfirmField,
    required double screenWidth,
    required double screenHeight,
  }) {
    final bool isVisible = isConfirmField ? signUpState.isConfirmPasswordVisible : signUpState.isPasswordVisible;
    final errorText = isConfirmField ? signUpState.confirmPasswordError : signUpState.passwordError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: screenWidth * 0.05)),
        SizedBox(height: screenHeight * 0.01),
        TextFormField(
          controller: controller ?? TextEditingController(),
          obscureText: !isVisible,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            hintText: '*********',
            errorText: errorText,
            suffixIcon: IconButton(
              icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                isConfirmField
                    ? signUpViewModel.toggleConfirmPasswordVisibility()
                    : signUpViewModel.togglePasswordVisibility();
              },
            ),
          ),
          onChanged: (value) {
            isConfirmField
                ? signUpViewModel.validateConfirmPassword(value)
                : signUpViewModel.validatePassword(value);
          },
        ),
      ],
    );
  }

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
                  signUpViewModel.signUp(context);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: signUpState.isFormValid ? Color(0xFF1D2538) : Colors.grey,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.3,
            vertical: screenHeight * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          'アカウント作成',
          style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildFooterText(double screenWidth) {
    return Center(
      child: Text(
        'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: screenWidth * 0.03),
      ),
    );
  }
}
