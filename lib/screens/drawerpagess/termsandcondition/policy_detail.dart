import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../CommonWidgets/footer_section.dart';
import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/staticdata.dart';
import '../../../ConstData/typography.dart';

class PolicyDetailScreen extends StatelessWidget {
  final String policyTitle;

  const PolicyDetailScreen({super.key, required this.policyTitle});

  static const Map<String, List<String>> policyDetails = {
    'PRIVACY POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This Privacy Policy explains how Nirvista PRE ICO and ICO collects, uses, stores, and protects your personal and financial information when you use our application, website, and services.',
      'By accessing or using our platform, you agree to the terms of this Privacy Policy.',
      'We collect the following types of information:',
      '• Personal Information: Name, email address, mobile number, date of birth',
      '• Account Information: Login credentials, profile data',
      '• Financial Information: Bank account details, transaction history, withdrawal records',
      '• KYC Information: Government-issued ID, address proof, photographs (if required)',
      '• Technical Information: IP address, device details, browser type, operating system, app usage logs',
      '• Payment Information: Transaction details processed via Razorpay, PhonePe, or other integrated gateways',
      'We use your information for:',
      '• Creating and managing your account',
      '• Processing token purchases, staking, and withdrawals',
      '• Identity verification and fraud prevention',
      '• Customer support and communication',
      '• Legal and regulatory compliance',
      '• Improving platform performance and user experience',
      'We do not sell, trade, or rent your personal data to third parties.',
      'Your data may be shared only with:',
      '• Payment gateway partners (Razorpay, PhonePe)',
      '• Legal or regulatory authorities if required by law',
      '• Service providers for hosting, analytics, and security',
      'We implement strict security measures such as encryption, secure servers, restricted access controls, and periodic security audits to protect your data. However, no system is 100% secure, and users acknowledge this risk.',
      'Data Retention: We retain personal and financial data only as long as required for legal, regulatory, and operational purposes.',
      'User Rights: You have the right to:',
      '• Access your personal data',
      '• Request corrections',
      '• Request deletion (subject to legal requirements)',
      '• Withdraw consent where applicable',
      'Contact for Privacy Concerns: support@nirvista.in, support@nirvistagroup.com | Support Number: 97656 53615',
    ],
    'TERMS & CONDITIONS': [
      'App Name: Nirvista PRE ICO and ICO',
      'By using this platform, you agree to comply with and be bound by these Terms and Conditions. If you do not agree, please discontinue usage.',
      'Eligibility: You must be legally capable of entering into contracts under Indian law and comply with applicable regulations.',
      'Account Responsibility: You are responsible for maintaining the confidentiality of your credentials and all actions taken under your account.',
      'Platform Rights: Nirvista PRE ICO and ICO reserves the right to suspend or terminate suspicious accounts, modify or discontinue services, and reject transactions that violate policies.',
      'User Obligations: Do not create fake accounts, manipulate prices/staking, commit illegal financial activities, or exploit security weaknesses.',
      'Token Disclaimer: Tokens are not shares or securities, and returns are not promised.',
      'Limitation of Liability: We are not liable for market volatility, loss of funds due to user error, payment gateway failures, or internet outages.',
      'Governing Law & Jurisdiction: Indian law applies, and disputes fall under the courts of Hyderabad, India.',
      'Need help? support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'REFUND & CANCELLATION POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'Refunds are allowed when payments succeed but tokens fail to credit, duplicate transactions occur, or system errors cause incorrect deductions.',
      'Refunds do not cover credited token purchases, completed staking deposits, processed withdrawals, or voluntary user cancellations.',
      'Users must raise refund requests within 48 hours. Our technical and finance teams verify each case, and approved refunds are processed within 7–10 working days to the original payment source.',
      'Transactions marked successful cannot be cancelled.',
      'Failed payments are automatically reversed; pending payments are verified within 24–48 hours.',
      'Contact support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615 for refunds.',
    ],
    'WITHDRAWAL POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'Withdrawal requests cover wallet balances, referral earnings, staking rewards, or other amounts.',
      'Eligibility: Users must be verified, complete KYC (if required), provide valid bank details, and have sufficient withdrawable balance.',
      'Limits: Minimum/maximum amounts follow in-app rules and regulatory constraints.',
      'Processing Time: Withdrawals finish within 24–72 working hours after approval; delays may arise from holidays, tech issues, or compliance checks.',
      'Status Types: Pending (under review), Approved (processing), Success (credited), Failed (reversed after checks).',
      'Failed withdrawals caused by wrong bank data, bank server issues, or network/gateway failure are reversed after internal verification.',
      'Administrative Rights: We may hold, reject, or request more documents for withdrawals flagged as suspicious.',
      'Support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'PAYMENT POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This governs all payments via integrated gateways (Razorpay, PhonePe, and future additions).',
      'Status definitions: Pending (initiated), Success (completed), Failed (unsuccessful), Cancelled (cancelled by user).',
      'Pending payments are verified within 24–48 hours before being marked Success or Failed.',
      'Failed payments are reversed by gateways as per their terms.',
      'Duplicate payments may be refunded under the Refund Policy.',
      'Invalid chargebacks could trigger temporary suspension, investigations, or permanent restrictions.',
      'We can block payment access for accounts involved in suspicious or illegal behavior.',
      'Reach support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615 for payment issues.',
    ],
    'STAKING POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'Staking lets users lock tokens for rewards over predefined periods.',
      'Conditions: Users must hold sufficient tokens, and each plan defines lock-in and reward rates.',
      'Tokens stay locked during the lock-in window; early withdrawals may incur penalties or rewards loss.',
      'Rewards calc automatically and rates are displayed before confirmation. Delays may occur for system or compliance checks.',
      'Risk disclaimer: Rewards are not guaranteed; market/regulatory shifts may affect payouts.',
      'We can alter staking plans, pause staking during emergencies, or hold rewards under suspicion.',
      'Need help? support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'REFERRAL POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'Earn by referring genuine, unique users once your account is verified.',
      'Rewards credit after referred users complete qualified transactions; the commission structure lives inside the app.',
      'Prohibited activities include fake accounts, self-referrals, automated scripts, or manipulating referrals; violations lead to bans and forfeited rewards.',
      'Referral winnings withdrawal follows the standard withdrawal rules with KYC/bank verification.',
      'We may modify rewards, cancel fraudulent referrals, or suspend violating accounts.',
      'For questions, contact support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'KYC & AML POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'KYC/AML prevents fraud, identity misuse, and illegal financial activity while ensuring compliance with Indian law.',
      'Purpose: Verify identity, ensure lawful transactions, and prevent misuse.',
      'KYC requirements: Government-issued ID, address proof, selfies/photos, and bank documents.',
      'Documents are reviewed manually or automatically. Users may resubmit if uploads are unclear.',
      'Until KYC completes, withdrawals may be restricted, staking limited, referral payouts held, or transaction caps imposed.',
      'AML monitoring checks suspicious transactions, abnormal withdrawals, multiple accounts, and referral abuse. Suspected accounts might be frozen, asked for more verification, or reported.',
      'KYC data is stored securely under the Privacy Policy.',
      'Support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'RISK DISCLOSURE POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This policy describes risks related to tokens, staking, referrals, and financial actions.',
      'Market risk: Token values fluctuate with demand, economics, regulations, and product updates; profits are not promised.',
      'Staking risk: Rewards are not guaranteed, lock-in windows restrict funds, and early exits may incur penalties.',
      'System risk: Downtime, gateway failures, network issues, or software bugs can occur.',
      'Financial risk: Users alone are responsible for decisions, losses, and legal compliance.',
      'Legal/regulatory risk: Legal changes may alter service availability without notice.',
      'We do not provide financial, investment, or legal advice.',
      'By using the platform, users accept these risks.',
      'Risk support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'USER CONDUCT POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'Users must always provide accurate information, secure their accounts, and obey all platform rules.',
      'Prohibited actions:',
      '• Creating multiple/fake accounts',
      '• Using another person’s identity',
      '• Fraudulent transactions or system exploits',
      '• Manipulating tokens, staking, or referrals',
      '• Using bots, scripts, automation, or unauthorized access',
      '• Illegal financial conduct',
      'Violations may lead to suspension/bans, frozen funds, forfeited rewards, and legal pursuit.',
      'We reserve the right to monitor, investigate, and act on suspicious behavior.',
      'Support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'DATA RETENTION & DELETION POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This policy explains data storage duration and deletion requests.',
      'Retention covers personal info, account data, KYC documents, transactions, payments, and referral/staking history.',
      'Data stays only as long as needed for compliance, maintaining records, resolving disputes, and safeguarding security; some records remain post-deletion if law requires.',
      'Users requesting deletion should contact support@nirvista.in or support@nirvistagroup.com. After verification, accounts are deactivated and profile data anonymized/removed while compliance data remains.',
      'Immediate deletion is limited for financial records, legal documents, or ongoing investigations.',
      'Support: Phone 97656 53615',
    ],
    'COOKIE POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This Cookie Policy details how cookies are used on our web and browser-based services.',
      'Cookies: Small text files stored on your device to maintain functionality and personalize experience.',
      'We use cookies to manage sessions, performance, user insights, security, and analytics.',
      'Cookie types:',
      '• Essential Cookies: Required for basic features',
      '• Performance Cookies: Analytics and optimizations',
      '• Security Cookies: Protect user accounts',
      'You can disable/delete cookies in your browser settings; doing so may affect functionality.',
      'Third-party services (analytics, payment gateways) may use their own cookies.',
      'Support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
    'GRIEVANCE REDRESSAL POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This policy complies with Indian IT Rules for grievances.',
      'Grievance Officer: Pandurang Patil (Grievance@nirvista.in | Grievance@nirvistagroup.com)',
      'Support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
      'Purpose: Ensure complaints, concerns, and disputes are handled fairly and promptly.',
      'Raise grievances via the grievance email, support email, or in-app system.',
      'Resolution timeline: Acknowledge within 48 hours and resolve within 7 working days.',
      'Scope: Payment issues, withdrawals, KYC, account access, technical bugs, policy violations.',
      'Escalation: Unresolved issues can be elevated through legal remedies under Indian law.',
      'Jurisdiction: Hyderabad, India.',
    ],
    'COMPLIANCE & LEGAL JURISDICTION POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This policy outlines the legal and compliance posture.',
      'Regulatory compliance: Information Technology Act, 2000; applicable financial/payment regulations; AML rules; and data protection laws. Policies/services may change to stay compliant.',
      'User responsibility: Ensure your activities obey local/national laws and expect regulatory updates.',
      'Jurisdiction: All disputes, claims, or proceedings fall under Hyderabad, India courts.',
      'Dispute resolution: Prefer mutual discussion, written correspondence, or arbitration before litigation.',
      'Policy updates may happen without notice.',
      'Legal contacts: support@nirvista.in | support@nirvistagroup.com | Grievance@nirvista.in | Grievance@nirvistagroup.com | Phone: 97656 53615',
    ],
    'DISCLAIMER POLICY': [
      'App Name: Nirvista PRE ICO and ICO',
      'This Policy limits legal liability and clarifies service nature.',
      'No financial advice: We do not provide investment, tax, or legal counsel; content is informational.',
      'No guarantee of returns: Token purchases, staking, and referral rewards may not appreciate; losses are possible.',
      'Service availability: Provided “as-is” and “as-available” without guarantees.',
      'Third-party services: Not responsible for gateway failures, bank issues, networks, or third-party errors.',
      'User responsibility: You handle your financial decisions, legal compliance, and account security.',
      'Limitation of liability: Nirvista PRE ICO and ICO and partners are not liable for direct/indirect losses, financial damage, data loss, or business interruption.',
      'Acceptance: Using the platform means you read, understood, and agreed to this policy.',
      'Support: support@nirvista.in | support@nirvistagroup.com | Phone: 97656 53615',
    ],
  };

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    final sections = policyDetails[policyTitle] ??
        ['Content for this policy is coming soon.'];
    return Scaffold(
      backgroundColor: notifire.getBgColor,
      appBar: AppBar(
        backgroundColor: notifire.getBgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getTextColor),
        title: Text(
          policyTitle,
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              notifire.getBgColor.withOpacity(0.95),
              notifire.getBgColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                gradient: LinearGradient(
                  colors: [
                    priMeryColor.withOpacity(0.2),
                    priMeryColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: priMeryColor.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    policyTitle,
                    style: Typographyy.heading5
                        .copyWith(color: notifire.getTextColor, height: 1.2),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Nirvista PRE ICO and ICO policies',
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  color: notifire.getContainerColor,
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: notifire.getGry700_300Color),
                ),
                child: Scrollbar(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: sections.length,
                    physics: const ClampingScrollPhysics(),
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final text = sections[index];
                      return _buildSection(context, text, notifire);
                    },
                  ),
                ),
              ),
            ),
            const FooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, String text, ColorNotifire notifire) {
    final trimmed = text.trim();
    final isBullet = trimmed.startsWith('•');
    final displayText = isBullet ? trimmed.substring(2).trim() : trimmed;
    final contactRegex = RegExp(r'[\w\.-]+@[\w\.-]+\.\w+');
    final hasEmail = contactRegex.hasMatch(displayText);
    final hasPhone = displayText.toLowerCase().contains('phone');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isBullet)
          Padding(
            padding: const EdgeInsets.only(top: 6, right: 6),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: priMeryColor,
                shape: BoxShape.circle,
              ),
            ),
          )
        else
          const SizedBox(width: 0),
        Expanded(
          child: SelectableText(
            displayText,
            style: Typographyy.bodyLargeMedium.copyWith(
              color: notifire.getTextColor,
              height: 1.6,
            ),
          ),
        ),
        if (hasEmail || hasPhone)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: displayText));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Copied to clipboard'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.copy, size: 18),
            color: priMeryColor,
            tooltip: 'Copy',
          )
        else
          const SizedBox(width: 0),
      ],
    );
  }
}
