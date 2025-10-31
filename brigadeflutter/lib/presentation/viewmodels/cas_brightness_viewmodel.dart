import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/use_cases/adjust_brightness_from_ambient.dart';
import '../../data/services_external/screen_brightness_service.dart';
import '../../data/services_external/ambient_light_service.dart';

class CasBrightnessViewModel extends ChangeNotifier {
  final AdjustBrightnessFromAmbient adjustUC;
  final ScreenBrightnessService screen;
  final AmbientLightService ambient;

  CasBrightnessViewModel({
    required this.adjustUC,
    required this.screen,
    required this.ambient,
  });

  bool supported = false;
  bool autoOn = false;
  double currentBrightness = 0.0;
  double? lastLux;
  StreamSubscription<double>? _subLux;

  Future<void> init() async {
    supported = ambient.isSupported();
    currentBrightness = await screen.getBrightness();
    notifyListeners(); // update state
  }

  void toggleAuto(bool value) {
    autoOn = value;
    _subLux?.cancel();
    if (autoOn) {
      _subLux = adjustUC.start();
    }
    notifyListeners(); // update state
  }

  @override
  void dispose() {
    _subLux?.cancel();
    super.dispose();
  }
}
