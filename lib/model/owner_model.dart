class Owner {
  final String uid;         // 고유 ID
  final String storeName;   // 점포명
  final String email;       // 이메일 주소
  final String zipCode;     // 우편번호
  final String prefecture;  // 도도부현 (도/도/부/현)
  final String city;        // 시/구/읍/면/동
  final String address;     // 상세 주소
  final String? building;   // 건물명, 호실 번호 (선택사항)
  final String authType;    // 인증 유형 (기본값: 'email')
  final String type;        // 사용자 유형 (기본값: 'owner')

  // 생성자
  Owner({
    required this.uid,
    required this.storeName,
    required this.email,
    required this.zipCode,
    required this.prefecture,
    required this.city,
    required this.address,
    this.building,  // 선택사항
    this.authType = 'email', // 기본값으로 'email' 설정
    this.type = 'owner',     // 기본값으로 'owner' 설정
  });

  // Firestore에 저장할 데이터를 Map 형태로 변환하는 메서드
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'uid': uid,
      'storeName': storeName,
      'email': email,
      'zipCode': zipCode,
      'prefecture': prefecture,
      'city': city,
      'address': address,
      'authType': authType, // authType 추가
      'type': type,         // type 추가
    };

    // building이 null일 경우 저장하지 않음
    if (building != null && building!.isNotEmpty) {
      data['building'] = building;
    }

    return data;
  }

  // Firestore에서 데이터를 가져와 Owner 객체로 변환하는 팩토리 메서드
  factory Owner.fromMap(Map<String, dynamic> map) {
    return Owner(
      uid: map['uid'] as String,
      storeName: map['storeName'] as String,
      email: map['email'] as String,
      zipCode: map['zipCode'] as String,
      prefecture: map['prefecture'] as String,
      city: map['city'] as String,
      address: map['address'] as String,
      building: map['building'] as String?, // building이 있을 때만 매핑
      authType: map['authType'] as String? ?? 'email', // 기본값 'email'
      type: map['type'] as String? ?? 'owner',         // 기본값 'owner'
    );
  }

  // Owner 객체 복사본을 생성하는 copyWith 메서드
  Owner copyWith({
    String? uid,
    String? storeName,
    String? email,
    String? zipCode,
    String? prefecture,
    String? city,
    String? address,
    String? building,
    String? authType,
    String? type,
  }) {
    return Owner(
      uid: uid ?? this.uid,
      storeName: storeName ?? this.storeName,
      email: email ?? this.email,
      zipCode: zipCode ?? this.zipCode,
      prefecture: prefecture ?? this.prefecture,
      city: city ?? this.city,
      address: address ?? this.address,
      building: building ?? this.building,  // building이 null이면 유지
      authType: authType ?? this.authType,  // authType 추가
      type: type ?? this.type,              // type 추가
    );
  }
}