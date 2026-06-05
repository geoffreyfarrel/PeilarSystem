import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DigitalEasyCardHtmlHost extends StatefulWidget {
  final String languageCode;
  final VoidCallback onBack;

  const DigitalEasyCardHtmlHost({
    super.key,
    required this.languageCode,
    required this.onBack,
  });

  @override
  State<DigitalEasyCardHtmlHost> createState() =>
      _DigitalEasyCardHtmlHostState();
}

class _DigitalEasyCardHtmlHostState extends State<DigitalEasyCardHtmlHost> {
  WebViewController? _controller;

  bool get _supportsWebView {
    return Platform.isAndroid || Platform.isIOS || Platform.isMacOS;
  }

  @override
  void initState() {
    super.initState();
    if (_supportsWebView) {
      _initializeController();
    }
  }

  Future<void> _initializeController() async {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF4F4F4))
      ..addJavaScriptChannel(
        'CardCustomizer',
        onMessageReceived: (message) {
          if (message.message == 'back') {
            widget.onBack();
          }
        },
      );

    await controller.clearCache();
    await controller.loadFlutterAsset('assets/card_editor.html');
    await controller.runJavaScript(
      "window.setCustomizerLanguage && window.setCustomizerLanguage('${widget.languageCode}');",
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _controller = controller;
    });
  }

  @override
  void didUpdateWidget(covariant DigitalEasyCardHtmlHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      _controller?.runJavaScript(
        "window.setCustomizerLanguage && window.setCustomizerLanguage('${widget.languageCode}');",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller != null) {
      return WebViewWidget(controller: controller);
    }

    if (_supportsWebView) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.web_asset_off, size: 42, color: Color(0xFF777777)),
            const SizedBox(height: 14),
            const Text(
              'This HTML customizer needs Flutter web or a mobile WebView.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            FilledButton(onPressed: widget.onBack, child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
