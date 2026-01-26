import 'package:get/get.dart';

class SettingsNavController extends GetxController implements GetxService {
  int initialTabIndex = 0;
  int initialProfileTabIndex = 0;

  void setInitialTab(int tabIndex, {int profileTabIndex = 0}) {
    initialTabIndex = tabIndex;
    initialProfileTabIndex = profileTabIndex;
    update();
  }
}
