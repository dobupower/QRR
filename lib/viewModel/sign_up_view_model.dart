import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';

class SignUpViewModel extends ChangeNotifier {
  // TextEditingController들을 정의하여 사용자 입력을 관리합니다.
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 인증 코드를 저장할 변수입니다.
  String? _verificationCode;

  // 비밀번호와 확인 비밀번호 필드의 가시성을 관리하는 변수들입니다.
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Getter를 통해 외부에서 각 컨트롤러에 접근할 수 있습니다.
  TextEditingController get nameController => _nameController;
  TextEditingController get emailController => _emailController;
  TextEditingController get passwordController => _passwordController;
  TextEditingController get confirmPasswordController => _confirmPasswordController;

  // Getter를 통해 비밀번호 필드의 가시성을 제어합니다.
  bool get isPasswordVisible => _isPasswordVisible;
  bool get isConfirmPasswordVisible => _isConfirmPasswordVisible;

  // 각 필드의 오류 메시지를 저장할 변수들입니다.
  String? _passwordError;
  String? _confirmPasswordError;
  String? _emailError;

  // Getter를 통해 외부에서 오류 메시지에 접근할 수 있습니다.
  String? get passwordError => _passwordError;
  String? get confirmPasswordError => _confirmPasswordError;
  String? get emailError => _emailError;

  // 폼이 유효한지 확인하는 메서드입니다. 각 필드를 검증한 후 오류가 없으면 true를 반환합니다.
  bool get isFormValid {
    validatePasswordFields(); // 비밀번호 필드 검증
    validateEmail(_emailController.text); // 이메일 필드 검증
    return _passwordError == null && _confirmPasswordError == null && _emailError == null;
  }

  // 비밀번호와 확인 비밀번호 필드를 검증하는 메서드입니다.
  void validatePasswordFields() {
    if (_passwordController.text.length < 8) {
      _passwordError = 'パスワードは8文字以上で入力してください。'; // 비밀번호가 8자리 이상인지 확인
    } else {
      _passwordError = null;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _confirmPasswordError = 'パスワードが一致しません。'; // 비밀번호와 확인 비밀번호가 일치하는지 확인
    } else {
      _confirmPasswordError = null;
    }
    notifyListeners(); // 상태가 변경되었음을 알립니다.
  }

  // 이메일 필드를 검증하는 메서드입니다.
  void validateEmail(String email) {
    const emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'; // 이메일 형식을 검증하는 정규식
    if (!RegExp(emailRegex).hasMatch(email)) {
      _emailError = '正しいメールアドレスを入力してください。'; // 이메일이 올바른 형식인지 확인
    } else {
      _emailError = null;
    }
    notifyListeners(); // 상태가 변경되었음을 알립니다.
  }

  // 비밀번호 가시성을 토글하는 메서드입니다.
  void togglePasswordVisibility() {
    _isPasswordVisible = !_isPasswordVisible;
    notifyListeners(); // 상태가 변경되었음을 알립니다.
  }

  // 확인 비밀번호 가시성을 토글하는 메서드입니다.
  void toggleConfirmPasswordVisibility() {
    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
    notifyListeners(); // 상태가 변경되었음을 알립니다.
  }

  // 회원가입 절차를 처리하는 메서드입니다.
  Future<void> signUp(BuildContext context) async {
    if (isFormValid) {
      final email = _emailController.text;

      // Firestore에서 이메일 중복 확인
      final existingUser = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (existingUser.docs.isNotEmpty) {
        // 이메일이 이미 존재하는 경우
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('このメールアドレスは既に登録されています。')),
        );
        return;
      }

      // 4자리 인증 코드 생성
      _verificationCode = _generateVerificationCode();

      // 인증 코드 이메일로 전송
      bool emailSent = await _sendVerificationEmail(email, _verificationCode!);

      if (emailSent) {
        final user = User(
          name: _nameController.text,
          email: email,
          password: _passwordController.text,
        );

        Navigator.pushNamed(context, '/store-selection', arguments: user);
      } else {
        debugPrint('이메일 전송 실패');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('이메일 전송에 실패했습니다. 다시 시도해주세요.')),
        );
      }
    } else {
      debugPrint('Form is not valid');
    }
  }

  // 4자리 인증 코드를 생성하는 메서드입니다.
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString(); // 1000부터 9999 사이의 난수를 생성
  }

  // 인증 코드를 이메일로 전송하는 메서드입니다.
  Future<bool> _sendVerificationEmail(String email, String code) async {
    // 실제 이메일과 비밀번호로 변경해야 합니다.
    String username = 'bbg999123@gmail.com';
    String password = 'xilw aglt tsgp jxch';

    final smtpServer = gmail(username, password); // Gmail SMTP 서버 설정
    final message = Message()
      ..from = Address('qrr@qrr.com', 'QRR') // 보내는 사람 이메일과 이름
      ..recipients.add(email) // 수신자 이메일
      ..subject = 'Your Verification Code' // 이메일 제목
      ..text = 'Your verification code is $code'; // 이메일 내용

    try {
      final sendReport = await send(message, smtpServer);
      debugPrint('Message sent: ' + sendReport.toString());
      return true; // 이메일 전송 성공
    } on MailerException catch (e) {
      debugPrint('Message not sent. \n' + e.toString());
      for (var p in e.problems) {
        debugPrint('Problem: ${p.code}: ${p.msg}');
      }
      return false; // 이메일 전송 실패
    }
  }

  // 인증 코드를 재전송하는 메서드입니다.
  Future<void> resendVerificationCode() async {
    // 새 인증 코드 생성
    _verificationCode = _generateVerificationCode();

    // 새 인증 코드 이메일로 전송
    if (_emailController.text.isNotEmpty) {
      bool emailSent = await _sendVerificationEmail(_emailController.text, _verificationCode!);
      if (emailSent) {
        debugPrint('Verification code resent to ${_emailController.text}');
      } else {
        debugPrint('이메일 재전송 실패');
      }
    }
  }

  // 사용자가 입력한 코드가 생성된 코드와 일치하는지 확인하는 메서드입니다.
  bool verifyCode(String inputCode) {
    return _verificationCode == inputCode;
  }

  // 사용자를 Firestore에 저장하는 메서드입니다.
  Future<void> saveUserToFirestore(User user) async {
    try {
      await FirebaseFirestore.instance.collection('users').add({
        'name': user.name,
        'email': user.email,
        'password': user.password, // 실제 애플리케이션에서는 비밀번호를 해싱하여 저장하세요.
        'store': user.store,
      });
      debugPrint('User added to Firestore');
    } catch (e) {
      debugPrint('Error adding user to Firestore: $e');
    }
  }

  // 사용자가 선택한 스토어를 업데이트하는 메서드입니다.
  void updateUserStore(User user, String store) {
    user.store = store;
  }

  // 이메일 인증이 완료된 후 사용자를 Firestore에 저장하는 메서드입니다.
  void onEmailVerified(BuildContext context, User user) {
    saveUserToFirestore(user).then((_) {
      Navigator.popUntil(context, (route) => route.isFirst); // 초기 화면으로 돌아갑니다.
    });
  }
}
