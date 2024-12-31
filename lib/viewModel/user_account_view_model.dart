import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user_model.dart';
import '../services/preferences_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
          .collection('Users')
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
