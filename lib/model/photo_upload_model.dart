class PhotoUpload {
  final String pubId;
  final String ownerId; // 소유자 ID (이메일 등)
  final String? logoUrl; // 가게 로고 URL
  final List<String?> photoUrls; // 가게 이미지 URL 리스트
  final String message; // 가게 메시지

  PhotoUpload({
    required this.pubId,
    required this.ownerId,
    required this.logoUrl,
    required this.photoUrls,
    required this.message,
  });

  /// Firestore에 저장할 때 사용할 Map 형태로 변환
  Map<String, dynamic> toMap() {
    return {
      'pubId': pubId,
      'ownerId': ownerId,
      'logoUrl': logoUrl,
      'photoUrls': photoUrls,
      'message': message,
    };
  }

  /// Firestore에서 데이터를 가져올 때 사용할 팩토리 생성자
  factory PhotoUpload.fromMap(Map<String, dynamic> map) {
    return PhotoUpload(
      pubId: map['pubId'] ?? '',
      ownerId: map['ownerId'],
      logoUrl: map['logoUrl'],
      photoUrls: List<String?>.from(map['photoUrls']),
      message: map['message'],
    );
  }
}
