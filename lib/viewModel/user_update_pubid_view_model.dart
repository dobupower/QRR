import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 상태 클래스
/// - `stores`: 전체 매장 이름 리스트
/// - `filteredStores`: 필터링된 매장 이름 리스트
/// - `selectedStore`: 선택된 매장 이름
class UserUpdatePubIdState {
  final List<String> stores;
  final List<String> filteredStores;
  final String? selectedStore;

  UserUpdatePubIdState({
    this.stores = const [],
    this.filteredStores = const [],
    this.selectedStore,
  });

  /// 상태 복사 메서드
  UserUpdatePubIdState copyWith({
    List<String>? stores,
    List<String>? filteredStores,
    String? selectedStore,
  }) {
    return UserUpdatePubIdState(
      stores: stores ?? this.stores,
      filteredStores: filteredStores ?? this.filteredStores,
      selectedStore: selectedStore ?? this.selectedStore,
    );
  }
}

class UpdatePubIdViewModel extends StateNotifier<UserUpdatePubIdState> {
  UpdatePubIdViewModel() : super(UserUpdatePubIdState());


  Future<void> fetchStoresFromFirestore() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('owners').get();

      // storeName 필드를 추출하여 리스트로 변환
      final storeNames = querySnapshot.docs
          .map((doc) => doc['storeName'] as String)
          .toList();

      // 상태 업데이트
      state = state.copyWith(
        stores: storeNames,
        filteredStores: storeNames,
      );
    } catch (e) {
      print('Firestore 데이터를 가져오는 중 오류 발생: $e');
    }
  }

  void filterStores(String query) {
    // 검색어가 비어 있는지 확인 후 필터링
    final filtered = query.isEmpty
        ? state.stores
        : state.stores.where((storeName) => storeName.toLowerCase().contains(query.toLowerCase())).toList();

    // 상태 업데이트
    state = state.copyWith(filteredStores: filtered);
  }


  // 사용자가 선택한 매장 이름을 `selectedStore` 상태에 저장합니다.
  void updateSelectedStore(String storeName) {
    state = state.copyWith(selectedStore: storeName);
  }

  Future<bool> updateSelectedStoreAndPubId(String storeName) async {
    try {
      updateSelectedStore(storeName); // 1. 상태 업데이트

      final prefs = await SharedPreferences.getInstance(); // 2. SharedPreferences에서 이메일 가져오기
      final email = prefs.getString('email');

      if (email == null) {
        print('SharedPreferences에서 이메일을 찾을 수 없습니다.');
        return false;
      }

      // 3. Firestore에서 이메일로 사용자 문서 찾기
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id; // 첫 번째 문서 ID 가져오기

        // 4. Firestore에서 pubId 필드를 업데이트
        await FirebaseFirestore.instance
            .collection('users')
            .doc(docId)
            .update({'pubId': storeName});

        print('pubId가 $storeName로 업데이트되었습니다.');
        return true; 
      } else {
        print('users 컬렉션에서 해당 이메일을 찾을 수 없습니다.');
        return false; 
      }
    } catch (e) {
      print('pubId 업데이트 중 오류 발생: $e');
      return false; 
    }
  }
}

final updatePubIdViewModelProvider =
    StateNotifierProvider<UpdatePubIdViewModel, UserUpdatePubIdState>((ref) {
  return UpdatePubIdViewModel();
});
