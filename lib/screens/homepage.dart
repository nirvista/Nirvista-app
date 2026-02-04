import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';
import '../controller/drawercontroller.dart';

import 'package:nirvista/screens/drawerpagess/analytics.dart';
import 'drawerpagess/dashboard.dart';
import 'drawerpagess/gethelp.dart';
import 'drawerpagess/chatscreenpages/messages.dart';
import 'drawerpagess/my_wallets.dart';
import 'drawerpagess/recipients.dart';
import 'drawerpagess/settings.dart';
import 'drawerpagess/transactions.dart';
import 'appbarcode.dart';
import 'drawercode.dart';
import 'drawerpagess/buycrypto/bankdeposit.dart';
import 'drawerpagess/buycrypto/creditcard.dart';
import 'drawerpagess/sellcrypto/sell_crypto.dart';
import 'drawerpagess/bank_edit.dart';
import '../CommonWidgets/footer_section.dart';

class HomePage extends StatefulWidget {
  final String page;
  const HomePage({super.key, required this.page});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ColorNotifire notifire = ColorNotifire();
  DrawerControllerr controller = Get.put(DrawerControllerr());

  Future<void> _refreshHome() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  static const Map<String, int> _pageTitleIndex = {
    'dashboard': 0,
    'invoices': 1,
    'messages': 2,
    'myWallets': 3,
    'transfer': 4,
    'creditCard': 5,
    'bankDeposit': 6,
    'sellCrypto': 7,
    'signIn': 8,
    'signup': 9,
    'authentication': 10,
    'forgetPassword': 11,
    'reason': 12,
    'transactions': 13,
    'recipients': 14,
    'analytics': 15,
    'getHelp': 16,
    'settings': 17,
    'bankEdit': 19,
    'withdrawal': 20,
    'stacking': DrawerControllerr.tokenStackingColorIndex,
  };

  void _syncPageTitleColor() {
    final target = _pageTitleIndex[widget.page] ?? controller.currentcolor;
    controller.colorSelecter(value: target);
  }

  Widget _refreshableStack({required Widget child}) {
    return RefreshIndicator(
      onRefresh: _refreshHome,
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  child,
                  const SizedBox(height: 24),
                  if (widget.page != 'dashboard') const FooterSection(),
                ],
              ),
          ),
        );
      }),
    );
  }

  Widget _pageForName(String pageName) {
    switch (pageName) {
      case 'dashboard':
        return const Dashboard();
      case 'transactions':
        return const Transactions();
      case 'messages':
        return const Messages();
      case 'myWallets':
        return const MyWallets();
      case 'transfer':
        return const Transactions();
      case 'creditCard':
        return const CreditCard();
      case 'bankDeposit':
        return const BankDeposit();
      case 'sellCrypto':
        return const SellCrypto();
      case 'recipients':
        return const Recipients();
      case 'analytics':
        return const Analytics();
      case 'getHelp':
        return const GetHelp();
      case 'settings':
        return const Settings();
      case 'bankEdit':
        return const BankEditPage();
      default:
        return const Dashboard();
    }
  }

  @override
  void initState() {
    super.initState();
    _syncPageTitleColor();
  }

  @override
  void didUpdateWidget(covariant HomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page != widget.page) {
      _syncPageTitleColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return GetBuilder<DrawerControllerr>(builder: (controller) {
      return Scaffold(
        body: LayoutBuilder(builder: (context, constraints) {
          //Mobile Layout
          if (constraints.maxWidth < 800) {
            return Scaffold(
              drawer: const DrawerCode(),
              appBar: const AppBarCode(),
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: notifire.getBgColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (constraints.maxWidth < 600)
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Text(
                            controller.pageTitle[controller.currentcolor]
                                .toString()
                                .tr,
                            style: Typographyy.heading4
                                .copyWith(color: notifire.getTextColor)),
                      ),
                    Expanded(
                      child: _refreshableStack(
                        child: _pageForName(widget.page),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          //webSite LayOut
          else {
            return Scaffold(
              body: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: notifire.getBgColor,
                child: Row(
                  children: [
                    const DrawerCode(),
                    Expanded(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const AppBarCode(),
                            if (constraints.maxWidth < 1000) ...[
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Text(
                                    controller
                                        .pageTitle[controller.currentcolor]
                                        .toString()
                                        .tr,
                                    style: Typographyy.heading4.copyWith(
                                        color: notifire.getTextColor)),
                              ),
                            ],

                            Expanded(
                              child: _refreshableStack(
                                child: _pageForName(widget.page),
                              ),
                            ),
                            //  Expanded(
                            //    child: Obx(() {
                            //    Widget selectedPage = controller.page[controller.pageSelecter.value];
                            // //   // Widget selectedPage = controller.page[controller.pageselecter.value];
                            // return selectedPage;
                            //    }),
                            //  ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }),
      );
    });
  }
}
