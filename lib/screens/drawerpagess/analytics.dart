import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../controller/analytics_controller.dart';

class Analytics extends StatefulWidget {
  const Analytics({super.key});

  @override
  State<Analytics> createState() => _AnalyticsState();
}

class _AnalyticsState extends State<Analytics> {
  ColorNotifire notifire = ColorNotifire();
  final AnalyticsController controller = Get.put(AnalyticsController());
  final List<String> _timeframes = [
    "Weekly",
    "Monthly",
    "Half-Yearly",
    "Yearly",
  ];
  String _selectedTimeframe = "Weekly";
  DateTimeRange? _selectedRange;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<AnalyticsController>(
      builder: (c) {
        return Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          color: notifire.getBgColor,
          padding: EdgeInsets.all(padding),
          child: _content(c),
        );
      },
    );
  }

  Widget _content(AnalyticsController c) {
    if (c.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (c.error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            c.error!,
            style: Typographyy.bodyLargeMedium
                .copyWith(color: Colors.redAccent),
          ),
          const SizedBox(height: 12),
          _primaryButton("Retry", c.fetchAnalytics),
          const SizedBox(height: 16),
          _staticSlider(),
        ],
      );
    }
    final data = c.analytics;
    if (data == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _primaryButton("Reload", c.fetchAnalytics),
          const SizedBox(height: 16),
          _staticSlider(),
        ],
      );
    }

    final wallets = data['wallets'] as Map<String, dynamic>? ?? {};
    final portfolio = data['portfolio'] as Map<String, dynamic>? ?? {};
    final activity = data['activity'] as Map<String, dynamic>? ?? {};

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(c),
          const SizedBox(height: 16),
          _buildFilterRow(),
          const SizedBox(height: 16),
          _overviewRow(wallets),
          const SizedBox(height: 16),
          _secondaryRow(wallets),
          const SizedBox(height: 16),
          _bottomRow(portfolio, activity),
          const SizedBox(height: 16),
          _staticSlider(),
        ],
      ),
    );
  }

  Widget _header(AnalyticsController c) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Analytics",
              style:
                  Typographyy.heading4.copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(height: 4),
            Text(
              "Wallets · Portfolio · Activity",
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
          ],
        ),
        const Spacer(),
        _primaryButton("Refresh", c.fetchAnalytics),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeframes.map((label) {
            final isSelected = label == _selectedTimeframe;
            return ChoiceChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (_) => _onSelectTimeframe(label),
              selectedColor: priMeryColor,
              backgroundColor: notifire.getBgColor,
              labelStyle: Typographyy.bodySmallMedium.copyWith(
                color: isSelected ? Colors.white : notifire.getTextColor,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Text(
              "Range: ${_rangeLabel()}",
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _pickDateRange,
              icon: SvgPicture.asset(
                "assets/images/calendar.svg",
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  notifire.getGry500_600Color,
                  BlendMode.srcIn,
                ),
              ),
              label: Text(
                "Select Range",
                style: Typographyy.bodySmallMedium
                    .copyWith(color: priMeryColor),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _rangeLabel() {
    if (_selectedRange == null) {
      return _selectedTimeframe;
    }
    String format(DateTime date) =>
        "${date.day}/${date.month}/${date.year}";
    return "${format(_selectedRange!.start)} - ${format(_selectedRange!.end)}";
  }

  void _onSelectTimeframe(String timeframe) {
    if (timeframe == _selectedTimeframe) return;
    setState(() {
      _selectedTimeframe = timeframe;
      _selectedRange = null;
    });
    controller.fetchAnalytics();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final result = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      currentDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: priMeryColor,
              onPrimary: Colors.white,
              surface: notifire.getContainerColor,
              onSurface: notifire.getTextColor,
            ),
          ),
          child: child ?? const SizedBox(),
        );
      },
    );
    if (result != null) {
      setState(() {
        _selectedRange = result;
        _selectedTimeframe = "Custom";
      });
      controller.fetchAnalytics();
    }
  }

  Widget _overviewRow(Map<String, dynamic> wallets) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _walletCard("Main Wallet", wallets['main'] as Map<String, dynamic>?, accent: priMeryColor),
        _walletCard("Token Wallet", wallets['token'] as Map<String, dynamic>?, accent: const Color(0xff26A17B)),
        _walletCard("Referral Wallet", wallets['referral'] as Map<String, dynamic>?, accent: const Color(0xffFB774A)),
        _walletCard("Rewards", wallets['rewards'] as Map<String, dynamic>?, accent: const Color(0xff7C3AED)),
      ],
    );
  }

  Widget _secondaryRow(Map<String, dynamic> wallets) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _stakingCard(wallets['staking'] as Map<String, dynamic>?),
      ],
    );
  }

  Widget _bottomRow(Map<String, dynamic> portfolio, Map<String, dynamic> activity) {
    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 900;
      if (isNarrow) {
        return Column(
          children: [
            _portfolioCard(portfolio),
            const SizedBox(height: 12),
            _activityCard(activity),
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: _portfolioCard(portfolio)),
          const SizedBox(width: 16),
          Expanded(child: _activityCard(activity)),
        ],
      );
    });
  }

  Widget _walletCard(String title, Map<String, dynamic>? wallet, {Color accent = const Color(0xff0B7D7B)}) {
    final balance = (wallet?['balance'] as num?)?.toDouble();
    final currency = wallet?['currency']?.toString();
    final pending = (wallet?['pendingWithdrawals'] as num?)?.toDouble();
    final credited = (wallet?['totalCredited'] as num?)?.toDouble();
    final debited = (wallet?['totalDebited'] as num?)?.toDouble();
    final totalEarned = (wallet?['totalEarned'] as num?)?.toDouble();

    return _card(
      title: title,
      icon: "assets/images/wallet.svg",
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelValue("Balance", _formatAmount(currency ?? "INR", balance)),
          if (pending != null) _labelValue("Pending Withdrawals", _formatAmount(currency ?? "INR", pending)),
          if (credited != null) _labelValue("Total Credited", _formatAmount(currency ?? "INR", credited)),
          if (debited != null) _labelValue("Total Debited", _formatAmount(currency ?? "INR", debited)),
          if (totalEarned != null) _labelValue("Total Earned", _formatAmount(currency ?? "INR", totalEarned)),
        ],
      ),
    );
  }

  Widget _stakingCard(Map<String, dynamic>? staking) {
    final staked = (staking?['staked'] as num?)?.toDouble();
    final expected = (staking?['expectedReturn'] as num?)?.toDouble();
    final rate = staking?['interestRate']?.toString();
    return _card(
      title: "Staking",
      icon: "assets/images/coin-convert.svg",
      accent: const Color(0xff0CAF60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelValue("Staked", staked?.toString() ?? "-"),
          _labelValue("Expected Return", expected?.toString() ?? "-"),
          _labelValue("Interest Rate", rate != null ? "$rate%" : "-"),
        ],
      ),
    );
  }

  Widget _portfolioCard(Map<String, dynamic> portfolio) {
    final tokensHeld = (portfolio['tokensHeld'] as num?)?.toDouble();
    final tokensStaked = (portfolio['tokensStaked'] as num?)?.toDouble();
    final referral = (portfolio['referralCommissions'] as num?)?.toDouble();
    return _card(
      title: "Portfolio",
      icon: "assets/images/Chart.svg",
      accent: const Color(0xff1AA39A),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelValue("Tokens Held", tokensHeld?.toString() ?? "-"),
          _labelValue("Tokens Staked", tokensStaked?.toString() ?? "-"),
          _labelValue("Referral Commissions", referral?.toString() ?? "-"),
        ],
      ),
    );
  }

  Widget _activityCard(Map<String, dynamic> activity) {
    final buy = activity['buy'] as Map<String, dynamic>? ?? {};
    final sell = activity['sell'] as Map<String, dynamic>? ?? {};
    final stake = activity['stake'] as Map<String, dynamic>? ?? {};
    return _card(
      title: "Activity",
      icon: "assets/images/receipt-tax.svg",
      accent: const Color(0xff7C3AED),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _labelValue("Buy Tokens", (buy['tokens'] ?? '-').toString()),
          _labelValue("Buy Fiat", (buy['fiat'] ?? '-').toString()),
          _labelValue("Sell Tokens", (sell['tokens'] ?? '-').toString()),
          _labelValue("Sell Fiat", (sell['fiat'] ?? '-').toString()),
          _labelValue("Stake Tokens", (stake['tokens'] ?? '-').toString()),
          _labelValue("Expected Return", (stake['expectedReturn'] ?? '-').toString()),
        ],
      ),
    );
  }

  Widget _card({required String title, required String icon, required Widget child, Color accent = const Color(0xff0B7D7B)}) {
    return Container(
      width: 320,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            notifire.getContainerColor,
            colorWithOpacity(notifire.getContainerColor, 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: notifire.getGry700_300Color),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(notifire.getBorderColor, 0.12),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                icon,
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getGry500_600Color)),
          const SizedBox(width: 8),
          Text(
            value,
            style: Typographyy.bodyLargeSemiBold
                .copyWith(color: notifire.getTextColor),
          ),
        ],
      ),
    );
  }

  String _formatAmount(String currency, double? amount) {
    if (amount == null) return '-';
    final isNegative = amount < 0;
    final value = amount.abs();
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    final sign = isNegative ? '-' : '+';
    return '$sign$currency $formatted';
  }

  Widget _primaryButton(String label, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: priMeryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: Text(
        label,
        style:
            Typographyy.bodyMediumExtraBold.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _staticSlider() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage("assets/images/03.png"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

