import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../viewModel/owner_sign_up_view_model.dart';
import '../../model/owner_signup_state_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      handleVerificationState(context, signUpState, signUpViewModel);
    });

    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) {},
      child: Scaffold(
        appBar: CustomAppBar(),
        body: AuthScreenBody(
          codeController: _codeController,
          ownerEmail: signUpState.owner?.email,
          signUpViewModel: signUpViewModel,
        ),
      ),
    );
  }

  void handleVerificationState(BuildContext context, OwnerSignUpState signUpState, OwnerSignUpViewModel signUpViewModel) {
    final localizations = AppLocalizations.of(context);
    if (signUpState.verificationSuccess) {
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.ownerEmailAuthScreenOkay ?? '')),
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
        SnackBar(content: Text(localizations?.emailAuthScreenCodeResend1 ?? '')),
      );
      signUpViewModel.resetResendCodeSuccess();
    }

    if (signUpState.resendCodeError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(signUpState.resendCodeError!)),
      );
      signUpViewModel.resetResendCodeError();
    }
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey),
        onPressed: () => Navigator.pop(context),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class AuthScreenBody extends StatelessWidget {
  final TextEditingController codeController;
  final String? ownerEmail;
  final OwnerSignUpViewModel signUpViewModel;

  AuthScreenBody({
    required this.codeController,
    required this.ownerEmail,
    required this.signUpViewModel,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.all(screenSize.width * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TitleSection(screenSize: screenSize),
          SizedBox(height: screenSize.height * 0.02),
          DescriptionSection(ownerEmail: ownerEmail, screenSize: screenSize),
          SizedBox(height: screenSize.height * 0.04),
          CodeInputField(codeController: codeController, screenSize: screenSize),
          Spacer(),
          ResendCodeButton(signUpViewModel: signUpViewModel),
          SubmitButton(
            codeController: codeController,
            signUpViewModel: signUpViewModel,
            screenSize: screenSize,
          ),
          SizedBox(height: screenSize.height * 0.05),
        ],
      ),
    );
  }
}

class TitleSection extends StatelessWidget {
  final Size screenSize;

  TitleSection({required this.screenSize});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)?.emailAuthScreenAccount ?? '',
        style: TextStyle(
          fontSize: screenSize.width * 0.07,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DescriptionSection extends StatelessWidget {
  final String? ownerEmail;
  final Size screenSize;

  DescriptionSection({required this.ownerEmail, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Center(
      child: Text(
        ('${ownerEmail ?? ''}') + (localizations?.emailAuthScreenCodeSend ?? '') + '\n' + (localizations?.emailAuthScreenCodeInput2 ?? ''),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenSize.width * 0.038,
          color: Colors.black,
        ),
      ),
    );
  }
}

class CodeInputField extends StatelessWidget {
  final TextEditingController codeController;
  final Size screenSize;

  CodeInputField({required this.codeController, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations?.emailAuthScreenCode ?? '',
          style: TextStyle(fontSize: screenSize.width * 0.045),
        ),
        SizedBox(height: screenSize.height * 0.01),
        TextField(
          controller: codeController,
          decoration: InputDecoration(
            hintText: localizations?.emailAuthScreenCodeInput1 ?? '',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(screenSize.width * 0.03),
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
          keyboardType: TextInputType.number,
          maxLength: 4,
        ),
      ],
    );
  }
}

class ResendCodeButton extends StatelessWidget {
  final OwnerSignUpViewModel signUpViewModel;

  ResendCodeButton({required this.signUpViewModel});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          signUpViewModel.resendVerificationCode(context);
        },
        child: Text(
          AppLocalizations.of(context)?.emailAuthScreenCodeResend2 ?? '',
          style: TextStyle(color: Colors.blue),
        ),
      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final TextEditingController codeController;
  final OwnerSignUpViewModel signUpViewModel;
  final Size screenSize;

  SubmitButton({
    required this.codeController,
    required this.signUpViewModel,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          await signUpViewModel.verifyCode(codeController.text, context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1D2538),
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.width * 0.3,
            vertical: screenSize.height * 0.015,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(screenSize.width * 0.07),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)?.emailAuthScreenAccount ?? '',
          style: TextStyle(
            fontSize: screenSize.width * 0.045,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
