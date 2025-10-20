// validaciones simples para formularios
final _emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}]',
    unicode: true);

String? requiredText(String? v, {int max = 500}) {
  if (v == null || v.trim().isEmpty) return 'required';
  if (v.length > max) return 'max $max chars';
  if (_emojiRegex.hasMatch(v)) return 'no emojis';
  return null;
}

String? validateType(String? v) {
  if (v == null || v.trim().isEmpty) return 'required';
  if (v.length > 60) return 'max 60 chars';
  if (_emojiRegex.hasMatch(v)) return 'no emojis';
  return null;
}

String? validatePlaceTime(String? v) {
  if (v == null || v.trim().isEmpty) return 'required';
  if (v.length > 100) return 'max 100 chars';
  if (_emojiRegex.hasMatch(v)) return 'no emojis';
  return null;
}

String? validateDescription(String? v) {
  if (v == null || v.trim().isEmpty) return 'required';
  if (v.length > 500) return 'max 500 chars';
  if (_emojiRegex.hasMatch(v)) return 'no emojis';
  return null;
}

