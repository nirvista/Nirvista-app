class RazorpayBridge {
  static bool get isSupported => false;

  static void openCheckout({
    required Map<String, dynamic> options,
    required void Function(Map<String, dynamic>) onSuccess,
    void Function()? onDismiss,
    void Function(Map<String, dynamic>)? onError,
  }) {
    // Web-only implementation.
  }
}
