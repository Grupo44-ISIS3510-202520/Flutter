// controla brillo de pantalla
import 'package:screen_brightness/screen_brightness.dart';

abstract class ScreenBrightnessService {
  Future<void> setBrightness(double value); // 0.0..1.0
  Future<double> getBrightness();
}

class ScreenBrightnessServiceImpl implements ScreenBrightnessService {
  final _sb = ScreenBrightness();

  @override
  Future<void> setBrightness(double value) async {
    final v = value.clamp(0.0, 1.0);
    await _sb.setScreenBrightness(v);
  }

  @override
  Future<double> getBrightness() => _sb.current;
}
  