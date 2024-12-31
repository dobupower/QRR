import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/owner_model.dart';
import '../model/photo_upload_model.dart';
import '../services/preferences_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OwnerAccountViewModel extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  OwnerAccountViewModel() : super(const AsyncValue.loading());

  /// 두 상태를 관리하기 위해 별도 변수 사용
  AsyncValue<Owner> ownerState = const AsyncValue.loading();
  AsyncValue<PhotoUpload> pubInfoState = const AsyncValue.loading();

  /// Firestore 구독을 관리하기 위한 변수
  StreamSubscription? _ownerSubscription;
  StreamSubscription? _pubInfoSubscription;

  /// Owner 데이터를 Firestore에서 실시간 구독
  Future<void> fetchOwnerData() async {
    ownerState = const AsyncValue.loading();
    state = _combineStates();

    try {

      // PreferencesManager에서 이메일 가져오기
      final email = await PreferencesManager.instance.getEmail();
      if (email == null) {
        throw Exception('이메일이 설정되지 않았습니다.');
      }

      // 기존 구독 취소 (중복 방지)
      _ownerSubscription?.cancel();

      // Firestore 실시간 데이터 구독
      _ownerSubscription = FirebaseFirestore.instance
          .collection('Owners')
          .where('email', isEqualTo: email)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          throw Exception('사용자 정보를 찾을 수 없습니다.');
        }

        final ownerData = querySnapshot.docs.first.data();
        final owner = Owner.fromJson(ownerData);

        ownerState = AsyncValue.data(owner);
        state = _combineStates();
      });
    } catch (e, stackTrace) {
      ownerState = AsyncValue.error(e, stackTrace);
      state = _combineStates();
    }
  }

  /// PubInfo 데이터를 Firestore에서 실시간 구독
  Future<void> fetchPubInfoData() async {
    pubInfoState = const AsyncValue.loading();
    state = _combineStates();

    try {
      final email = await PreferencesManager.instance.getEmail();
      if (email == null) {
        throw Exception('이메일이 설정되지 않았습니다.');
      }

      _pubInfoSubscription?.cancel();

      _pubInfoSubscription = FirebaseFirestore.instance
          .collection('PubInfos')
          .where('ownerId', isEqualTo: email)
          .snapshots()
          .listen((querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          throw Exception('PubInfos 데이터를 찾을 수 없습니다.');
        }

        final pubInfoData = querySnapshot.docs.first.data();
        final photoUpload = PhotoUpload.fromJson(pubInfoData);

        pubInfoState = AsyncValue.data(photoUpload);
        state = _combineStates();
      });
    } catch (e, stackTrace) {
      pubInfoState = AsyncValue.error(e, stackTrace);
      state = _combineStates();
    }
  }

  /// 두 상태를 병합하여 반환
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

  /// 구독 해제 (메모리 누수 방지)
  @override
  void dispose() {
    _ownerSubscription?.cancel();
    _pubInfoSubscription?.cancel();
    super.dispose();
  }
}

/// ViewModel을 Provider로 등록
final ownerAccountProvider =
    StateNotifierProvider<OwnerAccountViewModel, AsyncValue<Map<String, dynamic>>>((ref) {
  final viewModel = OwnerAccountViewModel();
  viewModel.fetchOwnerData(); // 초기화 시 Owner 데이터 조회
  viewModel.fetchPubInfoData(); // 초기화 시 PubInfo 데이터 조회
  return viewModel;
});