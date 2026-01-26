// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../controller/dashbordecontroller.dart';
import '../../controller/transactionscontroller.dart';

class Transactions extends StatefulWidget {
  const Transactions({super.key});

  @override
  State<Transactions> createState() => _TransactionsState();
}

class _TransactionsState extends State<Transactions> {
  final DashBordeController dashBordeController = DashBordeController.shared;
  TransactionController transactionController = Get.put(TransactionController());
  ColorNotifire notifire = ColorNotifire();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      dashBordeController.fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(15),
      color: notifire.getBgColor,
      child: GetBuilder<DashBordeController>(builder: (dashController) {
        return LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            child: _buildRecentTransactions(
                dashController, constraints.maxWidth),
          );
        });
      }),
    );
  }

  Widget _buildRecentTransactions(
      DashBordeController controller, double width) {
    final filtered = _filteredTransactions(controller.allTransactions);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
        color: notifire.getBgColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "Transactions".tr,
                style:
                    Typographyy.heading6.copyWith(color: notifire.getTextColor),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              const Spacer(),
              _searchBar(width),
              const SizedBox(width: 12),
              InkWell(
                onTap: controller.fetchTransactions,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: notifire.getContainerColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "Refresh".tr,
                        style: Typographyy.bodySmallSemiBold
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width < 1200 ? 1200 : width * 0.85,
              child: Column(
                children: [
                  Table(
                    columnWidths: const {0: FixedColumnWidth(80)},
                    children: [
                      _tableHeaderRow(),
                      if (controller.isTransactionsLoading)
                        _loadingTableRow(),
                      if (!controller.isTransactionsLoading &&
                          controller.transactionsError != null)
                        _messageTableRow(
                            controller.transactionsError ?? "Failed to load"),
                      if (!controller.isTransactionsLoading &&
                          controller.transactionsError == null &&
                          filtered.isEmpty)
                        _messageTableRow("No transactions found"),
                      if (!controller.isTransactionsLoading &&
                          controller.transactionsError == null)
                        ...filtered.map((tx) => _tableRow(tx)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _tableHeaderRow() {
    return TableRow(children: [
      _headerCellTable("Coin", isCenter: true),
      _headerCellTable("Transaction"),
      _headerCellTable("ID"),
      _headerCellTable("Date"),
      _headerCellTable("Status", isCenter: true),
      _headerCellTable("Gateway", isCenter: true),
      _headerCellTable("Actions"),
    ]);
  }

  Widget _headerCellTable(String title, {bool isCenter = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment:
            isCenter ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Text(
            title.tr,
            style: Typographyy.bodyLargeMedium
                .copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(
            "assets/images/Group 47984.svg",
            height: 14,
            width: 14,
            color: notifire.getGry600_500Color,
          ),
        ],
      ),
    );
  }

  TableRow _tableRow(Map<String, dynamic> tx) {
    final status = tx['status']?.toString() ?? '';
    final color = _statusColor(status);
    final subtitle = _transactionSubtitle(tx);
    final amount = _transactionTitle(tx);
    final date = _formatDate(tx['createdAt']?.toString());
    final gateway = _transactionGateway(tx);
    final id = _transactionId(tx);
    final isPurchase = (tx['category']?.toString() ?? '') == 'purchase';
    final recipient = _recipientLabel(tx);
    final reference = _referenceId(tx);
    final type = tx['type']?.toString() ?? '-';

    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10, right: 35),
        child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(_transactionLogo(tx))),
      ),
      ListTile(
        contentPadding: const EdgeInsets.all(0),
        dense: true,
        title: Text(
          amount,
          style: Typographyy.bodyLargeExtraBold
              .copyWith(color: notifire.getTextColor),
        ),
        subtitle: Text(
          subtitle,
          style: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry600_500Color),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          id,
          style: Typographyy.bodyLargeSemiBold
              .copyWith(color: notifire.getTextColor),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(
          date,
          style: Typographyy.bodyLargeSemiBold
              .copyWith(color: notifire.getTextColor),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 50, top: 10, bottom: 10),
        child: Container(
            width: 100,
            decoration: BoxDecoration(
                color: colorWithOpacity(color, 0.1),
                borderRadius: BorderRadius.circular(15)),
            padding: const EdgeInsets.all(8),
            child: Center(
                child: Text(
              _statusLabel(status),
              style: Typographyy.bodyLargeSemiBold
                  .copyWith(color: colorWithOpacity(color, 0.8)),
            ))),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
            child: Text(
          isPurchase ? "ICO" : gateway,
          style: Typographyy.bodyLargeSemiBold
              .copyWith(color: notifire.getTextColor),
        )),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: _actionsCell(
            recipient: recipient, type: type, reference: reference),
      ),
    ]);
  }

  TableRow _loadingTableRow() {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: notifire.getTextColor,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              "Loading transactions...",
              style: Typographyy.bodyMediumMedium
                  .copyWith(color: notifire.getTextColor),
            ),
          ],
        ),
      ),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ]);
  }

  TableRow _messageTableRow(String message) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Text(
          message,
          style: Typographyy.bodyMediumMedium.copyWith(
            color: notifire.getGry500_600Color,
          ),
        ),
      ),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
      const SizedBox(),
    ]);
  }

  Widget _actionsCell(
      {required String recipient,
      required String type,
      required String reference}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _actionLabel("Recipient", recipient, highlight: true),
        const SizedBox(height: 8),
        _actionLabel("Type", type),
        const SizedBox(height: 8),
        _actionLabel("Reference ID", reference),
      ],
    );
  }

  Widget _actionLabel(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: Typographyy.bodySmallSemiBold
                .copyWith(color: notifire.getGry500_600Color)),
        const SizedBox(height: 2),
        Text(
          value,
          style: (highlight
                  ? Typographyy.bodyMediumMedium
                  : Typographyy.bodyMediumMedium)
              .copyWith(
                  color: highlight
                      ? notifire.getTextColor
                      : notifire.getGry500_600Color),
        ),
      ],
    );
  }

  Widget _searchBar(double width) {
    final double barWidth = width < 600 ? width * 0.4 : 280.0;
    return Container(
      height: 44,
      width: barWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        style: Typographyy.bodyMediumMedium.copyWith(
          color: notifire.getTextColor,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.only(top: 12),
          prefixIcon: SizedBox(
            height: 20,
            width: 20,
            child: Center(
              child: SvgPicture.asset(
                "assets/images/Search.svg",
                color: notifire.getTextColor,
                height: 18,
                width: 18,
              ),
            ),
          ),
          hintText: "Search transaction...",
          border: InputBorder.none,
          hintStyle: Typographyy.bodyMediumMedium
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filteredTransactions(
      List<Map<String, dynamic>> transactions) {
    if (_searchQuery.isEmpty) {
      return transactions;
    }
    final q = _searchQuery.toLowerCase();
    return transactions.where((tx) {
      final subtitle = _transactionSubtitle(tx).toLowerCase();
      final id = _transactionId(tx).toLowerCase();
      final rawId = (tx['_id'] ??
              tx['id'] ??
              tx['transactionId'] ??
              tx['merchantTransactionId'] ??
              tx['referenceId'])
          ?.toString()
          .toLowerCase();
      final gateway = _transactionGateway(tx).toLowerCase();
      final status = tx['status']?.toString().toLowerCase() ?? '';
      final amount = tx['amount']?.toString().toLowerCase() ?? '';
      final currency = tx['currency']?.toString().toLowerCase() ?? '';
      final reference = _referenceId(tx).toLowerCase();
      final recipient = _recipientLabel(tx).toLowerCase();
      return subtitle.contains(q) ||
          id.contains(q) ||
          (rawId?.contains(q) ?? false) ||
          gateway.contains(q) ||
          status.contains(q) ||
          amount.contains(q) ||
          currency.contains(q) ||
          reference.contains(q) ||
          recipient.contains(q);
    }).toList();
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

  String _formatAmount(String currency, num? amount) {
    if (amount == null) {
      return '-';
    }
    final isNegative = amount < 0;
    final value = amount.abs();
    final formatted = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
    final sign = isNegative ? '-' : '+';
    return '$sign$currency $formatted';
  }

  String _transactionTitle(Map<String, dynamic> tx) {
    final currency = tx['currency']?.toString() ?? 'INR';
    num? amount = tx['amount'] as num?;
    final type = tx['type']?.toString().toLowerCase();
    if (type == 'debit' && amount != null) {
      amount = -amount;
    }
    return _formatAmount(currency, amount);
  }

  String _transactionSubtitle(Map<String, dynamic> tx) {
    final category = tx['category']?.toString() ?? '';
    if (category == 'purchase') {
      final metadata = tx['metadata'];
      if (metadata is Map<String, dynamic>) {
        final tokenAmount = metadata['tokenAmount'];
        final tokenSymbol = metadata['tokenSymbol'];
        if (tokenAmount != null && tokenSymbol != null) {
          return 'Token Buy ($tokenAmount $tokenSymbol)';
        }
      }
      return 'Token Buy';
    }
    if (category == 'topup') {
      return 'Money Added';
    }
    if (category == 'referral') {
      return 'Referral Income';
    }
    final description = tx['description']?.toString();
    if (description != null && description.isNotEmpty) {
      return description;
    }
    final type = tx['type']?.toString();
    if (type != null && type.isNotEmpty) {
      return type;
    }
    return 'Transaction';
  }

  String _transactionId(Map<String, dynamic> tx) {
    String? id = tx['_id']?.toString();
    id ??= tx['id']?.toString();
    id ??= tx['merchantTransactionId']?.toString();
    if (id == null || id.isEmpty) {
      return '-';
    }
    if (id.length <= 10) {
      return '#$id';
    }
    return '#${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  String _transactionGateway(Map<String, dynamic> tx) {
    final gateway = tx['paymentGateway']?.toString();
    if (gateway != null && gateway.isNotEmpty) {
      return gateway;
    }
    return '-';
  }

  String _recipientLabel(Map<String, dynamic> tx) {
    final recipient =
        tx['recipient'] ?? tx['to'] ?? tx['beneficiary'] ?? tx['walletAddress'];
    if (recipient == null) {
      return '-';
    }
    final text = recipient.toString();
    return text.isEmpty ? '-' : text;
  }

  String _referenceId(Map<String, dynamic> tx) {
    String? ref = tx['referenceId']?.toString();
    ref ??= tx['merchantTransactionId']?.toString();
    ref ??= tx['_id']?.toString();
    if (ref == null || ref.isEmpty) {
      return '-';
    }
    return ref;
  }

  String _transactionLogo(Map<String, dynamic> tx) {
    final category = tx['category']?.toString();
    if (category == 'referral') {
      return "assets/images/briefcase.svg";
    }
    if (category == 'purchase') {
      return "assets/images/eth.png";
    }
    return "assets/images/usdt.png";
  }

  Color _statusColor(String? status) {
    final normalized = status?.toLowerCase() ?? '';
    if (normalized.contains('completed') ||
        normalized.contains('success') ||
        normalized.contains('complete') ||
        normalized.contains('paid') ||
        normalized.contains('captured')) {
      return Colors.green;
    }
    if (normalized.contains('failed') ||
        normalized.contains('declined') ||
        normalized.contains('cancel') ||
        normalized.contains('error') ||
        normalized.contains('pending')) {
      return Colors.red;
    }
    if (normalized.contains('initiated') ||
        normalized.contains('processing')) {
      return Colors.orange;
    }
    if (normalized.contains('refunded') || normalized.contains('reversed')) {
      return Colors.blueGrey;
    }
    return Colors.grey;
  }

  String _statusLabel(String? status) {
    if (status == null || status.isEmpty) {
      return '-';
    }
    final normalized = status.toLowerCase();
    if (normalized.contains('completed') ||
        normalized.contains('complete') ||
        normalized.contains('success') ||
        normalized.contains('paid') ||
        normalized.contains('captured')) {
      return 'Success';
    }
    if (normalized.contains('pending')) {
      return 'Failed';
    }
    if (normalized.contains('initiated') || normalized.contains('processing')) {
      return 'Failed';
    }
    if (normalized.contains('failed') ||
        normalized.contains('declined') ||
        normalized.contains('cancel') ||
        normalized.contains('error')) {
      return 'Failed';
    }
    if (normalized.contains('refunded') || normalized.contains('reversed')) {
      return 'Refunded';
    }
    return status[0].toUpperCase() + status.substring(1);
  }
  Widget dataColumn1(
      {required String title,
      required String iconpath,
      required bool iscenter}) {
    return Row(
      mainAxisAlignment:
          iscenter ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        Text(title,
            style: Typographyy.bodyLargeExtraBold
                .copyWith(color: notifire.getGry500_600Color)),
        const SizedBox(
          width: 16,
        ),
        SizedBox(
            height: 16,
            width: 16,
            child: Center(
                child: SvgPicture.asset(iconpath,
                    height: 22,
                    width: 22,
                    color: notifire.getGry500_600Color))),
      ],
    );
  }

}
