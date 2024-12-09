import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/owner_model.dart';
import '../model/photo_upload_model.dart';
import '../services/preferences_manager.dart';

class OwnerAccountViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  OwnerAccountViewModel() : super(const AsyncValue.loading());

  /// 두 상태를 관리하기 위해 별도 변수 사용
  AsyncValue<Owner> ownerState = const AsyncValue.loading();
  AsyncValue<PhotoUpload> pubInfoState = const AsyncValue.loading();

  Future<void> fetchOwnerData() async {
    ownerState = const AsyncValue.loading();
    state = _combineStates(); // 상태를 업데이트

    try {
      // 1. PreferencesManager에서 이메일 가져오기
      final email = await PreferencesManager.instance.getEmail();

      if (email == null) {
        throw Exception('이메일이 설정되지 않았습니다.');
      }

      // 2. Firestore에서 이메일로 사용자 문서 조회
      final querySnapshot = await FirebaseFirestore.instance
          .collection('owners')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('사용자 정보를 찾을 수 없습니다.');
      }

      // 3. Firestore 데이터를 Owner 모델로 변환
      final ownerData = querySnapshot.docs.first.data();
      final owner = Owner.fromJson(ownerData);

      ownerState = AsyncValue.data(owner);
    } catch (e, stackTrace) {
      ownerState = AsyncValue.error(e, stackTrace);
    } finally {
      state = _combineStates(); // 최종 상태 업데이트
    }
  }

  Future<void> fetchPubInfoData() async {
    pubInfoState = const AsyncValue.loading();
    state = _combineStates(); // 상태를 업데이트

    try {
      // 1. PreferencesManager에서 이메일 가져오기
      final email = await PreferencesManager.instance.getEmail();

      if (email == null) {
        throw Exception('이메일이 설정되지 않았습니다.');
      }

      // 2. Firestore에서 PubInfos 문서 조회
      final querySnapshot = await FirebaseFirestore.instance
          .collection('PubInfos')
          .where('ownerId', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('PubInfos 데이터를 찾을 수 없습니다.');
      }

      // 3. Firestore 데이터를 PhotoUpload 모델로 변환
      final pubInfoData = querySnapshot.docs.first.data();
      final photoUpload = PhotoUpload.fromJson(pubInfoData);

      pubInfoState = AsyncValue.data(photoUpload);
    } catch (e, stackTrace) {
      pubInfoState = AsyncValue.error(e, stackTrace);
    } finally {
      state = _combineStates(); // 최종 상태 업데이트
    }
  }

  /// 두 상태를 병합하여 하나의 상태로 반환
  AsyncValue<Map<String, dynamic>> _combineStates() {
    final owner = ownerState;
    final pubInfo = pubInfoState;

    if (owner.isLoading || pubInfo.isLoading) {
      return const AsyncValue.loading();
    }

    if (owner.hasError) {
      return AsyncValue.error(owner.error!, owner.stackTrace ?? StackTrace.current);
    }

    if (pubInfo.hasError) {
      return AsyncValue.error(pubInfo.error!, pubInfo.stackTrace ?? StackTrace.current);
    }


    if (owner.hasValue && pubInfo.hasValue) {
      return AsyncValue.data({
        'owner': owner.value!,
        'pubInfo': pubInfo.value!,
      });
    }

    return const AsyncValue.loading();
  }
}

final ownerAccountProvider =
    StateNotifierProvider<OwnerAccountViewModel, AsyncValue<Map<String, dynamic>>>((ref) {
  final viewModel = OwnerAccountViewModel();
  viewModel.fetchOwnerData(); // 초기화 시 Owner 데이터 조회
  viewModel.fetchPubInfoData(); // 초기화 시 PubInfo 데이터 조회
  return viewModel;
});
