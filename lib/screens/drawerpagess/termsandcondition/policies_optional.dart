import '../../profile/policy_page.dart';
import 'package:flutter/material.dart';

const String _optionalPolicies = """
# Optional but Enterprise-Grade
Advanced policies for partners and enterprise use of our travel deals and rewards platform.

## 30. Affiliate / Partner Program Policy
- Partners must register, follow traffic-quality rules, avoid misleading claims, and comply with ad standards. Payouts are validated and may be reversed for fraud or cancellations.

## 31. Corporate Travel Policy
- Business accounts can have roles, approval flows, negotiated rates, and reporting. Billing may use cards, wallets, or invoicing where offered; misuse can lead to suspension.

## 32. Promotional Offers & Coupons Policy
- Offer terms specify eligibility, staking rules, excluded fees/taxes, redemption limits, expiry, and geography. Misuse or fraud may void offers and related bookings.

## 33. Loyalty / Rewards Policy
- Earn/redeem on eligible products; some fares/rates may be excluded. Rewards can expire, are usually non-transferable, and may be clawed back on refunds or fraud. Tiers/benefits may change with notice.

## 34. Emergency Assistance Disclaimer
- We provide best-effort disruption guidance (rebooking options, contacts) but are not a rescue or insurance service. Availability depends on hours, capacity, and vendor rules.

## 35. Sustainability & Responsible Travel Policy
- We encourage lower-impact options, may surface carbon/eco indicators, and expect respectful behavior toward communities and environments. We may favor partners with sustainable practices.
""";

class OptionalPoliciesScreen extends StatelessWidget {
  const OptionalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyPage(markdown: _optionalPolicies);
  }
}
