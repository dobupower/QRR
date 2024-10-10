import 'package:flutter_riverpod/flutter_riverpod.dart';

// ViewModel 역할을 하는 StateNotifier 클래스
class TabViewModel extends StateNotifier<int> {
  TabViewModel() : super(0); // 기본값으로 첫 번째 탭(0) 설정

  // 탭 인덱스를 변경하는 메서드
  void setTabIndex(int index) {
    state = index; // 선택된 탭의 인덱스를 상태로 저장
  }
}

// StateNotifierProvider를 사용해 TabViewModel을 관리
final tabViewModelProvider = StateNotifierProvider<TabViewModel, int>((ref) {
  return TabViewModel();
});
