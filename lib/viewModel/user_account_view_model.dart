import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../model/user_model.dart';
import '../services/preferences_manager.dart';

class UserAccountViewModel extends StateNotifier<AsyncValue<User>> {
  UserAccountViewModel() : super(const AsyncValue.loading()); // 초기 상태 설정

  
  Future<void> fetchUserData() async {
    state = const AsyncValue.loading(); // 상태를 로딩 상태로 설정

    try {
      // 1. PreferencesManager에서 이메일 가져오기
      final email = await PreferencesManager.instance.getEmail();

      if (email == null) {
        throw Exception('이메일이 설정되지 않았습니다.'); // 이메일이 없으면 예외 발생
      }

      // 2. Firestore에서 이메일로 사용자 문서 조회
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userDoc.docs.isEmpty) {
        throw Exception('사용자 정보를 찾을 수 없습니다.'); // 조회된 문서가 없으면 예외 발생
      }

      // 3. Firestore 데이터를 User 모델로 변환
      final userData = userDoc.docs.first.data();
      final user = User.fromJson({...userData, 'uid': userDoc.docs.first.id});

      state = AsyncValue.data(user); // 상태를 조회된 사용자 데이터로 설정
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace); // 상태를 에러로 설정
    }
  }

  //현재 사용자 이메일로 비밀번호 재설정 이메일을 보냅니다.
  Future<void> sendPasswordResetEmail() async {
    try {
      final user = state.value; // 현재 상태에서 사용자 데이터를 가져옵니다.

      if (user == null || user.email.isEmpty) {
        throw Exception('사용자의 이메일 정보를 확인할 수 없습니다.');
      }

      // Firebase Authentication을 사용하여 비밀번호 재설정 이메일 전송
      await firebase_auth.FirebaseAuth.instance
          .sendPasswordResetEmail(email: user.email);

      print('비밀번호 재설정 이메일이 발송되었습니다.'); // 성공 로그
    } catch (e) {
      print('비밀번호 재설정 이메일 발송 중 오류가 발생했습니다: $e');
      throw Exception('비밀번호 재설정 이메일 발송 실패: $e'); // 실패 시 예외 발생
    }
  }
  
  //사용자 패스워드를 재인증합니다.
  Future<bool> validatePassword(String password) async {
    try {
      final user = state.value; // 현재 상태에서 사용자 데이터를 가져옵니다.

      if (user == null || user.email.isEmpty) {
        throw Exception('사용자의 이메일 정보를 확인할 수 없습니다.');
      }

      // 1. 현재 로그인된 사용자 가져오기
      final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception('현재 로그인된 사용자를 찾을 수 없습니다.');
      }

      // 2. 이메일과 비밀번호로 자격 증명 생성
      final credential = firebase_auth.EmailAuthProvider.credential(
        email: user.email,
        password: password,
      );

      // 3. Firebase Authentication에서 재인증
      await currentUser.reauthenticateWithCredential(credential);

      // 4. 비밀번호 재설정 이메일 전송
      await sendPasswordResetEmail();

      print('비밀번호 인증 성공'); // 성공 로그
      return true;
    } catch (e) {
      print('비밀번호 인증 실패: $e'); // 실패 로그
      return false;
    }
  }

  void updatePubId(String newPubId) {
    final user = state.value; // 현재 상태에서 사용자 데이터를 가져옵니다.
    if (user != null) {
      // 기존 User 객체를 복사하여 pubId 업데이트
      final updatedUser = user.copyWith(pubId: newPubId);
      state = AsyncValue.data(updatedUser); // 상태를 업데이트된 User로 설정
      print('User pubId가 업데이트되었습니다: $newPubId'); // 성공 로그
    }
  }
}


final userAccountProvider =
    StateNotifierProvider<UserAccountViewModel, AsyncValue<User>>((ref) {
  final viewModel = UserAccountViewModel();
  viewModel.fetchUserData(); // 초기화 시 사용자 데이터 조회
  return viewModel;
});
