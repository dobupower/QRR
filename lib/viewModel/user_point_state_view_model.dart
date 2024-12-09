import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_points_state_model.dart';

// 포인트 상태 관리
final userPointsProvider = StateNotifierProvider<UserPointsViewModel, AsyncValue<UserPointsState>>((ref) {
  return UserPointsViewModel();
});

// 사용자 포인트 관리 ViewModel
class UserPointsViewModel extends StateNotifier<AsyncValue<UserPointsState>> {
  UserPointsViewModel() : super(const AsyncValue.loading()) {
    monitorUserPoints(); // 초기 포인트 로드
  }

  // Firestore에서 사용자 포인트를 실시간으로 감시
  Future<void> monitorUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');

    if (email != null) {
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isNotEmpty) {
          final userDoc = querySnapshot.docs.first;
          final points = userDoc.data()['points'] ?? 0;
          final uid = userDoc.data()['uid'] ?? 0000-0000-0000;
          
          // points와 uid를 함께 업데이트
          state = AsyncValue.data(UserPointsState(points: points, uid: uid));
        } else {
          // 사용자가 없으면 초기 상태로 설정
          state = AsyncValue.data(UserPointsState(points: 0, uid: '0000-0000-0000'));
        }
      });
    } else {
      state = AsyncValue.error('사용자 이메일이 없습니다.', StackTrace.current);
    }
  }
}
