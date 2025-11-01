import 'dart:async';
import 'dart:isolate';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PdfIsolateWorker {
  static Future<String> downloadPdf({
    required String url,
    required String id,
    required bool forceDownload,
    required String offlineMessage,
  }) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      _downloadPdfEntryPoint,
      {
        "port": receivePort.sendPort,
        "url": url,
        "id": id,
        "forceDownload": forceDownload,
        "offlineMessage": offlineMessage,
      },
    );

    return await receivePort.first as String;
  }

  static Future<void> _downloadPdfEntryPoint(Map args) async {
    final SendPort sendPort = args["port"];
    final String url = args["url"];
    final String id = args["id"];
    final bool forceDownload = args["forceDownload"];
    final String offlineMessage = args["offlineMessage"];

    try {
      final sanitizedName = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), "_");
      final Directory dir = await getApplicationDocumentsDirectory();
      final String filePath = p.join(dir.path, "$sanitizedName.pdf");
      final file = File(filePath);

      bool isConnected =
          (await Connectivity().checkConnectivity()) != ConnectivityResult.none;

      if (file.existsSync() && !forceDownload) {
        sendPort.send(filePath);
        return;
      }

      if (!isConnected) {
        if (file.existsSync()) {
          sendPort.send(filePath);
        } else {
          sendPort.send(offlineMessage);
        }
        return;
      }

      final dio = Dio();
      final response = await dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
        ),
      );

      await file.writeAsBytes(response.data);
      sendPort.send(filePath);
    } catch (_) {
      sendPort.send(offlineMessage);
    }
  }
}

