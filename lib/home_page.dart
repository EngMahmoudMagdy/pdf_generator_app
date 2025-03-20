import 'dart:io';
import 'package:flutter/material.dart';
import 'services/pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PdfService _pdfService = PdfService();
  bool _isGenerating = false;
  File? _generatedPdfFile;

  Future<void> _generatePdf() async {
    setState(() {
      _isGenerating = true;
    });

    try {
      final htmlContent = PdfService.getSampleHtmlTemplate();
      final file = await _pdfService.generatePdfFromHtml(
        htmlContent,
        'sample_report',
      );

      setState(() {
        _generatedPdfFile = file;
        _isGenerating = false;
      });

      if (file != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to generate PDF')),
        );
      }
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> _previewPdf() async {
    if (_generatedPdfFile != null) {
      await Printing.layoutPdf(
        onLayout: (_) => _generatedPdfFile!.readAsBytes(),
        name: 'Sample PDF Report',
        format: PdfPageFormat.a4,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HTML to PDF Converter'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                size: 80,
                color: Colors.deepPurple,
              ),
              const SizedBox(height: 20),
              const Text(
                'Convert HTML Template to PDF',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                'This app demonstrates how to convert HTML templates with sections, tables, images, and styled text to PDF format.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generatePdf,
                icon: const Icon(Icons.file_download),
                label: _isGenerating
                    ? const Text('Generating...')
                    : const Text('Generate Sample PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_generatedPdfFile != null) ...[
                ElevatedButton.icon(
                  onPressed: () => _pdfService.openPdf(_generatedPdfFile!),
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('View Generated PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _previewPdf,
                  icon: const Icon(Icons.preview),
                  label: const Text('Preview PDF'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
