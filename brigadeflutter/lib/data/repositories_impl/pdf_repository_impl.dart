import 'dart:io';
import '../../core/workers/pdf_isolate_worker.dart';
import '../repositories/pdf_repository.dart';
import 'package:path_provider/path_provider.dart';


class PdfRepositoryImpl implements PdfRepository {
  @override
  Future<File?> getPdfFile({
    required String id,
    required String url,
    bool forceDownload = false,
  }) async {
    final pathOrMessage = await PdfIsolateWorker.downloadPdf(
      url: url,
      id: id,
      forceDownload: forceDownload,
      offlineMessage: "OFFLINE",
    );

    if (pathOrMessage == "OFFLINE") return null;

    final file = File(pathOrMessage);
    return await file.exists() ? file : null;
  }

  @override
  Future<void> removePdfFromCache(String id) async {
    final sanitizedName = id.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), "_");
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$sanitizedName.pdf");
    if (file.existsSync()) await file.delete();
  }
}
