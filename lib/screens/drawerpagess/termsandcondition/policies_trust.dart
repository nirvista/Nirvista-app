import '../../profile/policy_page.dart';
import 'package:flutter/material.dart';

const String _trustPolicies = """
# User Trust & Platform Governance
How we support users, govern community behavior, and handle data lifecycle for our travel deals and rewards app.

## 25. Customer Support & Grievance Redressal Policy
- Support via in-app chat, email, and phone (where available). First responses target published support hours; complex cases may need more time.
- Escalation paths and regulator contacts (where applicable) are listed in Help Center for unresolved grievances.

## 26. User Conduct & Acceptable Use Policy
- No harassment, impersonation, scraping, spamming, fraudulent bookings/chargebacks, or unauthorized reselling of vouchers.
- Security testing must follow responsible disclosure; disruptive testing is prohibited.

## 27. Reviews & Ratings Policy
- Reviews must be genuine. Incentivized or deceptive reviews are not allowed.
- We may moderate or remove content that is offensive, fraudulent, or violates law/rights.

## 28. Communication & Notification Policy
- We send transactional messages (bookings, check-in reminders, payment status), service alerts, and security notices.
- Marketing messages require consent where required; you can opt out of marketing without affecting transactional messages.

## 29. Data Retention & Deletion Policy
- Account, booking, and payment records are retained for service delivery, legal, tax, and fraud-prevention reasons.
- Upon deletion requests, we remove or anonymize data not subject to mandatory retention; backups/logs purge on normal cycles.
""";

class TrustPoliciesScreen extends StatelessWidget {
  const TrustPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyPage(markdown: _trustPolicies);
  }
}
