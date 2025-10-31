// // mapea lux→brillo y aplica
// import 'dart:async';

// import '../../data/services_external/ambient_light_service.dart';
// import '../../data/services_external/screen_brightness_service.dart';

// class AdjustBrightnessFromAmbient {
//   final AmbientLightService ambient;
//   final ScreenBrightnessService screen;

//   AdjustBrightnessFromAmbient(this.ambient, this.screen);

//   // inicia la auto-regla. retorna subscription para cancelar.
//   StreamSubscription<double>? start({
//     double minLux = 5,    // muy oscuro
//     double maxLux = 800,  // muy iluminado
//     double minBrightness = 0.15,
//     double maxBrightness = 1.0,
//   }) {
//     final luxStream = ambient.ambientLux();
//     if (luxStream == null) return null;

//     return luxStream.listen((lux) async {
//       // normaliza lux al rango [minBrightness..maxBrightness]
//       final t = ((lux - minLux) / (maxLux - minLux)).clamp(0.0, 1.0);
//       final target = minBrightness + (maxBrightness - minBrightness) * t;
//       // aplica brillo suavizado
//       await screen.setBrightness(target);
//     }, onError: (_) {});
//   }
// }
