import '../../profile/policy_page.dart';
import 'package:flutter/material.dart';

const String _corePolicies = """
# Core Mandatory Policies
These are the must-have policies for our travel deals and rewards platform.

## 1. Privacy Policy
- We collect account/contact info, booking and voucher details, payment tokens (not full card data), device info, and usage patterns to operate the app, personalize offers, and prevent fraud.
- Data is shared only with trusted processors (payments, KYC/identity when required, analytics, customer support) and travel vendors to fulfill bookings/vouchers under confidentiality and security terms.
- We secure data with encryption in transit/at rest, role-based access, and fraud monitoring. You can access, correct, delete (where allowed), or download your data; some data is retained for legal/fraud obligations.
- Cookies/tracking are described in the Cookies Policy. Contact support for privacy questions or complaints.

## 2. Terms of Service
- The app helps you discover travel deals, buy vouchers/tickets, and earn or redeem rewards. Availability and pricing depend on vendors and location.
- You must provide accurate info and keep credentials/PIN/OTP secure. We may update features and terms; material changes are notified in-app/email. Continued use means acceptance.
- Disputes follow Governing Law & Jurisdiction; local consumer protections may still apply.

## 3. Terms & Conditions
- Prices show base fare plus taxes/fees; dynamic pricing can change until payment completes. Currency/FX is shown at checkout.
- Rewards: earning/redemption rules, validity, blackout dates, and non-transferability apply; misuse may void rewards.
- Vendor-specific terms (airlines/hotels/attractions/transport) apply alongside these terms.

## 4. Refund & Cancellation Policy
- Refundability is defined by the vendor and shown before you pay. Promo or restricted fares are often non-refundable.
- Where allowed, refunds go to the original method; timing depends on banks and vendors. Change/cancel fees (vendor + service) and fare differences may apply.
- Bundled deals may allow partial refunds only if components permit. Force majeure follows the Force Majeure Policy and vendor rules; credits may be used when refunds aren’t available.

## 5. Shipping / Delivery Policy
- Tickets, vouchers, and confirmations are delivered digitally (email and in-app wallet) usually within minutes after successful payment.
- If delivery fails (spam filters, wrong email, offline app), request a resend via support. We do not ship physical documents.

## 6. Pricing & Payment Policy
- Prices include base amount, taxes, and service/convenience fees. Dynamic pricing may vary with demand/availability until checkout completes.
- Supported payments: cards, wallets, bank transfers, and local methods where available. We may authorize before charging.
- Payment failures can void reservations. Chargebacks or suspected fraud may trigger holds, cancellations, or account review.

## 7. User Account & Registration Policy
- One account per user; keep login, PIN, and OTP private. Phone/email verification is required; KYC may be required if you use wallet/credits.
- We may suspend/close accounts for misuse, fraud, or legal risk. You can request closure; some data may be retained for legal/fraud reasons.

## 8. Cookies Policy
- Essential cookies run the app securely; analytics cookies improve performance; marketing cookies deliver relevant offers where permitted.
- Third-party providers (payments, analytics, chat, maps) may set their own cookies subject to their notices.
- You can manage cookies in your browser/device; disabling some cookies may reduce functionality.
""";

class CorePoliciesScreen extends StatelessWidget {
  const CorePoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyPage(markdown: _corePolicies);
  }
}
