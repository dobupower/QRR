import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../viewModel/qrcode_make_view_model.dart';

class QrTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qrCodeState = ref.watch(qrCodeProvider);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          qrCodeState.when(
            // QR 코드가 정상적으로 로드된 경우
            data: (qrCode) {
              if (qrCode != null) {
                return Column(
                  children: [
                    // QR 코드를 화면에 표시
                    QrImage(
                      data: qrCode.token,
                      version: QrVersions.auto,
                      size: 200.0,
                    ),
                    SizedBox(height: 20),
                  ],
                );
              } else {
                return Text('QRコードがありません。');
              }
            },
            // 로딩 중일 때 CircularProgressIndicator 표시
            loading: () => CircularProgressIndicator(),
            // 에러가 발생한 경우 에러 메시지 표시
            error: (error, _) => Text('エラーが発生しました: $error'),
          ),
          // QR 코드 재생성 버튼
          ElevatedButton(
            onPressed: () {
              ref.read(qrCodeProvider.notifier).regenerateQrCode(); // QR 코드 재생성 메소드 호출
            },
            child: Text('QRコードを再生成'),
          ),
        ],
      ),
    );
  }
}
