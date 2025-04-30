import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pdfUrl = 'https://www.hoboakabane.jp/qrr/privacy-policy.-qrr.pdf';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.ownerSettingsTabPrivacyPolicy ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        centerTitle: true,
        elevation: 1.0,
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
