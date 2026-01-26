import '../../profile/policy_page.dart';
import 'package:flutter/material.dart';

const String _legalPolicies = """
# Legal, Compliance & Risk Control
Our legal position, compliance measures, and risk controls for travel deals, vouchers, and rewards.

## 18. Limitation of Liability
- Where allowed by law, liability is capped at the amount you paid us for the affected booking/service. We are not liable for indirect or consequential losses unless mandatory law says otherwise.

## 19. Indemnification Policy
- You agree to indemnify us for losses arising from your breach of these policies, misuse of the platform, or violations of law/third-party rights.

## 20. Governing Law & Jurisdiction
- The governing law and dispute forum shown in your account locale apply; local consumer protections may still apply. Disputes may be handled via arbitration or courts as indicated in-app or on receipts.

## 21. Intellectual Property Policy
- App code, brand assets, and content belong to us or licensors. You get a limited, revocable license to use the app for personal travel and rewards.
- User content (e.g., reviews/photos) grants us a license to display and distribute within the service, subject to community rules and takedown for violations.

## 22. Anti-Fraud & Misuse Policy
- We monitor for payment abuse, voucher reselling, artificial reward generation, scraping, or exploit use. We may suspend/cancel bookings or claw back rewards tied to abuse.
- We may require identity verification or documents before releasing tickets, vouchers, or refunds.

## 23. AML / KYC Compliance Statement
- Wallet/credits may require identity verification, transaction monitoring, and limits. Transactions can be delayed or blocked if required by AML/KYC rules. Suspicious activity may be reported to regulators without notice.

## 24. Accessibility Statement
- We aim to support accessible design and improve compatibility with assistive technologies. Contact support for help completing bookings or account actions if you encounter barriers.
""";

class LegalPoliciesScreen extends StatelessWidget {
  const LegalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyPage(markdown: _legalPolicies);
  }
}
