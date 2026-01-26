import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/dashbordecontroller.dart';

class Activity extends StatefulWidget {
  const Activity({super.key});

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  ColorNotifire notifire = ColorNotifire();
  late DashBordeController dashBordeController;

  @override
  void initState() {
    super.initState();
    dashBordeController = DashBordeController.shared;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashBordeController.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<DashBordeController>(builder: (controller) {
      final referrals = controller.allTransactions
          .where((tx) => (tx['category']?.toString() ?? '') == 'referral')
          .toList();

      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.all(16),
        color: notifire.getBgColor,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text("Activities",
                      style: Typographyy.heading4
                          .copyWith(color: notifire.getTextColor)),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.fetchTransactions,
                    icon: const Icon(Icons.refresh),
                    color: notifire.getTextColor,
                  )
                ],
              ),
              const SizedBox(height: 16),
              _card(
                title: "Referral Transactions",
                child: referrals.isEmpty
                    ? _emptyState(
                        "No referral transactions found.",
                      )
                    : Column(
                        children: [
                          _referralHeader(),
                          const Divider(),
                          ...referrals.map((tx) => _referralRow(tx)),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              _card(
                title: "Recipients",
                child: referrals.isEmpty
                    ? _emptyState(
                        "Referral income will appear here.",
                      )
                    : Column(
                        children: _recipientRows(referrals),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: notifire.getGry700_300Color),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(notifire.getBorderColor, 0.08),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
                Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _referralHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _headerCell("Source"),
          _headerCell("Level", flex: 1),
          _headerCell("Amount Received", flex: 2, alignEnd: true),
          _headerCell("Date", flex: 2, alignEnd: true),
        ],
      ),
    );
  }

  Widget _referralRow(Map<String, dynamic> tx) {
    final source = _referralSource(tx);
    final level = _referralLevel(tx);
    final amount = _formatAmount(
        tx['currency']?.toString() ?? 'INR', tx['amount'] as num?);
    final date = _formatDate(tx['createdAt']?.toString());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          _valueCell(source),
          _valueCell(level, flex: 1),
          _valueCell(amount, flex: 2, alignEnd: true),
          _valueCell(date, flex: 2, alignEnd: true),
        ],
      ),
    );
  }

  List<Widget> _recipientRows(List<Map<String, dynamic>> referrals) {
    final Map<String, Map<String, dynamic>> totals = {};

    for (final tx in referrals) {
      final source = _referralSource(tx);
      final level = _referralLevel(tx);
      final currency = tx['currency']?.toString() ?? 'INR';
      final amount = (tx['amount'] as num?)?.toDouble() ?? 0;
      final key = '$source|$level|$currency';
      totals.putIfAbsent(key, () => {
            'source': source,
            'level': level,
            'currency': currency,
            'amount': 0.0,
          });
      totals[key]!['amount'] =
          (totals[key]!['amount'] as double) + amount;
    }

    return totals.values
        .map((row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row['source']?.toString() ?? '-',
                            style: Typographyy.bodyLargeSemiBold
                                .copyWith(color: notifire.getTextColor)),
                        const SizedBox(height: 4),
                        Text('Level ${row['level']}',
                            style: Typographyy.bodyMediumMedium.copyWith(
                                color: notifire.getGry500_600Color)),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        _formatAmount(row['currency']?.toString() ?? 'INR',
                            row['amount'] as num?),
                        style: Typographyy.bodyLargeExtraBold
                            .copyWith(color: priMeryColor),
                      ),
                    ),
                  )
                ],
              ),
            ))
        .toList();
  }

  Widget _headerCell(String text, {int flex = 2, bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Typographyy.bodySmallSemiBold
            .copyWith(color: notifire.getGry500_600Color),
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      ),
    );
  }

  Widget _valueCell(String text, {int flex = 2, bool alignEnd = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: Typographyy.bodyMediumMedium
            .copyWith(color: notifire.getTextColor),
        textAlign: alignEnd ? TextAlign.end : TextAlign.start,
      ),
    );
  }

  Widget _emptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        message,
        style: Typographyy.bodyMediumMedium
            .copyWith(color: notifire.getGry500_600Color),
      ),
    );
  }

  String _referralSource(Map<String, dynamic> tx) {
    final metadata = tx['metadata'];
    if (metadata is Map<String, dynamic>) {
      final from = metadata['source'] ?? metadata['from'] ?? metadata['user'];
      if (from != null) {
        final value = from.toString();
        if (value.isNotEmpty) return value;
      }
    }
    final recipient =
        tx['recipient'] ?? tx['from'] ?? tx['walletAddress'] ?? tx['to'];
    return recipient?.toString().isNotEmpty == true
        ? recipient.toString()
        : '-';
  }

  String _referralLevel(Map<String, dynamic> tx) {
    final metadata = tx['metadata'];
    if (metadata is Map<String, dynamic> && metadata['level'] != null) {
      return metadata['level'].toString();
    }
    if (tx['level'] != null) {
      return tx['level'].toString();
    }
    return '-';
  }

  String _formatAmount(String currency, num? amount) {
    if (amount == null) return '-';
    final value = amount.abs();
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    return '$currency $formatted';
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) {
      return '-';
    }
    try {
      final parsed = DateTime.parse(iso).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      final month = months[parsed.month - 1];
      final day = parsed.day.toString().padLeft(2, '0');
      final year = parsed.year;
      return '$day $month $year';
    } catch (_) {
      return '-';
    }
  }
}
