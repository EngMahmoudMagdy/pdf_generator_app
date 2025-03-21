import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'services/pdf_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PdfService _pdfService = PdfService();
  bool _isGenerating = false;
  File? _generatedPdfFile;
  String? _htmlContent;

  Future<void> _generatePdf() async {
    setState(() {
      _isGenerating = true;
      _htmlContent = PdfService.getSampleHtmlTemplate();
    });

    try {
      final file = await _pdfService.generatePdfFromHtml(
        _htmlContent!,
        'sample_report',
      );

      setState(() {
        _generatedPdfFile = file;
        _isGenerating = false;
      });

      if (kIsWeb || file != null) {
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
    if (_htmlContent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a PDF first')),
      );
      return;
    }
    
    setState(() {
      _isGenerating = true;
    });
    
    try {
      await _pdfService.previewPdf(_htmlContent!, context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error previewing PDF: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isGenerating = false;
      });
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
              ElevatedButton.icon(
                onPressed: _htmlContent == null ? null : _previewPdf,
                icon: const Icon(Icons.preview),
                label: const Text('Preview PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
              ),
              if (!kIsWeb && _generatedPdfFile != null) ...[
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _pdfService.openPdf(_generatedPdfFile);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error opening PDF: ${e.toString()}')),
                      );
                    }
                  },
                  icon: const Icon(Icons.remove_red_eye),
                  label: const Text('View Generated PDF'),
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
