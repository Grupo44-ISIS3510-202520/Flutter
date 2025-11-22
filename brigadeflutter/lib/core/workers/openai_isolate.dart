import 'dart:isolate';
import 'package:hive/hive.dart';

import '../../data/services_external/openai_service.dart';

class OpenAIIsolateMessage {
  OpenAIIsolateMessage(
    this.sendPort,
    this.emergencyType,
    this.apiKey,
    this.appDocPath,
  );
  final SendPort sendPort;
  final String emergencyType;
  final String apiKey;
  final String appDocPath;
}

Future<void> openAIIsolateEntry(OpenAIIsolateMessage message) async {
  try {
    Hive.init(message.appDocPath);
  } on HiveError {
    // Already initialized or other Hive-specific issue — ignore silently.
  } on Exception catch (e) {
    // Forward initialization failures to the caller isolate and stop.
    message.sendPort.send('InitError: $e');
    return;
  }

  try {
    final OpenAIServiceImpl service = OpenAIServiceImpl.withKey(message.apiKey);
    final String result = await service.getInstructionText(
      emergencyType: message.emergencyType,
    );
    message.sendPort.send(result);
  } catch (e) {
    message.sendPort.send('Error: $e');
  }
}
