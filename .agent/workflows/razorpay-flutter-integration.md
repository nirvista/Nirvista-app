---
description: Razorpay Payment Integration Guide for Flutter
---

# Razorpay Payment Integration Guide for Flutter

This guide provides step-by-step instructions to integrate Razorpay payment gateway into your Flutter app for adding money to the wallet, positioned right after the PhonePe option.

## Prerequisites

### 1. Add Razorpay Flutter SDK Dependency

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  razorpay_flutter: ^1.3.6
```

Run:
```bash
flutter pub get
```

### 2. Android Configuration

Add the following to `android/app/src/main/AndroidManifest.xml` inside the `<application>` tag:

```xml
<activity
    android:name="com.razorpay.CheckoutActivity"
    android:exported="true"
    android:theme="@style/Theme.AppCompat.NoActionBar">
</activity>
```

### 3. iOS Configuration

Add the following to `ios/Podfile`:

```ruby
pod 'razorpay-pod', '~> 1.3.9'
```

Run:
```bash
cd ios && pod install && cd ..
```

---

## Implementation Steps

### Step 1: Import Razorpay Package

In your wallet/add money screen file:

```dart
import 'package:razorpay_flutter/razorpay_flutter.dart';
```

### Step 2: Initialize Razorpay in Your Widget

```dart
class AddMoneyScreen extends StatefulWidget {
  @override
  _AddMoneyScreenState createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  late Razorpay _razorpay;
  String? _transactionId; // Store transaction ID from step 2

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    _razorpay.clear();
  }

  // ... rest of your widget
}
```

### Step 3: Create Order API Call

When user taps "Add Money" with Razorpay option:

```dart
Future<void> _initiateRazorpayPayment(double amount) async {
  try {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Step 1: Call your backend to create Razorpay order
    final response = await http.post(
      Uri.parse('YOUR_BASE_URL/api/payments/razorpay/order'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_AUTH_TOKEN', // Add your auth token
      },
      body: jsonEncode({
        'amount': amount, // Amount in rupees
      }),
    );

    // Hide loading indicator
    Navigator.pop(context);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      
      // Step 2: Extract response data
      final String orderId = data['orderId'];
      final String razorpayKey = data['key'];
      final int amountInPaise = data['amountInPaise'];
      _transactionId = data['transactionId']; // Store for verification

      // Step 3: Open Razorpay Checkout
      _openRazorpayCheckout(
        orderId: orderId,
        key: razorpayKey,
        amountInPaise: amountInPaise,
      );
    } else {
      // Handle error
      _showErrorDialog('Failed to create order: ${response.body}');
    }
  } catch (e) {
    Navigator.pop(context); // Hide loading if still showing
    _showErrorDialog('Error: $e');
  }
}
```

### Step 4: Open Razorpay Checkout

```dart
void _openRazorpayCheckout({
  required String orderId,
  required String key,
  required int amountInPaise,
}) {
  var options = {
    'key': key, // Razorpay key from backend
    'order_id': orderId, // Order ID from backend
    'amount': amountInPaise, // Amount in paise (already converted)
    'currency': 'INR',
    'name': 'CoinDash Wallet', // Your app name
    'description': 'Add Money to Wallet',
    'prefill': {
      'contact': 'USER_PHONE_NUMBER', // Optional: prefill user's phone
      'email': 'USER_EMAIL', // Optional: prefill user's email
    },
    'theme': {
      'color': '#4CAF50', // Your app's primary color
    },
    'modal': {
      'ondismiss': () {
        print('Razorpay checkout dismissed');
      }
    }
  };

  try {
    _razorpay.open(options);
  } catch (e) {
    _showErrorDialog('Error opening Razorpay: $e');
  }
}
```

### Step 5: Handle Payment Success Callback

```dart
void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  print('Payment Success: ${response.paymentId}');
  
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    // Step 6: Verify payment with your backend
    final verifyResponse = await http.post(
      Uri.parse('YOUR_BASE_URL/api/payments/razorpay/verify'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer YOUR_AUTH_TOKEN',
      },
      body: jsonEncode({
        'razorpay_payment_id': response.paymentId,
        'razorpay_order_id': response.orderId,
        'razorpay_signature': response.signature,
        'transactionId': _transactionId, // Transaction ID from step 2
      }),
    );

    Navigator.pop(context); // Hide loading

    if (verifyResponse.statusCode == 200) {
      // Payment verified successfully
      _showSuccessDialog('Payment successful!');
      
      // Step 7: Refresh wallet balance
      await _refreshWalletBalance();
    } else {
      _showErrorDialog('Payment verification failed: ${verifyResponse.body}');
    }
  } catch (e) {
    Navigator.pop(context);
    _showErrorDialog('Verification error: $e');
  }
}
```

### Step 6: Handle Payment Error

```dart
void _handlePaymentError(PaymentFailureResponse response) {
  print('Payment Error: ${response.code} - ${response.message}');
  _showErrorDialog('Payment failed: ${response.message}');
}
```

### Step 7: Handle External Wallet

```dart
void _handleExternalWallet(ExternalWalletResponse response) {
  print('External Wallet: ${response.walletName}');
  _showErrorDialog('External wallet selected: ${response.walletName}');
}
```

### Step 8: Refresh Wallet Balance

```dart
Future<void> _refreshWalletBalance() async {
  try {
    final response = await http.get(
      Uri.parse('YOUR_BASE_URL/api/wallet/summary'),
      headers: {
        'Authorization': 'Bearer YOUR_AUTH_TOKEN',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Update your UI with new balance
      setState(() {
        // Update wallet balance in your state management
        // e.g., walletBalance = data['balance'];
      });
    }
  } catch (e) {
    print('Error refreshing wallet: $e');
  }
}
```

### Step 9: Helper Methods for Dialogs

```dart
void _showErrorDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

void _showSuccessDialog(String message) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Success'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            Navigator.pop(context); // Go back to wallet screen
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

---

## UI Integration (Add Money Screen)

### Add Razorpay Option After PhonePe

In your Add Money screen where you have payment method options:

```dart
// ... PhonePe option widget ...

// Razorpay option
GestureDetector(
  onTap: () {
    // Get amount from your TextField/input
    double amount = double.parse(_amountController.text);
    _initiateRazorpayPayment(amount);
  },
  child: Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Image.asset(
          'assets/razorpay_logo.png', // Add Razorpay logo to assets
          height: 40,
          width: 40,
        ),
        SizedBox(width: 16),
        Text(
          'Razorpay',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Spacer(),
        Icon(Icons.arrow_forward_ios, size: 16),
      ],
    ),
  ),
),
```

---

## Complete Flow Summary

1. **User taps "Add Money"** → Selects Razorpay option
2. **Call** `POST /api/payments/razorpay/order` with amount in rupees
3. **Receive** `{ orderId, key, amountInPaise, transactionId }`
4. **Open Razorpay Checkout** with:
   - `key`: from response
   - `order_id`: from response
   - `amount`: amountInPaise (already in paise)
   - `currency`: "INR"
   - Optional: prefill contact/email
5. **On success callback**, call `POST /api/payments/razorpay/verify` with:
   - `razorpay_payment_id`
   - `razorpay_order_id`
   - `razorpay_signature`
   - `transactionId` (from step 3)
6. **On verification success**, call `GET /api/wallet/summary` to refresh balance
7. **Update UI** with new wallet balance

---

## Testing Checklist

- [ ] Razorpay SDK dependency added and installed
- [ ] Android manifest updated with CheckoutActivity
- [ ] iOS Podfile updated (if targeting iOS)
- [ ] Razorpay instance initialized in initState
- [ ] Event listeners registered (success, error, external wallet)
- [ ] Order creation API call working
- [ ] Razorpay checkout opens successfully
- [ ] Payment success callback triggers verification
- [ ] Payment verification API call working
- [ ] Wallet balance refreshes after successful payment
- [ ] Error handling works for failed payments
- [ ] UI shows loading states appropriately
- [ ] Razorpay option appears after PhonePe in UI

---

## Important Notes

1. **Replace Placeholders**:
   - `YOUR_BASE_URL` with your actual backend URL
   - `YOUR_AUTH_TOKEN` with your authentication token (from login/session)
   - `USER_PHONE_NUMBER` and `USER_EMAIL` with actual user data

2. **Security**:
   - Never hardcode Razorpay keys in your Flutter app
   - Always fetch the key from your backend
   - All payment verification must happen on the backend

3. **Error Handling**:
   - Handle network errors gracefully
   - Show user-friendly error messages
   - Log errors for debugging

4. **Testing**:
   - Use Razorpay test mode credentials during development
   - Test with different amounts
   - Test payment failures and cancellations
   - Test network interruptions

5. **Production**:
   - Switch to production Razorpay credentials
   - Test thoroughly before going live
   - Monitor payment success rates

---

## API Endpoints Reference

### Create Order
```
POST /api/payments/razorpay/order
Headers: { Authorization: Bearer TOKEN }
Body: { amount: 500 }  // Amount in rupees
Response: { orderId, key, amountInPaise, transactionId }
```

### Verify Payment
```
POST /api/payments/razorpay/verify
Headers: { Authorization: Bearer TOKEN }
Body: {
  razorpay_payment_id: "pay_xxx",
  razorpay_order_id: "order_xxx",
  razorpay_signature: "signature_xxx",
  transactionId: "txn_xxx"
}
Response: { success: true, message: "Payment verified" }
```

### Get Wallet Summary
```
GET /api/wallet/summary
Headers: { Authorization: Bearer TOKEN }
Response: { balance: 1500, ... }
```

---

## Troubleshooting

### Payment not opening
- Check if Razorpay SDK is properly initialized
- Verify Android manifest has CheckoutActivity
- Check if amount is in correct format (integer paise)

### Payment success but verification fails
- Ensure transactionId is correctly stored and sent
- Check backend logs for verification errors
- Verify signature validation on backend

### Wallet balance not updating
- Check if GET /api/wallet/summary is being called
- Verify authentication token is valid
- Check if setState is called to update UI

---

**End of Integration Guide**
