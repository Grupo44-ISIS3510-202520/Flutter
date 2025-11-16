import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../presentation/components/banner_offline.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key, required this.pdfUrl, required this.title});
  final String pdfUrl;
  final String title;

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final Connectivity _connectivity = Connectivity();

  bool _isLoading = true;
  bool _isOffline = false;
  bool _hasCachedFile = false;
  String? _localPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _hasCachedFile = false;
      });

      final List<ConnectivityResult> connectivityResult = await _connectivity.checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;

      if (_isOffline) {
        await _loadFromCache();
      } else {
        await _loadFromUrl();
        _downloadToCache();
      }
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _errorMessage = 'No se pudo cargar el documento';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFromUrl() async {
    try {
      final http.Response response = await http.get(Uri.parse(widget.pdfUrl));
      final Uint8List bytes = response.bodyBytes;

      final Directory dir = await getApplicationDocumentsDirectory();
      final File file = File('${dir.path}/temp_${_generatePdfId(widget.title)}.pdf');
      await file.writeAsBytes(bytes, flush: true);

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading from URL: $e');
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final String pdfId = _generatePdfId(widget.title);
      final String cachePath = await _getCachedPath(pdfId);
      final File cacheFile = File(cachePath);

      final bool cacheExists = await cacheFile.exists();

      if (cacheExists) {
        setState(() {
          _localPath = cacheFile.path;
          _hasCachedFile = true;
          _isLoading = false;
        });
      } else {
        print('PDF no encontrado en cache');
        setState(() {
          _errorMessage = 'No hay versión descargada disponible';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading from cache: $e');
      setState(() {
        _errorMessage = 'Error cargando documento offline';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadToCache() async {
    try {
      final String pdfId = _generatePdfId(widget.title);

      final http.Response response = await http.get(Uri.parse(widget.pdfUrl));
      final Uint8List bytes = response.bodyBytes;

      final String cachePath = await _getCachedPath(pdfId);
      final File cacheFile = File(cachePath);

      final Directory cacheDir = cacheFile.parent;
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      await cacheFile.writeAsBytes(bytes, flush: true);

      print('PDF guardado en cache: ${cacheFile.path}');
      print('Tamaño: ${bytes.length} bytes');

    } catch (e) {
      print('Background cache download failed: $e');
    }
  }

  Future<String> _getCachedPath(String id) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/cached_pdfs/$id.pdf';
  }

  String _generatePdfId(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  Future<void> _retryLoad() async {
    await _loadPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: <Widget>[

          if (_isOffline && !_hasCachedFile)
            const OfflineBanner(),


          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
      floatingActionButton: _errorMessage != null
          ? FloatingActionButton(
              onPressed: _retryLoad,
              tooltip: 'Reintentar',
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Cargando documento...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            if (!_isOffline)
              ElevatedButton(
                onPressed: _retryLoad,
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    return PDFView(
      filePath: _localPath,
      onError: (error) {
        setState(() {
          _errorMessage = 'Error mostrando el documento';
        });
      },
      onPageError: (int? page, error) {
        setState(() {
          _errorMessage = 'Error en página $page: $error';
        });
      },
      onRender: (int? pages) {
      },
    );
  }
}
