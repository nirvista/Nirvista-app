import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/drawerpagess/sellcrypto/s_step1.dart';
import '../screens/drawerpagess/sellcrypto/s_step2.dart';
import '../screens/drawerpagess/sellcrypto/s_step3.dart';


class SellCryptoController  extends  GetxController implements GetxService {

  int priceSelect = -1;

  setPriceSelect(value){
    priceSelect = value;
    update();
  }

  ScrollController scrollController = ScrollController();

  TextEditingController priceController = TextEditingController();

  var selectIndex = [];

  int selectStep = 0;

  setSelectStep(value){
    selectStep = value;
    update();
  }

  List step = [
    const SellStep1(),
    const SellStep2(),
    const SellStep3(),
  ];


}