import 'dart:async';
import 'package:brigadeflutter/data/services_external/ambient_light_service.dart';
import 'package:brigadeflutter/data/services_external/screen_brightness_service.dart';

// caso de uso: ajuste dinámico del brillo según luz ambiental
class AdjustBrightnessFromAmbient {
  AdjustBrightnessFromAmbient(
    this.ambientLightService,
    this.screenBrightnessService,
  );
  final AmbientLightService ambientLightService;
  final ScreenBrightnessService screenBrightnessService;

  // inicio del monitoreo continuo
  StreamSubscription<double> start() {
    return ambientLightService.ambientLuxStream().listen((lux) async {
      final brightness = _mapLuxToBrightness(lux);
      await screenBrightnessService.setBrightness(brightness);
    });
  }

  double _mapLuxToBrightness(double lux) {
    if (lux <= 50) return 0.3;
    if (lux <= 200) return 0.6;
    return 1.0;
  }
}
