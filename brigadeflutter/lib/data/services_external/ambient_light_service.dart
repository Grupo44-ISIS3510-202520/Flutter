import 'dart:async';
import 'package:light/light.dart';

// servicio abstracto
abstract class AmbientLightService {
  Future<double> getCurrentAmbientLight();
  Stream<double> ambientLuxStream();
  bool isSupported();
}

// implementación concreta usando paquete 'light'
class AmbientLightServiceImpl implements AmbientLightService {
  final Light _light = Light();
  StreamController<double>? _controller;

  @override
  Future<double> getCurrentAmbientLight() async {
    try {
      final int lux = await _light.lightSensorStream.first;
      return lux.toDouble();
    } catch (_) {
      return 100.0; // fallback
    }
  }

  @override
  Stream<double> ambientLuxStream() {
    _controller ??= StreamController<double>.broadcast();

    _light.lightSensorStream.listen(
      (int lux) => _controller?.add(lux.toDouble()),
      onError: (_) => _controller?.add(100.0),
    );

    return _controller!.stream;
  }

  @override
  bool isSupported() {
    // el paquete 'light' no provee soporte explícito → asumimos true
    return true;
  }
}
