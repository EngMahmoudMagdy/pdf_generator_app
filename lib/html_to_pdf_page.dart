import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:printing/printing.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HTMLToPdfPage extends StatefulWidget {
  final String htmlContent;

  const HTMLToPdfPage({super.key, required this.htmlContent});

  @override
  State<HTMLToPdfPage> createState() => _HTMLToPdfPageState();
}

class _HTMLToPdfPageState extends State<HTMLToPdfPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("WebView to PDF")),
      body: Html(data: widget.htmlContent),
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
