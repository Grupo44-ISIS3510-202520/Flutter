import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// whitelist básica: letras, números, espacios y puntuación segura
final RegExp kSafeChars = RegExp(
  r"[A-Za-zÁÉÍÓÚÜÑáéíóúüñ0-9 \-_/.,:;()'#&@!?]+",
);

/// bloquea secuencias típicas de inyección
final List<RegExp> kBlockedSequences = [
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
    var txt = newValue.text;

    // remove blocked sequences
    for (final r in kBlockedSequences) {
      txt = txt.replaceAll(r, '');
    }

    // keep only safe chars
    final buf = StringBuffer();
    for (final rune in txt.runes) {
      final ch = String.fromCharCode(rune);
      if (kSafeChars.hasMatch(ch)) buf.write(ch);
    }

    var safe = buf.toString();

    // enforce max length
    if (safe.length > max) safe = safe.substring(0, max);

    return TextEditingValue(
      text: safe,
      selection: TextSelection.collapsed(offset: safe.length),
      composing: TextRange.empty,
    );
  }
}

/// helper: oculta el contador nativo
const kNoCounter = SizedBox.shrink();

class NoEmojiAndLengthFormatter extends TextInputFormatter {
  NoEmojiAndLengthFormatter(this.max);
  final int max;

  static final _emoji = RegExp(r'[\u{1F300}-\u{1FAFF}]', unicode: true);
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldV,
    TextEditingValue newV,
  ) {
    var t = newV.text.replaceAll(_emoji, '');
    if (t.length > max) t = t.substring(0, max);
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}
