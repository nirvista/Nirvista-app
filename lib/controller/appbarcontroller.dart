import 'package:get/get.dart';

class AppBarController extends GetxController implements GetxService{

  bool isnotification = false;
  bool isAccount = false;
  bool isLanguage = false;
  bool isSearch = false;
  int lenguageselcet = 0;

  List lanuage = [
    "India",
    "USA",
    "VIETNAM",
    "UAE",
  ];

  List countryLogo = [
    "assets/images/in.svg",
    "assets/images/usa.jpg",
    "assets/images/vietnam.png",
    "assets/images/uae.jpg",
  ];

  List<bool> countryAvailable = [
    true,
    false,
    false,
    false,
  ];

  bool isCountryAvailable(int index) {
    if (index < 0 || index >= countryAvailable.length) return false;
    return countryAvailable[index];
  }

  selectlanguage(int value){
    lenguageselcet = value;
    update();
  }

  selectisSearch(bool value){
    isSearch = value;
    update();
  }

  setisnotification(bool value){
    isnotification = value;
    update();
  }
  setisAccount(bool value){
    isAccount = value;
    update();
   }
  setisLanguage(bool value){
    isLanguage = value;
    update();
  }
}
