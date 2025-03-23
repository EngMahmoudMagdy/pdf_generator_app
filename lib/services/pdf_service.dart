import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class PdfService {
  // Generate PDF document (works on all platforms)
  Future<pw.Document> generatePdfDocument(String htmlContent) async {
    // Create a PDF document
    final pdf = pw.Document();

    // Add a page with content derived from HTML
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Sample PDF Report',
                    style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue800)),
              ),
              pw.Paragraph(
                text:
                    'Generated on: ${DateTime.now().toString().split('.')[0]}',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.Header(level: 1, text: '1. Introduction'),
              pw.Paragraph(
                text:
                    'This is a sample PDF document generated from HTML template. It demonstrates various formatting options including sections, tables, images, and text styling.',
              ),
              pw.Header(level: 1, text: '2. Data Table Example'),
              pw.Table.fromTextArray(
                headers: ['ID', 'Name', 'Department', 'Position'],
                data: [
                  ['001', 'John Doe', 'Marketing', 'Manager'],
                  ['002', 'Jane Smith', 'Development', 'Senior Developer'],
                  ['003', 'Robert Johnson', 'Finance', 'Accountant'],
                  ['004', 'Emily Davis', 'Human Resources', 'Director'],
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.blue700,
                ),
                border: pw.TableBorder.all(
                  color: PdfColors.grey400,
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerLeft,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerLeft,
                  3: pw.Alignment.centerLeft,
                },
              ),
              pw.Header(level: 1, text: '3. Text Formatting Examples'),
              pw.Bullet(text: 'Bold text for emphasis'),
              pw.Bullet(text: 'Regular text for normal content'),
              pw.Bullet(
                  text: 'Colored text for highlighting important information'),
              pw.Bullet(text: 'Underlined text for specific details'),
              pw.SizedBox(height: 20),
              pw.Footer(
                title: pw.Text(
                  '© 2023 Your Company Name - All Rights Reserved',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf;
  }

  // Check if running on desktop platform
  bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  // Platform-specific method to save and return the PDF file
  Future<File?> generatePdfFromHtml(String htmlContent, String fileName) async {
    try {
      final pdf = await generatePdfDocument(htmlContent);

      if (kIsWeb) {
        // For web, we can't return a File object
        return null;
      } else if (isDesktop) {
        // For desktop platforms, use file_selector
        final Uint8List bytes = await pdf.save();

        // On macOS, we need to handle the file saving differently
        if (Platform.isMacOS) {
          final String? path = await getSaveLocationPath(fileName);
          if (path == null) return null;

          final File file = File(path);
          await file.writeAsBytes(bytes);
          return file;
        } else {
          // For Windows and Linux
          final FileSaveLocation? result = await getSaveLocation(
            suggestedName: '$fileName.pdf',
            acceptedTypeGroups: [
              const XTypeGroup(label: 'PDF', extensions: ['pdf'])
            ],
          );

          if (result == null) return null;

          final File file = File(result.path);
          await file.writeAsBytes(bytes);
          return file;
        }
      } else {
        // Mobile code remains the same
        // Request storage permission
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          throw Exception('Storage permission not granted');
        }

        // Get temporary directory
        final Directory tempDir = await getTemporaryDirectory();
        final String tempPath = tempDir.path;
        final String filePath = '$tempPath/$fileName.pdf';

        // Save the PDF to a file
        final File file = File(filePath);
        await file.writeAsBytes(await pdf.save());

        return file;
      }
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  // Helper method for macOS file saving
  Future<String?> getSaveLocationPath(String fileName) async {
    try {
      final XFile? file = await getSaveLocation(
        suggestedName: '$fileName.pdf',
        acceptedTypeGroups: [
          const XTypeGroup(label: 'PDF', extensions: ['pdf'])
        ],
      ).then((result) => result != null ? XFile(result.path) : null);

      return file?.path;
    } catch (e) {
      print('Error getting save location: $e');

      // Fallback for macOS
      final Directory documentsDir = await getApplicationDocumentsDirectory();
      return '${documentsDir.path}/$fileName.pdf';
    }
  }

  // Share PDF - platform specific
  Future<void> sharePdf(String htmlContent, String fileName) async {
    final pdf = await generatePdfDocument(htmlContent);
    final bytes = await pdf.save();

    savePDFOnDevice(bytes, fileName);
  }

  void savePDFOnDevice(Uint8List bytes, String fileName) async {
    if (kIsWeb) {
      // Web code remains the same
      // For web, use Printing package to download
      await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
    } else if (isDesktop) {
      if (Platform.isMacOS) {
        final String? path = await getSaveLocationPath(fileName);
        if (path != null) {
          final File file = File(path);
          await file.writeAsBytes(bytes);

          // Open the file after saving on macOS
          final Uri uri = Uri.file(file.path);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw Exception('Could not launch $uri');
          }
        }
      } else {
        // Windows and Linux code remains the same
        // For desktop, save to a user-selected location
        final FileSaveLocation? result = await getSaveLocation(
          suggestedName: '$fileName.pdf',
          acceptedTypeGroups: [
            const XTypeGroup(label: 'PDF', extensions: ['pdf'])
          ],
        );

        if (result != null) {
          final File file = File(result.path);
          await file.writeAsBytes(bytes);
          // Open the file after saving
          final Uri uri = Uri.file(file.path);
          if (!await launchUrl(uri)) {
            throw Exception('Could not launch $uri');
          }
        }
      }
    } else {
      // Mobile code remains the same
      // For mobile, use Printing package to share
      await Printing.sharePdf(bytes: bytes, filename: '$fileName.pdf');
    }
  }

  // Sample HTML template with sections, tables, images, and styled text
  static String getSampleHtmlTemplate() {
    // The HTML template remains the same
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
          color: #333;
        }
        .header {
          text-align: center;
          margin-bottom: 30px;
        }
        h1 {
          color: #2c3e50;
          border-bottom: 2px solid #3498db;
          padding-bottom: 10px;
        }
        h2 {
          color: #2980b9;
          margin-top: 25px;
        }
        .bold-text {
          font-weight: bold;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin: 20px 0;
        }
        table, th, td {
          border: 1px solid #ddd;
        }
        th {
          background-color: #f2f2f2;
          padding: 12px;
          text-align: left;
        }
        td {
          padding: 10px;
        }
        .image-container {
          text-align: center;
          margin: 20px 0;
        }
        img {
          max-width: 80%;
          height: auto;
        }
        .footer {
          margin-top: 30px;
          text-align: center;
          font-size: 12px;
          color: #7f8c8d;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Sample PDF Report</h1>
        <p>Generated on: <span class="bold-text">${DateTime.now().toString().split('.')[0]}</span></p>
      </div>
      
      <h2>1. Introduction</h2>
      <p>This is a <span class="bold-text">sample PDF document</span> generated from HTML template. It demonstrates various formatting options including sections, tables, images, and text styling.</p>
      
      <h2>2. Data Table Example</h2>
      <table>
        <tr>
          <th>ID</th>
          <th>Name</th>
          <th>Department</th>
          <th>Position</th>
        </tr>
        <tr>
          <td>001</td>
          <td>John Doe</td>
          <td>Marketing</td>
          <td>Manager</td>
        </tr>
        <tr>
          <td>002</td>
          <td>Jane Smith</td>
          <td>Development</td>
          <td>Senior Developer</td>
        </tr>
        <tr>
          <td>003</td>
          <td>Robert Johnson</td>
          <td>Finance</td>
          <td>Accountant</td>
        </tr>
        <tr>
          <td>004</td>
          <td>Emily Davis</td>
          <td>Human Resources</td>
          <td>Director</td>
        </tr>
      </table>
      
      <h2>3. Image Example</h2>
      <div class="image-container">
        <p>Below is a placeholder image. In a real application, you would use a base64 encoded image or a URL.</p>
        <img src="https://via.placeholder.com/400x200" alt="Placeholder Image">
      </div>
      
      <h2>4. Text Formatting Examples</h2>
      <p>This section demonstrates various text formatting options:</p>
      <ul>
        <li><span class="bold-text">Bold text</span> for emphasis</li>
        <li>Regular text for normal content</li>
        <li>You can also include <span style="color: #e74c3c;">colored text</span> for highlighting important information</li>
        <li>Or <span style="text-decoration: underline;">underlined text</span> for specific details</li>
      </ul>
      
      <div class="footer">
        <p>© 2023 Your Company Name - All Rights Reserved</p>
      </div>
    </body>
    </html>
    ''';
  }

  // View PDF - platform specific
  Future<void> openPdf(File? file) async {
    if (file == null) {
      print('No file to open');
      return;
    }

    if (kIsWeb) {
      // Web platform doesn't use this method
      return;
    } else if (isDesktop) {
      // For desktop platforms, use url_launcher
      try {
        // For macOS, we need a different approach
        if (Platform.isMacOS) {
          // Use the file path directly with Process.run
          final result = await Process.run('open', [file.path]);
          if (result.exitCode != 0) {
            throw Exception('Could not open file: ${result.stderr}');
          }
        } else {
          // For Windows and Linux, use url_launcher
          final Uri uri = Uri.file(file.path);
          if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
            throw Exception('Could not launch $uri');
          }
        }
      } catch (e) {
        print('Error opening PDF: $e');
        throw Exception('Failed to open PDF: $e');
      }
    } else {
      // For mobile platforms, use open_file
      try {
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) {
          throw Exception('Could not open file: ${result.message}');
        }
      } catch (e) {
        print('Error opening PDF: $e');
        throw Exception('Failed to open PDF: $e');
      }
    }
  }

  // Preview PDF - works on all platforms
  Future<void> previewPdf(String htmlContent, BuildContext context) async {
    try {
      final pdf = await generatePdfDocument(htmlContent);
      final bytes = await pdf.save();

      if (isDesktop) {
        // For desktop platforms, save the file instead of printing
        final String fileName =
            'sample_report_${DateTime.now().millisecondsSinceEpoch}';

        if (Platform.isMacOS) {
          // For macOS, save to a temporary file and open it
          final Directory tempDir = await getTemporaryDirectory();
          final String filePath = '${tempDir.path}/$fileName.pdf';
          final File file = File(filePath);
          await file.writeAsBytes(bytes);

          // Use Process.run to open the file with the default application
          final result = await Process.run('open', [filePath]);
          if (result.exitCode != 0) {
            throw Exception('Could not open file: ${result.stderr}');
          }
        } else {
          // For Windows and Linux
          final FileSaveLocation? result = await getSaveLocation(
            suggestedName: '$fileName.pdf',
            acceptedTypeGroups: [
              const XTypeGroup(label: 'PDF', extensions: ['pdf'])
            ],
          );

          if (result != null) {
            final File file = File(result.path);
            await file.writeAsBytes(bytes);

            // Open the file after saving
            final Uri uri = Uri.file(file.path);
            if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
              throw Exception('Could not open $uri');
            }
          }
        }
      } else {
        // For web and mobile, use Printing package
        await Printing.layoutPdf(
          onLayout: (_) => Future.value(bytes),
          name: 'Sample PDF Report',
          format: PdfPageFormat.a4,
          dynamicLayout: true,
        );
      }
    } catch (e) {
      print('Error in previewPdf: $e');
      rethrow;
    }
  }

  void generatePdfFromMarkDown(String text, String pdfName) async {
    final newpdf = Document();
    List<pw.Widget> widgets = await HTMLToPdf().convertMarkdown(text);
    newpdf.addPage(MultiPage(
        maxPages: 200,
        build: (context) {
          return widgets;
        }));
    final fileBytes = await newpdf.save();
    savePDFOnDevice(fileBytes, pdfName);
  }

  void generatePdfFromHTMLText(String text, String pdfName) async {
    final newpdf = Document();
    List<pw.Widget> widgets = await HTMLToPdf().convert(text);
    newpdf.addPage(MultiPage(
        maxPages: 200,
        build: (context) {
          return widgets;
        }));
    final fileBytes = await newpdf.save();
    savePDFOnDevice(fileBytes, pdfName);
  }

  void generatePdfFromHTMLText2(String text, String pdfName) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return await Printing.convertHtml(
          format: format,
          html: text,
        );
      },
    );
  }
}
