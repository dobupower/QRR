import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/preferences_manager.dart'; // PreferencesManager import

class OwnerSettingsTabViewModel extends StateNotifier<int?> {
  OwnerSettingsTabViewModel() : super(null) {
    _fetchPointLimit();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _ownerDocumentId; // 업데이트 시 사용할 문서 ID 저장

  // Firestore에서 포인트 리미트를 가져오기
  Future<void> _fetchPointLimit() async {
    try {
      final ownerEmail = PreferencesManager.instance.getEmail();
      if (ownerEmail == null) {
        print('Owner email is null.');
        return;
      }

      // 'owners' 컬렉션에서 'email' 필드가 ownerEmail과 일치하는 문서 검색
      final querySnapshot = await _firestore
          .collection('Owners')
          .where('email', isEqualTo: ownerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        _ownerDocumentId = doc.id; // 문서 ID 저장 (업데이트 시 사용)
        state = doc.data()['pointLimit'] as int?;
      } else {
        print('No owner found with email $ownerEmail.');
        // 필요한 경우 여기에서 추가 처리를 할 수 있습니다.
      }
    } catch (e) {
      print('Error fetching point limit: $e');
    }
  }

  // Firestore에 포인트 리미트를 업데이트 (submit 버튼 클릭 시 호출)
  Future<void> updatePointLimit(int newLimit) async {
    try {
      if (_ownerDocumentId == null) {
        print('Owner document ID is null.');
        return;
      }

      await _firestore.collection('Owners').doc(_ownerDocumentId).set({
        'pointLimit': newLimit,
      }, SetOptions(merge: true));
      state = newLimit; // Firestore 업데이트 후 상태도 업데이트
    } catch (e) {
      print('Error updating point limit: $e');
    }
  }

  // 상태만 변경하는 함수 (Firestore 호출 없이 사용)
  void setPointLimit(int newLimit) {
    state = newLimit;
  }
}

// Riverpod Provider
final ownerSettingProvider =
    StateNotifierProvider<OwnerSettingsTabViewModel, int?>(
  (ref) {
    return OwnerSettingsTabViewModel();
  },
);
