import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfIsolateWorker {
  // Sanitize id to a safe filename
  static String _sanitizeId(String id) {
    final s = id.toLowerCase();
    return s.replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
  }

  /// Returns the canonical path where the worker stores the cached PDF for [id].
  static Future<String> getCachedPath(String id) async {
    final sanitizedName = _sanitizeId(id);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = p.join(dir.path, "cached_pdfs", "$sanitizedName.pdf");
    return filePath;
  }

  /// Downloads the PDF in an isolate (or returns existing cached file path).
  /// Returns a file path (String) on success, or the exact [offlineMessage] string if offline/no-cache.
  static Future<String> downloadPdf({
    required String url,
    required String id,
    required bool forceDownload,
    required String offlineMessage,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();

    await Isolate.spawn(
      _downloadPdfEntryPoint,
      {
        "port": receivePort.sendPort,
        "errorPort": errorPort.sendPort,
        "url": url,
        "id": id,
        "forceDownload": forceDownload,
        "offlineMessage": offlineMessage,
      },
    );

    // Manejar tanto el resultado como errores
    final completer = Completer<String>();
    receivePort.listen((message) {
      completer.complete(message as String);
      receivePort.close();
      errorPort.close();
    });

    errorPort.listen((error) {
      if (!completer.isCompleted) {
        completer.complete(offlineMessage);
      }
      receivePort.close();
      errorPort.close();
    });

    // Timeout después de 30 segundos
    final result = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        print('PDF download timeout');
        return offlineMessage;
      },
    );

    return result;
  }

  // Entry point run inside the isolate
  static Future<void> _downloadPdfEntryPoint(dynamic message) async {
    final SendPort sendPort = message["port"] as SendPort;
    final SendPort errorPort = message["errorPort"] as SendPort;
    final String url = message["url"] as String;
    final String id = message["id"] as String;
    final bool forceDownload = message["forceDownload"] as bool;
    final String offlineMessage = message["offlineMessage"] as String;

    try {
      final sanitizedName = _sanitizeId(id);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory pdfDir = Directory(p.join(appDir.path, "cached_pdfs"));
      final String filePath = p.join(pdfDir.path, "$sanitizedName.pdf");
      final file = File(filePath);

      // Crear directorio si no existe
      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      // Verificar si el archivo existe y no forzamos descarga
      if (await file.exists() && !forceDownload) {
        sendPort.send(filePath);
        return;
      }

      // Verificar conectividad
      final connectivity = Connectivity();
      final connectivityResult = await connectivity.checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        // Sin conexión: retornar cache si existe, sino mensaje offline
        if (await file.exists()) {
          sendPort.send(filePath);
        } else {
          sendPort.send(offlineMessage);
        }
        return;
      }

      // Tenemos conexión: intentar descargar
      final dio = Dio();
      final response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data!.isNotEmpty) {
        final bytes = response.data!;

        // Escribir archivo
        await file.writeAsBytes(bytes, flush: true);
        sendPort.send(filePath);
      } else {
        // Error HTTP: retornar cache si existe
        if (await file.exists()) {
          sendPort.send(filePath);
        } else {
          sendPort.send(offlineMessage);
        }
      }
    } on DioException catch (e) {
      print('Dio error in isolate: $e');
      // En error de red, intentar retornar cache
      try {
        final path = await getCachedPath(id);
        final file = File(path);
        if (await file.exists()) {
          sendPort.send(path);
        } else {
          sendPort.send(offlineMessage);
        }
      } catch (_) {
        sendPort.send(offlineMessage);
      }
    } catch (e) {
      print('Unexpected error in PDF isolate: $e');
      try {
        final path = await getCachedPath(id);
        final file = File(path);
        if (await file.exists()) {
          sendPort.send(path);
        } else {
          sendPort.send(offlineMessage);
        }
      } catch (_) {
        sendPort.send(offlineMessage);
      }
    }
  }
}