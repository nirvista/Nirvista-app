import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nirvista/screens/drawerpagess/analytics.dart';
import '../screens/drawerpagess/dashboard.dart';
import '../screens/drawerpagess/gethelp.dart';
import '../screens/drawerpagess/chatscreenpages/messages.dart';
import '../screens/drawerpagess/my_wallets.dart';
import '../screens/drawerpagess/settings.dart';
import '../screens/drawercode.dart';
import '../screens/drawerpagess/transactions.dart';

class DrawerControllerr extends GetxController implements GetxService {
  static const int tokenStakingColorIndex = 21;
  int currentIndex = -1;
  int currentcolor = 0;
  RxInt index = 0.obs;
  // RxInt pageSelecter = 0.obs;
  RxBool istrue = false.obs;
  int selectedTile = -1.obs;

  bool isRtl = false;

  setRTL(bool value) {
    isRtl = value;
    update();
  }

  bool isLoading = false;

  offIsLoading(context, double width) {
    isLoading = true;
    update();
    Timer(const Duration(seconds: 2), () {
      isLoading = false;
      update();

      Get.back();
      Navigator.pushNamed(context, '/dashboard');
      function(value: -1);
      colorSelecter(value: 0);
      complete1(context, width: width);
    });
  }

  List page = [
    const Dashboard(),
    const Transactions(),
    const Messages(),
    const MyWallets(),
    const Analytics(),
    const GetHelp(),
    const Settings(),
    const GetHelp(),
  ].obs;

  List pageTitle = [
    'Dashboard',
    'Transactions',
    'Activity',
    'My Wallets',
    'Transfer',
    'Nirvista ICO',
    'Bank Deposit',
    'Sell Token',
    'Sign In',
    'Sign Up',
    'Authentication',
    'Forget Password',
    'Reason',
    'Transactions',
    'Recipients',
    'Analytics',
    'Get Help',
    'Settings',
    'Policy Pages',
    'Bank Details',
    'Withdrawal',
    'Token Staking',
  ];

  bool isTransfer = false;
  setIsTransfer(value) {
    isTransfer = value;
    update();
  }

  bool isFrom = false;

  setIsFrom(value) {
    isFrom = value;
    update();
  }

  bool isto = false;

  setIsTo(value) {
    isto = value;
    update();
  }

  bool isCoin = false;
  setIsCoin(value) {
    isCoin = value;
    update();
  }

  int selectFrom = 0;
  setSelectFrom(value) {
    selectFrom = value;
    update();
  }

  List from = [
    "Spot",
    "Margin",
    "Fiat",
    "P2P",
    "Convert",
  ];

  int selectTo = 0;
  setSelectTo(value) {
    selectTo = value;
    update();
  }

  List to = [
    "COIN-M Futures",
    "USD-M Futures",
    "Options",
    "Spot Wallet",
  ];

  int selectCoins = 0;
  setSelectCoin(value) {
    selectCoins = value;
    update();
  }

  List coins = [
    "Bitcoin",
    "Binance Coin",
    "Dogecoin",
    "Cardano",
    "Ethereum",
  ];

  function({required int value}) {
    currentIndex = value;
    update();
  }

  colorSelecter({required int value}) {
    final maxIndex = pageTitle.length - 1;
    if (maxIndex >= 0) {
      currentcolor = value.clamp(0, maxIndex).toInt();
    } else {
      currentcolor = 0;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isClosed) {
        update();
      }
    });
  }
}
