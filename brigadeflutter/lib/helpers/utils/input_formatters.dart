import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// whitelist básica: letras, números, espacios y puntuación segura
final RegExp kSafeChars = RegExp(
  r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9 \-_/.,:;()'#&@!?]+",
);

/// bloquea secuencias típicas de inyección
final List<RegExp> kBlockedSequences = <RegExp>[
  RegExp(r'--'), // comentario sql
  RegExp(r'/\*'), // comentario inicio
  RegExp(r'\*/'), // comentario fin
];

/// formatter que aplica límite y whitelist; elimina secuencias bloqueadas
class SafeTextFormatter extends TextInputFormatter {
  SafeTextFormatter({required this.max});
  final int max;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String txt = newValue.text;

    // remove blocked sequences
    for (int i = 0, n = kBlockedSequences.length; i < n; i++) {
      txt = txt.replaceAll(kBlockedSequences[i], '');
    }

    // keep only safe chars
    final StringBuffer buf = StringBuffer();
    final List<int> runes = txt.runes.toList();
    for (int i = 0, n = runes.length; i < n; i++) {
      final String ch = String.fromCharCode(runes[i]);
      if (kSafeChars.hasMatch(ch)) buf.write(ch);
    }

    String safe = buf.toString();

    // enforce max length
    if (safe.length > max) safe = safe.substring(0, max);

    return TextEditingValue(
      text: safe,
      selection: TextSelection.collapsed(offset: safe.length),
    );
  }
}

/// helper: oculta el contador nativo
const SizedBox kNoCounter = SizedBox.shrink();

class NoEmojiAndLengthFormatter extends TextInputFormatter {
  NoEmojiAndLengthFormatter(this.max);
  final int max;

  static final RegExp _emoji = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    String t = newV.text.replaceAll(_emoji, '');
    if (t.length > max) t = t.substring(0, max);
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}
