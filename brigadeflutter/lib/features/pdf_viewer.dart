import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/components/banner_offline.dart';
import '../data/repositories/pdf_repository.dart';
import '../data/repositories_impl/pdf_repository_impl.dart';

class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;
  final String? version;

  const PdfViewer({
    super.key,
    required this.pdfUrl,
    required this.title,
    this.version,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfRepository _repo = PdfRepositoryImpl();

  bool _loading = true;
  bool _isOffline = false;
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _preparePdf();
  }

  Future<void> _preparePdf() async {
    setState(() {
      _loading = true;
      _isOffline = false;
      _localPath = null;
      _error = null;
    });

    final hasNetwork = await _checkNetwork();

    final file = await _repo.getPdfFile(
      id: widget.title,
      url: widget.pdfUrl,
      forceDownload: hasNetwork,
    );

    if (file != null && await file.exists()) {
      setState(() {
        _localPath = file.path;
        _loading = false;
      });
      await _saveVersion();
      return;
    }

    if (!hasNetwork) {
      setState(() {
        _loading = false;
        _isOffline = true;
      });
      return;
    }

    setState(() {
      _error = "No se pudo descargar el documento.";
      _loading = false;
    });
  }

  Future<bool> _checkNetwork() async {
    final conn = await Connectivity().checkConnectivity();
    return conn != ConnectivityResult.none;
  }

  Future<void> _saveVersion() async {
    if (widget.version == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_seen_${widget.title}", widget.version!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _body(),
    );
  }

  Widget _body() {
    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_localPath != null) {
      return PDFView(filePath: _localPath!);
    }

    if (_isOffline) {
      return const Column(
        children: [
          OfflineBanner(),
        ],
      );
    }

    return Column(
      children: [
        if (_error != null)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(_error!),
          ),
        ElevatedButton.icon(
          onPressed: _preparePdf,
          icon: const Icon(Icons.refresh),
          label: const Text("Reintentar"),
        )
      ],
    );
  }
}
