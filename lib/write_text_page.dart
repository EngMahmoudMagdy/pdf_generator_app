import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf_generator_app/services/pdf_service.dart';
import 'package:pdf_generator_app/web_to_pdf_page.dart';

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
              height: 25,
            ),
            ElevatedButton(
              onPressed: addHtmlExample,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
              child: const Text('HTML Example'),
            ),
            const SizedBox(
              height: 5,
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
            const SizedBox(
              height: 5,
            ),
            ElevatedButton.icon(
              onPressed: generateHTMLFile2,
              icon: const Icon(Icons.chat),
              label: const Text('Generate PDF Flutter HTML To PDF tool'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
            if (!kIsWeb)
              ElevatedButton.icon(
                onPressed: generateHTMLFile3,
                icon: const Icon(Icons.chat),
                label: const Text('Preview in Flutter WebView And Print'),
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

  void generateHTMLFile2() {
    if (textEditingController.text.isNotEmpty) {
      _pdfService.generatePdfFromHTMLText2(
          textEditingController.text, 'html_pdf');
    }
  }

  void generateHTMLFile3() {
    if (textEditingController.text.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) =>
              WebToPdfPage(htmlContent: textEditingController.text),
        ),
      );
    }
  }

  void addMarkdownExample() {
    textEditingController.text = '''markdown
    # Heading 1
    ## Heading 2
    ### Heading 3
    #### Heading 4
    ##### Heading 5
    ###### Heading 6

    **Bold Text**
    *Italic Text*
    ***Bold and Italic Text***
    ~~Strikethrough Text~~
    `Inline Code`

    ---

    ### Links and Images
    [Google](https://www.google.com)  
    ![Markdown Logo](https://markdown-here.com/img/icon256.png)  

    ---

    ### Lists
    #### Unordered List
    - Item 1
    - Item 2
    - Subitem 2.1
    - Subitem 2.2

    #### Ordered List
    1. First item
    2. Second item
    1. Subitem 2.1
    2. Subitem 2.2

    ---

    ### Blockquotes
    > This is a blockquote.
    > It can span multiple lines.

    ---

    ### Code Blocks
    ```python
    def hello_world():
    print("Hello, World!")
    ```

    ---

    ### Tables
    | Name       | Age | Occupation   |
    |------------|-----|--------------|
    | John Doe   | 28  | Engineer     |
    | Jane Smith | 34  | Designer     |
    | Sam Brown  | 22  | Student      |

    ---

    ### Horizontal Rule
    ---

    ### Inline HTML (for advanced features)
    <p style="color: red;">This is a red paragraph using HTML.</p>
    ''';
  }

  void addHtmlExample() {
    textEditingController.text = '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>HTML Example</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f4f4;
      color: #333;
    }
    .highlight {
      background-color: yellow;
    }
    table {
      width: 100%;
      border-collapse: collapse;
    }
    th, td {
      border: 1px solid #ddd;
      padding: 8px;
    }
    th {
      background-color: #f2f2f2;
    }
  </style>
</head>
<body>

  <h1>Heading 1</h1>
  <h2>Heading 2</h2>
  <h3>Heading 3</h3>
  <h4>Heading 4</h4>
  <h5>Heading 5</h5>
  <h6>Heading 6</h6>

  <p><strong>Bold Text</strong></p>
  <p><em>Italic Text</em></p>
  <p><strong><em>Bold and Italic Text</em></strong></p>
  <p><del>Strikethrough Text</del></p>
  <p><code>Inline Code</code></p>

  <hr>

  <h2>Links and Images</h2>
  <a href="https://www.google.com">Google</a><br>
  <img src="https://markdown-here.com/img/icon256.png" alt="Markdown Logo" width="100">

  <hr>

  <h2>Lists</h2>
  <h3>Unordered List</h3>
  <ul>
    <li>Item 1</li>
    <li>Item 2
      <ul>
        <li>Subitem 2.1</li>
        <li>Subitem 2.2</li>
      </ul>
    </li>
  </ul>

  <h3>Ordered List</h3>
  <ol>
    <li>First item</li>
    <li>Second item
      <ol>
        <li>Subitem 2.1</li>
        <li>Subitem 2.2</li>
      </ol>
    </li>
  </ol>

  <hr>

  <h2>Blockquotes</h2>
  <blockquote>
    This is a blockquote. It can span multiple lines.
  </blockquote>

  <hr>

  <h2>Code Blocks</h2>
  <pre><code>
def hello_world():
    print("Hello, World!")
  </code></pre>

  <hr>

  <h2>Tables</h2>
  <table>
    <thead>
      <tr>
        <th>Name</th>
        <th>Age</th>
        <th>Occupation</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td>John Doe</td>
        <td>28</td>
        <td>Engineer</td>
      </tr>
      <tr>
        <td>Jane Smith</td>
        <td>34</td>
        <td>Designer</td>
      </tr>
      <tr>
        <td>Sam Brown</td>
        <td>22</td>
        <td>Student</td>
      </tr>
    </tbody>
  </table>

  <hr>

  <h2>Advanced Styling</h2>
  <p style="color: red;">This is a red paragraph using inline CSS.</p>
  <p class="highlight">This text is highlighted using a CSS class.</p>

  <hr>

  <h2>Forms</h2>
  <form>
    <label for="name">Name:</label>
    <input type="text" id="name" name="name"><br><br>
    <label for="email">Email:</label>
    <input type="email" id="email" name="email"><br><br>
    <input type="submit" value="Submit">
  </form>

  <hr>

  <h2>Multimedia</h2>
  <audio controls>
    <source src="audio.mp3" type="audio/mpeg">
    Your browser does not support the audio element.
  </audio><br>
  <video width="320" height="240" controls>
    <source src="video.mp4" type="video/mp4">
    Your browser does not support the video element.
  </video>

</body>
</html>
    ''';
  }
}
