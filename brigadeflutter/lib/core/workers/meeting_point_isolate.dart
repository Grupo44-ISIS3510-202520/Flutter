import 'dart:isolate';
import 'dart:math';
import 'dart:async';

class EmergencyIsolateWorker {
  static Future<Map<String, dynamic>> findNearestMeetingPoint({
    required double userLat,
    required double userLng,
    required List<Map<String, dynamic>> meetingPoints,
  }) async {
    final receivePort = ReceivePort();
    final errorPort = ReceivePort();

    try {
      await Isolate.spawn(
        _findNearestMeetingPointEntry,
        {
          'port': receivePort.sendPort,
          'errorPort': errorPort.sendPort,
          'userLat': userLat,
          'userLng': userLng,
          'meetingPoints': meetingPoints,
        },
        onError: errorPort.sendPort,
        onExit: receivePort.sendPort,
      );

      final completer = Completer<Map<String, dynamic>>();

      receivePort.listen((message) {
        if (!completer.isCompleted) {
          completer.complete(message as Map<String, dynamic>);
        }
        receivePort.close();
        errorPort.close();
      });

      errorPort.listen((error) {
        if (!completer.isCompleted) {
          completer.complete({
            'success': false,
            'error': 'Isolate error: $error'
          });
        }
        receivePort.close();
        errorPort.close();
      });

      final result = await completer.future.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          return {
            'success': false,
            'error': 'Timeout calculating nearest point'
          };
        },
      );

      return result;
    } catch (e) {
      return _calculateInMainThread(userLat, userLng, meetingPoints);
    }
  }

  static void _findNearestMeetingPointEntry(Map<String, dynamic> message) {
    final SendPort sendPort = message['port'];
    //final SendPort errorPort = message['errorPort'];
    final double userLat = message['userLat'];
    final double userLng = message['userLng'];
    final List<Map<String, dynamic>> meetingPoints = message['meetingPoints'];

    try {
      Map<String, dynamic>? nearestPoint;
      double nearestDist = double.maxFinite;

      for (final point in meetingPoints) {
        final double pointLat = point['lat'];
        final double pointLng = point['lng'];

        final distance = _distanceMeters(userLat, userLng, pointLat, pointLng);

        if (distance < nearestDist) {
          nearestDist = distance;
          nearestPoint = {
            'id': point['id'],
            'name': point['name'],
            'lat': pointLat,
            'lng': pointLng,
            'distanceMeters': distance,
          };
        }
      }

      if (nearestPoint != null) {
        sendPort.send({
          'success': true,
          'result': nearestPoint,
        });
      } else {
        sendPort.send({
          'success': false,
          'error': 'No meeting points found',
        });
      }
    } catch (e) {
      sendPort.send({
        'success': false,
        'error': 'Calculation error: $e',
      });
    }
  }

  static Map<String, dynamic> _calculateInMainThread(
      double userLat,
      double userLng,
      List<Map<String, dynamic>> meetingPoints
      ) {
    try {
      Map<String, dynamic>? nearestPoint;
      double nearestDist = double.maxFinite;

      for (final point in meetingPoints) {
        final double pointLat = point['lat'];
        final double pointLng = point['lng'];

        final distance = _distanceMeters(userLat, userLng, pointLat, pointLng);

        if (distance < nearestDist) {
          nearestDist = distance;
          nearestPoint = {
            'id': point['id'],
            'name': point['name'],
            'lat': pointLat,
            'lng': pointLng,
            'distanceMeters': distance,
          };
        }
      }

      if (nearestPoint != null) {
        return {
          'success': true,
          'result': nearestPoint,
          'fallback': true,
        };
      } else {
        return {
          'success': false,
          'error': 'No meeting points found',
          'fallback': true,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Fallback calculation failed: $e',
        'fallback': true,
      };
    }
  }

  static double _distanceMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000;
    final phi1 = _toRad(lat1);
    final phi2 = _toRad(lat2);
    final dPhi = _toRad(lat2 - lat1);
    final dLambda = _toRad(lon2 - lon1);

    final a = sin(dPhi / 2) * sin(dPhi / 2) +
        cos(phi1) * cos(phi2) * sin(dLambda / 2) * sin(dLambda / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRad(double deg) => deg * pi / 180.0;
}