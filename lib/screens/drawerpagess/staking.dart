import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../controller/staking_controller.dart';

class StakingScreen extends StatefulWidget {
  const StakingScreen({super.key});

  @override
  State<StakingScreen> createState() => _StakingScreenState();
}

class _StakingScreenState extends State<StakingScreen> {
  ColorNotifire notifire = ColorNotifire();
  final StakingController controller = Get.put(StakingController());
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<StakingController>(
      builder: (c) {
        return Container(
          color: notifire.getBgColor,
          padding: EdgeInsets.all(padding),
          child: SafeArea(
            top: false,
            bottom: false,
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: c.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _content(c),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(StakingController c) {
    return SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Staking",
                  style:
                      Typographyy.heading4.copyWith(color: notifire.getTextColor)),
              const Spacer(),
              _primaryButton("Refresh", c.fetchStakes, compact: true),
            ],
          ),
          const SizedBox(height: 12),
          _buildStakingStats(c),
          const SizedBox(height: 12),
          _holdingCard(c),
          const SizedBox(height: 16),
          _stakeForm(c),
          const SizedBox(height: 20),
          _stakesList(c),
        ],
      ),
    );
  }

  Widget _holdingCard(StakingController c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Token Holding",
                  style: Typographyy.bodyLargeExtraBold
                      .copyWith(color: notifire.getTextColor)),
              const SizedBox(height: 6),
              Text("${c.holdingBalance} NVT",
                  style: Typographyy.heading4
                      .copyWith(color: priMeryColor)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStakingStats(StakingController c) {
    final totalStaked = _sumField(c, 'tokenAmount');
    final totalRewards = _sumField(c, 'interestAmount');
    final lockText = _lockDaysText(c);
    return Wrap(
      spacing: 16,
      runSpacing: 12,
      children: [
        _statCard(
          title: "Total Staked",
          value: "${totalStaked.toStringAsFixed(2)} NVT",
          subtitle: "Tokens currently locked",
        ),
        _statCard(
          title: "Rewards Estimate",
          value: totalRewards > 0
              ? "INR ${totalRewards.toStringAsFixed(2)}"
              : "INR 0.00",
          subtitle: "Projected from interest payouts",
        ),
        _statCard(
          title: "Lock-in Period",
          value: lockText,
          subtitle: "Duration before unstake",
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      width: 230,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color)),
          const SizedBox(height: 8),
          Text(value,
              style:
                  Typographyy.heading6.copyWith(color: notifire.getTextColor)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color)),
        ],
      ),
    );
  }

  double _sumField(StakingController c, String key) {
    return c.stakes.fold<double>(0, (sum, stake) {
      final value = stake[key];
      if (value is num) {
        return sum + value.toDouble();
      }
      return sum;
    });
  }

  String _lockDaysText(StakingController c) {
    final days = c.stakes
        .map<int?>((stake) {
          final meta = stake['metadata'];
          if (meta is Map<String, dynamic>) {
            final lockDays = meta['lockDays'];
            if (lockDays is num) return lockDays.toInt();
          }
          return null;
        })
        .whereType<int>()
        .toList();
    if (days.isEmpty) return 'N/A';
    final minDay = days.reduce(min);
    final maxDay = days.reduce(max);
    return minDay == maxDay ? '$minDay days' : '$minDay-$maxDay days';
  }

  Widget _stakeForm(StakingController c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Start a new stake",
              style: Typographyy.bodyLargeExtraBold
                  .copyWith(color: notifire.getTextColor)),
          const SizedBox(height: 12),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "Token amount",
              hintText: "Enter tokens to stake",
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
          _primaryButton(
            "Start Staking",
            () async {
              final val = double.tryParse(amountController.text.trim());
              if (val == null || val <= 0) {
                Get.snackbar("Invalid amount", "Enter a valid token amount",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: colorWithOpacity(Colors.red, 0.1));
                return;
              }
              await c.startStake(val);
              if (c.actionMessage != null) {
                Get.snackbar("Success", c.actionMessage!,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: colorWithOpacity(Colors.green, 0.1));
              } else if (c.error != null) {
                Get.snackbar("Error", c.error!,
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: colorWithOpacity(Colors.red, 0.1));
              }
              amountController.clear();
            },
            loading: c.isSubmitting,
          ),
          if (c.error != null) ...[
            const SizedBox(height: 8),
            Text(
              c.error!,
              style:
                  Typographyy.bodyMediumMedium.copyWith(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stakesList(StakingController c) {
    if (c.stakes.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text(
          "No stakes yet.",
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Staking history",
            style: Typographyy.bodyLargeExtraBold
                .copyWith(color: notifire.getTextColor)),
        const SizedBox(height: 12),
        ...c.stakes.map((s) => _stakeCard(c, s)),
      ],
    );
  }

  Widget _stakeCard(StakingController c, Map<String, dynamic> s) {
    final tokenAmount = (s['tokenAmount'] as num?)?.toDouble();
    final interestRate = s['interestRate']?.toString();
    final interestAmount = (s['interestAmount'] as num?)?.toDouble();
    final expectedReturn = (s['expectedReturn'] as num?)?.toDouble();
    final status = s['status']?.toString() ?? '';
    final startedAt = s['startedAt']?.toString();
    final maturesAt = s['maturesAt']?.toString();
    final id = s['_id']?.toString() ?? '';
    final lockDays = s['metadata'] is Map<String, dynamic>
        ? (s['metadata']['lockDays']?.toString() ?? '')
        : '';

    final isClaimable = status.toLowerCase() != 'claimed';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/images/coin-convert.svg",
                height: 20,
                width: 20,
                colorFilter: ColorFilter.mode(
                  priMeryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${tokenAmount ?? 0} NVT",
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor),
              ),
              const Spacer(),
              _statusChip(status),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _miniStat("Interest Rate", interestRate != null ? "$interestRate%" : "-"),
              _miniStat("Interest", interestAmount?.toString() ?? "-"),
              _miniStat("Expected Return", expectedReturn?.toString() ?? "-"),
              if (lockDays.isNotEmpty) _miniStat("Lock Days", lockDays),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _miniStat("Started", _formatDate(startedAt)),
              _miniStat("Matures", _formatDate(maturesAt)),
              _miniStat("ID", _shortId(id)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _primaryButton(
                  "Claim",
                  () async {
                    if (id.isEmpty) return;
                    await c.claim(id);
                    if (c.actionMessage != null) {
                      Get.snackbar("Success", c.actionMessage!,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorWithOpacity(Colors.green, 0.1));
                    } else if (c.error != null) {
                      Get.snackbar("Error", c.error!,
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: colorWithOpacity(Colors.red, 0.1));
                    }
                  },
                  loading: c.isSubmitting,
                  enabled: isClaimable,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: notifire.getGry700_300Color),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: (!isClaimable || c.isSubmitting)
                      ? null
                      : () async {
                          if (id.isEmpty) return;
                          await c.claim(id);
                          if (c.actionMessage != null) {
                            Get.snackbar("Unstake requested", c.actionMessage!,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    colorWithOpacity(Colors.green, 0.1));
                          } else if (c.error != null) {
                            Get.snackbar("Error", c.error!,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor:
                                    colorWithOpacity(Colors.red, 0.1));
                          }
                        },
                  child: Text(
                    "Unstake",
                    style: Typographyy.bodyMediumExtraBold
                        .copyWith(color: notifire.getTextColor),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color)),
          const SizedBox(height: 4),
          Text(value,
              style: Typographyy.bodyLargeSemiBold
                  .copyWith(color: notifire.getTextColor)),
        ],
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.orange;
        break;
      case 'claimed':
      case 'completed':
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorWithOpacity(color, 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.isEmpty ? '-' : status,
        style: Typographyy.bodyMediumSemiBold.copyWith(color: color),
      ),
    );
  }

  Widget _primaryButton(String label, VoidCallback onTap,
      {bool loading = false, bool enabled = true, bool compact = false}) {
    return ElevatedButton(
      onPressed: (!enabled || loading) ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: priMeryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: compact
            ? const EdgeInsets.symmetric(horizontal: 14, vertical: 10)
            : const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      child: loading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Text(
              label,
              style: Typographyy.bodyMediumExtraBold
                  .copyWith(color: Colors.white),
            ),
    );
  }

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      return "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
    } catch (_) {
      return '-';
    }
  }

  String _shortId(String id) {
    if (id.isEmpty) return '-';
    if (id.length <= 10) return id;
    return "${id.substring(0, 6)}...${id.substring(id.length - 4)}";
  }
}
