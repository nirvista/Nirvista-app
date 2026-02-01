import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';

class BankEditPage extends StatefulWidget {
  final String? otp;

  const BankEditPage({super.key, this.otp});

  @override
  State<BankEditPage> createState() => _BankEditPageState();
}

class _BankEditPageState extends State<BankEditPage> {
  ColorNotifire notifire = ColorNotifire();
  final DrawerControllerr _drawerController = Get.put(DrawerControllerr());

  bool isProfileLoading = false;
  String? profileError;
  Map<String, dynamic>? bankDetails;

  bool isSaving = false;
  String? saveMessage;
  String? saveError;

  final TextEditingController holderController = TextEditingController();
  final TextEditingController accountController = TextEditingController();
  final TextEditingController ifscController = TextEditingController();
  final TextEditingController bankNameController = TextEditingController();

  bool get _hasValidOtp =>
      (widget.otp?.trim().length ?? 0) == 6;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _drawerController.colorSelecter(value: 19);
      }
    });
    _loadProfile();
  }

  @override
  void dispose() {
    holderController.dispose();
    accountController.dispose();
    ifscController.dispose();
    bankNameController.dispose();
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
        final detailsMap = details is Map<String, dynamic>
            ? Map<String, dynamic>.from(details)
            : null;
        if (!mounted) return;
        setState(() {
          bankDetails = detailsMap;
          holderController.text =
              detailsMap?['accountHolderName']?.toString() ?? '';
          accountController.text =
              detailsMap?['accountNumber']?.toString() ?? '';
          ifscController.text = detailsMap?['ifsc']?.toString() ?? '';
          bankNameController.text =
              detailsMap?['bankName']?.toString() ?? '';
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

  void _openBankOtp() {
    _drawerController.function(value: -1);
    _drawerController.colorSelecter(value: 19);
    Navigator.pushNamed(context, '/bankEditOtp');
  }

  void _returnToProfileAfterSave() {
    final navigator = Navigator.of(context);
    bool reachedDetails = false;
    navigator.popUntil((route) {
      if (route.settings.name == '/bankDetails') {
        reachedDetails = true;
        return true;
      }
      return route.isFirst;
    });
    if (reachedDetails) {
      navigator.pop(true);
    } else if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Future<void> _saveBankDetails() async {
    final holder = holderController.text.trim();
    final account = accountController.text.trim();
    final ifsc = ifscController.text.trim();
    final bankName = bankNameController.text.trim();
    final otpCode = widget.otp?.trim() ?? '';

    if (!_hasValidOtp) {
      setState(() {
        saveError = 'Verify OTP before saving.';
        saveMessage = null;
      });
      return;
    }

    final validationError = _validateBankForm(
      holder: holder,
      account: account,
      ifsc: ifsc,
      bankName: bankName,
    );
    if (validationError != null) {
      setState(() {
        saveError = validationError;
        saveMessage = null;
      });
      return;
    }

    setState(() {
      isSaving = true;
      saveError = null;
      saveMessage = null;
    });

    try {
      final response = await AuthApiService.addBankDetails(
        accountHolderName: holder,
        accountNumber: account,
        ifsc: ifsc,
        bankName: bankName,
        otp: otpCode,
      );
      if (!mounted) return;
      if (response['success'] == true) {
        final successMessage = response['message']?.toString() ??
            'Bank details updated successfully.';
        setState(() {
          saveMessage = successMessage;
          saveError = null;
          bankDetails = {
            'accountHolderName': holder,
            'accountNumber': account,
            'ifsc': ifsc,
            'bankName': bankName,
          };
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: const Color(0xFF22C55E),
          ),
        );
        await Future.delayed(const Duration(milliseconds: 600));
        await _loadProfile();
        _returnToProfileAfterSave();
        return;
      } else {
        setState(() {
          saveError = response['message']?.toString() ??
              'Failed to save bank details.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        saveError = 'Failed to save bank details.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
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

  String? _validateBankForm({
    required String holder,
    required String account,
    required String ifsc,
    required String bankName,
  }) {
    if (holder.isEmpty || account.isEmpty || ifsc.isEmpty || bankName.isEmpty) {
      return 'Please fill all bank fields.';
    }
    if (!RegExp(r'^\d{9,18}$').hasMatch(account)) {
      return 'Account number must be 9-18 digits.';
    }
    final normalizedIfsc = ifsc.toUpperCase();
    if (!RegExp(r'^[A-Z]{4}0[A-Z0-9]{6}$').hasMatch(normalizedIfsc)) {
      return 'Enter a valid IFSC code.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifire.getBgColor,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Bank Details",
                    style: Typographyy.heading4
                        .copyWith(color: notifire.getTextColor),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: Icon(Icons.arrow_back,
                        color: notifire.getTextColor, size: 18),
                    label: Text(
                      "Go Back",
                      style: Typographyy.bodySmallMedium
                          .copyWith(color: priMeryColor),
                    ),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: const Size(120, 32),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "You must verify OTP before updating your bank details.",
                style: Typographyy.bodyMediumMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
              const SizedBox(height: 16),
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
                      "Current Bank Details",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const SizedBox(height: 12),
                    if (isProfileLoading)
                      const SizedBox(
                        width: double.infinity,
                        child: LinearProgressIndicator(),
                      )
                    else if (profileError != null)
                      Text(
                        profileError!,
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: Colors.red),
                      )
                    else if (bankDetails == null)
                      Text(
                        "No bank details added yet.",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getGry500_600Color),
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
                      "OTP Verification",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const SizedBox(height: 12),
                    if (_hasValidOtp)
                      Text(
                        "OTP verified. You can now update your bank details.",
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: priMeryColor),
                      )
                    else ...[
                      Text(
                        "Request and verify OTP from the dedicated flow before editing.",
                        style: Typographyy.bodySmallMedium
                            .copyWith(color: notifire.getGry500_600Color),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openBankOtp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: priMeryColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            fixedSize: const Size.fromHeight(46),
                          ),
                          child: Text(
                            "Request OTP",
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
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
                      "Update Bank Details",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const SizedBox(height: 12),
                    _outlinedInput(
                      controller: holderController,
                      label: "Account Holder Name",
                      enabled: _hasValidOtp,
                    ),
                    const SizedBox(height: 12),
                    _outlinedInput(
                      controller: accountController,
                      label: "Account Number",
                      keyboard: TextInputType.number,
                      enabled: _hasValidOtp,
                    ),
                    const SizedBox(height: 12),
                    _outlinedInput(
                      controller: ifscController,
                      label: "IFSC Code",
                      enabled: _hasValidOtp,
                    ),
                    const SizedBox(height: 12),
                    _outlinedInput(
                      controller: bankNameController,
                      label: "Bank Name",
                      enabled: _hasValidOtp,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (!_hasValidOtp || isSaving) ? null : _saveBankDetails,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priMeryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          fixedSize: const Size.fromHeight(46),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "Save Bank Details",
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: Colors.white),
                              ),
                      ),
                    ),
                    if (saveMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        saveMessage!,
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: priMeryColor),
                      ),
                    ],
                    if (saveError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        saveError!,
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
