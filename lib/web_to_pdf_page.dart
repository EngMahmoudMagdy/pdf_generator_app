import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebToPdfPage extends StatefulWidget {
  final String htmlContent;

  const WebToPdfPage({super.key, required this.htmlContent});

  @override
  State<WebToPdfPage> createState() => _WebToPdfPageState();
}

class _WebToPdfPageState extends State<WebToPdfPage> {
  late WebViewController controller;

  @override
  void initState() {
    controller = WebViewController()
      ..loadRequest(
        Uri.dataFromString(
          widget.htmlContent,
          mimeType: 'text/html',
          encoding: Encoding.getByName('utf-8'),
        ),
      );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebView to PDF")),
      body: WebViewWidget(controller: controller),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.print),
        onPressed: () async {
          await Printing.layoutPdf(
            onLayout: (format) async => await Printing.convertHtml(
              format: format,
              html: widget.htmlContent,
            ),
          );
        },
      ),
    );
  }
}
