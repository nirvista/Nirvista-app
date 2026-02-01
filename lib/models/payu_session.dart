import 'dart:collection';

/// Represents the PayU session payload returned by the backend.
class PayUSession {
  final String endpoint;
  final Map<String, String> payload;
  final String? successUrl;
  final String? failureUrl;
  final bool mock;

  PayUSession({
    required this.endpoint,
    required Map<String, String> payload,
    this.successUrl,
    this.failureUrl,
    required this.mock,
  }) : payload = UnmodifiableMapView(payload);

  /// Builds a [PayUSession] from the raw backend response.
  factory PayUSession.fromMap(Map<String, dynamic> map) {
    final endpoint = map['endpoint']?.toString();
    if (endpoint == null || endpoint.isEmpty) {
      throw FormatException('PayU session is missing an endpoint.');
    }

    final formFields = <String, String>{};

    void addField(String key, dynamic value) {
      if (value == null) return;
      final text = value.toString();
      if (text.isEmpty) return;
      formFields[key] = text;
    }

    final rawPayload = map['payload'];
    if (rawPayload is Map) {
      rawPayload.forEach((key, value) {
        if (key != null) {
          addField(key.toString(), value);
        }
      });
    }

    addField('hash', map['hash']);
    final successUrl = map['surl']?.toString();
    final failureUrl = map['furl']?.toString();
    addField('surl', successUrl);
    addField('furl', failureUrl);

    final dynamic mockValue = map['mock'];
    final bool mock = mockValue is bool
        ? mockValue
        : mockValue?.toString().toLowerCase() == 'true';

    return PayUSession(
      endpoint: endpoint,
      payload: formFields,
      successUrl: successUrl,
      failureUrl: failureUrl,
      mock: mock,
    );
  }
}
