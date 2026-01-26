import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../ConstData/colorfile.dart';
import '../../../ConstData/colorprovider.dart';
import '../../../ConstData/staticdata.dart';
import '../../../ConstData/typography.dart';
import '../../../controller/ico_summary_controller.dart';

class CreditCard extends StatefulWidget {
  const CreditCard({super.key});

  @override
  State<CreditCard> createState() => _CreditCardState();
}

class _CreditCardState extends State<CreditCard> {
  final IcoSummaryController controller = Get.put(IcoSummaryController());
  ColorNotifire notifire = ColorNotifire();
  final TextEditingController tokenAmountController = TextEditingController();

  String _normalizeTokenSymbol(String? symbol) {
    final value = symbol?.trim();
    if (value == null || value.isEmpty) {
      return 'NVT Coin';
    }
    final upper = value.toUpperCase();
    if (upper == 'ICOX' || upper == 'ICO') {
      return 'NVT Coin';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<IcoSummaryController>(
      builder: (c) {
        return Container(
          color: notifire.getBgColor,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(padding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: _content(c),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _content(IcoSummaryController c) {
    if (c.isLoading) {
      return const CircularProgressIndicator();
    }
    if (c.error != null) {
      return _statusCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              c.error!,
              style: Typographyy.bodyLargeMedium
                  .copyWith(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            _primaryButton("Retry", c.fetchSummary),
          ],
        ),
      );
    }

    
    final data = c.summary;
    if (data == null) {
      return _statusCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "No data available",
              style: Typographyy.bodyLargeMedium
                  .copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(height: 12),
            _primaryButton("Reload", c.fetchSummary),
          ],
        ),
      );
    }

    final tokenSymbol =
        _normalizeTokenSymbol(data['tokenSymbol']?.toString());
    final price = (data['price'] as num?)?.toDouble();
    final balance = (data['balance'] as num?)?.toDouble();
    final valuation = (data['valuation'] as num?)?.toDouble();
    final kycStatus = data['kycStatus']?.toString() ?? '-';
    final sellAllowed = data['sellAllowed'] == true;
    final stage = data['stage'] is Map<String, dynamic>
        ? Map<String, dynamic>.from(data['stage'])
        : null;

    return LayoutBuilder(builder: (context, constraints) {
      final isNarrow = constraints.maxWidth < 900;
      final summaryCards = Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _infoCard(
            title: "Token Symbol",
            value: tokenSymbol,
            icon: "assets/images/document.svg",
          ),
          _infoCard(
            title: "Price",
            value: price != null ? "INR ${price.toStringAsFixed(2)}" : "-",
            icon: "assets/images/dollar-circle.svg",
          ),
          _infoCard(
            title: "Balance",
            value: balance != null ? "$balance $tokenSymbol" : "-",
            icon: "assets/images/wallet.svg",
          ),
          _infoCard(
            title: "Valuation",
            value:
                valuation != null ? "INR ${valuation.toStringAsFixed(2)}" : "-",
            icon: "assets/images/Chart.svg",
          ),
        ],
      );

      Widget statusColumn = Column(
        children: [
          _statusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("KYC Status",
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getTextColor)),
                const SizedBox(height: 8),
                _pill(kycStatus),
                const SizedBox(height: 16),
                Text("Sell Allowed",
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getTextColor)),
                const SizedBox(height: 8),
                _pill(sellAllowed ? "Yes" : "No",
                    color: sellAllowed ? Colors.green : Colors.orange),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _statusCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Stage",
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getTextColor)),
                const SizedBox(height: 12),
                if (stage != null) ...[
                  _stageRow("Label", stage['label']?.toString()),
                  _stageRow("Status", stage['status']?.toString()),
                  _stageRow("Active", stage['isActive']?.toString()),
                  _stageRow("Upcoming", stage['isUpcoming']?.toString()),
                  _stageRow("Ended", stage['isEnded']?.toString()),
                  _stageRow("Start", stage['startAt']?.toString()),
                  _stageRow("End", stage['endAt']?.toString()),
                ] else
                  Text("No stage info",
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: notifire.getGry500_600Color)),
              ],
            ),
          ),
        ],
      );

      final buyCard = _buySection(price, tokenSymbol);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "NVT Coin",
                style:
                    Typographyy.heading4.copyWith(color: notifire.getTextColor),
              ),
              const Spacer(),
              IconButton(
                onPressed: c.fetchSummary,
                icon: const Icon(Icons.refresh),
                color: notifire.getTextColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          summaryCards,
          const SizedBox(height: 18),
          if (isNarrow) ...[
            buyCard,
            const SizedBox(height: 14),
            statusColumn,
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: buyCard),
                const SizedBox(width: 16),
                Expanded(flex: 2, child: statusColumn),
              ],
            ),
        ],
      );
    });
  }

  Widget _infoCard({required String title, required String value, required String icon}) {
    return Container(
      width: 270,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(notifire.getBorderColor, 0.08),
            blurRadius: 14,
            offset: const Offset(0, 10),
          )
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
                colorFilter: ColorFilter.mode(
                  priMeryColor,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 8),
              Text(title,
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getGry500_600Color)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value,
              style: Typographyy.bodyLargeExtraBold
                  .copyWith(color: notifire.getTextColor)),
        ],
      ),
    );
  }

  Widget _statusCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(notifire.getBorderColor, 0.08),
            blurRadius: 14,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: child,
    );
  }

  Widget _pill(String text, {Color color = const Color(0xff0B7D7B)}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorWithOpacity(color, 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Typographyy.bodyLargeSemiBold.copyWith(color: color),
      ),
    );
  }

  Widget _stageRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: Typographyy.bodySmallSemiBold
                    .copyWith(color: notifire.getGry500_600Color)),
          ),
          Expanded(
            child: Text(
              value?.isNotEmpty == true ? value! : '-',
              style: Typographyy.bodyLargeSemiBold
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
        ],
      ),
    );
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

  Widget _buySection(double? price, String tokenSymbol) {
    final controller = Get.find<IcoSummaryController>();
    final tokens = double.tryParse(tokenAmountController.text.trim()) ?? 0;
    final estimate = (price != null && tokens > 0) ? price * tokens : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: notifire.getGry700_300Color),
        boxShadow: [
          BoxShadow(
            color: colorWithOpacity(notifire.getBorderColor, 0.12),
            blurRadius: 16,
            offset: const Offset(0, 12),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Buy $tokenSymbol",
                      style: Typographyy.heading5
                          .copyWith(color: notifire.getTextColor)),
                  const SizedBox(height: 4),
                  Text(
                    "Instant debit from main wallet",
                    style: Typographyy.bodyMediumMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: colorWithOpacity(priMeryColor, 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price != null
                      ? "INR ${price.toStringAsFixed(2)} / $tokenSymbol"
                      : "Price unavailable",
                  style: Typographyy.bodySmallSemiBold
                      .copyWith(color: priMeryColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "Token amount",
            style: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: tokenAmountController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: "Enter tokens to buy",
              prefixText: "$tokenSymbol ",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: notifire.getDrawerColor,
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: Row(
              children: [
                Icon(Icons.receipt_long,
                    size: 18, color: notifire.getGry500_600Color),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    estimate != null
                        ? "Approximate charge: INR ${estimate.toStringAsFixed(2)}"
                        : "Enter a token amount to see estimated total.",
                    style: Typographyy.bodyMediumMedium.copyWith(
                        color: estimate != null
                            ? notifire.getTextColor
                            : notifire.getGry500_600Color),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (estimate == null || controller.isBuying)
                  ? null
                  : () async {
                      final tokens =
                          double.tryParse(tokenAmountController.text.trim()) ??
                              0;
                      if (tokens <= 0) {
                        Get.snackbar("Invalid amount",
                            "Enter a valid token amount",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colorWithOpacity(Colors.red, 0.1));
                        return;
                      }
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) {
                          return AlertDialog(
                            title: Text("Confirm Purchase",
                                style: Typographyy.heading6
                                    .copyWith(color: notifire.getTextColor)),
                            content: Text(
                              "Buy $tokens $tokenSymbol for approx INR ${estimate.toStringAsFixed(2)} from main wallet?",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getTextColor),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true),
                                child: const Text("Confirm"),
                              ),
                            ],
                          );
                        },
                      );
                      if (confirmed != true) return;
                      await controller.buyTokens(tokenAmount: tokens);
                      if (controller.buyMessage != null) {
                        Get.snackbar("Success", controller.buyMessage!,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colorWithOpacity(Colors.green, 0.1));
                      } else if (controller.buyError != null) {
                        Get.snackbar("Error", controller.buyError!,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: colorWithOpacity(Colors.red, 0.1));
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: priMeryColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              child: controller.isBuying
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      estimate != null
                          ? "Buy Token • INR ${estimate.toStringAsFixed(2)}"
                          : "Buy Token",
                      style: Typographyy.bodyMediumExtraBold
                          .copyWith(color: Colors.white),
                    ),
            ),
          ),
          if (controller.buyError != null) ...[
            const SizedBox(height: 8),
            Text(
              controller.buyError!,
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: Colors.redAccent),
            ),
          ],
        ],
      ),
    );
  }
}
