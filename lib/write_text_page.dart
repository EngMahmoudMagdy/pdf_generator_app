import 'package:flutter/material.dart';
import 'package:pdf_generator_app/services/pdf_service.dart';

class WriteTextPage extends StatefulWidget {
  const WriteTextPage({super.key});

  @override
  State<WriteTextPage> createState() => _WriteTextPageState();
}

class _WriteTextPageState extends State<WriteTextPage> {
  final PdfService _pdfService = PdfService();

  var textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write Markup Text to PDF'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: textEditingController,
              minLines: 3,
              maxLines: 2000,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: generateMarkdownFile,
              icon: const Icon(Icons.chat),
              label: const Text('Generate PDF from MarkDown'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton.icon(
              onPressed: generateHTMLFile,
              icon: const Icon(Icons.chat),
              label: const Text('Generate PDF from HTML'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void generateMarkdownFile() {
    if (textEditingController.text.isNotEmpty) {
      _pdfService.generatePdfFromMarkDown(
          textEditingController.text, 'html_pdf');
    }
  }

  void generateHTMLFile() {
    if (textEditingController.text.isNotEmpty) {
      _pdfService.generatePdfFromHTMLText(
          textEditingController.text, 'html_pdf');
    }
  }
}
