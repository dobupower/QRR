import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

// 사용자 전체 상태 관리용 Provider
final userPointsUidProvider = StateNotifierProvider<UserPointsUidViewModel, AsyncValue<User>>((ref) {
  return UserPointsUidViewModel();
});

// 사용자 정보를 관리하는 ViewModel
class UserPointsUidViewModel extends StateNotifier<AsyncValue<User>> {
  UserPointsUidViewModel() : super(const AsyncValue.loading()) {
    _loadUser(); // 초기 사용자 정보 로드
  }

  // Firestore에서 사용자 정보를 한 번 로드하고 상태를 업데이트
  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    print('Loaded email from SharedPreferences: $email'); // 디버깅용 print

    if (email != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print('Firestore query completed. Documents found: ${querySnapshot.docs.length}'); // 디버깅용 print

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        print('User document data: ${userDoc.data()}'); // 디버깅용 print

        // fromJson 사용하여 User 객체 생성
        final user = User.fromJson(userDoc.data()..['uid'] = userDoc.id);

        // 상태 업데이트: User 객체 전체를 업데이트
        state = AsyncValue.data(user);

        // 포인트에 대한 실시간 감시 시작
        _monitorUserPoints(user.uid);
      } else {
        print('User not found in Firestore.'); // 디버깅용 print
        state = AsyncValue.error('사용자를 찾을 수 없습니다.', StackTrace.current);
      }
    } else {
      print('Email not found in SharedPreferences.'); // 디버깅용 print
      state = AsyncValue.error('사용자 이메일이 없습니다.', StackTrace.current);
    }
  }

  // 사용자 정보를 강제로 새로고침하는 메서드 추가
  Future<void> refreshUser() async {
    await _loadUser();
  }

  // Firestore에서 사용자 포인트를 실시간으로 감시
  void _monitorUserPoints(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((docSnapshot) {
      if (docSnapshot.exists) {
        final points = docSnapshot.data()?['points'] ?? 0;
        print('Real-time points update: $points'); // 디버깅용 print
        
        state.whenData((user) {
          final updatedUser = user.copyWith(points: points);
          state = AsyncValue.data(updatedUser); // 포인트 상태 업데이트
        });
      } else {
        print('User document does not exist anymore. Setting points to 0.'); // 디버깅용 print
        state = AsyncValue.data(state.value?.copyWith(points: 0) ?? User(uid: uid, name: '', email: '', points: 0, authType: 'email'));
      }
    });
  }
}
