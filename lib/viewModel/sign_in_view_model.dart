import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SignUpViewModel 클래스 정의, Riverpod의 StateNotifier를 상속받아 상태 관리
class SignUpViewModel extends StateNotifier<SignUpState> {
  // 생성자: 초기 상태로 SignUpState를 전달
  SignUpViewModel() : super(SignUpState());

  // 비밀번호 가림 상태를 토글하는 메서드
  // 현재 상태의 isPasswordVisible을 반전시켜 상태를 업데이트
  void togglePasswordVisibility() {
    state = state.copyWith(isPasswordVisible: !state.isPasswordVisible);
  }

  // 비밀번호 확인 필드 가림 상태를 토글하는 메서드
  // 현재 상태의 isConfirmPasswordVisible을 반전시켜 상태를 업데이트
  void toggleConfirmPasswordVisibility() {
    state = state.copyWith(isConfirmPasswordVisible: !state.isConfirmPasswordVisible);
  }
}

// SignUpState 클래스 정의 (불변 객체로 사용)
// 비밀번호와 비밀번호 확인 필드의 가림 여부를 저장하는 상태 클래스
class SignUpState {
  final bool isPasswordVisible; // 비밀번호 가림 여부를 저장하는 변수
  final bool isConfirmPasswordVisible; // 비밀번호 확인 필드 가림 여부를 저장하는 변수

  // 생성자: 초기값을 설정 (기본값은 둘 다 false로 설정, 즉 가림 상태)
  SignUpState({
    this.isPasswordVisible = false, // 기본적으로 비밀번호는 가려진 상태
    this.isConfirmPasswordVisible = false, // 기본적으로 비밀번호 확인도 가려진 상태
  });

  // copyWith 메서드: 상태를 변경할 때 일부 속성만 업데이트할 수 있게 도와줌
  // 새로운 값을 받으면 해당 값으로 업데이트, 없으면 기존 상태 유지
  SignUpState copyWith({
    bool? isPasswordVisible, // 비밀번호 가림 상태 변경
    bool? isConfirmPasswordVisible, // 비밀번호 확인 가림 상태 변경
  }) {
    return SignUpState(
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible, // 새 값이 없으면 기존 값 유지
      isConfirmPasswordVisible: isConfirmPasswordVisible ?? this.isConfirmPasswordVisible, // 새 값이 없으면 기존 값 유지
    );
  }
}

// signUpViewModelProvider 정의
// StateNotifierProvider를 통해 SignUpViewModel과 SignUpState를 Riverpod으로 관리
final signUpViewModelProvider = StateNotifierProvider<SignUpViewModel, SignUpState>(
  (ref) => SignUpViewModel(),
);
