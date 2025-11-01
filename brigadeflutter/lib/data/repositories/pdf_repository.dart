import 'dart:io';

abstract class PdfRepository {
  Future<File?> getPdfFile({required String id, required String url, bool forceDownload = false});
  Future<void> removePdfFromCache(String id);
}
