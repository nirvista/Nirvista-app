import 'package:get/get.dart';

class TransactionController extends GetxController implements GetxService {

  bool isFilter = false;

  setIsFilter(bool value){
    isFilter =! isFilter;
    update();
  }


  bool isTypeMenu = false;
  int selectType =0;

  List type = [
    "All Transactions",
    "Past 30 Days",
    "Past 15 Days",
  ];

  setSelectType(int value){
    selectType = value;
    update();
  }
  setIsTypeMenu(bool value){
    isTypeMenu = value;
    update();
  }

  bool isArchieveMenu = false;
  int selectIsArchieveMenu =0;

  List archieveMenu = [
    "Active",
    "Past 30 Days",
    "Past 15 Days",
  ];
  setSelectIsArchieveMenu(int value){
    selectIsArchieveMenu = value;
    update();
  }
  setIsArchieveMenu(bool value){
    isArchieveMenu = value;
    update();
  }

  bool isTransactionMenu = false;
  List transactionMenu = [
    "All Transactions",
    "Past 30 Days",
    "Past 15 Days",
  ];
  int selectIsTransactionMenu =0;
  setSelectIsisTransactionMenu(int value){
    selectIsTransactionMenu = value;
    update();
  }
  setIsTransactionMenu(bool value){
    isTransactionMenu = value;
    update();
  }

  bool isDateMenu = false;
  List dateMenu = [
    "Past 30 Days",
    "Past 15 Days",
    "Past 2 Month",
  ];
  int selectIsDateMenu =0;
  setSelectIsDateMenu(int value){
    selectIsDateMenu = value;
    update();
  }
  setIsDateMenu(bool value){
    isDateMenu = value;
    update();
  }

  bool isAmountMenu = false;

  List amountMenu = [
    "Past 30 Days",
    "Past 15 Days",
    "Past 2 Month",
  ];
  int selectIsAmountMenu =0;
  setSelectIsAmountMenu(int value){
    selectIsAmountMenu = value;
    update();
  }
  setIsAmountMenu(bool value){
    isAmountMenu = value;
    update();
  }
  }