import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pdfUrl = 'https://hoboakabane.jp/qrr/terms-of-use-qrr.pdf';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)?.ownerSettingsTabTermsOfservice ?? '',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: SfPdfViewer.network(pdfUrl),
    );
  }
}
