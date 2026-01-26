import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';
import '../appbarcode.dart';
import '../drawercode.dart';

class WithdrawalPage extends StatefulWidget {
  const WithdrawalPage({super.key});

  @override
  State<WithdrawalPage> createState() => _WithdrawalPageState();
}

class _WithdrawalPageState extends State<WithdrawalPage> {
  ColorNotifire notifire = ColorNotifire();
  final DrawerControllerr _drawerController = Get.put(DrawerControllerr());

  bool isProfileLoading = false;
  String? profileError;
  Map<String, dynamic>? bankDetails;

  bool isWalletLoading = false;
  String? walletError;
  double? availableBalance;

  String status = 'Not Submitted';
  String eta = '-';
  String failureReason = '-';

  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();
  static final RegExp _amountInputRegex = RegExp(r'^\d+(\.\d{0,2})?$');
  final TextInputFormatter _amountFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    return _amountInputRegex.hasMatch(text) ? newValue : oldValue;
  });

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _drawerController.colorSelecter(value: 20);
      }
    });
    _loadProfile();
    _loadWalletSummary();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    amountFocusNode.dispose();
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
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final details = data['bankDetails'];
        if (!mounted) return;
        setState(() {
          bankDetails = details is Map<String, dynamic>
              ? Map<String, dynamic>.from(details)
              : null;
        });
      } else {
        if (!mounted) return;
        setState(() {
          profileError =
              response['message']?.toString() ?? 'Failed to load profile.';
        });
      }
    } catch (_) {
      if (!mounted) return;
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

  Future<void> _loadWalletSummary() async {
    setState(() {
      isWalletLoading = true;
      walletError = null;
    });

    try {
      final response = await AuthApiService.getWalletSummary();
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final parsed = _parseBalance(data);
        if (!mounted) return;
        setState(() {
          availableBalance = parsed;
        });
      } else {
        if (!mounted) return;
        setState(() {
          walletError =
              response['message']?.toString() ?? 'Failed to load balance.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        walletError = 'Failed to load balance.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isWalletLoading = false;
        });
      }
    }
  }

  double? _parseBalance(Map<String, dynamic> data) {
    final candidates = [
      data['availableBalance'],
      data['available_balance'],
      data['balance'],
      data['walletBalance'],
      data['wallet_balance'],
    ];
    for (final value in candidates) {
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  void _submitWithdrawal() {
    final amountText = amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0;

    if (bankDetails == null) {
      setState(() {
        status = 'Failed';
        eta = '-';
        failureReason = 'Add bank details before withdrawing.';
      });
      return;
    }

    if (amount <= 0) {
      setState(() {
        status = 'Failed';
        eta = '-';
        failureReason = 'Enter a valid withdrawal amount.';
      });
      return;
    }

    if (availableBalance != null && amount > availableBalance!) {
      setState(() {
        status = 'Failed';
        eta = '-';
        failureReason = 'Amount exceeds available balance.';
      });
      return;
    }

    setState(() {
      status = 'Processing';
      eta = '1-2 hours';
      failureReason = '-';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Withdrawal submitted for processing.')),
    );
  }

  Widget _stepTile(
      {required int step,
      required String label,
      required bool active,
      required bool done}) {
    final color = done || active ? priMeryColor : notifire.getGry700_300Color;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
          color: active ? colorWithOpacity(priMeryColor, 0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: color,
              child: Text(
                step.toString(),
                style:
                    Typographyy.bodySmallSemiBold.copyWith(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Typographyy.bodySmallMedium
                    .copyWith(color: notifire.getTextColor),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _readonlyRow(String label, String value) {
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

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    final statusColor = status == 'Failed'
        ? Colors.red
        : status == 'Processing'
            ? Colors.orange
            : status == 'Completed'
                ? Colors.green
                : notifire.getGry500_600Color;

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 800) {
        return Scaffold(
          backgroundColor: notifire.getBgColor,
          drawer: const DrawerCode(),
          appBar: const AppBarCode(),
          body: SafeArea(child: _buildBody(statusColor)),
        );
      }
      return Scaffold(
        backgroundColor: notifire.getBgColor,
        body: Row(
          children: [
            const DrawerCode(),
            Expanded(
              child: Column(
                children: [
                  const AppBarCode(),
                  Expanded(
                    child: SafeArea(child: _buildBody(statusColor)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBody(Color statusColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Withdraw Funds",
            style: Typographyy.heading4.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(height: 6),
          Text(
            "Submit a withdrawal request and track its status.",
            style:
                Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _stepTile(
                step: 1,
                label: "Bank & Amount",
                active: status == 'Not Submitted',
                done: status != 'Not Submitted',
              ),
              const SizedBox(width: 12),
              _stepTile(
                step: 2,
                label: "Review",
                active: status == 'Processing',
                done: status == 'Processing' || status == 'Completed',
              ),
              const SizedBox(width: 12),
              _stepTile(
                step: 3,
                label: "Status",
                active: status != 'Not Submitted',
                done: status == 'Completed',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: notifire.getGry700_300Color),
              color: notifire.getContainerColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bank Details",
                  style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),
                ),
                const SizedBox(height: 12),
                if (isProfileLoading)
                  const LinearProgressIndicator()
                else if (profileError != null)
                  Text(
                    profileError!,
                    style: Typographyy.bodyMediumMedium.copyWith(color: Colors.red),
                  )
                else if (bankDetails == null)
                  Text(
                    "No bank details found. Add bank details before withdrawing.",
                    style:
                        Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),
                  )
                else ...[
                  _readonlyRow(
                    "Account holder",
                    bankDetails?['accountHolderName']?.toString() ?? '-',
                  ),
                  _readonlyRow(
                    "Account number",
                    bankDetails?['accountNumber']?.toString() ?? '-',
                  ),
                  _readonlyRow(
                    "IFSC",
                    bankDetails?['ifsc']?.toString() ?? '-',
                  ),
                  _readonlyRow(
                    "Bank name",
                    bankDetails?['bankName']?.toString() ?? '-',
                  ),
                ],
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bankEdit');
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: priMeryColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    "Edit Bank Details",
                    style: Typographyy.bodyMediumSemiBold.copyWith(color: priMeryColor),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                Text(
                  "Withdrawal Amount",
                  style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),
                ),
                const SizedBox(height: 12),
                if (isWalletLoading)
                  const LinearProgressIndicator()
                else if (walletError != null)
                  Text(
                    walletError!,
                    style: Typographyy.bodyMediumMedium.copyWith(color: Colors.red),
                  )
                else
                  Text(
                    availableBalance != null
                        ? "Available balance: ${availableBalance!.toStringAsFixed(2)}"
                        : "Available balance: -",
                    style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  focusNode: amountFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                  autocorrect: false,
                  enableSuggestions: false,
                  inputFormatters: [
                    _amountFormatter,
                  ],
                  decoration: InputDecoration(
                    hintText: "Enter withdrawal amount",
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
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    hintText: "Add a note (optional)",
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitWithdrawal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: priMeryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      fixedSize: const Size.fromHeight(46),
                    ),
                    child: Text(
                      "Submit Withdrawal",
                      style: Typographyy.bodyMediumMedium.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
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
                Text(
                  "Withdrawal Status",
                  style: Typographyy.bodyLargeExtraBold.copyWith(color: notifire.getTextColor),
                ),
                const SizedBox(height: 12),
                _readonlyRow("Status", status),
                _readonlyRow("Processing ETA", eta),
                _readonlyRow("Failure reason", failureReason),
                const SizedBox(height: 8),
                Text(
                  "Status updates will appear here once processing begins.",
                  style: Typographyy.bodySmallMedium.copyWith(color: statusColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}
