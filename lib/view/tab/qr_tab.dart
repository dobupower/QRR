import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrTab extends StatefulWidget {
  @override
  _QrTabState createState() => _QrTabState();
}

class _QrTabState extends State<QrTab> {
  String qrData = "https://example.com"; // 기본 QR 코드 데이터

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // QR 코드 생성 위젯
          QrImage(
            data: qrData, // QR 코드에 넣을 데이터
            version: QrVersions.auto, // QR 코드의 버전 설정 (자동)
            size: 200.0, // QR 코드의 크기
          ),
          SizedBox(height: 20),
          // QR 코드 데이터를 입력받을 TextField
          TextField(
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'QRコードに入れるデータを入力してください', // 입력 필드 설명
            ),
            onChanged: (value) {
              setState(() {
                qrData = value; // 입력값에 따라 QR 코드 데이터를 변경
              });
            },
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // QR 코드를 생성하기 위한 로직 (이미 QR 코드가 생성됨)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('QRコードが生成されました！')),
              );
            },
            child: Text('QRコードを生成'), // 버튼 텍스트
          ),
        ],
      ),
    );
  }
}
