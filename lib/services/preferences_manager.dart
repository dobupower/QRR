import 'package:shared_preferences/shared_preferences.dart';

class PreferencesManager {
  // 싱글톤 인스턴스
  static final PreferencesManager _instance = PreferencesManager._internal();

  // 내부 생성자
  PreferencesManager._internal();

  // 외부에서 인스턴스를 얻을 때 사용하는 접근자
  static PreferencesManager get instance => _instance;

  SharedPreferences? _preferences;

  // SharedPreferences 초기화
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // 이메일 저장
  Future<void> setEmail(String email) async {
    await _preferences?.setString('email', email);
  }

  // 이메일 불러오기
  String? getEmail() {
    return _preferences?.getString('email');
  }

  // 타입 저장 (user, owner)
  Future<void> setType(String type) async {
    await _preferences?.setString('type', type);
  }

  // 타입 불러오기
  String? getType() {
    return _preferences?.getString('type');
  }

  // 로그인 상태 확인
  bool isLoggedIn() {
    return getEmail() != null;
  }

  // 로그아웃 처리
  Future<void> logout() async {
    await _preferences?.clear(); // 모든 SharedPreferences 데이터 삭제
  }

  // 알림 상태 가져오기 
  bool getNotificationStatus() {
    return _preferences?.getBool('notificationStatus') ?? true; // 기본값은 true
  }

  // 알림 상태 저장
  Future<void> setNotificationStatus(bool value) async {
    await _preferences?.setBool('notificationStatus', value);
  }
}
