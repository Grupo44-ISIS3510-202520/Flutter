import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewer({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  bool isReady = false;
  String? localPath;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/temp.pdf");
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        localPath = file.path;
        isReady = true;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: errorMessage != null
          ? Center(child: Text("Error: $errorMessage"))
          : isReady
          ? PDFView(filePath: localPath!)
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
