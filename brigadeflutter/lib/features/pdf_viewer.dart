import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/repositories_impl/pdf_repository_impl.dart';
import '../presentation/components/banner_offline.dart';


class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewer({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  final PdfRepositoryImpl _pdfRepository = PdfRepositoryImpl();
  final Connectivity _connectivity = Connectivity();

  File? _pdfFile;
  bool _isLoading = true;
  bool _isOffline = false;
  bool _downloadFailed = false;
  PdfControllerPinch? _pdfController;
  int _totalPages = 0;
  int _currentPage = 1;
  bool _pdfLoaded = false;
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _downloadFailed = false;
        _pdfLoaded = false;
      });

      // Verificar conectividad
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOffline = connectivityResult == ConnectivityResult.none;

      // Obtener el archivo PDF usando el repositorio
      final file = await _pdfRepository.getPdfFile(
        id: _generatePdfId(widget.title),
        url: widget.pdfUrl,
        forceDownload: false,
      );

      if (file != null && await file.exists()) {
        await _initializePdfController(file);
        setState(() {
          _pdfFile = file;
          _isOffline = false;
        });
      } else {
        setState(() {
          _downloadFailed = true;
        });
      }
    } catch (e) {
      print('Error loading PDF: $e');
      setState(() {
        _downloadFailed = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initializePdfController(File file) async {
    if (_isInitializing) return;

    _isInitializing = true;
    try {
      _pdfController?.dispose();

      // Crear el controlador y obtener el documento
      final document = await PdfDocument.openFile(file.path);
      _pdfController = PdfControllerPinch(document: PdfDocument.openFile(file.path));

      // Obtener el número total de páginas
      final totalPages = document.pagesCount;

      setState(() {
        _totalPages = totalPages;
        _pdfLoaded = true;
        _isInitializing = false;
      });
    } catch (e) {
      print('Error initializing PDF controller: $e');
      setState(() {
        _isInitializing = false;
        _downloadFailed = true;
      });
    }
  }

  String _generatePdfId(String title) {
    return title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
  }

  void _goToPreviousPage() {
    if (_pdfController != null && _currentPage > 1) {
      final newPage = _currentPage - 1;
      _pdfController!.jumpToPage(newPage);
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  void _goToNextPage() {
    if (_pdfController != null && _currentPage < _totalPages) {
      final newPage = _currentPage + 1;
      _pdfController!.jumpToPage(newPage);
      setState(() {
        _currentPage = newPage;
      });
    }
  }

  Future<void> _goToPage(int page) async {
    if (_pdfController != null && page >= 1 && page <= _totalPages) {
      _pdfController!.jumpToPage(page);
      setState(() {
        _currentPage = page;
      });
    }
  }

  void _showPageSelector() {
    if (_totalPages <= 1) return;

    int? selectedPage;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ir a página'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Selecciona una página (1 - $_totalPages)'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Página...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      selectedPage = int.tryParse(value);
                    },
                    onSubmitted: (value) {
                      _navigateToSelectedPage(selectedPage, context);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => _navigateToSelectedPage(selectedPage, context),
            child: const Text('Ir'),
          ),
        ],
      ),
    );
  }

  void _navigateToSelectedPage(int? page, BuildContext dialogContext) {
    if (page != null && page >= 1 && page <= _totalPages) {
      _goToPage(page); // Sin await
      Navigator.pop(dialogContext);
    } else {
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un número de página válido'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_pdfLoaded && _totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Text(
                  '$_currentPage/$_totalPages',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Banner offline
          if (_isOffline && _pdfFile == null)
            const OfflineBanner(),

          // Mensaje de error
          if (_downloadFailed && !_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'No se pudo cargar el documento',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadPdf,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),

          // Contenido principal
          Expanded(
            child: _buildPdfContent(),
          ),

          // Controles de navegación
          if (_pdfLoaded && _totalPages > 1)
            Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _currentPage > 1 ? _goToPreviousPage : null,
                  ),

                  // Selector de página
                  Expanded(
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: _showPageSelector,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.grey),
                              ),
                              child: Text(
                                'Página $_currentPage de $_totalPages',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: _currentPage < _totalPages ? _goToNextPage : null,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _isOffline && _pdfFile == null
          ? null
          : FloatingActionButton(
        onPressed: _loadPdf,
        tooltip: 'Recargar',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildPdfContent() {
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

    if (_pdfController != null && _pdfLoaded) {
      return PdfViewPinch(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
        },
        onDocumentLoaded: (document) {
          print('PDF document loaded successfully');
          // Actualizar el número total de páginas si es diferente
          if (document.pagesCount != _totalPages) {
            setState(() {
              _totalPages = document.pagesCount;
            });
          }
        },
        onDocumentError: (error) {
          print('PDF document error: $error');
          setState(() {
            _downloadFailed = true;
            _pdfLoaded = false;
          });
        },
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
          pageLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (_, error) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error cargando página: $error',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_downloadFailed) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Error al cargar el documento',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Verifica tu conexión a internet e intenta nuevamente',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insert_drive_file, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Documento no disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}