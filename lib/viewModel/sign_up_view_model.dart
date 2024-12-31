import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../model/signup_state_model.dart';
import '../services/auth_service.dart';
import 'dart:math';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignUpViewModel extends StateNotifier<SignUpState> {
  // AuthService, FirebaseAuth, Firestore, GoogleSignIn을 관리하는 객체
  final AuthService _authService;
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  // 생성자: SignUpViewModel을 초기화하면서 필수 의존성 주입
  SignUpViewModel(this._authService)
      : _firebaseAuth = firebase_auth.FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance,
        _googleSignIn = GoogleSignIn(),
        super(
          SignUpState(
            nameController: TextEditingController(),
            emailController: TextEditingController(),
            passwordController: TextEditingController(),
            confirmPasswordController: TextEditingController(),
            codeController: TextEditingController(),
          ),
        );

  // 컴포넌트가 제거될 때 호출되는 dispose 메서드 (메모리 누수 방지)
  @override
  void dispose() {
    // 각 텍스트 컨트롤러를 dispose하여 메모리 누수 방지
    state.nameController?.dispose();
    state.emailController?.dispose();
    state.passwordController?.dispose();
    state.confirmPasswordController?.dispose();
    state.codeController?.dispose();
    super.dispose();
  }

  // 이메일 유효성 검사
  void validateEmail(String email, BuildContext context) {
    // 이메일 형식이 맞는지 정규 표현식으로 확인
    const emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
    if (!RegExp(emailRegex).hasMatch(email)) {
      state = state.copyWith(emailError: AppLocalizations.of(context)?.ownerSignUpViewModelEmailError ?? '');
    } else {
      state = state.copyWith(emailError: null);
    }
  }

  // 비밀번호 유효성 검사
  void validatePassword(String password, BuildContext context) {
    // 비밀번호 길이가 8자 이상인지 확인
    if (password.length < 8) {
      state = state.copyWith(passwordError: AppLocalizations.of(context)?.ownerSignUpViewModelPasswordError1 ?? '');
    } else {
      state = state.copyWith(passwordError: null);
    }
    // 확인 비밀번호가 입력되었을 경우, 확인 비밀번호 검증 호출
    if (state.confirmPasswordController?.text.isNotEmpty == true) {
      validateConfirmPassword(state.confirmPasswordController!.text, context);
    }
  }

  // 비밀번호 확인 유효성 검사
  void validateConfirmPassword(String confirmPassword, BuildContext context) {
    // 비밀번호와 확인 비밀번호가 일치하는지 확인
    if (confirmPassword != state.passwordController?.text) {
      state = state.copyWith(confirmPasswordError: AppLocalizations.of(context)?.ownerSignUpViewModelPasswordError2 ?? '');
    } else {
      state = state.copyWith(confirmPasswordError: null);
    }
  }

  // 비밀번호 표시/숨기기 토글
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 확인 비밀번호 표시/숨기기 토글
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }

  // 사용자가 오너인지 고객인지 설정
  void setType(bool isOwner) {
    state = state.copyWith(type: isOwner ? 'owners' : 'customer');
  }

  // 선택된 상점 이름 업데이트
  void updateSelectedStore(String storeName) {
    state = state.copyWith(selectedStore: storeName);
  }

  // 사용자와 관련된 상점 정보 업데이트 (Firestore에 저장)
  void updateUserStore(User user, String pubId) {
    // pubId를 포함한 사용자 정보를 업데이트
    User updatedUser = user.copyWith(pubId: pubId);
    _authService.saveUserToFirestore(updatedUser.toMap());
  }

  // 회원가입 처리
  Future<void> signUp(BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (state.isFormValid) {
      state = state.copyWith(isLoading: true); // 로딩 상태로 변경
      try {
        final email = state.emailController?.text ?? '';
        // 이메일 중복 체크
        if (await _authService.isEmailAlreadyRegistered(email, context)) {
          state = state.copyWith(emailError: localizations?.ownerSignUpViewModelEmailAllready ?? '');
          return;
        }
        // 인증 코드 생성
        final verificationCode = _generateVerificationCode();
        state = state.copyWith(verificationCode: verificationCode);
        
        // 인증 이메일 발송
        bool emailSent = await _authService.sendVerificationEmail(email, verificationCode, context);
        if (emailSent) {
          // 이메일 발송 성공 시, 스토어 선택 화면으로 이동
          Navigator.pushNamed(context, '/store-selection');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.signupViewModelSendMail ?? '')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizations?.signupViewModelSendMailFail ?? '')),
          );
        }
      } catch (e) {
        debugPrint('회원가입 오류: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.ownerSignUpViewModelSignupError1 ?? '')),
        );
      } finally {
        state = state.copyWith(isLoading: false); // 로딩 상태 해제
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.ownerSignUpViewModelSignupError2 ?? '')),
      );
    }
  }

  // 인증 코드 생성
  String _generateVerificationCode() {
    final random = Random();
    return (random.nextInt(9000) + 1000).toString();
  }

  // 인증 코드 확인
  Future<void> verifyCode(String inputCode, BuildContext context) async {
    final localizations = AppLocalizations.of(context);
    if (state.verificationCode == inputCode) {
      state = state.copyWith(verificationErrorMessage: null);
      try {
        // Firebase Auth로 사용자 생성
        firebase_auth.UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
          email: state.emailController?.text ?? '',
          password: state.passwordController?.text ?? '',
        );
        String uid = await _authService.generateUniqueUID(context);

        final user = User(
          uid: uid,
          name: state.nameController?.text ?? '',
          email: state.emailController?.text ?? '',
          points: 0,
          authType: 'email',
          pubId: state.selectedStore,
        );

        // 사용자 정보를 Firestore에 저장
        if (user != null) {
          await _authService.saveUserToFirestore(user.toMap());
        }

        // 회원가입 완료 후 첫 화면으로 돌아가기
        Navigator.popUntil(context, (route) => route.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.ownerEmailAuthScreenOkay ?? '')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations?.ownerSignUpViewModelSignupError3 ?? '')),
        );
      }
    } else {
      state = state.copyWith(verificationErrorMessage: localizations?.ownerSignUpViewModelCodeError ?? '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations?.signupViewModelVerifyCodeError ?? '')),
      );
    }
  }

  // 인증 코드 재전송
  Future<void> resendVerificationCode(BuildContext context) async {
    final newCode = _generateVerificationCode();
    state = state.copyWith(verificationCode: newCode);
    if (state.emailController?.text.isNotEmpty == true) {
      try {
        await _authService.sendVerificationEmail(state.emailController!.text, newCode, context);
      } catch (e) {
        debugPrint('인증 코드 재전송 실패: $e');
      }
    }
  }

  // Firestore에서 상점 목록 가져오기
  Future<void> fetchStoresFromFirestore(BuildContext context) async {
    try {
      // 환경 변수에서 OWNER_COLLECTION_ENDPOIN 값과 REGION 값 가져오기
      final endpoint = dotenv.env['OWNER_COLLECTION_ENDPOINT'];
      final region = dotenv.env['REGION'];

      // 환경 변수가 없는 경우 예외 처리
      if (endpoint == null) {
        throw Exception('OWNER_COLLECTION_ENDPOIN 환경 변수가 설정되지 않았습니다.');
      }

      // Firebase Functions에서 지정된 region으로 함수 호출
      final functions = FirebaseFunctions.instanceFor(region: region);
      final callable = functions.httpsCallable(endpoint);
      final response = await callable.call();

      // 받아온 데이터에서 오너 정보 추출
      final storesData = response.data['owners'] as List<dynamic>;
      final storeNames = storesData.map((store) => store['storeName'] as String).toList();

      // 상태 업데이트
      state = state.copyWith(
        stores: storeNames,
        filteredStores: storeNames,
      );
    } catch (e) {
      print('Firestore 데이터를 가져오는 중 오류 발생: $e');
    }
  }

  // 상점 목록 필터링
  void filterStores(String query) {
    // 검색어가 비어 있는지 확인 후 필터링
    final filtered = query.isEmpty
        ? state.stores
        : state.stores.where((storeName) => storeName.toLowerCase().contains(query.toLowerCase())).toList();

    // 상태 업데이트
    state = state.copyWith(filteredStores: filtered);
  }
}

// AuthService 의존성 주입
final authServiceProvider = Provider((ref) => AuthService());

final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>(
  (ref) {
    final authService = ref.watch(authServiceProvider);
    return SignUpViewModel(authService);
  },
);
