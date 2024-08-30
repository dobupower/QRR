class User {
  // 필드 선언: 사용자의 이름, 이메일, 비밀번호는 필수 필드입니다.
  // 'store'는 사용자가 선택한 스토어를 나타내며, 나중에 업데이트될 수 있으므로 nullable입니다.
  final String name;
  final String email;
  final String password;
  String? store; // 이 필드를 final에서 제거: store는 나중에 선택될 수 있으므로 final이 아닙니다.

  // 생성자: User 객체를 생성합니다. name, email, password는 필수, store는 선택입니다.
  User({
    required this.name,
    required this.email,
    required this.password,
    this.store,
  });

  // 객체를 JSON으로 변환하는 메서드: Firestore에 데이터를 저장할 때 JSON 형식으로 변환됩니다.
  Map<String, dynamic> toJson() {
    return {
      'name': name, // JSON의 'name' 키에 사용자 이름을 저장
      'email': email, // JSON의 'email' 키에 사용자 이메일을 저장
      'store': store, // JSON의 'store' 키에 사용자가 선택한 스토어를 저장 (null일 수 있음)
      'password': password, // JSON의 'password' 키에 비밀번호를 저장 (보안상 해싱하여 저장해야 함)
    };
  }

  // JSON에서 객체를 생성하는 팩토리 메서드: Firestore에서 데이터를 가져올 때 사용
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      name: json['name'], // JSON의 'name' 값을 가져와 name 필드에 할당
      email: json['email'], // JSON의 'email' 값을 가져와 email 필드에 할당
      store: json['store'] ?? '', // JSON의 'store' 값을 가져와 store 필드에 할당 (없으면 빈 문자열)
      password: json['password'], // JSON의 'password' 값을 가져와 password 필드에 할당
    );
  }

  // User 객체의 일부 필드를 업데이트하기 위한 메서드
  // 주로 store 필드를 업데이트할 때 사용
  User copyWith({String? store}) {
    return User(
      name: this.name, // 기존 name 값을 그대로 유지
      email: this.email, // 기존 email 값을 그대로 유지
      store: store ?? this.store, // 새 store 값이 주어지면 업데이트, 그렇지 않으면 기존 store 값 유지
      password: this.password, // 기존 password 값을 그대로 유지
    );
  }
}
