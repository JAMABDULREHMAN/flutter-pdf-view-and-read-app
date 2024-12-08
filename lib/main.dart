import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() {
  runApp(const PDFApp());
}

class PDFApp extends StatelessWidget {
  const PDFApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const PDFHomeScreen(),
    );
  }
}

class PDFHomeScreen extends StatefulWidget {
  const PDFHomeScreen({super.key});

  @override
  _PDFHomeScreenState createState() => _PDFHomeScreenState();
}

class _PDFHomeScreenState extends State<PDFHomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final pw.Document _pdf = pw.Document();
  final List<File> _images = [];
  String? _pdfPath;

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFiles = await _picker.pickMultiImage();
    setState(() {
      _images.addAll(pickedFiles.map((file) => File(file.path)).toList());
    });
  }

  // Create a PDF from selected images
  Future<void> _createPDF() async {
    _pdf.addPage(
      pw.MultiPage(
        build: (context) => _images
            .map((image) => pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(image.readAsBytesSync()),
                    fit: pw.BoxFit.contain,
                  ),
                ))
            .toList(),
      ),
    );

    final outputDir = await getApplicationDocumentsDirectory();
    final pdfFile = File('${outputDir.path}/output.pdf');
    await pdfFile.writeAsBytes(await _pdf.save());

    setState(() {
      _pdfPath = pdfFile.path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PDF saved at: ${pdfFile.path}')),
    );
  }

  // Open PDF viewer
  void _openPDFViewer() {
    if (_pdfPath != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(pdfPath: _pdfPath!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image to PDF"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Display selected images
            Expanded(
              child: _images.isEmpty
                  ? const Center(
                      child: Text(
                        'No images selected.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: _images.length,
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _images[index],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
            ),

            // Buttons to pick image, create PDF, and view PDF
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(FontAwesomeIcons.image),
                  label: const Text("Pick Images"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _images.isNotEmpty ? _createPDF : null,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Create PDF"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pdfPath != null ? _openPDFViewer : null,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text("View PDF"),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({super.key, required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Viewer'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: PDFView(
        filePath: pdfPath,
        autoSpacing: true,
        enableSwipe: true,
        swipeHorizontal: true,
      ),
    );
  }
}
