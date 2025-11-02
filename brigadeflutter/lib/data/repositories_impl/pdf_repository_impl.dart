import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../core/workers/pdf_isolate_worker.dart';
import '../repositories/pdf_repository.dart';

class PdfRepositoryImpl implements PdfRepository {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<File?> getPdfFile({
    required String id,
    required String url,
    bool forceDownload = false,
  }) async {
    try {
      //print('Getting PDF file - ID: $id, URL: $url, forceDownload: $forceDownload');

      final connectivityResult = await _connectivity.checkConnectivity();
      final bool isOnline = connectivityResult != ConnectivityResult.none;

      //print('Connectivity: $connectivityResult, IsOnline: $isOnline');

      if (!isOnline && !forceDownload) {
        final cachedPath = await PdfIsolateWorker.getCachedPath(id);
        final cachedFile = File(cachedPath);
        final cacheExists = await cachedFile.exists();
        //print('Offline mode - Cache exists: $cacheExists at $cachedPath');

        if (cacheExists) {
          return cachedFile;
        }
        return null; 
      }

      final pathOrMessage = await PdfIsolateWorker.downloadPdf(
        url: url,
        id: id,
        forceDownload: forceDownload,
        offlineMessage: "OFFLINE",
      );

      //print('Isolate result: $pathOrMessage');

      if (pathOrMessage == "OFFLINE") {
        final cachedPath = await PdfIsolateWorker.getCachedPath(id);
        final cachedFile = File(cachedPath);
        final cacheExists = await cachedFile.exists();
        //print('Offline message received - Cache exists: $cacheExists');

        return cacheExists ? cachedFile : null;
      }

      final file = File(pathOrMessage);
      final fileExists = await file.exists();
      //print('File exists at path: $fileExists - $pathOrMessage');

      return fileExists ? file : null;
    } catch (e) {
      //print('Error in PdfRepositoryImpl.getPdfFile: $e');
      try {
        final cachedPath = await PdfIsolateWorker.getCachedPath(id);
        final cachedFile = File(cachedPath);
        final cacheExists = await cachedFile.exists();
        //print('Error fallback - Cache exists: $cacheExists');

        return cacheExists ? cachedFile : null;
      } catch (cacheError) {
        //print('Cache fallback error: $cacheError');
        return null;
      }
    }
  }

  @override
  Future<void> removePdfFromCache(String id) async {
    try {
      final path = await PdfIsolateWorker.getCachedPath(id);
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
        //print('Removed PDF from cache: $id');
      } else {
        print('PDF not found in cache: $id');
      }
    } catch (e) {
      print('Error removing PDF from cache: $e');
      rethrow;
    }
  }
}