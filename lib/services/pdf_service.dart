import 'dart:html' as html;
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class PdfService {
  Future<File?> generatePdfFromHtml(String htmlContent, String fileName) async {
    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission not granted');
      }

      // Get temporary directory
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;

      // Convert HTML to PDF
      final File? file = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent,
        tempPath,
        fileName,
      );

      return file;
    } catch (e) {
      print('Error generating PDF: $e');
      return null;
    }
  }

  Future<void> openPdf(File file) async {
    try {
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  // Sample HTML template with sections, tables, images, and styled text
  static String getSampleHtmlTemplate() {
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

  void generatePdfFromMarkDown(String text, String pdfName) async {
    final newpdf = Document();
    List<Widget> widgets = await HTMLToPdf().convertMarkdown(text);
    newpdf.addPage(MultiPage(
        maxPages: 200,
        build: (context) {
          return widgets;
        }));
    final fileBytes = await newpdf.save();
    if (fileBytes == null) {
      print("Error: File bytes are null on web.");
    }
    if (kIsWeb) {
      await savePdfWeb(newpdf);
    } else {
      saveFile(pdfName, fileBytes);
    }
  }

  Future<void> savePdfWeb(Document pdf) async {
    final Uint8List pdfBytes = await pdf.save();
    final blob = html.Blob([pdfBytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "markdown_output.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  void generatePdfFromHTMLText(String text, String pdfName) async {
    final newpdf = Document();
    List<Widget> widgets = await HTMLToPdf().convert(text);
    newpdf.addPage(MultiPage(
        maxPages: 200,
        build: (context) {
          return widgets;
        }));
    final fileBytes = await newpdf.save();
    if (fileBytes == null) {
      print("Error: File bytes are null on web.");
    }
    if (kIsWeb) {
      await savePdfWeb(newpdf);
    } else {
      saveFile(pdfName, fileBytes);
    }
  }

  void saveFile(String name, List<int> pdfBytes) async {
    try {
      final outputPdfFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save as PDF',
        fileName: 'name.pdf',
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (outputPdfFile != null) {
        final pdfFile = File(outputPdfFile);
        await pdfFile.writeAsBytes(pdfBytes);
        OpenFile.open(pdfFile.path); // Open the saved PDF file
      } else {
        print("User canceled the file save dialog.");
      }
    } catch (e) {
      print("Error saving PDF: $e");
    }
  }
}
