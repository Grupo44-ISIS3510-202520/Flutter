import 'dart:typed_data';
import 'package:http/http.dart' as http;

Future<Uint8List> downloadPdfBytes(Map<String, String> args) async {
  final String? url = args['url'];
  if (url == null) throw Exception('No url provided to downloader isolate');

  final Uri uri = Uri.parse(url);
  final http.Response resp = await http.get(uri);

  if (resp.statusCode != 200) {
    throw Exception('HTTP ${resp.statusCode} when downloading PDF');
  }

  return resp.bodyBytes;
}
