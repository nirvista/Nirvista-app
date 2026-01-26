import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';

class ReviewDetailsPage extends StatelessWidget {
  const ReviewDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Scaffold(
      backgroundColor: notifire.getBgColor,
      appBar: AppBar(
        backgroundColor: notifire.getBgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: notifire.getTextColor),
        title: Text(
          "Review Details",
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _summaryCard(notifire),
              const SizedBox(height: 16),
              _detailsCard(notifire),
              const SizedBox(height: 16),
              _statusCard(notifire),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Transfer submitted.')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: priMeryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    fixedSize: const Size.fromHeight(48),
                  ),
                  child: Text(
                    "Confirm Transfer",
                    style: Typographyy.bodyMediumSemiBold
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(ColorNotifire notifire) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Transfer Summary",
            style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 8),
          Text(
            "Review the details before confirming.",
            style: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
        ],
      ),
    );
  }

  Widget _detailsCard(ColorNotifire notifire) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Details",
            style: Typographyy.bodyLargeExtraBold
                .copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 12),
          _detailRow(notifire, "Amount", "-"),
          _detailRow(notifire, "Fees", "-"),
          _detailRow(notifire, "Recipient", "-"),
          _detailRow(notifire, "Method", "Wallet transfer"),
          _detailRow(notifire, "Estimated arrival", "Within 1-2 hours"),
        ],
      ),
    );
  }

  Widget _statusCard(ColorNotifire notifire) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status",
            style: Typographyy.bodyLargeExtraBold
                .copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 12),
          _detailRow(notifire, "Current status", "Pending confirmation"),
          _detailRow(notifire, "Failure reason", "-"),
        ],
      ),
    );
  }

  Widget _detailRow(ColorNotifire notifire, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
          Text(
            value,
            style: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
        ],
      ),
    );
  }
}
