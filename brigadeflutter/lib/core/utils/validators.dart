// validaciones simples para formularios
import 'constants.dart';

final RegExp _emojiRegex = RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}]',
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

// campos personales
String? validateName(String? v) {
  if (v == null || v.trim().isEmpty) return 'required';
  if (_emojiRegex.hasMatch(v)) return 'no emojis';
  if (v.trim().length > 15) return 'max 15 chars';
  return null;
}

String? validateLastName(String? v) => validateName(v);

String? validateUniandesCode(String? v) {
  if (v == null || v.trim().isEmpty) return 'required';
  return RegExp(r'^\d{6,12}$').hasMatch(v) ? null : 'invalid code';
}



// listas controladas
String? validateBloodGroup(String? v) =>
    (v != null && kBloodGroups.contains(v)) ? null : 'invalid blood group';

String? validateRole(String? v) =>
    (v != null && kRoles.contains(v)) ? null : 'invalid role';

// email dominio + límite 20 + sin emojis
String? validateEmailDomain(String? v, {String domain = kAllowedEmailDomain}) {
  if (v == null || v.trim().isEmpty) return 'required';
  final String e = v.trim();
  if (_emojiRegex.hasMatch(e)) return 'no emojis';
  if (e.length > 30) return 'max 30 chars';
  final bool ok = RegExp('^[^@\\s]+@${RegExp.escape(domain)}\$',
      caseSensitive: false).hasMatch(e);
  return ok ? null : 'use your @$domain email';
}

// password límite 20 + sin emojis
String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'required';
  if (_emojiRegex.hasMatch(v)) return 'no emojis';
  if (v.length < 6) return 'min 6 chars';
  if (v.length > 20) return 'max 20 chars';
  return null;
}

String? validatePasswordConfirm(String? v, String original) {
  if (v == null || v.isEmpty) return 'required';
  if (v != original) return 'passwords do not match';
  return null;
}
