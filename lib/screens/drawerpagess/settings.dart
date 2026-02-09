// ignore_for_file: deprecated_member_use

import 'package:file_picker/file_picker.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/dashbordecontroller.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  ColorNotifire notifire = ColorNotifire();
  bool isProfileLoading = false;
  String? profileError;
  Map<String, dynamic>? profileData;
  String kycStatus = 'pending';
  bool isNameSaving = false;
  bool isImageUploading = false;
  String? profileActionMessage;
  int profileTabIndex = 0;
  bool isReferralsLoading = false;
  String? referralsError;
  List<Map<String, dynamic>> referralUsers = [];
  int referralDepth = 0;

  final TextEditingController nameController = TextEditingController();
  bool nameInitialized = false;
  final DrawerControllerr drawerController = Get.put(DrawerControllerr());
  bool _bankDetailsExpanded = false;
  final TextEditingController pinOtpController = TextEditingController();
  final TextEditingController pinNewController = TextEditingController();
  final TextEditingController pinConfirmController = TextEditingController();
  bool pinOtpSent = false;
  bool isSendingPinOtp = false;
  bool isUpdatingPin = false;
  String? pinChangeMessage;
  String? pinChangeError;
  String? pinOtpExpiresAt;
  Map<String, dynamic>? kycDetails;
  bool _isReferralLinkLoading = false;
  String? _referralLinkError;
  String? _referralLink;
  String? _referralCode;
  Map<String, dynamic>? _referralAnalytics;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadReferralDownline();
    _loadKycStatus();
    _loadReferralLink();
  }

  Widget _referralStatCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    String? clipboardValue,
  }) {
    return Container(
      width: 220,
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
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: Typographyy.heading6
                      .copyWith(color: notifire.getTextColor),
                ),
              ),
              if (clipboardValue != null)
                GestureDetector(
                  onTap: () => _copyReferralCode(context, clipboardValue),
                  child: Icon(
                    Icons.copy,
                    size: 18,
                    color: notifire.getGry500_600Color,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color)),
        ],
      ),
    );
  }

  Widget _referralTransactionRow(Map<String, dynamic> tx) {
    final amount = (tx['amount'] as num?)?.toDouble();
    final status = tx['type']?.toString() ??
        tx['status']?.toString() ??
        tx['description']?.toString() ??
        '-';
    final date = _formatReferralDate(tx['createdAt']?.toString());
    final normalizedStatus = (tx['status']?.toString() ?? '').toLowerCase();
    Color badgeColor;
    if (normalizedStatus.contains('success') ||
        normalizedStatus.contains('paid')) {
      badgeColor = const Color(0xFF22C55E);
    } else if (normalizedStatus.contains('fail') ||
        normalizedStatus.contains('decline')) {
      badgeColor = const Color(0xFFEF4444);
    } else {
      badgeColor = const Color(0xFF6366F1);
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notifire.getContainerColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(amount != null ? "INR ${amount.toStringAsFixed(2)}" : "-"),
                const SizedBox(height: 4),
                Text(
                  status,
                  style: Typographyy.bodySmallMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: Typographyy.bodySmallMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorWithOpacity(badgeColor, 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (tx['status']?.toString() ?? 'Pending').toUpperCase(),
              style: Typographyy.bodySmallSemiBold.copyWith(color: badgeColor),
            ),
          ),
        ],
      ),
    );
  }

  void _copyReferralCode(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Referral code copied".tr),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _loadReferralLink() async {
    setState(() {
      _isReferralLinkLoading = true;
      _referralLinkError = null;
    });
    try {
      final response = await AuthApiService.getReferralCode();
      if (response['success'] == true) {
        final payload = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final link = payload['link'] ??
            payload['referralLink'] ??
            payload['url'] ??
            payload['referralUrl'];
        final code = payload['code'] ??
            payload['referralCode'] ??
            payload['referral'] ??
            payload['referral_code'];
        final analyticsSource = payload['analytics'] ??
            payload['stats'] ??
            payload['statistics'];
        Map<String, dynamic>? analytics;
        if (analyticsSource is Map<String, dynamic>) {
          analytics = analyticsSource;
        } else if (analyticsSource is Map) {
          analytics = Map<String, dynamic>.from(analyticsSource);
        }
        if (mounted) {
          setState(() {
            _referralLink = link?.toString();
            _referralCode = code?.toString();
            _referralAnalytics = analytics;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _referralLinkError =
                response['message']?.toString() ?? 'Failed to load referral.';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _referralLinkError = 'Failed to load referral.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isReferralLinkLoading = false;
        });
      }
    }
  }

  void _copyReferral(String value) {
    Clipboard.setData(ClipboardData(text: value));
    _showReferralSnack("Referral copied");
  }

  void _shareReferral(String value) {
    Share.share('Create an account using this link for Nirvista: $value');
    _showReferralSnack("Referral shared");
  }

  Future<void> _openReferralLink(String value) async {
    final uri = Uri.tryParse(value);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showReferralSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.tr),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildReferralShareRow(String? code) {
    final linkValue = (_referralLink?.trim().isNotEmpty ?? false)
        ? _referralLink!
        : null;
    final shareCandidate = (code?.trim().isNotEmpty ?? false)
        ? code!.trim()
        : null;
    final shareValue = linkValue ?? shareCandidate;

    if (_isReferralLinkLoading) {
      return const LinearProgressIndicator();
    }

    if (shareValue == null) {
      final error = _referralLinkError ?? "Referral link not available yet.";
      return Text(
        error.tr,
        style: Typographyy.bodyMediumMedium
            .copyWith(color: notifire.getGry500_600Color),
      );
    }

    final statusText = linkValue != null
        ? "Your referral link is ready."
        : "Your referral code is ready.";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          statusText.tr,
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notifire.getContainerColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: priMeryColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.link, color: priMeryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SelectableText(
                      shareValue,
                      maxLines: 2,
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: notifire.getTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _copyReferral(shareValue),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: priMeryColor),
                        foregroundColor: priMeryColor,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.copy, size: 18),
                      label: Text("Copy link".tr,
                          style: Typographyy.bodyMediumSemiBold
                              .copyWith(color: priMeryColor)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _shareReferral(shareValue),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: notifire.getGry700_300Color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.share, size: 18),
                      label: Text("Share link".tr,
                          style: Typographyy.bodyMediumSemiBold
                              .copyWith(color: notifire.getTextColor)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (linkValue != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openReferralLink(linkValue),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: priMeryColor),
                foregroundColor: priMeryColor,
              ),
              icon: Icon(Icons.open_in_new, color: priMeryColor),
              label: Text(
                "Open link".tr,
                style: Typographyy.bodySmallSemiBold
                    .copyWith(color: priMeryColor),
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatReferralDate(String? date) {
    if (date == null || date.isEmpty) return '-';
    final parsed = DateTime.tryParse(date);
    if (parsed == null) return date;
    return "${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}";
  }

  @override
  void dispose() {
    nameController.dispose();
    pinOtpController.dispose();
    pinNewController.dispose();
    pinConfirmController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isProfileLoading = true;
      profileError = null;
    });

    try {
      final response = await AuthApiService.profile();
      if (response['success'] == true) {
        Map<String, dynamic>? data;
        if (response['data'] is Map<String, dynamic>) {
          data = response['data'] as Map<String, dynamic>;
        } else if (response['name'] != null || response['mobile'] != null) {
          data = response;
        }

        if (data != null) {
        final profileMap = data;
        final verification = profileMap['verification'];
        final rawStatus = verification is Map<String, dynamic>
            ? verification['kycStatus'] ?? verification['status']
            : profileMap['kycStatus'] ?? profileMap['status'];
        final normalizedStatus = _normalizeKycStatus(rawStatus?.toString());
        setState(() {
          profileData = profileMap;
          kycStatus = normalizedStatus;
          final serverName = profileMap['name']?.toString() ?? '';
          if (!nameInitialized || nameController.text != serverName) {
            nameController.text = serverName;
            nameInitialized = true;
          }
        });
        } else {
          setState(() {
            profileError = 'Failed to load profile data.';
          });
        }
      } else {
        setState(() {
          profileError =
              response['message']?.toString() ?? 'Failed to load profile.';
        });
      }
    } catch (_) {
      setState(() {
        profileError = 'Failed to load profile.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isProfileLoading = false;
        });
      }
    }
  }

  Future<void> _loadReferralDownline({int depth = 0}) async {
    setState(() {
      isReferralsLoading = true;
      referralsError = null;
    });

    try {
      final response = await AuthApiService.getReferralDownline(depth: depth);
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final users = data['users'];
        final parsed = <Map<String, dynamic>>[];
        if (users is List) {
          for (final item in users) {
            if (item is Map<String, dynamic>) {
              parsed.add(Map<String, dynamic>.from(item));
            }
          }
        }
        if (mounted) {
          setState(() {
            referralUsers = parsed;
            referralDepth = depth;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            referralsError =
                response['message']?.toString() ?? 'Failed to load referrals.';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          referralsError = 'Failed to load referrals.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isReferralsLoading = false;
        });
      }
    }
  }

  Future<void> _loadKycStatus() async {
    try {
      final response = await AuthApiService.getKycStatus();
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(response['data'] as Map<String, dynamic>)
            : null;
        final rawStatus = data?['status'] ?? data?['kycStatus'];
        final statusValue =
            _normalizeKycStatus(rawStatus?.toString() ?? kycStatus);
        if (!mounted) {
          return;
        }
        setState(() {
          if (data != null) {
            kycDetails = data;
          }
          kycStatus = statusValue.toLowerCase();
        });
      }
    } catch (_) {
      // ignore errors silently for now
    }
  }

  String _normalizeKycStatus(String? raw) {
    if (raw == null) return 'pending';
    final value = raw.toLowerCase();
    if (value.contains('approve') ||
        value.contains('verified') ||
        value.contains('admin_ver') ||
        value.contains('pass') ||
        value.contains('success')) {
      return 'approved';
    }
    if (value.contains('reject') || value.contains('fail')) {
      return 'rejected';
    }
    if (value.contains('pending') ||
        value.contains('review') ||
        value.contains('in_review')) {
      return 'pending';
    }
    return value;
  }

  Color _kycStatusColor() {
    switch (kycStatus) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _kycStatusLabel() {
    if (isProfileLoading) {
      return 'KYC: Loading...';
    }
    switch (kycStatus) {
      case 'approved':
        return 'KYC: Approved';
      case 'rejected':
        return 'KYC: Rejected';
      default:
        return 'KYC: Pending';
    }
  }

  String _kycStatusBannerText() {
    switch (kycStatus) {
      case 'approved':
        return 'KYC Approved - Access Granted';
      case 'rejected':
        return 'KYC Rejected - Please resubmit';
      default:
        return 'KYC Pending - Verification in progress';
    }
  }

  Map<String, dynamic>? get _kycMetadata {
    final raw = kycDetails?['metadata'];
    if (raw is Map<String, dynamic>) {
      return Map<String, dynamic>.from(raw);
    }
    return null;
  }

  String? get _kycRejectionReason {
    final reason = kycDetails?['rejectionReason'] ?? kycDetails?['reason'];
    if (reason == null) {
      return null;
    }
    final text = reason.toString().trim();
    return text.isEmpty ? null : text;
  }

  String _stringValue(Object? value, {String fallback = '-'}) {
    if (value == null) {
      return fallback;
    }
    return value.toString();
  }

  String _formatDateString(String? iso) {
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

  String _boolLabel(Object? value) {
    return value == true ? 'Yes' : 'No';
  }

  bool _isPlaceholderEmail(String? email) {
    if (email == null) {
      return true;
    }
    final trimmed = email.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return true;
    }
    return trimmed.toLowerCase().contains('mobile.local');
  }

  String? _profileImageUrl() {
    final url = profileData?['profileImageUrl']?.toString();
    if (url != null && url.isNotEmpty) {
      return url;
    }
    final fallback = profileData?['selfieUrl']?.toString();
    return (fallback != null && fallback.isNotEmpty) ? fallback : null;
  }

  bool _lockFlag(String key) {
    final locks = profileData?['profileLocks'];
    return locks is Map<String, dynamic> && locks[key] == true;
  }

  Future<void> _saveProfileName() async {
    // Lock name editing if KYC is approved
    if (kycStatus == 'approved') {
      setState(() {
        profileError = 'Profile name cannot be changed after KYC approval.';
        profileActionMessage = null;
      });
      return;
    }

    if (_lockFlag('name')) {
      setState(() {
        profileError = 'Profile name is locked and cannot be changed.';
        profileActionMessage = null;
      });
      return;
    }

    final name = nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        profileError = 'Please enter your name.';
        profileActionMessage = null;
      });
      return;
    }

    setState(() {
      isNameSaving = true;
      profileError = null;
      profileActionMessage = null;
    });

    try {
      final response = await AuthApiService.updateProfileName(name: name);
      if (response['success'] == true) {
        setState(() {
          profileActionMessage = 'Name updated successfully.';
        });
        await _loadProfile();
      } else {
        setState(() {
          profileError =
              response['message']?.toString() ?? 'Failed to update name.';
        });
      }
    } catch (_) {
      setState(() {
        profileError = 'Failed to update name.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isNameSaving = false;
        });
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_lockFlag('profileImage')) {
      return;
    }
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (!mounted || result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.first;
    setState(() {
      isImageUploading = true;
      profileError = null;
      profileActionMessage = null;
    });

    try {
      final response = await AuthApiService.uploadProfileImage(
        filename: file.name,
        bytes: file.bytes,
        filePath: file.path,
      );
      if (response['success'] == true) {
        setState(() {
          profileActionMessage = 'Profile image updated.';
        });
        await _loadProfile();
      } else {
        setState(() {
          profileError = response['message']?.toString() ??
              'Failed to upload profile image.';
        });
      }
    } catch (_) {
      setState(() {
        profileError = 'Failed to upload profile image.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isImageUploading = false;
        });
      }
    }
  }

  Future<void> _openBankDetails() async {
    drawerController.function(value: -1);
    drawerController.colorSelecter(value: 19);
    final shouldRefresh = await Navigator.pushNamed(context, '/bankDetails');
    if (shouldRefresh == true && mounted) {
      _loadProfile();
    }
  }

  void _openWithdrawal() {
    drawerController.function(value: -1);
    drawerController.colorSelecter(value: 20);
    Navigator.pushNamed(context, '/withdrawal');
  }

  Widget _profileTabButton({required String label, required int index}) {
    final isActive = profileTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          profileTabIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: isActive ? priMeryColor : notifire.getGry700_300Color),
          color: isActive
              ? priMeryColor.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Center(
          child: Text(
            label,
            style: Typographyy.bodyMediumMedium.copyWith(
              color: isActive ? priMeryColor : notifire.getTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _outlinedInput({
    required TextEditingController controller,
    required String label,
    bool enabled = true,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Typographyy.bodyMediumMedium
            .copyWith(color: notifire.getGry500_600Color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifire.getGry700_300Color),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifire.getGry700_300Color),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: notifire.getGry700_300Color),
        ),
      ),
    );
  }

  Widget _detailRow({required String label, required String value}) {
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

  List<Widget> _bankDetailRows(Map<String, dynamic> data) {
    return [
      _detailRow(
        label: "Account holder",
        value: data['accountHolderName']?.toString() ?? '-',
      ),
      _detailRow(
        label: "Account number",
        value: data['accountNumber']?.toString() ?? '-',
      ),
      _detailRow(
        label: "IFSC",
        value: data['ifsc']?.toString() ?? '-',
      ),
      _detailRow(
        label: "Bank name",
        value: data['bankName']?.toString() ?? '-',
      ),
      const SizedBox(height: 12),
      Divider(color: notifire.getGry700_300Color),
      const SizedBox(height: 12),
      _detailRow(
        label: "Added By",
        value: data['addedBy']?.toString() ??
            data['createdBy']?.toString() ??
            'User',
      ),
      _detailRow(
        label: "Verified By",
        value: data['verifiedBy']?.toString() ??
            (data['isVerified'] == true ? 'Admin' : 'Pending'),
      ),
    ];
  }

  int _referralLevel(Map<String, dynamic> user) {
    final levelValue = user['referralLevel'];
    if (levelValue is num) {
      return levelValue.toInt();
    }
    return int.tryParse(levelValue?.toString() ?? '') ?? 0;
  }

  String _referralName(Map<String, dynamic> user) {
    final rawName = user['name']?.toString() ?? '';
    return rawName.trim().isNotEmpty ? rawName : 'Unknown';
  }

  List<Map<String, dynamic>> _sortedReferralUsers() {
    final users = List<Map<String, dynamic>>.from(referralUsers);
    users.sort((a, b) {
      final levelA = _referralLevel(a);
      final levelB = _referralLevel(b);
      if (levelA != levelB) {
        return levelA.compareTo(levelB);
      }
      final nameA = _referralName(a).toLowerCase();
      final nameB = _referralName(b).toLowerCase();
      return nameA.compareTo(nameB);
    });
    return users;
  }

  Widget _buildReferralLevelHeader(int level) {
    final displayLevel = level + 1;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: notifire.getGry700_300Color),
              color: notifire.getGry50_800Color,
            ),
            child: Text(
              'Level $displayLevel',
              style: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildReferralTreeList() {
    final users = _sortedReferralUsers();
    final widgets = <Widget>[];
    int? currentLevel;
    for (final user in users) {
      final level = _referralLevel(user);
      if (currentLevel != level) {
        widgets.add(_buildReferralLevelHeader(level));
        currentLevel = level;
      }
      final indent = level > 0 ? 18.0 * level : 0.0;
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: indent),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  color: priMeryColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _referralName(user),
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getTextColor),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: notifire.getBgColor,
      child: DefaultTabController(
        length: 6,
        initialIndex: 0,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverToBoxAdapter(
                        child: _buildTabBar(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 25,
                        ),
                      ),
                    ];
                  },
                  body: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: TabBarView(children: [
                    _tabContent(_buildUser(width: constraints.maxWidth)),
                    _tabContent(_buildReferrals(width: constraints.maxWidth)),
                    _tabContent(_buildApi(width: constraints.maxWidth)),
                    _tabContent(_build2SF(width: constraints.maxWidth)),
                    _tabContent(_buildKycSection()),
                    _tabContent(_buildHelpSection()),
                    ]),
                  ));
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  children: [
                    _buildTabBar(),
                    const SizedBox(
                      height: 25,
                    ),
                    Expanded(
                      child: TabBarView(children: [
                        _tabContent(_buildUser(width: constraints.maxWidth)),
                        _tabContent(
                            _buildReferrals(width: constraints.maxWidth)),
                        _tabContent(_buildApi(width: constraints.maxWidth)),
                        _tabContent(_build2SF(width: constraints.maxWidth)),
                        _tabContent(_buildKycSection()),
                        _tabContent(_buildHelpSection()),
                      ]),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _tabContent(Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      physics: const AlwaysScrollableScrollPhysics(),
      primary: false,
      dragStartBehavior: DragStartBehavior.down,
      child: Column(
        children: [
          child,
          const SizedBox(height: 16),
          _staticSlider(),
        ],
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

  Widget _buildUser({required double width}) {
    final name = profileData?['name']?.toString() ?? 'Your Name';
    final email = profileData?['email']?.toString() ?? '';
    final showEmail = !_isPlaceholderEmail(email);
    final mobile = profileData?['mobile']?.toString() ?? '-';
    final country = profileData?['country']?.toString() ?? '-';
    final profileImageUrl = _profileImageUrl();
    final verification = profileData?['verification'];
    final emailVerified =
        verification is Map<String, dynamic> && verification['email'] == true;
    final mobileVerified =
        verification is Map<String, dynamic> && verification['mobile'] == true;
    final accountLevel = profileData?['accountLevel'];
    final accountLevelText = accountLevel is Map<String, dynamic>
        ? 'Level ${accountLevel['level'] ?? '-'} (${accountLevel['status'] ?? '-'})'
        : '-';
    final wallets = profileData?['wallets'];
    final bankDetails = profileData?['bankDetails'];
    final bankDetailsMap = bankDetails is Map<String, dynamic>
        ? Map<String, dynamic>.from(bankDetails)
        : null;
    final nameLocked = _lockFlag('name');
    final imageLocked = _lockFlag('profileImage');

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            width: 800,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: notifire.getContainerColor,
                      backgroundImage: (profileImageUrl != null &&
                              profileImageUrl.isNotEmpty)
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child:
                          (profileImageUrl == null || profileImageUrl.isEmpty)
                              ? Icon(Icons.person,
                                  color: notifire.getGry500_600Color)
                              : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: Typographyy.heading5
                                .copyWith(color: notifire.getTextColor),
                          ),
                          if (showEmail) ...[
                            const SizedBox(height: 6),
                            Text(
                              email,
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            mobile,
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: _kycStatusColor()),
                              color: _kycStatusColor().withValues(alpha: 0.1),
                            ),
                            child: Text(
                              _kycStatusLabel(),
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: _kycStatusColor()),
                            ),
                          )
                        ],
                      ),
                    ),
                    width < 600 ? const SizedBox() : const Spacer(),
                    width < 600
                        ? const SizedBox()
                        : Container(
                            height: 42,
                            width: 160,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: notifire.getContainerColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  country,
                                  style: Typographyy.bodyMediumMedium.copyWith(
                                      color: notifire.getGry500_600Color),
                                ),
                                const Spacer(),
                                SvgPicture.asset(
                                  "assets/images/chevron-down.svg",
                                  height: 20,
                                  width: 20,
                                ),
                              ],
                            ),
                          ),
                  ],
                ),
                if (isProfileLoading) ...[
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(),
                ],
                if (profileError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    profileError!,
                    style: Typographyy.bodyMediumMedium
                        .copyWith(color: Colors.red),
                  ),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _profileTabButton(label: "Profile", index: 0),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _profileTabButton(label: "Bank Details", index: 1),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (profileTabIndex == 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Profile Settings",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: notifire.getGry700_300Color),
                    ),
                    child: Column(
                      children: [
                        _outlinedInput(
                          controller: nameController,
                          label: kycStatus == 'approved'
                              ? "Name (Locked - KYC Approved)"
                              : "Name",
                          enabled: !nameLocked && kycStatus != 'approved',
                        ),
                        if (kycStatus == 'approved') ...[
                          const SizedBox(height: 8),
                          Text(
                            "Name cannot be changed after KYC approval",
                            style: Typographyy.bodySmallMedium
                                .copyWith(color: notifire.getGry500_600Color),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: (nameLocked ||
                                        isNameSaving ||
                                        kycStatus == 'approved')
                                    ? null
                                    : _saveProfileName,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: priMeryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  fixedSize: const Size.fromHeight(44),
                                ),
                                child: isNameSaving
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        nameLocked ? "Name Locked" : "Save",
                                        style: Typographyy.bodyMediumMedium
                                            .copyWith(color: Colors.white),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: imageLocked || isImageUploading
                                    ? null
                                    : _uploadProfileImage,
                                icon: Icon(
                                  imageLocked ? Icons.lock : Icons.upload_file,
                                ),
                                label: Text(
                                  imageLocked ? "Image Locked" : "Upload Photo",
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (profileActionMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            profileActionMessage!,
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: priMeryColor),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Your Details",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: notifire.getGry700_300Color),
                    ),
                    child: Column(
                      children: [
                        _detailRow(label: "Name", value: name),
                        if (showEmail) _detailRow(label: "Email", value: email),
                        _detailRow(label: "Mobile", value: mobile),
                        _detailRow(label: "Country", value: country),
                        _detailRow(
                            label: "Account Level", value: accountLevelText),
                        if (showEmail)
                          _detailRow(
                              label: "Email Verified",
                              value: _boolLabel(emailVerified)),
                        _detailRow(
                            label: "Mobile Verified",
                            value: _boolLabel(mobileVerified)),
                        _detailRow(label: "KYC Status", value: kycStatus),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Wallets",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: notifire.getGry700_300Color),
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          label: "Token Balance",
                          value: _stringValue(wallets is Map<String, dynamic>
                              ? wallets['token']
                              : null),
                        ),
                        _detailRow(
                          label: "Referral Balance",
                          value: _stringValue(wallets is Map<String, dynamic>
                              ? wallets['referral']
                              : null),
                        ),
                        _detailRow(
                          label: "Rewards Balance",
                          value: _stringValue(wallets is Map<String, dynamic>
                              ? wallets['rewards']
                              : null),
                        ),
                      ],
                    ),
                  ),
                ],
                if (profileTabIndex == 1) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Bank Details",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: notifire.getGry700_300Color),
                      color: notifire.getContainerColor,
                    ),
                    child: bankDetailsMap == null
                        ? Text(
                            "No bank details added.",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getGry500_600Color),
                          )
                        : ExpansionTile(
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _bankDetailsExpanded = expanded;
                              });
                            },
                            initiallyExpanded: _bankDetailsExpanded,
                            title: Text(
                              "Tap to view details",
                              style: Typographyy.bodyMediumMedium.copyWith(
                                color: notifire.getTextColor,
                              ),
                            ),
                            subtitle: Text(
                              "Account holder - ${bankDetailsMap['accountNumber']?.toString() ?? '-'}",
                              style: Typographyy.bodySmallMedium.copyWith(
                                color: notifire.getGry500_600Color,
                              ),
                            ),
                            children: _bankDetailRows(bankDetailsMap),
                          ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bank Actions",
                    style: Typographyy.heading5
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Open the dedicated screens for bank edits and withdrawals.",
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton(
                        onPressed: _openBankDetails,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: priMeryColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          "Bank Details",
                          style: Typographyy.bodyMediumSemiBold
                              .copyWith(color: priMeryColor),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _openWithdrawal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priMeryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          "Withdraw Funds",
                          style: Typographyy.bodyMediumSemiBold
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferrals({required double width}) {
    final dash = DashBordeController.shared;
    final referrals = dash.allTransactions
        .where((tx) =>
            (tx['category']?.toString() ?? '').toLowerCase() == 'referral')
        .toList();
    final totalEarnings = referrals.fold<double>(
        0,
        (sum, tx) =>
            sum +
            ((tx['amount'] is num) ? (tx['amount'] as num).toDouble() : 0));
    final withdrawable = dash.referralWalletBalance ?? 0;
    final profileCode = profileData?['referralCode']?.toString();
    final code = (_referralCode?.trim().isEmpty ?? true)
        ? (profileCode?.trim().isEmpty ?? true ? null : profileCode)
        : _referralCode;
    final referralCount = referralUsers.length;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Referral overview",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getTextColor),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          final drawerController =
                              Get.isRegistered<DrawerControllerr>()
                                  ? Get.find<DrawerControllerr>()
                                  : null;
                          drawerController?.colorSelecter(value: 13);
                          drawerController?.function(value: -1);
                          Navigator.pushNamed(context, '/transactions');
                        },
                        child: Text(
                          "View transactions".tr,
                          style: Typographyy.bodySmallSemiBold
                              .copyWith(color: priMeryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _referralStatCard(
                        context,
                        title: "Referral code",
                        value: code?.trim().isEmpty ?? true ? '-' : code!,
                        subtitle: "Share this with friends",
                        clipboardValue: code,
                      ),
                      _referralStatCard(
                        context,
                        title: "Referrals",
                        value: referralCount.toString(),
                        subtitle: "Downline members tracked",
                      ),
                      _referralStatCard(
                        context,
                        title: "Total earnings",
                        value: "INR ${totalEarnings.toStringAsFixed(2)}",
                        subtitle: "Commissions total",
                      ),
                      _referralStatCard(
                        context,
                        title: "Withdrawable",
                        value: "INR ${withdrawable.toStringAsFixed(2)}",
                        subtitle: "Available balance",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildReferralCommissionCards(),
                  const SizedBox(height: 16),
                  _buildReferralShareRow(code),
                  const SizedBox(height: 16),
                  _buildReferralAnalyticsCards(),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    "Referral Tree",
                    style: Typographyy.heading5
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Downline members grouped by level.",
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                  const SizedBox(height: 16),
                  if (isReferralsLoading) ...[
                    const LinearProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(
                      "Loading downline...",
                      style: Typographyy.bodySmallMedium
                          .copyWith(color: notifire.getGry500_600Color),
                    ),
                  ] else if (referralsError != null) ...[
                    Text(
                      referralsError!,
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: Colors.red),
                    ),
                  ] else if (referralUsers.isEmpty) ...[
                    Text(
                      "No downline users yet.",
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: notifire.getGry500_600Color),
                    ),
                  ] else ...[
                    ..._buildReferralTreeList(),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Text(
                        "Referral transaction history",
                        style: Typographyy.heading5
                            .copyWith(color: notifire.getTextColor),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          final drawerController =
                              Get.isRegistered<DrawerControllerr>()
                                  ? Get.find<DrawerControllerr>()
                                  : null;
                          drawerController?.colorSelecter(value: 13);
                          drawerController?.function(value: -1);
                          Navigator.pushNamed(context, '/transactions');
                        },
                        child: Text(
                          "See all".tr,
                          style: Typographyy.bodySmallSemiBold
                              .copyWith(color: priMeryColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (referrals.isEmpty)
                    Text(
                      "No referral transactions yet.",
                      style: Typographyy.bodyMediumMedium
                          .copyWith(color: notifire.getGry500_600Color),
                    )
                  else
                    Column(
                      children: referrals
                          .take(5)
                          .map(_referralTransactionRow)
                          .toList(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReferralAnalyticsCards() {
    final metrics = [
      {'label': 'Click-throughs', 'key': 'clicks'},
      {'label': 'Conversions', 'key': 'conversions'},
      {'label': 'Rewards', 'key': 'rewards'},
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: metrics.map((metric) {
        final value = _formatReferralMetric(metric['key']!);
        return Container(
          width: 170,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifire.getGry700_300Color),
            color: notifire.getContainerColor,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(metric['label']!,
                  style: Typographyy.bodySmallMedium
                      .copyWith(color: notifire.getGry500_600Color)),
              const SizedBox(height: 8),
              Text(
                value,
                style: Typographyy.heading6
                    .copyWith(color: notifire.getTextColor),
              ),
              const SizedBox(height: 6),
              Text(
                "Track clicks, conversions, and rewards".tr,
                style: Typographyy.bodySmallMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatReferralMetric(String key) {
    final value = _referralAnalytics?[key];
    if (value is num) {
      if (value == value.roundToDouble()) {
        return value.toInt().toString();
      }
      return value.toStringAsFixed(2);
    }
    if (value is String && value.isNotEmpty) {
      return value;
    }
    return '0';
  }

  Widget _buildReferralCommissionCards() {
    final entries = [
      {
        'title': 'Direct Commission',
        'detail': 'Earn 5% from friends you refer.',
        'icon': Icons.link,
        'color': const Color(0xFF2A6BCB),
      },
      {
        'title': 'Team Build',
        'detail': 'Get 2% from your network’s transactions.',
        'icon': Icons.group_add,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Growth Bonus',
        'detail': 'Tiered rewards for sustained referrals.',
        'icon': Icons.emoji_events,
        'color': const Color(0xFFF97316),
      },
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: entries.map((entry) {
        return Container(
          width: 220,
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
                  Icon(entry['icon'] as IconData,
                      color: entry['color'] as Color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry['title'] as String,
                      style: Typographyy.bodyMediumSemiBold.copyWith(
                          color: notifire.getTextColor),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                entry['detail'] as String,
                style: Typographyy.bodySmallMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Future<void> _sendPinChangeOtp() async {
    setState(() {
      isSendingPinOtp = true;
      pinChangeError = null;
      pinChangeMessage = null;
    });
    try {
      final response = await AuthApiService.initiatePinChange();
      final message =
          response['message']?.toString() ?? 'OTP request has been sent.';
      if (response['success'] == true) {
        setState(() {
          pinOtpSent = true;
          pinOtpExpiresAt = response['expiresAt']?.toString();
          pinChangeMessage = message;
          pinChangeError = null;
        });
      } else {
        setState(() {
          pinOtpSent = false;
          pinChangeMessage = null;
          pinChangeError = message;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        pinOtpSent = false;
        pinChangeError = 'Unable to send OTP. Please try again.';
        pinChangeMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          isSendingPinOtp = false;
        });
      }
    }
  }

  Future<void> _confirmPinChange() async {
    final otp = pinOtpController.text.trim();
    final newPin = pinNewController.text.trim();
    final confirmPin = pinConfirmController.text.trim();
    if (!pinOtpSent) {
      setState(() {
        pinChangeError = 'Request an OTP before updating your PIN.';
        pinChangeMessage = null;
      });
      return;
    }
    if (otp.isEmpty || newPin.isEmpty || confirmPin.isEmpty) {
      setState(() {
        pinChangeError = 'Please fill in all PIN fields.';
        pinChangeMessage = null;
      });
      return;
    }
    if (newPin != confirmPin) {
      setState(() {
        pinChangeError = 'New PIN and confirmation must match.';
        pinChangeMessage = null;
      });
      return;
    }
    if (newPin.length < 4 || confirmPin.length < 4) {
      setState(() {
        pinChangeError = 'PIN must be at least 4 digits.';
        pinChangeMessage = null;
      });
      return;
    }
    setState(() {
      isUpdatingPin = true;
      pinChangeError = null;
      pinChangeMessage = null;
    });
    try {
      final response = await AuthApiService.confirmPinChange(
        otp: otp,
        newPin: newPin,
        confirmPin: confirmPin,
      );
      final message =
          response['message']?.toString() ?? 'PIN updated successfully.';
      if (response['success'] == true) {
        setState(() {
          pinChangeMessage = message;
          pinChangeError = null;
          pinOtpSent = false;
          pinOtpExpiresAt = null;
          pinOtpController.clear();
          pinNewController.clear();
          pinConfirmController.clear();
        });
        if (mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          });
        }
      } else {
        setState(() {
          pinChangeError = message;
          pinChangeMessage = null;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        pinChangeError = 'Unable to update PIN. Please try again later.';
        pinChangeMessage = null;
      });
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingPin = false;
        });
      }
    }
  }

  Widget _build2SF({required double width}) {
    final mobileDisplay = _stringValue(profileData?['mobile']);
    final statusText = pinOtpSent
        ? 'OTP sent to $mobileDisplay${pinOtpExpiresAt != null ? ' · expires at $pinOtpExpiresAt' : ''}'
        : 'Send an OTP to $mobileDisplay before updating your PIN.';
    final statusColor = pinOtpSent ? Colors.green : notifire.getGry500_600Color;
    Widget sendButton = ElevatedButton(
      onPressed: isSendingPinOtp ? null : _sendPinChangeOtp,
      style: ElevatedButton.styleFrom(
        backgroundColor: priMeryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: const Size.fromHeight(48),
        elevation: 0,
      ),
      child: isSendingPinOtp
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Text(
              "Send OTP",
              style: Typographyy.bodyMediumMedium.copyWith(color: Colors.white),
            ),
    );
    Widget updateButton = ElevatedButton(
      onPressed: isUpdatingPin || !pinOtpSent ? null : _confirmPinChange,
      style: ElevatedButton.styleFrom(
        backgroundColor: priMeryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: const Size.fromHeight(48),
        elevation: 0,
      ),
      child: isUpdatingPin
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white),
            )
          : Text(
              "Update PIN",
              style: Typographyy.bodyMediumMedium.copyWith(color: Colors.white),
            ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Change PIN",
                    style: Typographyy.heading5
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Verify via OTP and update your transaction PIN securely.",
                    style: Typographyy.bodySmallRegular
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Registered mobile: $mobileDisplay",
                    style: Typographyy.bodySmallRegular
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    statusText,
                    style: Typographyy.bodySmallMedium
                        .copyWith(color: statusColor),
                  ),
                  if (pinChangeError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      pinChangeError!,
                      style: Typographyy.bodySmallRegular
                          .copyWith(color: Colors.red),
                    ),
                  ],
                  if (pinChangeMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      pinChangeMessage!,
                      style: Typographyy.bodySmallRegular
                          .copyWith(color: Colors.green),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _buildPinTextField(
                    label: "OTP",
                    hint: "Enter the OTP",
                    controller: pinOtpController,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  _buildPinTextField(
                    label: "New PIN",
                    hint: "Enter new PIN",
                    controller: pinNewController,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 16),
                  _buildPinTextField(
                    label: "Confirm PIN",
                    hint: "Re-enter new PIN",
                    controller: pinConfirmController,
                    maxLength: 6,
                  ),
                  const SizedBox(height: 24),
                  width < 520
                      ? Column(
                          children: [
                            SizedBox(width: double.infinity, child: sendButton),
                            const SizedBox(height: 12),
                            SizedBox(
                                width: double.infinity, child: updateButton),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: sendButton),
                            const SizedBox(width: 12),
                            Expanded(child: updateButton),
                          ],
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApi({required double width}) {
    final username = profileData?['username']?.toString() ??
        profileData?['email']?.toString() ??
        '-';
    const clientId = '**************';
    const clientSecret = '***************';
    Widget sendButton = ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        fixedSize: const Size.fromHeight(48),
        elevation: 0,
        backgroundColor: priMeryColor,
      ),
      child: Text(
        "API key generation is currently not available on your account",
        style: Typographyy.bodySmallMedium.copyWith(color: Colors.white),
        textAlign: TextAlign.center,
      ),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            width: 600,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "API Access is Disabled",
                  style: Typographyy.heading5
                      .copyWith(color: notifire.getTextColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Generate API keys from this section to integrate into your own system.",
                  style: Typographyy.bodySmallRegular
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(height: 12),
                Text(
                  "API Access is Disabled",
                  style: Typographyy.bodySmallMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(height: 24),
                _buildApiField(label: "Show Username", value: username),
                const SizedBox(height: 16),
                _buildApiField(label: "Client ID", value: clientId),
                const SizedBox(height: 16),
                _buildApiField(label: "Client Secret", value: clientSecret),
                const SizedBox(height: 24),
                width < 520
                    ? SizedBox(width: double.infinity, child: sendButton)
                    : Row(
                        children: [
                          Expanded(child: sendButton),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKycSection() {
    final metadata = _kycMetadata;
    final submittedAtValue = kycDetails?['submittedAt']?.toString() ??
        kycDetails?['createdAt']?.toString();
    final submittedOn =
        submittedAtValue != null ? _formatDateString(submittedAtValue) : null;
    final hasSubmissionInfo = (submittedOn != null && submittedOn != '-') ||
        (metadata != null && metadata.isNotEmpty) ||
        (_kycRejectionReason != null);
    final statusMessage = _kycStatusMessage();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "KYC Verification",
              style:
                  Typographyy.heading5.copyWith(color: notifire.getTextColor),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message:
                  "Your documents were collected during signup and cannot be updated here.",
              child: Icon(Icons.info_outline,
                  color: notifire.getGry500_600Color, size: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifire.getGry700_300Color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _kycStatusBanner(),
              const SizedBox(height: 16),
              if (hasSubmissionInfo) ...[
                _kycSubmissionSummary(
                  submittedOn ?? '-',
                  metadata,
                  _kycRejectionReason,
                ),
                const SizedBox(height: 12),
              ],
              if (statusMessage != null) ...[
                statusMessage,
                const SizedBox(height: 12),
              ],
              Text(
                "KYC verification updates happen automatically after signup. Contact support if you need to make changes.",
                style: Typographyy.bodySmallRegular
                    .copyWith(color: notifire.getGry500_600Color),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifire.getGry700_300Color),
                ),
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings,
                        color: priMeryColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "KYC approvals go through our admin compliance dashboard; reach out for admin updates if needed.",
                        style: Typographyy.bodySmallRegular
                            .copyWith(color: notifire.getGry500_600Color),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kycStatusBanner() {
    final color = _kycStatusColor();
    final icon = kycStatus == 'approved'
        ? Icons.verified
        : kycStatus == 'rejected'
            ? Icons.cancel
            : Icons.hourglass_top;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _kycStatusBannerText(),
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          )
        ],
      ),
    );
  }

  Widget? _kycStatusMessage() {
    switch (kycStatus) {
      case 'approved':
        return Text(
          "KYC verified and validated by admin.",
          style:
              Typographyy.bodySmallRegular.copyWith(color: Colors.green),
        );
      case 'pending':
        return Text(
          "Documents are under review. Admin will respond shortly.",
          style: Typographyy.bodySmallRegular
              .copyWith(color: notifire.getGry500_600Color),
        );
      case 'rejected':
        return Text(
          "Please correct the highlighted issues and resubmit.",
          style: Typographyy.bodySmallRegular.copyWith(color: Colors.red),
        );
      default:
        return null;
    }
  }

  Widget _kycSubmissionSummary(
    String submittedOn,
    Map<String, dynamic>? metadata,
    String? rejectionReason,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Submission Details",
          style: Typographyy.bodyLargeSemiBold
              .copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 12),
        _detailRow(label: "Submitted On", value: submittedOn),
        if (metadata != null) ...[
          const SizedBox(height: 6),
          _detailRow(
            label: "PAN Number",
            value: _stringValue(metadata['panNumber']),
          ),
          const SizedBox(height: 6),
          _detailRow(
            label: "Aadhaar Number",
            value: _stringValue(metadata['aadhaarNumber']),
          ),
        ],
        if (rejectionReason != null) ...[
          const SizedBox(height: 6),
          _detailRow(label: "Rejection Reason", value: rejectionReason),
        ],
      ],
    );
  }

  Widget _buildPinTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLength = 6,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Typographyy.bodySmallMedium
                .copyWith(color: notifire.getTextColor)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          maxLength: maxLength,
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getTextColor),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getGry500_600Color),
            counterText: '',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color)),
            disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color)),
          ),
        ),
      ],
    );
  }

  Widget _buildApiField({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Typographyy.bodySmallMedium
                .copyWith(color: notifire.getTextColor)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifire.getGry700_300Color),
            color: notifire.getBgColor,
          ),
        child: Text(
          value,
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ),
    ],
  );
}

  Future<void> _launchSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@nirvista.in',
      queryParameters: {'subject': 'Nirvista Support'},
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 15,
          ),
          SizedBox(
            height: 50,
            width: 700,
            child: TabBar(
                labelStyle: Typographyy.bodyMediumMedium
                    .copyWith(color: notifire.getTextColor),
                isScrollable: true,
                indicatorColor: priMeryColor,
                labelColor: priMeryColor,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: priMeryColor),
                ),
                unselectedLabelColor: notifire.getTextColor,
                tabs: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/user.svg",
                            height: 20,
                            width: 20,
                            color: notifire.getTextColor),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(
                          width: 8,
                        ),
                        Text("Profile",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/share.svg",
                            height: 20,
                            width: 20,
                            color: notifire.getTextColor),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(
                          width: 8,
                        ),
                        Text("Refrrals",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset("assets/images/keyboard.svg",
                            height: 20,
                            width: 20,
                            color: notifire.getTextColor),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(
                          width: 8,
                        ),
                        Text("Api Keys",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                            "assets/images/fingerprint-viewfinder.svg",
                            height: 20,
                            width: 20,
                            color: notifire.getTextColor),
                        // Icon(Icons.supervisor_account),
                        const SizedBox(
                          width: 8,
                        ),
                        Text("Change PIN",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user,
                            color: notifire.getTextColor, size: 20),
                        const SizedBox(width: 8),
                        Text("KYC",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.support_agent,
                            color: notifire.getTextColor, size: 20),
                        const SizedBox(width: 8),
                        Text("Support",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: notifire.getTextColor)),
                      ],
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection() {
    final contactItems = [
      {'label': 'Email', 'value': 'support@nirvista.in'},
      {'label': 'Phone', 'value': '97656 53615'},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            width: 700,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Get Help & Support",
                  style: Typographyy.heading5
                      .copyWith(color: notifire.getTextColor),
                ),
                const SizedBox(height: 8),
                Text(
                  "Need help with KYC, payments, API keys, or approvals? Visit the Get Help hub or connect with support.",
                  style: Typographyy.bodySmallMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: contactItems
                      .map(
                        (item) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border:
                                Border.all(color: notifire.getGry700_300Color),
                            color: notifire.getContainerColor,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "${item['label']}: ",
                                style: Typographyy.bodySmallSemiBold
                                    .copyWith(color: notifire.getTextColor),
                              ),
                              Text(
                                item['value']!,
                                style: Typographyy.bodySmallMedium
                                    .copyWith(color: priMeryColor),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/getHelp');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priMeryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: const Size.fromHeight(48),
                        ),
                        child: Text("Open Get Help".tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _launchSupportEmail,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: priMeryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          fixedSize: const Size.fromHeight(48),
                        ),
                        child: Text("Email Support".tr),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notifire.getContainerColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: notifire.getGry700_300Color),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.admin_panel_settings,
                          color: priMeryColor, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Admin approvals and KYC reviews run through the compliance dashboard; reach out if you need an expedited update.",
                          style: Typographyy.bodySmallMedium
                              .copyWith(color: notifire.getGry500_600Color),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
