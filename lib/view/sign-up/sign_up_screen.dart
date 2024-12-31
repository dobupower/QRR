import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/sign_up_view_model.dart';
import '../../model/signup_state_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    final signUpState = ref.watch(signUpViewModelProvider);
    final signUpViewModel = ref.read(signUpViewModelProvider.notifier);
    final localizations = AppLocalizations.of(context);

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
              _buildHeader(screenWidth, context),
              SizedBox(height: screenHeight * 0.02),
              _buildTextField(
                label: localizations?.signupScreenName1 ?? '',
                hint: localizations?.signupScreenName2 ?? '',
                controller: signUpState.nameController,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildEmailField(
                label: localizations?.ownerSignUpScreenEmail1 ?? '',
                hint: 'Enter your email',
                controller: signUpState.emailController,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                context: context
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildPasswordField(
                label: localizations?.ownerSignUpScreenPassword1 ?? '',
                controller: signUpState.passwordController,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
                isConfirmField: false,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                context: context
              ),
              SizedBox(height: screenHeight * 0.02),
              _buildPasswordField(
                label: localizations?.ownerSignUpScreenPasswordConfirm1 ?? '',
                controller: signUpState.confirmPasswordController,
                signUpState: signUpState,
                signUpViewModel: signUpViewModel,
                isConfirmField: true,
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                context: context
              ),
              SizedBox(height: screenHeight * 0.1),
              _buildSubmitButton(context, signUpState, signUpViewModel, screenWidth, screenHeight),
              SizedBox(height: screenHeight * 0.02),
              _buildFooterText(screenWidth, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth, BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.firstScreenSignUp ?? '',
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
    required BuildContext context
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
          onChanged: (value) => signUpViewModel.validateEmail(value, context),
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
    required BuildContext context
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
                ? signUpViewModel.validateConfirmPassword(value, context)
                : signUpViewModel.validatePassword(value, context);
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
        onPressed: signUpState.isFormValid && !signUpState.isLoading
            ? () {
                if (_formKey.currentState?.validate() ?? false) {
                  signUpViewModel.signUp(context);
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: signUpState.isFormValid && !signUpState.isLoading
              ? Color(0xFF1D2538)
              : Colors.grey,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.3,
            vertical: screenHeight * 0.01,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: signUpState.isLoading
            ? CircularProgressIndicator(color: Colors.white)  // 로딩 중일 경우
            : Text(
                AppLocalizations.of(context)?.ownerSignUpScreenSubmit1 ?? '',
                style: TextStyle(fontSize: screenWidth * 0.045, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildFooterText(double screenWidth, BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.ownerSignUpScreenSubmit2 ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: screenWidth * 0.03),
      ),
    );
  }
}
