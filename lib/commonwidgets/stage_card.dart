import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../ConstData/colorfile.dart';
import '../ConstData/colorprovider.dart';
import '../ConstData/staticdata.dart';
import '../ConstData/typography.dart';

class StageCard extends StatelessWidget {
  final String label;
  final String status;
  final String? startAt;
  final String? endAt;
  final bool isActive;
  final bool isUpcoming;
  final bool isEnded;
  final bool isHighlight;

  const StageCard({
    super.key,
    required this.label,
    required this.status,
    required this.startAt,
    required this.endAt,
    required this.isActive,
    required this.isUpcoming,
    required this.isEnded,
    required this.isHighlight,
  });

  String _formatDate(String? iso) {
    if (iso == null || iso.isEmpty) {
      return 'Not Released';
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
      return '$month ${parsed.day}, ${parsed.year}';
    } catch (_) {
      return 'Not Released';
    }
  }

  String _statusLabel() {
    if (isActive) {
      return 'Active';
    }
    if (isUpcoming) {
      return 'Upcoming';
    }
    if (isEnded) {
      return 'Ended';
    }
    if (status.isNotEmpty) {
      final normalized = status.toLowerCase();
      if (normalized == 'tbd' || normalized == 'to be decided') {
        return 'Not Released';
      }
      return status[0].toUpperCase() + status.substring(1);
    }
    return 'Inactive';
  }

  Color _statusColor() {
    if (isActive) {
      return Colors.green;
    }
    if (isUpcoming) {
      return priMeryColor;
    }
    if (isEnded) {
      return Colors.grey;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    final statusColor = _statusColor();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: isHighlight ? priMeryColor : notifire.getGry700_300Color,
          width: isHighlight ? 1.4 : 1,
        ),
        color: isHighlight
            ? priMeryColor.withValues(alpha: 0.08)
            : notifire.getBgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Typographyy.bodyLargeMedium
                      .copyWith(color: notifire.getTextColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: statusColor.withValues(alpha: 0.15),
                  border: Border.all(color: statusColor.withValues(alpha: 0.6)),
                ),
                child: Text(
                  _statusLabel(),
                  style: Typographyy.bodySmallRegular.copyWith(color: statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Start: ${_formatDate(startAt)}',
            style: Typographyy.bodySmallRegular
                .copyWith(color: notifire.getGry500_600Color),
          ),
          const SizedBox(height: 4),
          Text(
            'End: ${_formatDate(endAt)}',
            style: Typographyy.bodySmallRegular
                .copyWith(color: notifire.getGry500_600Color),
          ),
          if (isHighlight) ...[
            const SizedBox(height: 6),
            Text(
              'Current Stage',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: priMeryColor),
            ),
          ]
        ],
      ),
    );
  }
}
