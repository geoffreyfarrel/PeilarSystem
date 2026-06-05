// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

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
  late final String _viewType;
  late final html.IFrameElement _iframe;
  late final html.EventListener _messageListener;

  @override
  void initState() {
    super.initState();
    _viewType = 'easycard-customizer-${DateTime.now().microsecondsSinceEpoch}';
    final version = DateTime.now().millisecondsSinceEpoch;
    _iframe = html.IFrameElement()
      ..src =
          'assets/assets/card_editor.html?v=$version&lang=${widget.languageCode}'
      ..style.border = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'clipboard-read; clipboard-write'
      ..setAttribute('title', 'EasyCard advanced customizer');

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );

    _messageListener = (event) {
      if (event is html.MessageEvent &&
          event.data == 'easycard-customizer-back') {
        widget.onBack();
      }
    };
    html.window.addEventListener('message', _messageListener);
  }

  @override
  void didUpdateWidget(covariant DigitalEasyCardHtmlHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.languageCode != widget.languageCode) {
      _iframe.contentWindow?.postMessage({
        'type': 'easycard-language',
        'language': widget.languageCode,
      }, '*');
    }
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', _messageListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
