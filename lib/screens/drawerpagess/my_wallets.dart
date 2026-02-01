// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../CommonWidgets/card.dart';
import '../../CommonWidgets/columcard.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../controller/dashbordecontroller.dart';
import '../../controller/drawercontroller.dart';
import '../../controller/mywalletscontroller.dart';
import '../../services/auth_api_service.dart';
import '../comingsoon.dart';

class MyWallets extends StatefulWidget {
  const MyWallets({super.key});

  @override
  State<MyWallets> createState() => _MyWalletsState();
}

class _MyWalletsState extends State<MyWallets> {
  final MyWalletsController myWalletsController =
      Get.isRegistered<MyWalletsController>()
          ? Get.find<MyWalletsController>()
          : Get.put(MyWalletsController());
  final DashBordeController dashBordeController = DashBordeController.shared;

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: notifire.getBgColor,
      child: GetBuilder<DashBordeController>(builder: (dashController) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWalletSummary(dashController, constraints.maxWidth),
                    const SizedBox(height: 30),
                    _buildRecentTransactions(
                        dashController, constraints.maxWidth),
                    const SizedBox(height: 30),
                    _buildPortfolioIllustration(),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildWalletSummary(DashBordeController controller, double width) {
    final walletCards = _buildWalletCards(controller, context, width);
    final crossAxisCount = width < 600
        ? 1
        : width < 1000
            ? 2
            : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Your Portfolio".tr,
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 150,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: walletCards.length,
          itemBuilder: (context, index) {
            return walletCards[index];
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              sendMoney(width: width, context: context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: priMeryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            ),
            icon: const Icon(Icons.add_circle_outline,
                color: Colors.white, size: 18),
            label: Text(
              "Add Money",
              style:
                  Typographyy.bodyMediumExtraBold.copyWith(color: whiteColor),
            ),
          ),
        ),
      ],
    );
  }

  Map<String, String> _walletDisplayStrings(DashBordeController controller) {
    final isLoading = controller.isWalletLoading;
    final hasError = controller.walletError != null &&
        controller.mainWalletBalance == null &&
        controller.tokenWalletBalance == null &&
        controller.referralWalletBalance == null;

    String normalizedSymbol(String? symbol, {required String fallbackSymbol}) {
      final value = symbol?.trim();
      if (value == null || value.isEmpty) {
        return fallbackSymbol;
      }
      final upper = value.toUpperCase();
      if (upper == 'ICOX' || upper == 'ICO') {
        return 'NVT Coin';
      }
      return value;
    }

    String formatValue(String? prefix, double? value,
        {String fallbackSymbol = 'INR'}) {
      final symbol = normalizedSymbol(prefix, fallbackSymbol: fallbackSymbol);
      if (value != null) {
        return '$symbol ${_formatNumber(value)}';
      }
      if (isLoading) return '$symbol ...';
      if (hasError) return '$symbol -';
      return '$symbol -';
    }

    return {
      'main': formatValue(
          controller.mainWalletCurrency, controller.mainWalletBalance,
          fallbackSymbol: 'INR'),
      'token': formatValue(
          controller.tokenSymbol, controller.tokenWalletBalance,
          fallbackSymbol: 'NVT Coin'),
      'referral': formatValue('INR', controller.referralWalletBalance,
          fallbackSymbol: 'INR'),
    };
  }

  List<Widget> _buildWalletCards(
      DashBordeController controller, BuildContext context, double width) {
    final display = _walletDisplayStrings(controller);

    return [
      ComunCard(
        price: display['main'] ?? '-',
        color1: const Color(0xff0CAF60),
        color2: const Color(0xff4ADE80),
        subtitle: "Main Wallet",
        pr: 0.6,
      ),
      ComunCard(
        price: display['token'] ?? '-',
        color1: const Color(0xff26A17B),
        color2: const Color(0xff2DD4BF),
        subtitle: "Token Wallet",
        pr: 0.7,
      ),
      ComunCard(
        price: display['referral'] ?? '-',
        color1: const Color(0xffFB774A),
        color2: const Color(0xffFFC837),
        subtitle: "Referral Commission",
        pr: 0.4,
      ),
    ];
  }

  String _formatNumber(double? value) {
    if (value == null) {
      return '-';
    }
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(2);
  }

  Widget _buildRecentTransactions(
      DashBordeController controller, double width) {
    return Container(
      height: 450,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
        color: notifire.getBgColor,
      ),
      child: SizedBox(
        height: 450,
        width: width,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            SizedBox(
              width: width < 1200 ? 1200 : width * 0.8,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Recent Transactions".tr,
                          style: Typographyy.heading6
                              .copyWith(color: notifire.getTextColor),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            final drawerController =
                                Get.isRegistered<DrawerControllerr>()
                                    ? Get.find<DrawerControllerr>()
                                    : null;
                            drawerController?.colorSelecter(value: 13);
                            drawerController?.function(value: -1);
                            Navigator.pushNamed(context, '/transactions');
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: notifire.getContainerColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "View all".tr,
                                  style: Typographyy.bodySmallSemiBold
                                      .copyWith(color: notifire.getTextColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(width: 5),
                                SvgPicture.asset(
                                  "assets/images/chevron-right.svg",
                                  height: 16,
                                  width: 16,
                                  color: notifire.getTextColor,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Table(
                      columnWidths: const {
                        0: FixedColumnWidth(80),
                      },
                      children: [
                        TableRow(children: [
                          _buildIconTitle(title: "Coin"),
                          _buildIconTitle(title: "Transaction"),
                          _buildIconTitle(title: "ID"),
                          _buildIconTitle(title: "Date"),
                          _buildIconTitle(title: "Status"),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Gateway",
                                  style: Typographyy.bodyLargeMedium
                                      .copyWith(color: notifire.getTextColor),
                                ),
                                const SizedBox(width: 8),
                                SvgPicture.asset(
                                  "assets/images/Group 47984.svg",
                                  height: 15,
                                  width: 15,
                                  color: notifire.getGry600_500Color,
                                )
                              ],
                            ),
                          ),
                        ]),
                        if (controller.allTransactions.isEmpty)
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Text(
                                "No recent transactions",
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
                          ]),
                        ...controller.allTransactions.take(6).map((tx) {
                          final status = tx['status']?.toString() ?? '';
                          final color = _statusColor(status);
                          return _transactionRow(
                            logo: _transactionLogo(tx),
                            price: _transactionTitle(tx),
                            subtitle: _transactionSubtitle(tx),
                            id: _transactionId(tx),
                            date: _formatDate(tx['createdAt']?.toString()),
                            status: _statusLabel(status),
                            fees: _transactionGateway(tx),
                            color: color,
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _transactionRow(
      {required String logo,
      required String price,
      required String subtitle,
      required String id,
      required String date,
      required String status,
      required String fees,
      required Color color}) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.only(top: 10, right: 35),
        child: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.transparent,
            backgroundImage: AssetImage(logo)),
      ),
      ListTile(
        contentPadding: const EdgeInsets.all(0),
        dense: true,
        title: Text(
          price,
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
              status,
              style: Typographyy.bodyLargeSemiBold
                  .copyWith(color: colorWithOpacity(color, 0.8)),
            ))),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
            child: Text(
          fees,
          style: Typographyy.bodyLargeSemiBold
              .copyWith(color: notifire.getTextColor),
        )),
      ),
    ]);
  }

  Widget _buildIconTitle({required String title}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            title,
            style: Typographyy.bodyLargeMedium
                .copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(width: 8),
          SvgPicture.asset(
            "assets/images/Group 47984.svg",
            height: 15,
            width: 15,
            color: notifire.getGry600_500Color,
          )
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
    final description = tx['description']?.toString();
    if (description != null && description.isNotEmpty) {
      return description;
    }
    final type = tx['type']?.toString();
    if (type != null && type.isNotEmpty) {
      return type;
    }
    return category.isNotEmpty ? category : 'Transaction';
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
        normalized.contains('paid') ||
        normalized.contains('captured')) {
      return Colors.green;
    }
    if (normalized.contains('failed') ||
        normalized.contains('declined') ||
        normalized.contains('cancel') ||
        normalized.contains('error')) {
      return Colors.red;
    }
    if (normalized.contains('initiated') ||
        normalized.contains('pending') ||
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
        normalized.contains('success') ||
        normalized.contains('paid') ||
        normalized.contains('captured')) {
      return 'Success';
    }
    if (normalized.contains('initiated') ||
        normalized.contains('pending') ||
        normalized.contains('processing')) {
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

  // ignore: unused_element
  Widget _buildui() {
    String mainCardPrice = dashBordeController.mainWalletBalance != null
        ? 'INR ${_formatNumber(dashBordeController.mainWalletBalance)}'
        : 'INR -';
    String tokenCardPrice = dashBordeController.tokenWalletBalance != null
        ? '${dashBordeController.tokenSymbol} ${_formatNumber(dashBordeController.tokenWalletBalance)}'
        : '${dashBordeController.tokenSymbol} -';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: notifire.getGry700_300Color),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Text(
                    'Total Balance',
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                  const Spacer(),
                  SvgPicture.asset(
                    "assets/images/dots-vertical29.svg",
                    height: 20,
                    width: 20,
                    color: notifire.getGry500_600Color,
                  ),
                ],
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "\$56,476.00 ",
                    style: Typographyy.heading2
                        .copyWith(color: notifire.getTextColor)),
                TextSpan(
                    text: "USD",
                    style: Typographyy.heading5
                        .copyWith(color: notifire.getGry500_600Color)),
              ])),
              Row(
                children: [
                  SvgPicture.asset(
                    "assets/images/heroicons-outline_trending-up.svg",
                    height: 20,
                    width: 20,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "2,05%",
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: const Color(0xff22C55E)),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    height: 5,
                    width: 5,
                    decoration: BoxDecoration(
                        color: notifire.getGry700_300Color,
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "January 29, 2022",
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getGry500_600Color),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 30,
        ),
        Text(
          "Card Lists",
          style: Typographyy.heading5.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(
          height: 16,
        ),
        cardss(
            price: mainCardPrice,
            bgcolor: priMeryColor,
            textcolor: Colors.white),
        const SizedBox(
          height: 15,
        ),
        cardss(
            price: tokenCardPrice,
            bgcolor: notifire.getGry700_300Color,
            textcolor: notifire.getTextColor),
        const SizedBox(
          height: 16,
        ),
        const SizedBox(
          height: 16,
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: const Size.fromHeight(56),
                    backgroundColor: notifire.getBgColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: priMeryColor)),
                  ),
                  onPressed: () {},
                  child: Text(
                    "Manage Card",
                    style: Typographyy.bodyLargeExtraBold
                        .copyWith(color: priMeryColor),
                  )),
            ),
          ],
        ),
      ],
    );
  }

  List cardList = [
    "assets/images/wallet1.svg",
    "assets/images/card-send1.svg",
    "assets/images/card-receive1.svg",
    "assets/images/receipt1.svg",
    "assets/images/shop-add.svg",
    "assets/images/coin-convert.svg",
  ];

  List carName = [
    "Deposit",
    "Send",
    "Receive",
    "Invoicing",
    "Checkout",
    "Swap (Coming Soon)",
  ];

  // ignore: unused_element
  Widget _buildui1({required double size}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                // height: 180,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: notifire.getGry700_300Color),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Quick Links",
                            style: Typographyy.bodyLargeExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                          const Spacer(),
                          SvgPicture.asset(
                            "assets/images/chevron-down.svg",
                            height: 20,
                            width: 20,
                            color: notifire.getGry500_600Color,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      // Wrap(
                      //   // spacing: 16,
                      //   // runSpacing: 16,
                      //   // runAlignment: WrapAlignment.center,
                      //   // crossAxisAlignment: WrapCrossAlignment.center,
                      //   children: [
                      //     _buildcard(icon: "assets/images/wallet1.svg", title: "Deposit"),
                      //     _buildcard(icon: "assets/images/card-send1.svg", title: "Send"),
                      //     _buildcard(icon: "assets/images/card-receive1.svg", title: "Receive"),
                      //     _buildcard(icon: "assets/images/receipt1.svg", title: "Invoicing"),
                      //     _buildcard(icon: "assets/images/shop-add.svg", title: "Checkout"),
                      //   ],
                      // ),

                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: carName.length,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: size < 600 ? 2 : 5,
                            mainAxisExtent: 100,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16),
                        itemBuilder: (context, index) {
                          return InkWell(
                              onTap: () {
                                switch (index) {
                                  case 0:
                                    addCurrency(width: size, context: context);
                                    break;
                                  case 1:
                                    sendMoney(width: size, context: context);
                                    break;
                                  case 2:
                                    review(width: size, context: context);
                                    break;
                                  case 3:
                                    invoicing(width: size, context: context);
                                    break;
                                  case 4:
                                    checkout(width: size, context: context);
                                    break;
                                  case 5:
                                    Get.snackbar(
                                      "Coming Soon",
                                      "Token swap is not available yet.",
                                      snackPosition: SnackPosition.BOTTOM,
                                    );
                                    break;
                                }
                              },
                              child: _buildcard(
                                  icon: cardList[index],
                                  title: carName[index]));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 160,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last 30",
                          style: Typographyy.bodyXLargeExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          "days",
                          style: Typographyy.bodyXLargeExtraBold
                              .copyWith(color: notifire.getTextColor),
                        ),
                      ],
                    ),
                    const Flexible(
                        child: SizedBox(
                      width: 20,
                    )),
                    SvgPicture.asset(
                      "assets/images/chevron-down.svg",
                      height: 20,
                      width: 20,
                      color: notifire.getGry500_600Color,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
                height: 80,
                child: VerticalDivider(
                  color: notifire.getGry700_300Color,
                  width: 60,
                )),
            Expanded(
              child: SizedBox(
                  width: 160,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Transactions',
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: notifire.getGry500_600Color),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        '29',
                        style: Typographyy.bodyXLargeExtraBold
                            .copyWith(color: notifire.getTextColor),
                      ),
                    ],
                  )),
            ),
            size < 800
                ? const SizedBox()
                : SizedBox(
                    height: 80,
                    child: VerticalDivider(
                      color: notifire.getGry700_300Color,
                      width: 60,
                    )),
            size < 800
                ? const SizedBox()
                : Expanded(
                    child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Spent',
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '\$10,654.00',
                              style: Typographyy.bodyXLargeExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                          ],
                        )),
                  ),
            size < 800
                ? const SizedBox()
                : SizedBox(
                    height: 80,
                    child: VerticalDivider(
                      color: notifire.getGry700_300Color,
                      width: 60,
                    )),
            size < 800
                ? const SizedBox()
                : Expanded(
                    child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Cashback',
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '\$2,456.00',
                              style: Typographyy.bodyXLargeExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                          ],
                        )),
                  ),
          ],
        ),
        size < 800
            ? const SizedBox(
                height: 15,
              )
            : const SizedBox(),
        size < 800
            ? Row(
                children: [
                  Expanded(
                    child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Spent',
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '\$10,654.00',
                              style: Typographyy.bodyXLargeExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                          ],
                        )),
                  ),
                  SizedBox(
                      height: 80,
                      child: VerticalDivider(
                        color: notifire.getGry700_300Color,
                        width: 60,
                      )),
                  Expanded(
                    child: SizedBox(
                        width: 160,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total Cashback',
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              '\$2,456.00',
                              style: Typographyy.bodyXLargeExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                          ],
                        )),
                  ),
                ],
              )
            : const SizedBox(),
        const SizedBox(
          height: 30,
        ),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(24),
                // height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  border: Border.all(color: notifire.getGry700_300Color),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Statistics",
                          style: Typographyy.heading6
                              .copyWith(color: notifire.getTextColor),
                        ),
                        const Spacer(),
                        size < 500
                            ? const SizedBox()
                            : Row(
                                children: [
                                  Switch(
                                    activeColor: priMeryColor,
                                    trackColor: myWalletsController.isMoonIn
                                        ? WidgetStatePropertyAll(priMeryColor)
                                        : WidgetStatePropertyAll(
                                            notifire.getGry700_300Color),
                                    activeTrackColor: priMeryColor,
                                    thumbColor:
                                        WidgetStatePropertyAll(whiteColor),
                                    value: myWalletsController.isMoonIn,
                                    onChanged: (value) {
                                      myWalletsController.setIsMoonIn(value);
                                    },
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Money In",
                                    style: Typographyy.bodySmallExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                        const Flexible(
                            child: SizedBox(
                          width: 24,
                        )),
                        size < 600
                            ? const SizedBox()
                            : Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: Switch(
                                      activeColor: priMeryColor,
                                      trackColor: myWalletsController.isMoonOut
                                          ? WidgetStatePropertyAll(priMeryColor)
                                          : WidgetStatePropertyAll(
                                              notifire.getGry700_300Color),
                                      activeTrackColor: priMeryColor,
                                      thumbColor:
                                          WidgetStatePropertyAll(whiteColor),
                                      value: myWalletsController.isMoonOut,
                                      onChanged: (value) {
                                        myWalletsController.setIsMoonOut(value);
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Money Out",
                                    style: Typographyy.bodySmallExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                        const SizedBox(
                          width: 30,
                        ),
                        PopupMenuButton(
                          tooltip: "",
                          offset: const Offset(0, 40),
                          color: notifire.getContainerColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                          onOpened: () {
                            myWalletsController.setMenuOpen(true);
                          },
                          onCanceled: () {
                            myWalletsController.setMenuOpen(false);
                          },
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                  padding: const EdgeInsets.all(0),
                                  child: SizedBox(
                                    height: 70,
                                    width: 100,
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: myWalletsController
                                          .listOfMonths.length,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              InkWell(
                                                  onTap: () {
                                                    myWalletsController
                                                        .setListValue(index);
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    myWalletsController
                                                        .listOfMonths[index],
                                                    style: Typographyy
                                                        .bodySmallSemiBold
                                                        .copyWith(
                                                            color: notifire
                                                                .getTextColor),
                                                  )),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )),
                            ];
                          },
                          child: Container(
                            height: 34,
                            width: 121,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: notifire.getGry50_800Color,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  myWalletsController.listOfMonths[
                                          myWalletsController.selectListIteam]
                                      .toString(),
                                  style: Typographyy.bodySmallSemiBold
                                      .copyWith(color: notifire.getTextColor),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                SvgPicture.asset(
                                    myWalletsController.isMenuOpen
                                        ? "assets/images/chevron-up.svg"
                                        : "assets/images/chevron-down.svg",
                                    color: myWalletsController.isMenuOpen
                                        ? priMeryColor
                                        : notifire.getGry500_600Color),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: SfCartesianChart(
                              series: <CartesianSeries<ChartData, int>>[
                                ColumnSeries<ChartData, int>(
                                    dataSource: chartData,
                                    xValueMapper: (ChartData data, _) => data.x,
                                    yValueMapper: (ChartData data, _) => data.y,
                                    color: priMeryColor,
                                    borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12)))
                              ]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        size < 800
            ? Column(
                children: [
                  _buidCurrency(),
                  const SizedBox(
                    height: 24,
                  ),
                  _buidConversion(),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: _buidCurrency(),
                  ),
                  const SizedBox(
                    width: 24,
                  ),
                  Expanded(
                    child: _buidConversion(),
                  ),
                ],
              )
      ],
    );
  }

  Widget _buidCurrency() {
    return Container(
      // height: 227,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Currency",
            style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
          ),
          const SizedBox(
            height: 16,
          ),
          ListTile(
            leading: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/images/in.svg",
                )),
            trailing: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "56,476.00",
                  style: Typographyy.bodyLargeExtraBold
                      .copyWith(color: notifire.getTextColor)),
              TextSpan(
                  text: " USD",
                  style: Typographyy.bodyLargeMedium
                      .copyWith(color: notifire.getGry500_600Color)),
            ])),
            title: Text(
              "IND",
              style: Typographyy.bodyLargeExtraBold
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/images/us.svg",
                )),
            trailing: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "29,955.00",
                  style: Typographyy.bodyLargeExtraBold
                      .copyWith(color: notifire.getTextColor)),
              TextSpan(
                  text: " USD",
                  style: Typographyy.bodyLargeMedium
                      .copyWith(color: notifire.getGry500_600Color)),
            ])),
            title: Text(
              "USD",
              style: Typographyy.bodyLargeExtraBold
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.transparent,
                child: SvgPicture.asset(
                  "assets/images/fr.svg",
                )),
            trailing: RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: "56,476.00",
                  style: Typographyy.bodyLargeExtraBold
                      .copyWith(color: notifire.getTextColor)),
              TextSpan(
                  text: " USD",
                  style: Typographyy.bodyLargeMedium
                      .copyWith(color: notifire.getGry500_600Color)),
            ])),
            title: Text(
              "GBP",
              style: Typographyy.bodyLargeExtraBold
                  .copyWith(color: notifire.getTextColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buidConversion() {
    return Container(
      // height: 227,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          "Conversion",
          style: Typographyy.heading6.copyWith(color: notifire.getTextColor),
        ),
        const SizedBox(
          height: 24,
        ),
        _buildConversion(),
        const SizedBox(
          height: 20,
        ),
        _buildConversion1(),
      ]),
    );
  }

  Widget _buildConversion() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: PopupMenuButton(
            onOpened: () {
              myWalletsController.setMenuOpen1(true);
            },
            onCanceled: () {
              myWalletsController.setMenuOpen1(false);
            },
            tooltip: "",
            offset: const Offset(0, 40),
            constraints: const BoxConstraints(maxWidth: 60, minWidth: 60),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: notifire.getContainerColor,
            child: Container(
              height: 56,
              // width: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifire.getGry700_300Color)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    myWalletsController
                        .menuIteam[myWalletsController.selectMenuIteam],
                    style: Typographyy.bodyMediumExtraBold
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset(
                    myWalletsController.isMenuOpen1
                        ? "assets/images/chevron-up.svg"
                        : "assets/images/chevron-down.svg",
                    height: 20,
                    width: 20,
                  )
                ],
              ),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      height: 100,
                      width: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: myWalletsController.menuIteam.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              InkWell(
                                  onTap: () {
                                    myWalletsController
                                        .setSelectMenuIteam(index);
                                    Get.back();
                                  },
                                  child: Text(
                                    myWalletsController.menuIteam[index],
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  )),
                            ],
                          );
                        },
                      ),
                    ))
              ];
            },
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifire.getGry700_300Color)),
            child: TextField(
              style: Typographyy.bodyLargeMedium
                  .copyWith(color: notifire.getTextColor),
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildConversion1() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: PopupMenuButton(
            constraints: const BoxConstraints(maxWidth: 60, minWidth: 60),
            onOpened: () {
              myWalletsController.setMenuOpen2(true);
            },
            onCanceled: () {
              myWalletsController.setMenuOpen2(false);
            },
            tooltip: "",
            offset: const Offset(0, 40),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            color: notifire.getContainerColor,
            child: Container(
              height: 56,
              // width: 80,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: notifire.getGry700_300Color)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    myWalletsController
                        .menuIteam[myWalletsController.selectMenuIteam1],
                    style: Typographyy.bodyMediumExtraBold
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  SvgPicture.asset(
                    myWalletsController.isMenuOpen2
                        ? "assets/images/chevron-up.svg"
                        : "assets/images/chevron-down.svg",
                    height: 20,
                    width: 20,
                  )
                ],
              ),
            ),
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                    padding: const EdgeInsets.all(0),
                    child: SizedBox(
                      height: 100,
                      width: 50,
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: myWalletsController.menuIteam.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              const SizedBox(
                                height: 12,
                              ),
                              InkWell(
                                  onTap: () {
                                    myWalletsController
                                        .setSelectMenuIteam1(index);
                                    Get.back();
                                  },
                                  child: Text(
                                    myWalletsController.menuIteam[index],
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  )),
                            ],
                          );
                        },
                      ),
                    ))
              ];
            },
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          flex: 3,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: notifire.getGry700_300Color)),
            child: TextField(
              style: Typographyy.bodyLargeMedium
                  .copyWith(color: notifire.getTextColor),
              decoration: const InputDecoration(
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  border: InputBorder.none),
            ),
          ),
        )
      ],
    );
  }

  List<ChartData> chartData = [
    ChartData(1, 35, 0),
    ChartData(2, 23, 0),
    ChartData(3, 54, 0),
    ChartData(4, 125, 0),
    ChartData(5, 40, 0),
    ChartData(6, 120, 0),
    ChartData(7, 70, 0),
    ChartData(8, 80, 0),
    ChartData(9, 30, 0),
    ChartData(10, 70, 0),
  ];

  Widget _buildcard({required String icon, required String title}) {
    return Container(
      height: 92,
      width: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: notifire.getGry700_300Color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: notifire.getGry50_800Color,
            child: SvgPicture.asset(
              icon,
              height: 20,
              width: 20,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            title,
            style: Typographyy.bodySmallSemiBold
                .copyWith(color: notifire.getTextColor),
          ),
        ],
      ),
    );
  }
}

class ChartData {
  ChartData(this.x, this.y, this.y1);
  final int x;
  final double y;
  final double y1;
}

Future<void> addCurrency({required double width, context}) async {
  final controller = Get.isRegistered<MyWalletsController>()
      ? Get.find<MyWalletsController>()
      : Get.put(MyWalletsController());
  final dialogFuture = showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      controller.registerTopupOverlayContext(context);
      return GetBuilder<MyWalletsController>(builder: (myWalletsController) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 8),
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: notifire.getBgColor,
            content: Container(
              // height: 200,
              width: width < 600 ? Get.width : 500,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: SvgPicture.asset(
                            "assets/images/plus.svg",
                            height: 22,
                            width: 22,
                            color: priMeryColor,
                          )),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                    "Add Currency",
                    style: Typographyy.heading4
                        .copyWith(color: notifire.getTextColor),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Text(
                    "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy",
                    style: Typographyy.bodySmallMedium.copyWith(
                        color: notifire.getGry500_600Color,
                        wordSpacing: 1.4,
                        height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  TextField(
                    style: Typographyy.bodyLargeRegular
                        .copyWith(color: notifire.getTextColor),
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: notifire.getGry700_300Color)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: notifire.getGry700_300Color)),
                        disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: notifire.getGry700_300Color)),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: notifire.getGry700_300Color)),
                        hintText: "Search...",
                        hintStyle: Typographyy.bodyLargeRegular
                            .copyWith(color: notifire.getGry500_600Color),
                        prefixIcon: SizedBox(
                          height: 22,
                          width: 22,
                          child: Center(
                              child: SvgPicture.asset(
                            "assets/images/Search.svg",
                            height: 20,
                            width: 20,
                            color: notifire.getTextColor,
                          )),
                        )),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  ListTile(
                    title: Text(
                      "Indian Rupee",
                      style: Typographyy.bodyLargeSemiBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    trailing: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: Colors.white,
                        fillColor: WidgetStatePropertyAll(priMeryColor),
                        value: myWalletsController.isCheckBox,
                        shape: const CircleBorder(),
                        side: BorderSide(color: notifire.getGry700_300Color),
                        onChanged: (bool? value) {
                          setState(() {
                            myWalletsController.setIsCheckBox(value);
                          });
                        },
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset("assets/images/in.svg"),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListTile(
                    title: Text(
                      "Portugal Euro",
                      style: Typographyy.bodyLargeSemiBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    trailing: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: Colors.white,
                        fillColor: WidgetStatePropertyAll(priMeryColor),
                        value: myWalletsController.isCheckBox1,
                        shape: const CircleBorder(),
                        side: BorderSide(color: notifire.getGry700_300Color),
                        onChanged: (bool? value) {
                          // Navigate to Coming Soon page for non-India countries
                          Get.to(() => const ComingSoon());
                        },
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset("assets/images/pt.svg"),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListTile(
                    title: Text(
                      "Us Dollar",
                      style: Typographyy.bodyLargeSemiBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    trailing: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: Colors.white,
                        fillColor: WidgetStatePropertyAll(priMeryColor),
                        value: myWalletsController.isCheckBox3,
                        shape: const CircleBorder(),
                        side: BorderSide(color: notifire.getGry700_300Color),
                        onChanged: (bool? value) {
                          // Navigate to Coming Soon page for non-India countries
                          Get.to(() => const ComingSoon());
                        },
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset("assets/images/us.svg"),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListTile(
                    title: Text(
                      "French Franc",
                      style: Typographyy.bodyLargeSemiBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    trailing: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: Colors.white,
                        fillColor: WidgetStatePropertyAll(priMeryColor),
                        value: myWalletsController.isCheckBox4,
                        shape: const CircleBorder(),
                        side: BorderSide(color: notifire.getGry700_300Color),
                        onChanged: (bool? value) {
                          // Navigate to Coming Soon page for non-India countries
                          Get.to(() => const ComingSoon());
                        },
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset("assets/images/fr.svg"),
                    ),
                  ),
                  const SizedBox(
                    height: 18,
                  ),
                  ListTile(
                    title: Text(
                      "Spain Euro",
                      style: Typographyy.bodyLargeSemiBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    trailing: Transform.scale(
                      scale: 1.3,
                      child: Checkbox(
                        checkColor: Colors.white,
                        fillColor: WidgetStatePropertyAll(priMeryColor),
                        value: myWalletsController.isCheckBox5,
                        shape: const CircleBorder(),
                        side: BorderSide(color: notifire.getGry700_300Color),
                        onChanged: (bool? value) {
                          // Navigate to Coming Soon page for non-India countries
                          Get.to(() => const ComingSoon());
                        },
                      ),
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: SvgPicture.asset("assets/images/es.svg"),
                    ),
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                fixedSize: const Size.fromHeight(48)),
                            onPressed: () {
                              Get.back();
                            },
                            child: Text(
                              "Add a Currency",
                              style: Typographyy.bodyMediumExtraBold
                                  .copyWith(color: Colors.white),
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        });
      });
    },
  );
  return dialogFuture
      .whenComplete(controller.clearTopupOverlayContext);
}

Future<void> sendMoney({required double width, context}) async {
  final controller = Get.isRegistered<MyWalletsController>()
      ? Get.find<MyWalletsController>()
      : Get.put(MyWalletsController());
  controller.resetTopupState(keepAmount: false);

  Widget buildContent(
    MyWalletsController myWalletsController, {
    required bool isBottomSheet,
    required double bottomInset,
  }) {
    final isCompact = width < 380;

    Widget buildMethodCard({
      required int value,
      required String title,
      required String subtitle,
      required IconData icon,
    }) {
      final isSelected = myWalletsController.selectedTopupMethod == value;
      return InkWell(
        onTap: () {
          myWalletsController.setTopupMethod(value);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? priMeryColor : notifire.getGry700_300Color,
            ),
            color: isSelected
                ? colorWithOpacity(priMeryColor, 0.08)
                : Colors.transparent,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    isSelected ? priMeryColor : notifire.getGry700_300Color,
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : notifire.getTextColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Typographyy.bodySmallMedium
                          .copyWith(color: notifire.getGry500_600Color),
                    ),
                  ],
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isSelected ? priMeryColor : notifire.getGry500_600Color,
              ),
            ],
          ),
        ),
      );
    }

    Widget buildDetailRow(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: Typographyy.bodySmallMedium
                    .copyWith(color: notifire.getGry500_600Color),
              ),
            ),
            Expanded(
              child: SelectableText(
                value,
                style: Typographyy.bodySmallExtraBold
                    .copyWith(color: notifire.getTextColor),
              ),
            ),
          ],
        ),
      );
    }

    final scrollView = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        top: 8,
        bottom: isBottomSheet ? (bottomInset > 0 ? 8 : 24) : 24,
        left: 16,
        right: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32), // Balance the close button
              Text(
                "Add Money",
                style:
                    Typographyy.heading4.copyWith(color: notifire.getTextColor),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Get.back();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    "assets/images/plus.svg",
                    height: 20,
                    width: 20,
                    color: priMeryColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 16),
          Text(
            "Choose a payment method and enter the amount to add.",
            style: Typographyy.bodySmallMedium.copyWith(
              color: notifire.getGry500_600Color,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isCompact ? 24 : 32),
          Row(
            children: [
              Text(
                "Payment Method",
                style: Typographyy.bodyLargeExtraBold
                    .copyWith(color: notifire.getTextColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          buildMethodCard(
            value: MyWalletsController.topupMethodRazorpay,
            title: "Razorpay",
            subtitle: "Cards / UPI / Wallets",
            icon: Icons.payment,
          ),
          SizedBox(height: isCompact ? 12 : 16),
          buildMethodCard(
            value: MyWalletsController.topupMethodPayU,
            title: "PayU",
            subtitle: "Cards, UPI & wallets via PayU",
            icon: Icons.account_balance_wallet,
          ),
          SizedBox(height: isCompact ? 16 : 24),
          TextField(
            controller: myWalletsController.amountController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Typographyy.bodyLargeExtraBold
                .copyWith(color: notifire.getTextColor),
            decoration: InputDecoration(
              labelText: "Amount",
              suffixText: "INR",
              hintText: "Enter amount",
              labelStyle: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
              hintStyle: Typographyy.bodySmallMedium
                  .copyWith(color: notifire.getGry500_600Color),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: notifire.getGry700_300Color),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Minimum top-up amount is ₹1,000.",
            style: Typographyy.bodySmallMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
          const SizedBox(height: 8),
          if (myWalletsController.topupError != null) ...[
            const SizedBox(height: 12),
            Text(
              myWalletsController.topupError!,
              style: Typographyy.bodySmallMedium.copyWith(color: Colors.red),
            ),
          ],
          if (myWalletsController.topupSuccess != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colorWithOpacity(priMeryColor, 0.12),
              ),
              child: Text(
                myWalletsController.topupSuccess!,
                style: Typographyy.bodySmallExtraBold
                    .copyWith(color: priMeryColor),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (_isFailureStatus(myWalletsController.topupStatus))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: priMeryColor),
                    fixedSize: const Size.fromHeight(48),
                  ),
                  onPressed: myWalletsController.isStatusLoading
                      ? null
                      : () async {
                          await _retryTopup(myWalletsController);
                        },
                  child: Text(
                    "Retry Payment",
                    style: Typographyy.bodyMediumExtraBold
                        .copyWith(color: priMeryColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    final container = Container(
      width: isBottomSheet ? double.infinity : (width < 600 ? Get.width : 520),
      padding: EdgeInsets.only(
        left: isBottomSheet ? 0 : 24,
        right: isBottomSheet ? 0 : 24,
        top: isBottomSheet ? 16 : 24,
        bottom: 0, // No bottom padding, handled by SafeArea
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: scrollView,
          ),
          // Button section - always visible above keyboard
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: isBottomSheet ? 16 : 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      fixedSize: const Size.fromHeight(48),
                      backgroundColor: priMeryColor,
                      disabledBackgroundColor:
                          colorWithOpacity(priMeryColor, 0.6),
                    ),
                    onPressed: myWalletsController.isTopupLoading
                        ? null
                        : () async {
                            await myWalletsController.initiateTopup();
                          },
                    child: myWalletsController.isTopupLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            "Initiate Payment",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (!isBottomSheet) {
      return container;
    }

    return Material(
      color: notifire.getBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      clipBehavior: Clip.antiAlias,
      child: container,
    );
  }

  if (width < 600) {
    final bottomSheetFuture = showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        controller.registerTopupOverlayContext(context);
        return GetBuilder<MyWalletsController>(
          builder: (myWalletsController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: DraggableScrollableSheet(
                initialChildSize: 0.9,
                minChildSize: 0.5,
                maxChildSize: 0.95,
                builder: (context, scrollController) {
                  // Helper function for payment method cards
                  Widget buildMethodCard({
                    required int value,
                    required String title,
                    required String subtitle,
                    required IconData icon,
                  }) {
                    final isSelected =
                        myWalletsController.selectedTopupMethod == value;
                    return InkWell(
                      onTap: () {
                        myWalletsController.setTopupMethod(value);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? priMeryColor
                                : notifire.getGry700_300Color,
                          ),
                          color: isSelected
                              ? colorWithOpacity(priMeryColor, 0.08)
                              : Colors.transparent,
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isSelected
                                  ? priMeryColor
                                  : notifire.getGry700_300Color,
                              child: Icon(
                                icon,
                                color: isSelected
                                    ? Colors.white
                                    : notifire.getTextColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: Typographyy.bodyLargeExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    subtitle,
                                    style: Typographyy.bodySmallMedium.copyWith(
                                        color: notifire.getGry500_600Color),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle,
                                  color: priMeryColor, size: 24),
                          ],
                        ),
                      ),
                    );
                  }

                  // Helper function for detail rows
                  Widget buildDetailRow(String label, String value) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              label,
                              style: Typographyy.bodySmallMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Expanded(
                            child: SelectableText(
                              value,
                              style: Typographyy.bodySmallExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: notifire.getBgColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header with close button and title
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const SizedBox(width: 32),
                              Text(
                                "Add Money",
                                style: Typographyy.heading4
                                    .copyWith(color: notifire.getTextColor),
                              ),
                              InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  Get.back();
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  child: SvgPicture.asset(
                                    "assets/images/plus.svg",
                                    height: 20,
                                    width: 20,
                                    color: priMeryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Scrollable content
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Choose a payment method and enter the amount to add.",
                                  style: Typographyy.bodySmallMedium.copyWith(
                                    color: notifire.getGry500_600Color,
                                    height: 1.4,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  "Payment Method",
                                  style: Typographyy.bodyLargeExtraBold
                                      .copyWith(color: notifire.getTextColor),
                                ),
                                const SizedBox(height: 16),
                                buildMethodCard(
                                  value: MyWalletsController.topupMethodRazorpay,
                                  title: "Razorpay",
                                  subtitle: "Cards / UPI / Wallets",
                                  icon: Icons.payment,
                                ),
                                const SizedBox(height: 12),
                                buildMethodCard(
                                  value: MyWalletsController.topupMethodPayU,
                                  title: "PayU",
                                  subtitle: "Cards, UPI & wallets via PayU",
                                  icon: Icons.account_balance_wallet,
                                ),
                                const SizedBox(height: 24),
                                TextField(
                                  controller:
                                      myWalletsController.amountController,
                                  autofocus: false,
                                  textInputAction: TextInputAction.done,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  style: Typographyy.bodyLargeExtraBold
                                      .copyWith(color: notifire.getTextColor),
                                  decoration: InputDecoration(
                                    labelText: "Amount",
                                    suffixText: "INR",
                                    hintText: "Enter amount",
                                    labelStyle: Typographyy.bodySmallMedium
                                        .copyWith(
                                            color: notifire.getGry500_600Color),
                                    hintStyle: Typographyy.bodySmallMedium
                                        .copyWith(
                                            color: notifire.getGry500_600Color),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                          color: notifire.getGry700_300Color),
                                    ),
                                  ),
                                ),
                                if (myWalletsController.topupError != null) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    myWalletsController.topupError!,
                                    style: Typographyy.bodySmallMedium
                                        .copyWith(color: Colors.red),
                                  ),
                                ],
                                if (myWalletsController.topupSuccess !=
                                    null) ...[
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color:
                                          colorWithOpacity(priMeryColor, 0.12),
                                    ),
                                    child: Text(
                                      myWalletsController.topupSuccess!,
                                      style: Typographyy.bodySmallExtraBold
                                          .copyWith(color: priMeryColor),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 20),
                                const SizedBox(
                                    height: 100), // Extra space for button
                              ],
                            ),
                          ),
                        ),
                        // Fixed button at bottom
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: notifire.getBgColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: SafeArea(
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  fixedSize: const Size.fromHeight(48),
                                  backgroundColor: priMeryColor,
                                  disabledBackgroundColor:
                                      colorWithOpacity(priMeryColor, 0.6),
                                ),
                                onPressed: myWalletsController.isTopupLoading
                                    ? null
                                    : () async {
                                        await myWalletsController
                                            .initiateTopup();
                                      },
                                child: myWalletsController.isTopupLoading
                                    ? const SizedBox(
                                        height: 18,
                                        width: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        "Initiate Payment",
                                        style: Typographyy.bodyMediumExtraBold
                                            .copyWith(color: Colors.white),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
    return bottomSheetFuture
        .whenComplete(controller.clearTopupOverlayContext);
  }

  final dialogFuture = showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      controller.registerTopupOverlayContext(context);
      return GetBuilder<MyWalletsController>(builder: (myWalletsController) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: notifire.getBgColor,
          content: buildContent(
            myWalletsController,
            isBottomSheet: false,
            bottomInset: MediaQuery.of(context).viewInsets.bottom,
          ),
        );
      });
    },
  );
}

Future<void> review({required double width, context}) async {
  return showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return GetBuilder<MyWalletsController>(builder: (myWalletsController) {
        return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 8),
            contentPadding: EdgeInsets.zero,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: notifire.getBgColor,
            content: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  // height: 200,
                  width: width < 600 ? Get.width : 500,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                              onTap: () {
                                Get.back();
                              },
                              child: SvgPicture.asset(
                                "assets/images/plus.svg",
                                height: 22,
                                width: 22,
                                color: priMeryColor,
                              )),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Text(
                        "Review detail of your transfer",
                        style: Typographyy.heading4
                            .copyWith(color: notifire.getTextColor),
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      Text(
                        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the",
                        style: Typographyy.bodySmallMedium.copyWith(
                            color: notifire.getGry500_600Color,
                            wordSpacing: 1.4,
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      Table(
                        children: [
                          TableRow(children: [
                            Text(
                              "Transfer details",
                              style: Typographyy.bodyMediumExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/tabler_edit.svg",
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Edit",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: priMeryColor),
                                )
                              ],
                            ),
                          ]),
                          const TableRow(children: [
                            SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "You send",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$2,955.00",
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: priMeryColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Total fees",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "-\$29.00",
                                    style: Typographyy.bodyMediumMedium
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Amount we’ll convert",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$2,926.00",
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Guarenteed rate (48 hours)",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "\$0.2950",
                                    style: Typographyy.bodyMediumMedium
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Should arrive",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "by Jan 29",
                                    style: Typographyy.bodyMediumMedium
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Divider(
                              height: 48,
                              color: notifire.getGry700_300Color,
                            ),
                            Divider(
                              height: 48,
                              color: notifire.getGry700_300Color,
                            ),
                          ]),
                          TableRow(children: [
                            Text(
                              "Recipient",
                              style: Typographyy.bodyMediumExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SvgPicture.asset(
                                  "assets/images/tabler_edit.svg",
                                  height: 20,
                                  width: 20,
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Text(
                                  "Edit",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: priMeryColor),
                                )
                              ],
                            ),
                          ]),
                          const TableRow(children: [
                            SizedBox(
                              height: 24,
                            ),
                            SizedBox(
                              height: 24,
                            ),
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Name",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "User",
                                    style: Typographyy.bodyMediumExtraBold
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Email",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Flexible(
                                      child: Text(
                                    "-",
                                    style: Typographyy.bodyMediumMedium
                                        .copyWith(
                                            color: notifire.getTextColor,
                                            overflow: TextOverflow.ellipsis),
                                  )),
                                ],
                              ),
                            )
                          ]),
                          TableRow(children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Text(
                                "Account number",
                                style: Typographyy.bodyMediumMedium.copyWith(
                                    color: notifire.getGry500_600Color),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "AM29295504729",
                                    style: Typographyy.bodyMediumMedium
                                        .copyWith(color: notifire.getTextColor),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ],
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    fixedSize: const Size.fromHeight(48)),
                                onPressed: () {
                                  myWalletsController.offIsLoading(
                                      context, width);
                                },
                                child: Text(
                                  "Confirm and Send",
                                  style: Typographyy.bodyMediumExtraBold
                                      .copyWith(color: Colors.white),
                                )),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                myWalletsController.isLoading
                    ? const CircularProgressIndicator()
                    : const SizedBox(),
              ],
            ));
      });
    },
  );
}

Future<void> swapTokensDialog({required double width, context}) async {
  final controller = Get.find<MyWalletsController>();
  controller.resetTopupState(keepAmount: false);
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder<Map<String, dynamic>>(
        future: AuthApiService.getIcoSummary(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          double? price;
          final data = snapshot.data;
          if (data != null) {
            final payload = data['data'] is Map<String, dynamic>
                ? data['data'] as Map<String, dynamic>
                : data;
            price = (payload['price'] as num?)?.toDouble();
          }
          return StatefulBuilder(
            builder: (ctx, setState) {
              final tokens = double.tryParse(
                      controller.swapAmountController.text.trim()) ??
                  0;
              final estimate =
                  (price != null && tokens > 0) ? price * tokens : null;
              return AlertDialog(
                backgroundColor: notifire.getBgColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                contentPadding: const EdgeInsets.all(20),
                title: Text(
                  "Swap (Debit Main Wallet)",
                  style: Typographyy.heading5
                      .copyWith(color: notifire.getTextColor),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller.swapAmountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Token amount",
                        hintText: "Enter token amount",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: notifire.getGry700_300Color),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: notifire.getGry700_300Color),
                        ),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton(
                        onPressed: controller.isSwapLoading
                            ? null
                            : () async {
                                final amt = double.tryParse(controller
                                        .swapAmountController.text
                                        .trim()) ??
                                    0;
                                if (amt <= 0) {
                                  Get.snackbar("Invalid amount",
                                      "Enter a valid token amount",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor:
                                          colorWithOpacity(Colors.red, 0.1));
                                  return;
                                }
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Confirm Swap"),
                                    content: Text(
                                        "Swap $amt tokens from main wallet?"
                                        "${estimate != null ? "\nApprox cost: INR ${estimate.toStringAsFixed(2)}" : ""}"),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(false),
                                          child: const Text("Cancel")),
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.of(ctx).pop(true),
                                          child: const Text("Confirm")),
                                    ],
                                  ),
                                );
                                if (confirmed != true) return;
                                await controller.swapTokens();
                                if (controller.swapSuccess != null) {
                                  Get.snackbar(
                                      "Success", controller.swapSuccess!,
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor:
                                          colorWithOpacity(Colors.green, 0.1));
                                  Get.back();
                                } else if (controller.swapError != null) {
                                  Get.snackbar("Error", controller.swapError!,
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor:
                                          colorWithOpacity(Colors.red, 0.1));
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priMeryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: controller.isSwapLoading
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
                                    ? "Swap for ~ INR ${estimate.toStringAsFixed(2)}"
                                    : "Swap",
                                style: Typographyy.bodyMediumExtraBold
                                    .copyWith(color: Colors.white),
                              ),
                      ),
                    ),
                    if (controller.swapError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        controller.swapError!,
                        style: Typographyy.bodyMediumMedium
                            .copyWith(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}

Future<void> checkout({required double width, context}) async {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return GetBuilder<MyWalletsController>(builder: (myWalletsController) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: notifire.getBgColor,
          content: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                // height: 200,
                width: width < 600 ? Get.width : 600,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: SvgPicture.asset(
                              "assets/images/plus.svg",
                              height: 22,
                              width: 22,
                              color: priMeryColor,
                            )),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Text(
                      "Review detail of your request",
                      style: Typographyy.heading4
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Text(
                      "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the",
                      style: Typographyy.bodySmallMedium.copyWith(
                          color: notifire.getGry500_600Color,
                          wordSpacing: 1.4,
                          height: 1.4),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Table(
                      children: [
                        TableRow(children: [
                          Text(
                            "Transfer details",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                "assets/images/tabler_edit.svg",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Edit",
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: priMeryColor),
                              )
                            ],
                          ),
                        ]),
                        const TableRow(children: [
                          SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "You send",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "\$2,955.00",
                                  style: Typographyy.bodyMediumExtraBold
                                      .copyWith(color: priMeryColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Total fees",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "-\$29.00",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: notifire.getTextColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Amount we’ll convert",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "\$2,926.00",
                                  style: Typographyy.bodyMediumExtraBold
                                      .copyWith(color: notifire.getTextColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Guarenteed rate (48 hours)",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "\$0.2950",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: notifire.getTextColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Should arrive",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "by Jan 29",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: notifire.getTextColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Divider(
                            height: 48,
                            color: notifire.getGry700_300Color,
                          ),
                          Divider(
                            height: 48,
                            color: notifire.getGry700_300Color,
                          ),
                        ]),
                        TableRow(children: [
                          Text(
                            "Recipient",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SvgPicture.asset(
                                "assets/images/tabler_edit.svg",
                                height: 20,
                                width: 20,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Text(
                                "Edit",
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: priMeryColor),
                              )
                            ],
                          ),
                        ]),
                        const TableRow(children: [
                          SizedBox(
                            height: 24,
                          ),
                          SizedBox(
                            height: 24,
                          ),
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Name",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "User",
                                  style: Typographyy.bodyMediumExtraBold
                                      .copyWith(color: notifire.getTextColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Email",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                    child: Text(
                                  "-",
                                  style: Typographyy.bodyMediumMedium.copyWith(
                                      color: notifire.getTextColor,
                                      overflow: TextOverflow.ellipsis),
                                )),
                              ],
                            ),
                          )
                        ]),
                        TableRow(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Text(
                              "Account number",
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  "AM29295504729",
                                  style: Typographyy.bodyMediumMedium
                                      .copyWith(color: notifire.getTextColor),
                                ),
                              ],
                            ),
                          )
                        ]),
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  fixedSize: const Size.fromHeight(48)),
                              onPressed: () {
                                myWalletsController.offIsLoading(
                                    context, width);
                              },
                              child: Text(
                                "Send Request",
                                style: Typographyy.bodyMediumExtraBold
                                    .copyWith(color: Colors.white),
                              )),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              myWalletsController.isLoading
                  ? const CircularProgressIndicator()
                  : const SizedBox(),
            ],
          ),
        );
      });
    },
  );
}

Future<void> invoicing({required double width, context}) async {
  return showDialog<void>(
    context: context, // user must tap button!
    builder: (BuildContext context) {
      return GetBuilder<MyWalletsController>(builder: (myWalletsController) {
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8),
          contentPadding: EdgeInsets.zero,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: notifire.getBgColor,
          content: Container(
            // height: 200,
            width: width < 600 ? Get.width : 500,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                        onTap: () {
                          Get.back();
                        },
                        child: SvgPicture.asset(
                          "assets/images/plus.svg",
                          height: 22,
                          width: 22,
                          color: priMeryColor,
                        )),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                Text(
                  "Request payment form",
                  style: Typographyy.heading4
                      .copyWith(color: notifire.getTextColor),
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "Lorem Ipsum is simply dummy text of the printing and typesetting industry Lorem Ipsum is simply dummy",
                  style: Typographyy.bodySmallMedium.copyWith(
                      color: notifire.getGry500_600Color,
                      wordSpacing: 1.4,
                      height: 1.4),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  style: Typographyy.bodyLargeRegular
                      .copyWith(color: notifire.getTextColor),
                  decoration: InputDecoration(
                    hintText: "Name, @username, or email",
                    hintStyle: Typographyy.bodyLargeRegular
                        .copyWith(color: notifire.getGry500_600Color),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                  ),
                ),
                const SizedBox(
                  height: 24,
                ),
                Row(
                  children: [
                    Text(
                      "Recent Contact",
                      style: Typographyy.bodyLargeExtraBold
                          .copyWith(color: notifire.getTextColor),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        InkWell(
                            onTap: () {
                              myWalletsController.scrollController.animateTo(
                                  -40,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.bounceOut);
                            },
                            child: SvgPicture.asset(
                              "assets/images/chevron-left.svg",
                              height: 22,
                              width: 22,
                              color: notifire.getGry500_600Color,
                            )),
                        const SizedBox(
                          width: 8,
                        ),
                        InkWell(
                            onTap: () {
                              myWalletsController.scrollController.animateTo(
                                  10 * 100,
                                  duration: const Duration(milliseconds: 1000),
                                  curve: Curves.easeIn);
                            },
                            child: SvgPicture.asset(
                              "assets/images/chevron-right.svg",
                              height: 22,
                              width: 22,
                              color: notifire.getGry500_600Color,
                            )),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
                SizedBox(
                  height: 100,
                  width: Get.width,
                  child: ListView.builder(
                    controller: myWalletsController.scrollController,
                    scrollDirection: Axis.horizontal,
                    itemCount: myWalletsController.usersName.length - 1,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Row(
                        children: [
                          const SizedBox(
                            width: 22,
                          ),
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.transparent,
                                backgroundImage: AssetImage(myWalletsController
                                    .usersProfile[index + 1]),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                myWalletsController.usersName[index + 1],
                                style: Typographyy.bodyMediumMedium
                                    .copyWith(color: notifire.getTextColor),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                TextField(
                  style: Typographyy.bodyLargeRegular
                      .copyWith(color: notifire.getTextColor),
                  decoration: InputDecoration(
                    suffixIcon: PopupMenuButton(
                      onCanceled: () {
                        myWalletsController.setIsCurrencyMenu(false);
                      },
                      onOpened: () {
                        myWalletsController.setIsCurrencyMenu(true);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      color: notifire.getContainerColor,
                      constraints:
                          const BoxConstraints(minWidth: 140, maxWidth: 140),
                      tooltip: "",
                      offset: const Offset(0, 40),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.transparent,
                              child: SvgPicture.asset(
                                  myWalletsController.currencyLogo[
                                      myWalletsController.selectCurrency])),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            myWalletsController.currencyName[
                                myWalletsController.selectCurrency],
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: notifire.getTextColor),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          SvgPicture.asset(
                            myWalletsController.isCurrencyMenu
                                ? "assets/images/chevron-up.svg"
                                : "assets/images/chevron-down.svg",
                            height: 20,
                            width: 20,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                              padding: const EdgeInsets.all(0),
                              child: SizedBox(
                                height: 120,
                                width: 140,
                                child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount:
                                      myWalletsController.currencyName.length,
                                  shrinkWrap: true,
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      dense: true,
                                      onTap: () {
                                        myWalletsController
                                            .setSelectCurrency(index);
                                        Get.back();
                                      },
                                      title: Text(
                                        myWalletsController.currencyName[index],
                                        style: Typographyy.bodyMediumExtraBold
                                            .copyWith(
                                                color: notifire.getTextColor),
                                      ),
                                      leading: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.transparent,
                                          child: SvgPicture.asset(
                                              myWalletsController
                                                  .currencyLogo[index])),
                                    );
                                  },
                                ),
                              ))
                        ];
                      },
                    ),
                    hintText: "Enter an Amount",
                    hintStyle: Typographyy.bodyLargeRegular
                        .copyWith(color: notifire.getGry500_600Color),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                    disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            BorderSide(color: notifire.getGry700_300Color)),
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              fixedSize: const Size.fromHeight(48)),
                          onPressed: () {
                            // myWalletsController.offIsLoading();
                            Get.back();
                          },
                          child: Text(
                            "Continue",
                            style: Typographyy.bodyMediumExtraBold
                                .copyWith(color: Colors.white),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

Widget _buildPortfolioIllustration() {
  return Column(
    children: [
      SizedBox(
        height: 180,
        child: Image.asset(
          "assets/images/empty-wallet-change.svg",
          fit: BoxFit.contain,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        "Keep your portfolio in view and never miss a milestone.",
        style: Typographyy.bodyMediumMedium.copyWith(
          color: notifire.getGry500_600Color,
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Future<void> _retryTopup(MyWalletsController controller) async {
  await controller.verifyRazorpayPayment(auto: true);
}

bool _isFailureStatus(String? status) {
  final normalized = status?.toLowerCase() ?? '';
  return normalized.contains('failed') ||
      normalized.contains('declined') ||
      normalized.contains('error');
}
