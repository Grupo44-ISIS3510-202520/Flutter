import 'package:flutter/material.dart';

/// Paleta base de la Brigada Estudiantil
abstract final class AppColors {
  // Base
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF162021); // Neutral muy oscuro
  static const blue = Color(0xFF2762EA);  // Primario
  static const red = Color(0xFFE24842);   // Acción de alerta

  // Superficies pastel de Figma
  static const roseSurface = Color(0xFFFFE2E1);
  static const sandSurface = Color(0xFFFFECD5);
  static const blueSurface = Color(0xFFDBE9FE);
  static const pinkSurface = Color(0xFFFCE5F3);

  // Transparencias útiles
  static const white30 = Color(0x4DFFFFFF);
  static const black30 = Color(0x4D000000);

  // Sombras neutrales en claro
  static const grey100 = Color(0xFFF6F6F6);
  static const grey900 = Color(0xFF101010);

  // ColorScheme para claro basado en la paleta
  static const lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: blue,
    onPrimary: white,
    secondary: red,
    onSecondary: white,
    surface: white,            // tarjetas por defecto
    onSurface: black,
    background: grey100,       // fondo de pantallas
    onBackground: black,
    error: red,
    onError: white,
    surfaceVariant: blueSurface, // listas, chips suaves
    onSurfaceVariant: black,
    outline: Color(0xFFCBD5E1),  // bordes sutiles
    outlineVariant: Color(0xFFE2E8F0),
    tertiary: black,             // iconografía neutra
    onTertiary: white,
    shadow: black30,
    scrim: black30,
    inverseSurface: black,
    onInverseSurface: white,
    inversePrimary: Color(0xFF9DB7FF),
  );

  // ColorScheme para oscuro con buen contraste y manteniendo identidad
  static const darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9DB7FF), // tono elevando el azul en oscuro
    onPrimary: black,
    secondary: Color(0xFFFF938F), // rojo levantado para contraste
    onSecondary: black,
    surface: black,             // superficies elevadas
    onSurface: white,
    background: Color(0xFF0F1518),
    onBackground: white,
    error: Color(0xFFFF6B66),
    onError: black,
    surfaceVariant: Color(0xFF1F2A33), // equivalente del pastel en dark
    onSurfaceVariant: white,
    outline: Color(0xFF3A454E),
    outlineVariant: Color(0xFF2A343C),
    tertiary: white,
    onTertiary: black,
    shadow: black30,
    scrim: black30,
    inverseSurface: white,
    onInverseSurface: black,
    inversePrimary: blue,
  );
}

/// Tokens semánticos adicionales que no existen en ColorScheme
/// Se resuelven por tema para awareness de contexto.
@immutable
class BrigadeExtras extends ThemeExtension<BrigadeExtras> {
  final Color successPastel;   // podrías mapearlo a sandSurface
  final Color infoPastel;      // azul pastel
  final Color warningPastel;   // arena pastel
  final Color dangerPastel;    // rosa pastel

  const BrigadeExtras({
    required this.successPastel,
    required this.infoPastel,
    required this.warningPastel,
    required this.dangerPastel,
  });

  static const light = BrigadeExtras(
    successPastel: Color(0xFFE7F5E8), // verde suave sintético
    infoPastel: AppColors.blueSurface,
    warningPastel: AppColors.sandSurface,
    dangerPastel: AppColors.roseSurface,
  );

  static const dark = BrigadeExtras(
    successPastel: Color(0xFF1E2A21),
    infoPastel: Color(0xFF1B2534),
    warningPastel: Color(0xFF2B2620),
    dangerPastel: Color(0xFF2D1F20),
  );

  @override
  BrigadeExtras copyWith({
    Color? successPastel,
    Color? infoPastel,
    Color? warningPastel,
    Color? dangerPastel,
  }) {
    return BrigadeExtras(
      successPastel: successPastel ?? this.successPastel,
      infoPastel: infoPastel ?? this.infoPastel,
      warningPastel: warningPastel ?? this.warningPastel,
      dangerPastel: dangerPastel ?? this.dangerPastel,
    );
  }

  @override
  BrigadeExtras lerp(ThemeExtension<BrigadeExtras>? other, double t) {
    if (other is! BrigadeExtras) return this;
    Color lerpColor(Color a, Color b) => Color.lerp(a, b, t)!;
    return BrigadeExtras(
      successPastel: lerpColor(successPastel, other.successPastel),
      infoPastel: lerpColor(infoPastel, other.infoPastel),
      warningPastel: lerpColor(warningPastel, other.warningPastel),
      dangerPastel: lerpColor(dangerPastel, other.dangerPastel),
    );
  }
}

/// Helpers de awareness para no repetir lógica en cada widget
extension ThemeCtx on BuildContext {
  ColorScheme get colors => Theme.of(this).colorScheme;
  BrigadeExtras get extras =>
      Theme.of(this).extension<BrigadeExtras>() ?? BrigadeExtras.light;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
