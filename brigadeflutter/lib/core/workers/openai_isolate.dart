// import 'dart:isolate';
// import '../../data/services_external/openai_service.dart';

// // message data passed to isolate
// class OpenAIIsolateMessage {
//   final SendPort sendPort;
//   final String emergencyType;
//   OpenAIIsolateMessage(this.sendPort, this.emergencyType);
// }

// // entrypoint function for the isolate
// Future<void> openAIIsolateEntry(OpenAIIsolateMessage message) async {
//   final service = OpenAIServiceImpl();
//   try {
//     final result = await service.getInstructionText(
//       emergencyType: message.emergencyType,
//     );
//     message.sendPort.send(result);
//   } catch (e) {
//     message.sendPort.send('Error: $e');
//   }
// }

import 'dart:isolate';
import '../../data/services_external/openai_service.dart';

// Include the key as argument instead of reading dotenv again
class OpenAIIsolateMessage {
  final SendPort sendPort;
  final String emergencyType;
  final String apiKey;
  OpenAIIsolateMessage(this.sendPort, this.emergencyType, this.apiKey);
}

Future<void> openAIIsolateEntry(OpenAIIsolateMessage message) async {
  try {
    final service = OpenAIServiceImpl.withKey(message.apiKey);
    final result = await service.getInstructionText(
      emergencyType: message.emergencyType,
    );
    message.sendPort.send(result);
  } catch (e) {
    message.sendPort.send('Error: $e');
  }
}
