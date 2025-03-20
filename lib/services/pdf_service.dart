import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
      final String filePath = '$tempPath/$fileName.pdf';

      // Create a PDF document
      final pdf = pw.Document();
      
      // Parse HTML and convert to PDF widgets
      // This is a simplified approach - in a real app, you'd need more complex HTML parsing
      final htmlLines = htmlContent.split('\n');
      
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
                      color: PdfColors.blue800
                    )
                  ),
                ),
                pw.Paragraph(
                  text: 'Generated on: ${DateTime.now().toString().split('.')[0]}',
                  style: pw.TextStyle(
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
                pw.Header(level: 1, text: '1. Introduction'),
                pw.Paragraph(
                  text: 'This is a sample PDF document generated from HTML template. It demonstrates various formatting options including sections, tables, images, and text styling.',
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
                pw.Bullet(text: 'Colored text for highlighting important information'),
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

      // Save the PDF to a file
      final File file = File(filePath);
      await file.writeAsBytes(await pdf.save());
      
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
}
