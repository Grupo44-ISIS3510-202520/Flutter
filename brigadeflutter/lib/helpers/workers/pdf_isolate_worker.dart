import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfIsolateWorker {
  static String _sanitizeId(String id) {
    final String s = id.toLowerCase();
    return s.replaceAll(RegExp(r'[^a-z0-9_-]'), '_');
  }

  static Future<String> getCachedPath(String id) async {
    final String sanitizedName = _sanitizeId(id);
    final Directory dir = await getApplicationDocumentsDirectory();
    final String filePath = p.join(dir.path, 'cached_pdfs', '$sanitizedName.pdf');
    return filePath;
  }

  static Future<String> downloadPdf({
    required String url,
    required String id,
    required bool forceDownload,
    required String offlineMessage,
  }) async {
    final ReceivePort receivePort = ReceivePort();
    final ReceivePort errorPort = ReceivePort();

    await Isolate.spawn(
      _downloadPdfEntryPoint,
      <String, Object>{
        'port': receivePort.sendPort,
        'errorPort': errorPort.sendPort,
        'url': url,
        'id': id,
        'forceDownload': forceDownload,
        'offlineMessage': offlineMessage,
      },
    );

    final Completer<String> completer = Completer<String>();
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

    final String result = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        //print('PDF download timeout');
        return offlineMessage;
      },
    );

    return result;
  }

  static Future<void> _downloadPdfEntryPoint(dynamic message) async {
    final SendPort sendPort = message['port'] as SendPort;
    //final SendPort errorPort = message["errorPort"] as SendPort;
    final String url = message['url'] as String;
    final String id = message['id'] as String;
    final bool forceDownload = message['forceDownload'] as bool;
    final String offlineMessage = message['offlineMessage'] as String;

    try {
      final String sanitizedName = _sanitizeId(id);
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory pdfDir = Directory(p.join(appDir.path, 'cached_pdfs'));
      final String filePath = p.join(pdfDir.path, '$sanitizedName.pdf');
      final File file = File(filePath);

      if (!await pdfDir.exists()) {
        await pdfDir.create(recursive: true);
      }

      if (await file.exists() && !forceDownload) {
        sendPort.send(filePath);
        return;
      }

      final Connectivity connectivity = Connectivity();
      final List<ConnectivityResult> connectivityResult = await connectivity.checkConnectivity();
      final bool isConnected = connectivityResult != ConnectivityResult.none;

      if (!isConnected) {
        if (await file.exists()) {
          sendPort.send(filePath);
        } else {
          sendPort.send(offlineMessage);
        }
        return;
      }

      final Dio dio = Dio();
      final Response<List<int>> response = await dio.get<List<int>>(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
        ),
      );

      if (response.statusCode == 200 && response.data != null && response.data!.isNotEmpty) {
        final List<int> bytes = response.data!;

        await file.writeAsBytes(bytes, flush: true);
        sendPort.send(filePath);
      } else {
        if (await file.exists()) {
          sendPort.send(filePath);
        } else {
          sendPort.send(offlineMessage);
        }
      }
    } on DioException {
      try {
        final String path = await getCachedPath(id);
        final File file = File(path);
        if (await file.exists()) {
          sendPort.send(path);
        } else {
          sendPort.send(offlineMessage);
        }
      } catch (_) {
        sendPort.send(offlineMessage);
      }
    } catch (e) {
      try {
        final String path = await getCachedPath(id);
        final File file = File(path);
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