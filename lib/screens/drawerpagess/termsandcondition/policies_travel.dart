import '../../profile/policy_page.dart';
import 'package:flutter/material.dart';

const String _travelPolicies = """
# Travel-Specific Policies
How travel bookings, vouchers, and trip changes work on our deals and rewards platform.

## 9. Booking Policy
- Provide accurate traveler names, IDs, and contact info. Bookings are confirmed when payment is accepted and you receive a confirmation/ticket/PNR.
- Vendor terms (airlines, hotels, attractions, transport) apply to fulfillment and may override platform rules for changes/penalties.

## 10. Modification & Rescheduling Policy
- Changes depend on fare/rate rules and availability. Fees may include vendor change fees plus any fare/rate difference; platform service fees may apply.
- Request changes through the app; options depend on timing and vendor policies.

## 11. No-Show Policy
- A no-show typically forfeits the fare/rate and may void returns or rewards. Some vendors allow taxes-only refunds; rules vary.
- For stays, late arrival must follow hotel policy or the room may be released.

## 12. Check-in & Check-out Policy
- Follow airline check-in deadlines (web/app/airport); missing them can void travel rights.
- Hotels: standard check-in/out times apply; ID and deposit may be required. Early check-in/late check-out is subject to availability/fees.

## 13. Travel Insurance Disclaimer
- Insurance is optional unless required by destination. If offered, coverage is provided by the insurer (not us); policy terms apply.
- Declining insurance means you accept risks for medical events, delays, baggage, or cancellations.

## 14. Visa & Documentation Responsibility Policy
- You are responsible for valid passports, visas/transit permissions, health/vaccination proofs, and any permits.
- Guidance we share is informational only; entry decisions are made by authorities and vendors.

## 15. Force Majeure Policy
- Events like weather, strikes, disasters, pandemics, or government actions may disrupt travel.
- We assist with rebooking or credits where vendors allow. Refunds/alternatives follow vendor rules and applicable law.

## 16. Airline / Hotel / Vendor Responsibility Disclaimer
- We act as an intermediary. Carriers, hotels, and other vendors are responsible for transport, stay quality, schedules, baggage rules, and on-the-ground services per their terms.

## 17. Third-Party Service Disclaimer
- Some features (maps, payments, chat, ID verification, transport APIs) are provided by third parties with their own terms/privacy notices.
- We do not control their uptime or content; some issues may require their support.
""";

class TravelPoliciesScreen extends StatelessWidget {
  const TravelPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PolicyPage(markdown: _travelPolicies);
  }
}
