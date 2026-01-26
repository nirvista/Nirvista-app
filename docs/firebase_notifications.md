# Firebase Notifications & Backend Payloads

## Setup steps

1. Create a Firebase project that matches your app's bundle/application id (`com.nirvista.app` for Android, the corresponding iOS bundle).
2. Download the configuration files and drop them in the platform folders:
   * `android/app/google-services.json`
   * `ios/Runner/GoogleService-Info.plist`
3. Make sure the files are tracked in git (they are platform secrets, so keep them safe or gitignored per your workflow).
4. Enable Firebase Cloud Messaging in the Firebase console and configure APNs credentials/certificates for iOS if you plan on testing on physical devices.

The Flutter app already calls `Firebase.initializeApp()` and registers the background handler, so no additional Dart code changes are required after you add the files above.

## What the app does

- Initializes `FirebaseMessaging` in `main.dart`.
- Requests notification permissions and sets foreground presentation options.
- Uses `NotificationService` (leveraging `flutter_local_notifications`) to post system-level notifications whenever an FCM message arrives in the foreground, background, or when the user taps a notification.
- Logs `FirebaseMessaging.instance.getToken()` in the debug console so you can capture the device token you need for server-to-device messages.

## Backend payload requirements

Use the FCM HTTP v1 API or the legacy API to deliver notifications. The client expects either `notification` fields or `data` keys named `title`/`body`. A minimal payload looks like:

```json
POST https://fcm.googleapis.com/fcm/send
Authorization: key=<SERVER_KEY>
Content-Type: application/json

{
  "to": "<FCM_DEVICE_TOKEN>",
  "priority": "high",
  "notification": {
    "title": "Payment failed",
    "body": "Something went wrong while processing your ICO purchase."
  },
  "data": {
    "payload": "payment_failed",
    "bank_update": "require_kyc"
  }
}
```

`NotificationService` will show the `notification.title`/`notification.body` values. If the notification fields are not present, it falls back to `data.title`/`data.body`.

Include any navigation hints or metadata in the `data` map (`payload`, `route`, etc.) so you can interpret taps inside `FirebaseMessaging.onMessageOpenedApp`.

If you need to send device groups or conditionally target users, refer to the FCM REST documentation; the same payload format applies when you target tokens issued by `FirebaseMessaging.getToken()`.
