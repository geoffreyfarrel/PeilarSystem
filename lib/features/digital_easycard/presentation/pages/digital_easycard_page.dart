import 'package:flutter/material.dart';

import '../../../landing/presentation/providers/language_provider.dart';
import '../widgets/digital_easycard_html_host.dart'
    if (dart.library.html) '../widgets/digital_easycard_html_host_web.dart';

class DigitalEasyCardPage extends StatefulWidget {
  final AppLanguage language;
  final VoidCallback onBack;

  const DigitalEasyCardPage({
    super.key,
    required this.language,
    required this.onBack,
  });

  @override
  State<DigitalEasyCardPage> createState() => _DigitalEasyCardPageState();
}

class _DigitalEasyCardPageState extends State<DigitalEasyCardPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          widget.onBack();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F4F4),
        body: SafeArea(
          bottom: false,
          child: DigitalEasyCardHtmlHost(
            languageCode: widget.language.name,
            onBack: widget.onBack,
          ),
        ),
      ),
    );
  }
}
