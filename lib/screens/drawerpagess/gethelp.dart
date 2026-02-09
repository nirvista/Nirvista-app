import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';

const List<Map<String, String>> _topFaqCards = [
  {
    'title': 'Why can’t I access my balance?',
    'description':
        'Your balance may be temporarily unavailable due to KYC status, network synchronization, or system maintenance. Please ensure your account is verified and your app is up to date.',
    'meta': 'Nirvista • Balance',
  },
  {
    'title': 'Why is my balance showing zero?',
    'description':
        'Your wallet may still be syncing with the blockchain, or there are currently no funds available in the selected wallet.',
    'meta': 'Nirvista • Balance',
  },
  {
    'title': 'Why are withdrawals disabled?',
    'description':
        'Withdrawals are enabled only after successful KYC verification. This is mandatory to comply with regulatory and security standards.',
    'meta': 'Nirvista • Withdrawal',
  },
  {
    'title': 'Why is my KYC still pending?',
    'description':
        'Your documents are under review by our verification team. Verification usually takes 24–72 hours.',
    'meta': 'Nirvista • KYC',
  },
  {
    'title': 'Why can’t I sell my tokens?',
    'description':
        'Token selling is available only after KYC approval and when your account status is active.',
    'meta': 'Nirvista • Token',
  },
];

const List<String> _searchChips = [
  'Send Money',
  'Transfer',
  'Withdraw',
  'KYC',
  'Buy Token',
];

const List<Map<String, String>> _categoryCards = [
  {
    'title': 'Sending Money',
    'description':
        'Send funds instantly and securely using blockchain-powered transactions.',
  },
  {
    'title': 'Your Account',
    'description':
        'Manage your profile, KYC status, security settings, and verification details.',
  },
  {
    'title': 'Sell Token',
    'description':
        'Convert your NVT tokens into supported currencies after KYC verification.',
  },
  {
    'title': 'Nirvista Business',
    'description':
        'Tools and solutions for merchants and enterprises using Nirvista payments.',
  },
];

const String _globalNotice =
    '⚠ Important\nWithdrawals, referral income, and staking rewards are available only after successful KYC verification.';

class GetHelp extends StatefulWidget {
  const GetHelp({super.key});

  @override
  State<GetHelp> createState() => _GetHelpState();
}

class _GetHelpState extends State<GetHelp> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      color: notifire.getBgColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get Help',
              style:
                  Typographyy.heading4.copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(height: 6),
            Text(
              'Your support center for Nirvista Wallet, ICO, and Business services.',
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
            const SizedBox(height: 12),
            _buildTopFaqSection(notifire, width),
            const SizedBox(height: 12),
            _buildSearchSection(notifire),
            const SizedBox(height: 12),
            _buildCategorySection(notifire, width),
            const SizedBox(height: 12),
            _buildMoneySection(notifire),
            const SizedBox(height: 12),
            _buildFaqDetail(notifire),
            const SizedBox(height: 12),
            _buildGlobalNotice(notifire),
            const SizedBox(height: 12),
            _buildSupportCta(notifire),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTopFaqSection(ColorNotifire notifire, double width) {
    final cardWidth = width < 700 ? double.infinity : (width - 64) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Help Cards',
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _topFaqCards
              .map((card) => SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifire.getContainerColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: notifire.getGry700_300Color),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            card['title']!,
                            style: Typographyy.heading6.copyWith(
                                color: notifire.getTextColor, height: 1.3),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            card['description']!,
                            style: Typographyy.bodySmallMedium.copyWith(
                                color: notifire.getGry500_600Color,
                                height: 1.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            card['meta']!,
                            style: Typographyy.bodySmallMedium
                                .copyWith(color: notifire.getGry700_300Color),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildSearchSection(ColorNotifire notifire) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How can we help you?',
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 6),
        Text(
          'Search answers, FAQs, and guides to resolve your issues instantly.',
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.search, color: notifire.getGry500_600Color),
            hintText: 'Search help topics…',
            hintStyle: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getGry500_600Color),
            filled: true,
            fillColor: notifire.getContainerColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifire.getGry700_300Color),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifire.getGry700_300Color),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _searchChips
              .map((chip) => Chip(
                    backgroundColor: notifire.getContainerColor,
                    label: Text(
                      chip,
                      style: Typographyy.bodySmallMedium
                          .copyWith(color: notifire.getTextColor),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildCategorySection(ColorNotifire notifire, double width) {
    final cardWidth = width < 700 ? double.infinity : (width - 64) / 2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category Cards',
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _categoryCards
              .map((category) => SizedBox(
                    width: cardWidth,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: notifire.getContainerColor,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: notifire.getGry700_300Color),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category['title']!,
                            style: Typographyy.heading6.copyWith(
                                color: notifire.getTextColor, height: 1.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category['description']!,
                            style: Typographyy.bodySmallMedium.copyWith(
                                color: notifire.getGry500_600Color,
                                height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildMoneySection(ColorNotifire notifire) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nirvista Money',
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 6),
        Text(
          'Holding balances, managing wallets, making payments, and using digital assets securely.',
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ],
    );
  }

  Widget _buildFaqDetail(ColorNotifire notifire) {
    final bullets = [
      'Your KYC verification is pending or rejected',
      'The wallet is syncing with the blockchain',
      'Temporary system maintenance',
      'Network connectivity issues',
    ];
    final steps = [
      'Check your KYC status',
      'Ensure your app is updated',
      'Refresh the page',
      'Contact support if the issue continues',
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Why can’t I access my balance?',
            style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 12),
          Text(
            'Your balance access may be limited due to one of the following reasons:',
            style: Typographyy.bodySmallMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
          const SizedBox(height: 10),
          ...bullets
              .map(
                (bullet) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          color: priMeryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          bullet,
                          style: Typographyy.bodySmallMedium.copyWith(
                              color: notifire.getGry500_600Color, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          const SizedBox(height: 12),
          Text(
            'Resolution steps:',
            style: Typographyy.bodyMediumSemiBold
                .copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 8),
          ...steps
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '${entry.key + 1}. ${entry.value}',
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildGlobalNotice(ColorNotifire notifire) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getGry700_300Color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _globalNotice,
        style:
            Typographyy.bodySmallMedium.copyWith(color: notifire.getTextColor),
      ),
    );
  }

  Widget _buildSupportCta(ColorNotifire notifire) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Still need help?',
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 8),
        Text(
          'Contact Nirvista Support',
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              child: const Text('Raise Support Ticket (Coming Soon)'),
            ),
            ElevatedButton(
              onPressed: () => launchUrlString('mailto:support@nirvista.com'),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              child: const Text('Email Support'),
            ),
            ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              ),
              child: const Text('Live Chat (Coming Soon)'),
            ),
          ],
        ),
      ],
    );
  }
}
