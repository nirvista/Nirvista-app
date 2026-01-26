// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../CommonWidgets/card.dart';
import '../../CommonWidgets/columcard.dart';
import '../../CommonWidgets/stage_card.dart';
import '../../ConstData/colorfile.dart';
import '../../ConstData/colorprovider.dart';
import '../../ConstData/staticdata.dart';
import '../../ConstData/typography.dart';
import '../../controller/dashbordecontroller.dart';
import '../../controller/drawercontroller.dart';
import '../../services/auth_api_service.dart';
import 'my_wallets.dart' show sendMoney;

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ColorNotifire notifire = ColorNotifire();
  final controller = PageController();
  final DashBordeController dashBordeController = DashBordeController.shared;
  DrawerControllerr contoller = Get.put(DrawerControllerr());
  String _userName = 'User'; // Default username
  final ScrollController _scrollController = ScrollController();
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _autoRefreshTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final response = await AuthApiService.profile();
      if (response['success'] == true) {
        final data = response['data'] is Map<String, dynamic>
            ? response['data'] as Map<String, dynamic>
            : response;
        final name = data['name']?.toString();
        if (mounted && name != null && name.isNotEmpty) {
          setState(() {
            _userName = name;
          });
        }
      }
    } catch (_) {
      // Silently fail, keep default username
    }
  }

  Future<void> _refreshDashboard() async {
    try {
      await Future.wait([
        dashBordeController.fetchIcoStages(),
        dashBordeController.fetchWalletSummary(),
        dashBordeController.fetchTransactions(),
        _loadUserProfile(),
      ]);
    } catch (_) {
      // Swallow errors to keep indicators stable.
    }
  }

  void _startAutoRefresh() {
    _autoRefreshTimer?.cancel();
    _autoRefreshTimer =
        Timer.periodic(const Duration(minutes: 5), (_) => _refreshDashboard());
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    debugPrint('Dashboard build');
    return GetBuilder<DashBordeController>(builder: (dashBordeController) {
      return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: notifire.getBgColor,
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 600) {
              return RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics()
                      .applyTo(const BouncingScrollPhysics()),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        _buildDashBordUi1(
                            width: constraints.maxWidth, count: 2),
                        const SizedBox(
                          height: 30,
                        ),
                        Container(
                          color: notifire.getBgColor,
                          child: _buildDashBordUi2(width: constraints.maxWidth),
                        ),
                        const DashboardEndGraphic(),
                      ],
                    ),
                  ),
                ),
              );
            } else if (constraints.maxWidth < 1000) {
              return RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics()
                      .applyTo(const BouncingScrollPhysics()),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              color: notifire.getBgColor,
                              margin: EdgeInsets.all(padding),
                              child: _buildDashBordUi1(
                                  width: constraints.maxWidth, count: 3),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: notifire.getBgColor,
                              margin: EdgeInsets.all(padding),
                              child: _buildDashBordUi2(
                                  width: constraints.maxWidth),
                            ),
                          ),
                        ],
                      ),
                      const DashboardEndGraphic(),
                    ],
                  ),
                ),
              );
            } else {
              return RefreshIndicator(
                onRefresh: _refreshDashboard,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics()
                      .applyTo(const BouncingScrollPhysics()),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              // height: 184,
                              color: notifire.getBgColor,
                              margin: EdgeInsets.all(padding),
                              child: _buildDashBordUi1(
                                  width: constraints.maxWidth, count: 4),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              // height: Get.height,
                              color: notifire.getBgColor,
                              margin: EdgeInsets.all(padding),
                              child: _buildDashBordUi2(
                                  width: constraints.maxWidth),
                            ),
                          ),
                        ],
                      ),
                      const DashboardEndGraphic(),
                    ],
                  ),
                ),
              );
            }
          },
        ),
      );
    });
  }

  PopupMenuItem coinselecter({required bool i1or2}) {
    return PopupMenuItem(
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 200,
          width: 140,
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
            itemCount: dashBordeController.coinsName.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  i1or2
                      ? dashBordeController.selectcoin(index)
                      : dashBordeController.selectcoin1(index);
                  Future.delayed(
                    const Duration(milliseconds: 200),
                    () {
                      Get.back();
                    },
                  );
                },
                child: ListTile(
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage:
                          AssetImage(dashBordeController.listOfCoin[index]),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                  title: Text(dashBordeController.coinsName[index],
                      style: Typographyy.bodyLargeMedium
                          .copyWith(color: notifire.getTextColor)),
                ),
              );
            },
          ),
        ));
  }

  Widget _buildDashBordUi1({required double width, required int count}) {
    final stages = dashBordeController.stages;
    final stageCount = stages.length;
    final isStageLoading = dashBordeController.isStageLoading;
    final stageError = dashBordeController.stageError;
    final walletDisplay = _walletDisplayStrings(dashBordeController);
    final walletCards = _buildWalletCards(dashBordeController, context, width,
        walletDisplay: walletDisplay);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //col1
        Row(
          children: [
            Expanded(
              child: Container(
                // height: 184,
                decoration: BoxDecoration(
                    color: priMeryColor,
                    borderRadius: BorderRadius.circular(radius)),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        child: Padding(
                          padding: EdgeInsets.all(width < 600 ? 15 : 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Welcome $_userName".tr,
                                  style: Typographyy.heading4
                                      .copyWith(color: whiteColor),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                              const SizedBox(
                                height: 8,
                              ),
                              Text(
                                  "Track balances, rewards, and activity in one view"
                                      .tr,
                                  style: Typographyy.bodyMediumRegular.copyWith(
                                      color: colorWithOpacity(whiteColor, 0.5)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2),
                              const SizedBox(
                                height: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    width < 600
                        ? const SizedBox()
                        : Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const SizedBox(
                                height: 180,
                                width: 250,
                              ),
                              Positioned(
                                  top: -44,
                                  right: 0,
                                  left: 0,
                                  child: Image.asset(
                                    "assets/images/Group 48563.png",
                                    width: 300,
                                    height: 300,
                                  ))
                            ],
                          ),
                  ],
                ),
              ),
            )
          ],
        ),
        //col2
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(
            children: [
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: count,
                      mainAxisExtent: 150,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10),
                  shrinkWrap: true,
                  itemCount: walletCards.length,
                  itemBuilder: (context, index) {
                    return walletCards[index];
                  },
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: SizedBox(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
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
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _openSwapDialog(width, context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: priMeryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SvgPicture.asset(
                      "assets/images/coin-convert.svg",
                      height: 18,
                      width: 18,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Swap Tokens",
                      style: Typographyy.bodyMediumExtraBold
                          .copyWith(color: whiteColor),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.sync_alt, color: Colors.white, size: 18),
                  ],
                ),
              )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(
            children: [
              Expanded(
                child: isStageLoading && stageCount == 0
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: LinearProgressIndicator(),
                      )
                    : stageError != null && stageCount == 0
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              stageError,
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: Colors.red),
                            ),
                          )
                        : GridView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: count,
                                    mainAxisExtent: 140,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10),
                            shrinkWrap: true,
                            itemCount: stageCount,
                            itemBuilder: (context, index) {
                              final stage = stages[index];
                              final key = stage['key']?.toString();
                              final isActive = stage['isActive'] == true;
                              final isUpcoming = stage['isUpcoming'] == true;
                              final isEnded = stage['isEnded'] == true;
                              final status = stage['status']?.toString() ?? '';
                              final isHighlight = isActive ||
                                  (dashBordeController.activeStageKey != null &&
                                      dashBordeController.activeStageKey ==
                                          key);

                              return StageCard(
                                label: stage['label']?.toString() ?? 'Stage',
                                status: status,
                                startAt: stage['startAt']?.toString(),
                                endAt: stage['endAt']?.toString(),
                                isActive: isActive,
                                isUpcoming: isUpcoming,
                                isEnded: isEnded,
                                isHighlight: isHighlight,
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
        //col3
        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(
            children: [
              Expanded(
                child: Container(
                    height: 450,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(radius),
                        border: Border.all(color: notifire.getGry700_300Color),
                        color: notifire.getBgColor),
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
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text("Recent Transactions".tr,
                                                style: Typographyy.heading6
                                                    .copyWith(
                                                        color: notifire
                                                            .getTextColor),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                  color: notifire
                                                      .getContainerColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text("View all".tr,
                                                      style: Typographyy
                                                          .bodySmallSemiBold
                                                          .copyWith(
                                                              color: notifire
                                                                  .getTextColor),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  SvgPicture.asset(
                                                    "assets/images/chevron-right.svg",
                                                    height: 16,
                                                    width: 16,
                                                    color:
                                                        notifire.getTextColor,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 24,
                                        ),
                                        Table(
                                          columnWidths: const {
                                            0: FixedColumnWidth(80),
                                            // 1: FixedColumnWidth(200),
                                            // 2: FixedColumnWidth(200),
                                            // 3: FixedColumnWidth(200),
                                            // 4: FixedColumnWidth(200),
                                            // 5: FixedColumnWidth(200),
                                          },
                                          children: [
                                            TableRow(children: [
                                              buildiconandtitle(
                                                  title: "Coin",
                                                  context: context),
                                              buildiconandtitle(
                                                  title: "Transaction",
                                                  context: context),
                                              buildiconandtitle(
                                                  title: "ID",
                                                  context: context),
                                              buildiconandtitle(
                                                  title: "Date",
                                                  context: context),
                                              buildiconandtitle(
                                                  title: "Status",
                                                  context: context),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      "Gateway",
                                                      style: Typographyy
                                                          .bodyLargeMedium
                                                          .copyWith(
                                                              color: notifire
                                                                  .getTextColor),
                                                    ),
                                                    const SizedBox(
                                                      width: 8,
                                                    ),
                                                    SvgPicture.asset(
                                                      "assets/images/Group 47984.svg",
                                                      height: 15,
                                                      width: 15,
                                                      color: notifire
                                                          .getGry600_500Color,
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ]),
                                            if (dashBordeController
                                                .recentTransactions.isEmpty)
                                              TableRow(children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 18),
                                                  child: Text(
                                                    "No recent transactions",
                                                    style: Typographyy
                                                        .bodyMediumMedium
                                                        .copyWith(
                                                            color: notifire
                                                                .getGry500_600Color),
                                                  ),
                                                ),
                                                const SizedBox(),
                                                const SizedBox(),
                                                const SizedBox(),
                                                const SizedBox(),
                                                const SizedBox(),
                                              ]),
                                            ...dashBordeController
                                                .recentTransactions
                                                .take(6)
                                                .map((tx) {
                                              final status =
                                                  tx['status']?.toString() ??
                                                      '';
                                              final color =
                                                  _statusColor(status);
                                              return tableroww(
                                                logo: _transactionLogo(tx),
                                                price: _transactionTitle(tx),
                                                subtitle:
                                                    _transactionSubtitle(tx),
                                                id: _transactionId(tx),
                                                date: _formatDate(
                                                    tx['createdAt']
                                                        ?.toString()),
                                                status: _statusLabel(status),
                                                fees: _transactionGateway(tx),
                                                color: color,
                                                context: context,
                                              );
                                            }),

                                            // row(
                                            //     title: "Sent to Antonio",
                                            //     date: "Jan 14, 2022",
                                            //     profile:
                                            //         "assets/images/avatar-10.png",
                                            //     price: "-\$150.00",
                                            //     tralling: "Pending",
                                            //     textcolor: Colors.red),

                                            // row(
                                            //     title: "Witdraw Paypal",
                                            //     date: "Jan 13, 2022",
                                            //     profile:
                                            //         "assets/images/Frame 24.png",
                                            //     price: "+\$200.00",
                                            //     tralling: "Success",
                                            //     textcolor: Colors.green),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
              ),
            ],
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
      if (isLoading) {
        return '$symbol ...';
      }
      if (hasError) {
        return '$symbol -';
      }
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

  Widget _buildDashBordUi2({required double width}) {
    final walletDisplay = _walletDisplayStrings(dashBordeController);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: notifire.getGry700_300Color),
              color: notifire.getBgColor),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: width < 600 ? 15 : 24),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Wallet".tr,
                      style: Typographyy.heading6
                          .copyWith(color: notifire.getTextColor),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _refreshDashboard,
                          icon: Icon(
                            Icons.refresh,
                            color: notifire.getGry500_600Color,
                          ),
                          tooltip: "Reload dashboard",
                        ),
                        SvgPicture.asset(
                          "assets/images/dots-vertical.svg",
                          height: 20,
                          width: 20,
                          color: notifire.getGry500_600Color,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: 233,
                child: PageView(
                  controller: controller,
                  children: [
                    cardss(
                        price: walletDisplay['main'] ?? '-',
                        bgcolor: priMeryColor,
                        textcolor: Colors.white),
                    cardss(
                        price: walletDisplay['token'] ?? '-',
                        bgcolor: priMeryColor,
                        textcolor: Colors.white),
                    cardss(
                        price: walletDisplay['referral'] ?? '-',
                        bgcolor: priMeryColor,
                        textcolor: Colors.white),
                  ],
                ),
              ),
              const SizedBox(
                height: 14,
              ),
              SmoothPageIndicator(
                  controller: controller,
                  effect: ExpandingDotsEffect(
                      dotColor: notifire.getGry700_300Color,
                      activeDotColor: priMeryColor,
                      radius: 15,
                      dotHeight: 10,
                      dotWidth: 10),
                  count: 3),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Buy & sell crypto in minutes",
                    style: Typographyy.heading6
                        .copyWith(color: notifire.getTextColor),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Wrap(
                runAlignment: WrapAlignment.spaceEvenly,
                runSpacing: 10,
                spacing: 20,
                children: [
                  InkWell(
                      onTap: () {
                        sendMoney(width: width, context: context);
                      },
                      child: _buildComencards(
                          title: "Load Balance",
                          iconpath: "assets/images/card-send1.svg")),

                  InkWell(
                    onTap: () {
                      _openWithdraw(width: width, context: context);
                    },
                    child: _buildComencards(
                        title: "Withdraw",
                        iconpath: "assets/images/card-send1.svg"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/transactions');
                      contoller.colorSelecter(value: 13);
                      contoller.function(value: -1);
                    },
                    child: _buildComencards(
                        title: "Transaction",
                        iconpath: "assets/images/receipt1.svg"),
                  ),
                  // InkWell(

                  //   onTap: () {
                  //     addCurrency(width: width,context: context);
                  //   },
                  //   child: _buildComencards(
                  //       title: "Currency",
                  //       iconpath: "assets/images/dollar-circle.svg"),
                  // ),
                  // InkWell(

                  //  onTap: () {
                  //    transfer(width: width,context: context);
                  //  },
                  //   child: _buildComencards(
                  //       title: "Transfer",
                  //       iconpath: "assets/images/credit-card-convert.svg"),
                  // ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/creditCard');
                      contoller.colorSelecter(value: 5);
                    },
                    child: _buildComencards(
                        title: "Buy Token",
                        iconpath: "assets/images/shop-add.svg"),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pushNamed(context, '/sellCrypto');
                      contoller.colorSelecter(value: 7);
                      contoller.function(value: -1);
                    },
                    child: _buildComencards(
                        title: "Sell Token",
                        iconpath: "assets/images/wallet1.svg"),
                  ),
                  // _buildComencards(
                  //     title: "More",
                  //     iconpath: "assets/images/element-plus.svg"),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
            ]),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 30),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: notifire.getGry700_300Color),
              color: notifire.getBgColor),
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: width < 600 ? 15 : 24,
                vertical: width < 600 ? 15 : 29),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Quick Exchange (Coming Soon)".tr,
                      style: Typographyy.heading6
                          .copyWith(color: notifire.getTextColor),
                    ),
                    TextButton.icon(
                      onPressed: () => _openSwapDialog(width, context),
                      icon: const Icon(Icons.sync_alt, size: 18),
                      label: Text(
                        "Coming Soon",
                        style: Typographyy.bodyMediumExtraBold
                            .copyWith(color: priMeryColor),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: priMeryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Text(
                  "Swap tokens will be available soon. Stay tuned for updates."
                      .tr,
                  style: Typographyy.bodyMediumMedium
                      .copyWith(color: notifire.getGry500_600Color),
                ),
                const SizedBox(
                  height: 18,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      colors: [
                        colorWithOpacity(priMeryColor, 0.12),
                        colorWithOpacity(priMeryColor, 0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Exchange with wallet rates",
                              style: Typographyy.bodyLargeExtraBold
                                  .copyWith(color: notifire.getTextColor),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Swap actions are disabled until the feature launches."
                                  .tr,
                              style: Typographyy.bodyMediumMedium
                                  .copyWith(color: notifire.getGry500_600Color),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => _openSwapDialog(width, context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: priMeryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          "Coming Soon",
                          style: Typographyy.bodyMediumExtraBold
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
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
      return '$month ${parsed.day}, ${parsed.year}';
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
      return 'Completed';
    }
    if (normalized.contains('initiated') ||
        normalized.contains('pending') ||
        normalized.contains('processing')) {
      return 'Pending';
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

  Future<void> _openSwapDialog(double width, BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text("Coming Soon".tr),
          content: Text(
            "Token swap is not available yet.".tr,
            style: Typographyy.bodyMediumMedium
                .copyWith(color: notifire.getGry500_600Color),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                "Close".tr,
                style: Typographyy.bodyMediumSemiBold
                    .copyWith(color: priMeryColor),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openWithdraw(
      {required double width, required BuildContext context}) async {
    Navigator.pushNamed(context, '/withdrawal');
    contoller.function(value: -1);
    contoller.colorSelecter(value: 20);
  }

  List<Widget> _buildWalletCards(
      DashBordeController controller, BuildContext context, double width,
      {Map<String, String>? walletDisplay}) {
    final display = walletDisplay ?? _walletDisplayStrings(controller);

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

  bool isExchange = false;

  Widget _buildComencards({required String title, required String iconpath}) {
    return Column(
      children: [
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: notifire.getGry700_300Color),
          ),
          child: Center(
              child: SvgPicture.asset(
            iconpath,
            height: 24,
            width: 24,
          )),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(title.tr,
            style: Typographyy.bodyMediumSemiBold
                .copyWith(color: notifire.getGry500_600Color)),
      ],
    );
  }

  TableRow row(
      {required String title,
      required String date,
      required String profile,
      required String price,
      required String tralling,
      required Color textcolor}) {
    return TableRow(children: [
      CircleAvatar(
          radius: 20,
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage(profile)),
      Padding(
        padding: const EdgeInsets.only(top: 10, left: 20),
        child: Text(title,
            style: Typographyy.bodyMediumExtraBold
                .copyWith(color: notifire.getTextColor)),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
              width: 20,
              child: SvgPicture.asset("assets/images/calendar.svg"),
            ),
            const SizedBox(
              width: 8,
            ),
            Text(date,
                style: Typographyy.bodyMediumMedium
                    .copyWith(color: notifire.getGry500_600Color)),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Center(
            child: Text(price,
                style: Typographyy.bodyMediumExtraBold
                    .copyWith(color: notifire.getTextColor))),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Center(
            child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: colorWithOpacity(textcolor, 0.2),
                    borderRadius: BorderRadius.circular(8)),
                height: 32,
                width: 50,
                child: Center(
                    child: Text(tralling,
                        style: Typographyy.bodySmallMedium
                            .copyWith(color: textcolor))))),
      ),
    ]);
  }
}

TableRow tableroww(
    {required String logo,
    required String price,
    required String subtitle,
    required String id,
    required String date,
    required String status,
    required String fees,
    required Color color,
    context}) {
  ColorNotifire notifire = Provider.of<ColorNotifire>(context, listen: true);
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

class DashboardEndGraphic extends StatelessWidget {
  const DashboardEndGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    final notifire = Provider.of<ColorNotifire>(context, listen: true);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: notifire.getGry700_300Color),
            ),
            child: CircleAvatar(
              radius: 38,
              backgroundColor: Colors.transparent,
              backgroundImage:
                  const AssetImage('assets/images/03.png'),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Made with ❤️ by Nirvista',
            style: Typographyy.bodySmallMedium.copyWith(
              color: notifire.getTextColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Widget buildiconandtitle({required String title, context}) {
  ColorNotifire notifire = Provider.of<ColorNotifire>(context, listen: true);
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
        const SizedBox(
          width: 8,
        ),
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
