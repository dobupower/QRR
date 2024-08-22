import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    
    _nameFocusNode.addListener(() => _scrollToFocus(_nameFocusNode));
    _emailFocusNode.addListener(() => _scrollToFocus(_emailFocusNode));
    _passwordFocusNode.addListener(() => _scrollToFocus(_passwordFocusNode));
    _confirmPasswordFocusNode.addListener(() => _scrollToFocus(_confirmPasswordFocusNode));
  }

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
    return LayoutBuilder(
      builder: (context, constraints) {
        double width = constraints.maxWidth;
        double height = constraints.maxHeight;

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
                // 뒤로 가기 버튼 동작
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(16.0),
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      '会員登録',
                      style: TextStyle(
                        fontSize: width * 0.06,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  _buildTextField('表示名', 'あかばね', width, height, _nameFocusNode),
                  SizedBox(height: height * 0.02),
                  _buildTextField('メールアドレス', 'Enter your email', width, height, _emailFocusNode),
                  SizedBox(height: height * 0.02),
                  _buildPasswordField('パスワード', '*********', width, height, _passwordFocusNode, true),
                  SizedBox(height: height * 0.02),
                  _buildPasswordField('パスワード確認', '*********', width, height, _confirmPasswordFocusNode, true),
                  SizedBox(height: height * 0.1),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // 회원가입 로직
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1D2538),
                        padding: EdgeInsets.symmetric(
                          horizontal: width * 0.3,
                          vertical: height * 0.01,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      child: Text(
                        'アカウント作成',
                        style: TextStyle(
                          fontSize: width * 0.045,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  Center(
                    child: Text(
                      'アカウント作成することでサービス利用規約およびプライバシーポリシーに同意したことになります。必ず御読みください。',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: width * 0.03,
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

  Widget _buildTextField(String label, String hint, double width, double height, FocusNode focusNode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: width * 0.05),
        ),
        SizedBox(height: height * 0.01),
        TextFormField(
          focusNode: focusNode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(String label, String hint, double width, double height, FocusNode focusNode, bool isPassword) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: width * 0.05),
        ),
        SizedBox(height: height * 0.01),
        TextFormField(
          focusNode: focusNode,
          obscureText: isPassword
              ? (label == 'パスワード' ? !_isPasswordVisible : !_isConfirmPasswordVisible)
              : false,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey[300]!,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15.0),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 2.0,
              ),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      (label == 'パスワード' ? _isPasswordVisible : _isConfirmPasswordVisible)
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        if (label == 'パスワード') {
                          _isPasswordVisible = !_isPasswordVisible;
                        } else {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        }
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
