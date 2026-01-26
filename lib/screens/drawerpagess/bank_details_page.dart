import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/typography.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';

class BankDetailsPage extends StatefulWidget {
  const BankDetailsPage({super.key});

  @override
  State<BankDetailsPage> createState() => _BankDetailsPageState();
}

class _BankDetailsPageState extends State<BankDetailsPage> {
  ColorNotifire notifire = ColorNotifire();
  final DrawerControllerr _drawerController = Get.put(DrawerControllerr());

  bool isLoading = false;
  String? errorMessage;
  Map<String, dynamic>? bankDetails;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _drawerController.colorSelecter(value: 19);
      }
    });
    _loadBankDetails();
  }

  Future<void> _loadBankDetails() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
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
          errorMessage =
              response['message']?.toString() ?? 'Unable to load bank details.';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Unable to load bank details.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _openEditFlow() {
    _drawerController.function(value: -1);
    _drawerController.colorSelecter(value: 19);
    Navigator.pushNamed(context, '/bankEditOtp');
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
        value: data['addedBy']?.toString() ?? data['createdBy']?.toString() ?? 'User',
      ),
      _detailRow(
        label: "Verified By",
        value: data['verifiedBy']?.toString() ?? (data['isVerified'] == true ? 'Admin' : 'Pending'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return SafeArea(
      child: Scaffold(
        backgroundColor: notifire.getBgColor,
        appBar: AppBar(
          backgroundColor: notifire.getBgColor,
          elevation: 0,
          iconTheme: IconThemeData(color: notifire.getTextColor),
          title: Text(
            "Bank Details",
            style:
                Typographyy.heading4.copyWith(color: notifire.getTextColor),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Review your saved bank details before making edits.",
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
                child: isLoading
                    ? const SizedBox(
                        width: double.infinity,
                        child: LinearProgressIndicator(),
                      )
                    : errorMessage != null
                        ? Text(
                            errorMessage!,
                            style: Typographyy.bodyMediumMedium
                                .copyWith(color: Colors.red),
                          )
                        : bankDetails == null
                            ? Text(
                                "No bank details added.",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: _bankDetailRows(bankDetails!),
                              ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      bankDetails == null || isLoading ? null : _openEditFlow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: priMeryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    fixedSize: const Size.fromHeight(46),
                  ),
                  child: Text(
                    "Edit Bank Details",
                    style: Typographyy.bodyMediumMedium
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
}
