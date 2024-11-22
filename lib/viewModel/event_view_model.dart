import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_storage/firebase_storage.dart';

// ViewModel: Firebase Storage에서 이벤트 이미지를 가져오고 상태를 관리
class EventViewModel extends StateNotifier<AsyncValue<List<String>>> {
  final FirebaseStorage _storage;

  EventViewModel(this._storage) : super(const AsyncLoading()) {
    fetchEventImages();
  }

  // Firebase Storage에서 'event' 폴더의 모든 이미지 URL을 가져오는 메서드
  Future<void> fetchEventImages() async {
    try {
      state = const AsyncLoading();
      final ListResult result = await _storage.ref('event').listAll();
      final List<String> urls = await Future.wait(
        result.items.map((ref) => ref.getDownloadURL()).toList(),
      );
      state = AsyncData(urls);
    } catch (e, stackTrace) {
      state = AsyncError(e, stackTrace);
    }
  }
}

// ViewModel을 제공하는 Riverpod 프로바이더
final eventViewModelProvider = StateNotifierProvider<EventViewModel, AsyncValue<List<String>>>(
  (ref) => EventViewModel(FirebaseStorage.instance),
);

// 현재 페이지 인덱스를 관리하는 프로바이더
final eventCurrentIndexProvider = StateProvider<int>((ref) => 0);
