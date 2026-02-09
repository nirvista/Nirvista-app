import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../CommonWidgets/applogo.dart';
import '../../CommonWidgets/bottombar.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../services/auth_api_service.dart';
import '../drawerpagess/termsandcondition/policy_detail.dart';

enum KycStatus { pending, approved, rejected }

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  KycStatus status = KycStatus.pending;
  bool isStatusLoading = true;
  String? statusError;
  Map<String, dynamic>? kycDetails;
  ColorNotifire notifire = ColorNotifire();

  @override
  void initState() {
    super.initState();
    _checkKycStatus();
  }

  Future<void> _checkKycStatus() async {
    setState(() {
      isStatusLoading = true;
      statusError = null;
    });

    try {
      final response = await AuthApiService.getKycStatus();
      if (response['success'] == true) {
        final kycData = response['data'];
        final apiStatus = kycData is Map<String, dynamic>
            ? (kycData['status'] ?? 'pending').toString()
            : 'pending';
        if (!mounted) return;
        setState(() {
          kycDetails = kycData is Map<String, dynamic>
              ? Map<String, dynamic>.from(kycData)
              : null;
          status = _kycStatusFromString(apiStatus);
        });
      } else {
        final message =
            response['message']?.toString() ?? 'Unable to load KYC status.';
        if (!mounted) return;
        setState(() {
          statusError = message;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        statusError = 'Failed to fetch KYC status. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isStatusLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return DefaultTabController(
      length: 1,
      initialIndex: 0,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            color: notifire.getBgColor,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bottomInset = MediaQuery.of(context).viewInsets.bottom;
                final smallPadding =
                    EdgeInsets.fromLTRB(10, 10, 10, bottomInset + 24);
                final largePadding =
                    EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24);
                if (constraints.maxWidth < 600) {
                  return Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: notifire.getBgColor,
                    bottomNavigationBar: const BottomBarr(),
                    body: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics()
                          .applyTo(const BouncingScrollPhysics()),
                      padding: smallPadding,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildKycUi(
                                    width: constraints.maxWidth),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                } else if (constraints.maxWidth < 980) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics()
                        .applyTo(const BouncingScrollPhysics()),
                    padding: largePadding,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildKycUi(width: constraints.maxWidth),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                } else {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics()
                        .applyTo(const BouncingScrollPhysics()),
                    padding: largePadding,
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildKycUi(width: constraints.maxWidth),
                            ),
                            Expanded(child: _buildImageUi()),
                          ],
                        )
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKycUi({required double width}) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: width < 600 ? 20 : 80),
          const AppLogo(textColor: Colors.white),
          const SizedBox(height: 32),
          Text("KYC & Verification".tr,
              style: Typographyy.heading3.copyWith(
                  color: notifire.getWhitAndBlack)),
          const SizedBox(height: 16),
          Text("Complete your identity verification".tr,
              style: Typographyy.bodyLargeMedium
                  .copyWith(color: notifire.getGry500_600Color)),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: notifire.getContainerColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _statusBanner(),
                const SizedBox(height: 20),
                _kycCard(),
                const SizedBox(height: 16),
                if (statusError != null) ...[
                  Text(
                    statusError!,
                    style: Typographyy.bodyMediumMedium
                        .copyWith(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  "This form was filled during signup and is now read-only. We refresh the verification status automatically so you can track it here.",
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getGry500_600Color),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          SizedBox(height: width < 600 ? 20 : 80),
          width < 600
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => Get.to(
                          () => const PolicyDetailScreen(
                              policyTitle: 'PRIVACY POLICY'),
                        ),
                        child: Text("Privacy Policy".tr,
                            style: Typographyy.bodyLargeSemiBold
                                .copyWith(color: notifire.getGry600_500Color)),
                      ),
                      Text(
                        "© 2026 Nirvista. All rights reserved. Access subject to eligibility"
                            .tr,
                        style: Typographyy.bodyLargeSemiBold
                            .copyWith(color: notifire.getGry600_500Color),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildImageUi() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              color: priMeryColor,
              height: 935,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 70),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text("Secure Your Account",
                        style: Typographyy.heading2
                            .copyWith(color: containerColor)),
                    Text(
                      'Complete your KYC verification to access all features and ensure your account security. Your data is protected with bank-level encryption.',
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: containerColor.withValues(alpha: 0.7)),
                      textAlign: TextAlign.center,
                    ),
                    const Flexible(
                        child: SizedBox(
                      height: 140,
                    )),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(
                  vertical: 24.0, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  AppLogo(size: 64),
                ],
              ),
            ),
            Positioned(
                right: 0,
                left: 0,
                bottom: 300,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: Image.asset(
                      "assets/images/hero-1-img 2.png",
                      height: 500,
                      width: 500,
                    ))),
            Positioned(
                right: 0,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/images/Group.svg",
                      height: 142,
                      width: 26,
                    ))),
            Positioned(
                bottom: 0,
                child: Container(
                    margin: const EdgeInsets.all(12),
                    child: SvgPicture.asset(
                      "assets/images/Vector.svg",
                      height: 81,
                      width: 81,
                    ))),
          ],
        ),
      ],
    );
  }

  // ---------------- UI COMPONENTS ----------------

  Widget _statusBanner() {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case KycStatus.approved:
        color = Colors.green;
        icon = Icons.verified;
        text = "KYC Approved - Access Granted";
        break;
      case KycStatus.rejected:
        color = Colors.red;
        icon = Icons.cancel;
        text = "KYC Rejected - Please resubmit";
        break;
      default:
        color = Colors.orange;
        icon = Icons.hourglass_top;
        text = "KYC Pending - Verification in progress";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _kycCard() {
    if (isStatusLoading && (kycDetails == null || kycDetails!.isEmpty)) {
      return SizedBox(
        height: 180,
        child: Center(
          child: CircularProgressIndicator(color: notifire.getTextColor),
        ),
      );
    }

    final rows = <Widget>[
      _detailRow("Status".tr, _kycStatusLabel()),
    ];

    final submittedAt = _kycSubmittedAt;
    if (submittedAt != null) {
      rows.add(_detailRow("Submitted On".tr, submittedAt));
    }
    final updatedAt = _kycUpdatedAt;
    if (updatedAt != null && updatedAt != submittedAt) {
      rows.add(_detailRow("Last Updated".tr, updatedAt));
    }
    final reference = _kycReference;
    if (reference != null) {
      rows.add(_detailRow("Reference ID".tr, reference));
    }
    final reason = _kycRejectionReason;
    if (reason != null) {
      rows.add(_detailRow("Rejection Reason".tr, reason));
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "KYC Status".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: notifire.getTextColor,
              ),
            ),
            const SizedBox(height: 16),
            ...rows,
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Typographyy.bodySmallRegular
                  .copyWith(color: notifire.getGry500_600Color),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
        ],
      ),
    );
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
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute';
    } catch (_) {
      return '-';
    }
  }

  String? get _kycSubmittedAt {
    final raw = kycDetails?['submittedAt'] ?? kycDetails?['createdAt'];
    if (raw == null) {
      return null;
    }
    final formatted = _formatDate(raw.toString());
    return formatted == '-' ? null : formatted;
  }

  String? get _kycUpdatedAt {
    final raw = kycDetails?['updatedAt'];
    if (raw == null) {
      return null;
    }
    final formatted = _formatDate(raw.toString());
    return formatted == '-' ? null : formatted;
  }

  String? get _kycReference {
    final ref =
        kycDetails?['referenceId'] ?? kycDetails?['_id'] ?? kycDetails?['id'];
    if (ref == null) {
      return null;
    }
    final text = ref.toString();
    return text.isEmpty ? null : text;
  }

  String? get _kycRejectionReason {
    final reason = kycDetails?['rejectionReason'] ??
        kycDetails?['reason'] ??
        kycDetails?['rejection_reason'];
    if (reason == null) {
      return null;
    }
    final text = reason.toString();
    return text.isEmpty ? null : text;
  }

  String _kycStatusLabel() {
    switch (status) {
      case KycStatus.approved:
        return "Approved".tr;
      case KycStatus.rejected:
        return "Rejected".tr;
      default:
        return isStatusLoading ? "Checking status...".tr : "Pending".tr;
    }
  }

  KycStatus _kycStatusFromString(String raw) {
    switch (raw.toLowerCase()) {
      case 'approved':
        return KycStatus.approved;
      case 'rejected':
        return KycStatus.rejected;
      default:
        return KycStatus.pending;
    }
  }
}
