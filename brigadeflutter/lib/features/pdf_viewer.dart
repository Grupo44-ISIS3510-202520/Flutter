import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../presentation/components/banner_offline.dart';

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

      // Verificar conectividad
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;

      print('📱 Estado: ${_isOffline ? 'Offline' : 'Online'}');
      print('📄 PDF: ${widget.title}');

      if (_isOffline) {
        // Modo offline: intentar cargar desde cache
        await _loadFromCache();
      } else {
        // Modo online: cargar desde URL como antes
        await _loadFromUrl();

        // INMEDIATAMENTE descargar en cache para offline (sin isolate)
        _downloadToCache();
      }
    } catch (e) {
      print('❌ Error loading PDF: $e');
      setState(() {
        _errorMessage = 'No se pudo cargar el documento';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFromUrl() async {
    try {
      print('🔄 Cargando desde URL...');

      // Cargar directamente desde la URL como en el código original
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/temp_${_generatePdfId(widget.title)}.pdf");
      await file.writeAsBytes(bytes, flush: true);

      print('✅ PDF cargado desde URL: ${file.path}');

      setState(() {
        _localPath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading from URL: $e');
      // Si falla la URL, intentar desde cache
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final pdfId = _generatePdfId(widget.title);
      final cachePath = await _getCachedPath(pdfId);
      final cacheFile = File(cachePath);

      print('🔍 Buscando en cache: $pdfId');
      print('📁 Ruta de cache: $cachePath');

      final cacheExists = await cacheFile.exists();
      print('📄 Existe en cache: $cacheExists');

      if (cacheExists) {
        print('✅ PDF encontrado en cache: ${cacheFile.path}');
        setState(() {
          _localPath = cacheFile.path;
          _hasCachedFile = true;
          _isLoading = false;
        });
      } else {
        print('❌ PDF NO encontrado en cache');
        setState(() {
          _errorMessage = 'No hay versión descargada disponible';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error loading from cache: $e');
      setState(() {
        _errorMessage = 'Error cargando documento offline';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadToCache() async {
    try {
      final pdfId = _generatePdfId(widget.title);
      print('💾 Iniciando descarga background para cache: $pdfId');

      // Descargar directamente sin isolate
      final response = await http.get(Uri.parse(widget.pdfUrl));
      final bytes = response.bodyBytes;

      final cachePath = await _getCachedPath(pdfId);
      final cacheFile = File(cachePath);

      // Crear directorio si no existe
      final cacheDir = cacheFile.parent;
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }

      await cacheFile.writeAsBytes(bytes, flush: true);

      print('✅ PDF guardado en cache: ${cacheFile.path}');
      print('📏 Tamaño del archivo: ${bytes.length} bytes');

    } catch (e) {
      print('⚠️ Background cache download failed: $e');
      // No mostramos error porque es en segundo plano
    }
  }

  Future<String> _getCachedPath(String id) async {
    final dir = await getApplicationDocumentsDirectory();
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
        children: [
          // Banner offline solo cuando estamos offline y no tenemos archivo en cache
          if (_isOffline && !_hasCachedFile)
            const OfflineBanner(),

          // Contenido principal
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
          children: [
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
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            if (!_isOffline) // Solo mostrar reintentar si estamos online
              ElevatedButton(
                onPressed: _retryLoad,
                child: const Text('Reintentar'),
              ),
          ],
        ),
      );
    }

    // Mostrar el PDF
    return PDFView(
      filePath: _localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      onError: (error) {
        print('❌ Error en PDFView: $error');
        setState(() {
          _errorMessage = 'Error mostrando el documento';
        });
      },
      onPageError: (page, error) {
        print('❌ Error en página $page: $error');
        setState(() {
          _errorMessage = 'Error en página $page: $error';
        });
      },
      onRender: (pages) {
        print('✅ PDF renderizado con $pages páginas');
      },
    );
  }
}