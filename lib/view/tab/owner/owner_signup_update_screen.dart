import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/owner_sign_up_view_model.dart';
import '../../../model/owner_signup_state_model.dart';

/// Main Sign-Up Screen
class OwnerSignUpUpdateScreen extends ConsumerStatefulWidget {
  @override
  _OwnerSignUpScreenState createState() => _OwnerSignUpScreenState();
}

class _OwnerSignUpScreenState extends ConsumerState<OwnerSignUpUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the sign-up state to rebuild UI on changes
    final signUpState = ref.watch(ownerSignUpViewModelProvider);
    // Read the ViewModel to perform state changes
    final signUpViewModel = ref.read(ownerSignUpViewModelProvider.notifier);

    // Navigate to PhotoUploadScreen on successful sign-up
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (signUpState.signUpSuccess) {
        print('Navigating to PhotoUploadScreen'); // Debug log
        Navigator.pop(context);

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

    // Calculate screen size using MediaQuery
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width;
    final screenHeight = screenSize.height;

    return Scaffold(
      appBar: CustomAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04), // Set padding for the entire screen
        child: Form(
          key: _formKey, // Manage form state
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FormTitle(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.02), // Spacer

              StoreNameField(screenWidth: screenWidth, signUpViewModel: signUpViewModel),
              SizedBox(height: screenHeight * 0.02), // Spacer

              AddressFields(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.02), // Spacer

              CityField(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.02), // Spacer

              AddressField(screenWidth: screenWidth),
              SizedBox(height: screenHeight * 0.02), // Spacer

              BuildingField(screenWidth: screenWidth, signUpViewModel: signUpViewModel),
              SizedBox(height: screenHeight * 0.1), // Extra space above the button

              SubmitButton(
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    await signUpViewModel.updateOwnerInfo();
                    Navigator.pop(context);
                  }
                },
                screenWidth: screenWidth,
                screenHeight: screenHeight,
              ),
              SizedBox(height: screenHeight * 0.02), // Bottom spacer

              TermsText(screenWidth: screenWidth),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom AppBar Widget
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.grey),
        onPressed: () => Navigator.pop(context), // Back button
      ),
      backgroundColor: Colors.transparent, // Transparent AppBar
      elevation: 0, // Remove shadow
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

/// Form Title Widget
class FormTitle extends StatelessWidget {
  final double screenWidth;

  const FormTitle({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '会員登録', // Title
        style: TextStyle(
          fontSize: screenWidth * 0.06, // Relative font size
          fontWeight: FontWeight.bold, // Bold font
        ),
      ),
    );
  }
}

/// Store Name Field Widget
class StoreNameField extends ConsumerWidget {
  final double screenWidth;
  final OwnerSignUpViewModel signUpViewModel;

  const StoreNameField({
    required this.screenWidth,
    required this.signUpViewModel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomTextField(
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
    );
  }
}

/// Address Fields Widget (Zip Code and Prefecture)
class AddressFields extends ConsumerWidget {
  final double screenWidth;

  const AddressFields({required this.screenWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.read(ownerSignUpViewModelProvider.notifier);

    return Row(
      children: [
        Expanded(
          child: CustomTextField(
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
        SizedBox(width: screenWidth * 0.02), // Spacer between Zip Code and Prefecture
        Expanded(
          child: CustomTextField(
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
    );
  }
}

/// City Field Widget
class CityField extends ConsumerWidget {
  final double screenWidth;

  const CityField({required this.screenWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.read(ownerSignUpViewModelProvider.notifier);

    return CustomTextField(
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
    );
  }
}

/// Address Field Widget
class AddressField extends ConsumerWidget {
  final double screenWidth;

  const AddressField({required this.screenWidth});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signUpViewModel = ref.read(ownerSignUpViewModelProvider.notifier);

    return CustomTextField(
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
    );
  }
}

/// Building Field Widget (Optional)
class BuildingField extends StatelessWidget {
  final double screenWidth;
  final OwnerSignUpViewModel signUpViewModel;

  const BuildingField({
    required this.screenWidth,
    required this.signUpViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: '建物名、部屋番号など(任意)',
      hint: '建物名、部屋番号などを入力してください',
      screenWidth: screenWidth,
      onChanged: signUpViewModel.updateBuilding,
      isOptional: true, // Mark as optional
    );
  }
}

/// Submit Button Widget
class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;
  final double screenWidth;
  final double screenHeight;

  const SubmitButton({
    required this.onPressed,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: onPressed, 
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1D2538),
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.3, 
            vertical: screenHeight * 0.01, 
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50), 
          ),
        ),
        child: Text(
          'アカウント作成', // Button text
          style: TextStyle(
            fontSize: screenWidth * 0.045, // Font size
            color: Colors.white, // Text color
          ),
        ),
      ),
    );
  }
}

/// Terms and Conditions Text Widget
class TermsText extends StatelessWidget {
  final double screenWidth;

  const TermsText({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: screenWidth * 0.03, // Text size
          color: Colors.black,
        ),
      ),
    );
  }
}

/// Custom Text Field Widget
class CustomTextField extends StatelessWidget {
  final String label;
  final String hint;
  final double screenWidth;
  final Function(String) onChanged;
  final String? Function(String?)? validator;
  final bool isOptional;

  const CustomTextField({
    required this.label,
    required this.hint,
    required this.screenWidth,
    required this.onChanged,
    this.validator,
    this.isOptional = false,
  });

  @override
  Widget build(BuildContext context) {
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
}
