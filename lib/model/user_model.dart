class User {
  final String uid; // 사용자 고유 ID
  final String name; // 사용자 이름
  final String email; // 사용자 이메일
  final int points; // 사용자 포인트 (기본 값은 0)
  final String type; // 사용자 유형 (예: 'customer' 또는 'owner')
  String? pubId; // 선택한 매장 ID (선택적)
  String? profilePicUrl; // 프로필 사진 URL (선택적)

  // 생성자: 필수 매개변수와 선택적 매개변수를 받아 User 객체를 초기화
  User({
    required this.uid,
    required this.name,
    required this.email,
    required this.points,
    required this.type,
    this.pubId,
    this.profilePicUrl,
  });

  // User 객체를 Map 형식으로 변환 (Firebase 또는 다른 DB에 저장할 때 사용)
  Map<String, dynamic> toMap() {
    return {
      'uid': uid, // User의 고유 ID
      'name': name, // User의 이름
      'email': email, // User의 이메일
      'points': points, // User의 포인트
      'type': type, // User의 유형
      'pubId': pubId, // 선택된 매장의 ID
      'profilePicUrl': profilePicUrl, // User의 프로필 사진 URL
    };
  }

  // Map 데이터를 받아 User 객체로 변환 (Firebase 또는 다른 DB에서 데이터를 불러올 때 사용)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] ?? '', // UID가 없으면 빈 문자열을 할당
      name: map['name'] ?? '', // 이름이 없으면 빈 문자열을 할당
      email: map['email'] ?? '', // 이메일이 없으면 빈 문자열을 할당
      points: map['points'] ?? 0, // 포인트가 없으면 0을 할당
      type: map['type'] ?? 'customer', // 유형이 없으면 기본값 'customer'를 할당
      pubId: map['pubId'], // 매장 ID는 선택적
      profilePicUrl: map['profilePicUrl'], // 프로필 사진 URL은 선택적
    );
  }

  // 현재 User 객체의 일부 속성만 변경하고, 나머지는 유지한 새로운 User 객체를 반환하는 메서드
  User copyWith({
    String? uid, // 변경할 uid (null이면 기존 값 유지)
    String? name, // 변경할 name (null이면 기존 값 유지)
    String? email, // 변경할 email (null이면 기존 값 유지)
    int? points, // 변경할 points (null이면 기존 값 유지)
    String? type, // 변경할 type (null이면 기존 값 유지)
    String? pubId, // 변경할 pubId (null이면 기존 값 유지)
    String? profilePicUrl, // 변경할 profilePicUrl (null이면 기존 값 유지)
  }) {
    return User(
      uid: uid ?? this.uid, // uid가 주어지면 변경, 아니면 기존 값 유지
      name: name ?? this.name, // name이 주어지면 변경, 아니면 기존 값 유지
      email: email ?? this.email, // email이 주어지면 변경, 아니면 기존 값 유지
      points: points ?? this.points, // points가 주어지면 변경, 아니면 기존 값 유지
      type: type ?? this.type, // type이 주어지면 변경, 아니면 기존 값 유지
      pubId: pubId ?? this.pubId, // pubId가 주어지면 변경, 아니면 기존 값 유지
      profilePicUrl: profilePicUrl ?? this.profilePicUrl, // profilePicUrl이 주어지면 변경, 아니면 기존 값 유지
    );
  }
}