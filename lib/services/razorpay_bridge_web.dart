// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js' as js;
// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:js_util' as js_util;

class RazorpayBridge {
  static bool get isSupported {
    return js_util.hasProperty(js.context, 'Razorpay');
  }

  static void openCheckout({
    required Map<String, dynamic> options,
    required void Function(Map<String, dynamic>) onSuccess,
    void Function()? onDismiss,
    void Function(Map<String, dynamic>)? onError,
  }) {
    final jsOptions = js_util.newObject();

    options.forEach((key, value) {
      js_util.setProperty(jsOptions, key, value);
    });

    js_util.setProperty(
      jsOptions,
      'handler',
      js.allowInterop((response) {
        final data = <String, dynamic>{};
        if (response != null) {
          final paymentId =
              js_util.getProperty(response, 'razorpay_payment_id');
          final orderId = js_util.getProperty(response, 'razorpay_order_id');
          final signature = js_util.getProperty(response, 'razorpay_signature');
          if (paymentId != null) {
            data['razorpay_payment_id'] = paymentId.toString();
          }
          if (orderId != null) {
            data['razorpay_order_id'] = orderId.toString();
          }
          if (signature != null) {
            data['razorpay_signature'] = signature.toString();
          }
        }
        onSuccess(data);
      }),
    );

    if (onDismiss != null) {
      final modal = js_util.newObject();
      js_util.setProperty(
        modal,
        'ondismiss',
        js.allowInterop(() {
          onDismiss();
        }),
      );
      js_util.setProperty(jsOptions, 'modal', modal);
    }

    final razorpayConstructor = js_util.getProperty(js.context, 'Razorpay');
    if (razorpayConstructor == null) {
      if (onError != null) {
        onError({'message': 'Razorpay SDK not available on the page.'});
      }
      return;
    }

    final instance =
        js_util.callConstructor(razorpayConstructor, [jsOptions]);

    if (onError != null) {
      js_util.callMethod(instance, 'on', [
        'payment.failed',
        js.allowInterop((response) {
          final errorData = <String, dynamic>{};
          final error = response != null
              ? js_util.getProperty(response, 'error')
              : null;
          if (error != null) {
            errorData['code'] = js_util.getProperty(error, 'code')?.toString();
            errorData['description'] =
                js_util.getProperty(error, 'description')?.toString();
            errorData['reason'] =
                js_util.getProperty(error, 'reason')?.toString();
          }
          onError(errorData);
        }),
      ]);
    }

    js_util.callMethod(instance, 'open', []);
  }
}
