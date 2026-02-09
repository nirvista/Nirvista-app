const String _referralBaseUrl = 'https://register.nirvista.io';

String? formatReferralShareValue(String? raw) {
  final trimmed = raw?.trim();
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  final protocolRegex = RegExp(r'https?://', caseSensitive: false);
  if (protocolRegex.hasMatch(trimmed)) {
    return trimmed;
  }
  final sanitized = trimmed.replaceAll(RegExp(r'^/+'), '');
  return '$_referralBaseUrl/$sanitized';
}
