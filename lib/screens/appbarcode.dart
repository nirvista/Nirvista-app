// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../ConstData/colorprovider.dart';
import '../ConstData/typography.dart';
import '../controller/appbarcontroller.dart';
import '../controller/drawercontroller.dart';
import '../controller/settings_nav_controller.dart';
import '../services/auth_api_service.dart';
import 'authscreens/singin.dart';

class AppBarCode extends StatefulWidget implements PreferredSizeWidget {
  const AppBarCode({super.key});

  @override
  State<AppBarCode> createState() => _AppBarCodeState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarCodeState extends State<AppBarCode> {

  DrawerControllerr controllerr = Get.put(DrawerControllerr());
  AppBarController  appBarController = Get.put(AppBarController());
  ColorNotifire notifire = ColorNotifire();
  String _profileName = 'User';
  String _profileEmail = '';
  String? _profileImageUrl;
  bool _profileLoading = false;
  String? _accountLevel;
  String _kycStatus = 'pending';

  bool _isPlaceholderEmail(String? email) {
    if (email == null) {
      return true;
    }
    final trimmed = email.trim();
    if (trimmed.isEmpty || trimmed == '-') {
      return true;
    }
    return trimmed.toLowerCase().contains('mobile.local');
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _profileLoading = true;
    });
    try {
      final res = await AuthApiService.profile();
      if (res['success'] == true) {
        final data = res['data'] is Map<String, dynamic>
            ? res['data'] as Map<String, dynamic>
            : res;
        if (!mounted) return;
        setState(() {
          _profileName = data['name']?.toString().trim().isNotEmpty == true
              ? data['name'].toString()
              : 'User';
          final emailValue = data['email']?.toString();
          _profileEmail = _isPlaceholderEmail(emailValue)
              ? ''
              : emailValue!.trim();
          final profileUrl = data['profileImageUrl']?.toString();
          final selfieUrl = data['selfieUrl']?.toString();
          _profileImageUrl = (profileUrl != null && profileUrl.isNotEmpty)
              ? profileUrl
              : (selfieUrl != null && selfieUrl.isNotEmpty ? selfieUrl : null);
          final verification = data['verification'];
          final kycValue = verification is Map<String, dynamic>
              ? (verification['kycStatus'] ?? verification['status'])
              : data['kycStatus'] ?? data['kycStatusLabel'];
          _kycStatus = kycValue?.toString().toLowerCase() ?? 'pending';
          final levelValue = data['accountLevel'] ??
              data['level'] ??
              data['tier'] ??
              data['userLevel'];
          _accountLevel = levelValue?.toString();
        });
      }
    } catch (_) {
      // keep defaults
    } finally {
      if (mounted) {
        setState(() {
          _profileLoading = false;
        });
      }
    }
  }

  ImageProvider _profileImageProvider() {
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return const AssetImage("assets/images/05.png");
  }

  String? _accountLevelLabel() {
    final level = _accountLevel?.trim();
    if (level == null || level.isEmpty) return null;
    return level;
  }

  String _kycStatusLabel() {
    switch (_kycStatus) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return _kycStatus.isEmpty
            ? 'Pending'
            : _kycStatus[0].toUpperCase() + _kycStatus.substring(1);
    }
  }

  void _openSettingsTab({required int tabIndex, int profileTabIndex = 0}) {
    final nav = Get.put(SettingsNavController());
    nav.setInitialTab(tabIndex, profileTabIndex: profileTabIndex);
    Navigator.pushNamed(context, '/settings');
    controllerr.function(value: -1);
    controllerr.colorSelecter(value: 17);
  }

  @override
  Widget build(BuildContext context) {
    notifire = Provider.of<ColorNotifire>(context,listen: true);
    return GetBuilder<AppBarController>(
      builder: (appBarController) {
        return LayoutBuilder(builder: (context, constraints) {
          return constraints.maxWidth < 800
              ? appbarr(isphon: true,size: constraints.maxWidth)
              : PreferredSize(
                  preferredSize: const Size.fromHeight(115),
                  child: appbarr(isphon: false,size: constraints.maxWidth),
                );
        });
      }
    );
  }

  Widget _assetWidget(String path, {double? height, double? width, Color? color}) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.svg')) {
      return SvgPicture.asset(path, height: height, width: width, color: color);
    }
    return Image.asset(path, height: height, width: width, color: color, fit: BoxFit.cover);
  }

  PreferredSizeWidget appbarr({required bool isphon,required double size}) {
    notifire = Provider.of<ColorNotifire>(context, listen: true);
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: isphon ? 52 : 115,
      backgroundColor: notifire.getBgColor,
      elevation: 0,
      actions: [
        const SizedBox(),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                color: appBarController.isLanguage?  notifire.getGry100_300Color :notifire.getDrawerColor,
              ),
              width: isphon? 50 :150,
            ),
            PopupMenuButton(
                onOpened: () {
                  appBarController.setisLanguage(true);
                },
                onCanceled: () {
                  appBarController.setisLanguage(false);
                },
                tooltip: "",
                color: notifire.getContainerColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                offset:  Offset(-5, isphon? 50 :55),
                padding: EdgeInsets.zero,
                itemBuilder: (ctx) => [
                  language(),
                ],
                child: isphon? CircleAvatar(
                backgroundColor: Colors.transparent,
                  radius: 15,
                  child: _assetWidget(appBarController.countryLogo[appBarController.lenguageselcet], height: 30, width: 30),
                 ) :
                Container(
                   height: 48,
                   width: 160,
                  margin: const EdgeInsets.all(4),
                  color: Colors.transparent,
                  child: ListTile(
                    onTap: null,
                    trailing:  Transform.translate(
                        offset: const Offset(-15, 0),
                        child: SvgPicture.asset(appBarController.isLanguage? "assets/images/chevron-up.svg"  :"assets/images/chevron-down.svg")),
                    leading:  CircleAvatar(
                      radius: 15,
                    backgroundColor: Colors.transparent,
                     child: _assetWidget(appBarController.countryLogo[appBarController.lenguageselcet], height: 30, width: 30),
                    ),
                    title: Text(appBarController.lanuage[appBarController.lenguageselcet], style: Typographyy.bodyLargeMedium.copyWith(color:  notifire.getTextColor),maxLines: 1,),
                  ),
                )
            )
          ],
        ),
        isphon? const SizedBox(width: 10,): const SizedBox(),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/myWallets');
            controllerr.function(value: -1);
            controllerr.colorSelecter(value: 3);
          },
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: notifire.getDrawerColor),
              child: Center(
                  child: SvgPicture.asset("assets/images/wallet.svg",
                      height: 24, width: 24, color: notifire.getIconColor))
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: appBarController.isnotification ? notifire.getGry100_300Color : notifire.getDrawerColor),
          child: Theme(
            data: ThemeData(
                splashColor: Colors.transparent,
                hoverColor: Colors.transparent,
              dialogBackgroundColor: notifire.getDrawerColor
                ),
            child: PopupMenuButton(
              onOpened: () {
                appBarController.setisnotification(true);
              },
              onCanceled:  () {
                appBarController.setisnotification(false);
              },
              constraints: const BoxConstraints(
                maxWidth: 396,
                minWidth: 396,
              ),
              tooltip: "",
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              color: notifire.getContainerColor,
              offset:  Offset(50, isphon? 55 : 80),
              icon: Center(
                  child: SvgPicture.asset("assets/images/bell.svg",
                      height: 28, width: 28, color: notifire.getIconColor)),
              itemBuilder: (ctx) => [
                notification(isphon: isphon),
              ],
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 48,
               margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(120),
                color: appBarController.isAccount?  notifire.getGry100_300Color :notifire.getDrawerColor,
              ),
              width: isphon? 50 :165,
            ),
            PopupMenuButton(
              onOpened: () {
                appBarController.setisAccount(true);
              },
              onCanceled: () {
                appBarController.setisAccount(false);
              },
              color: notifire.getContainerColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              offset:  Offset(10, isphon? 55 :85),
                constraints: const BoxConstraints(
                  minWidth: 260,
                  maxWidth: 300,
                ),
                tooltip: "",
                itemBuilder: (ctx) => [
                account(isphon: isphon),
              ],
                padding: EdgeInsets.zero,
                child: isphon?   CircleAvatar(
                  radius: 15,
                 backgroundColor: Colors.transparent,
                  backgroundImage: _profileImageProvider()) : Container(
                // height: 48,
                width: 180,
                color: Colors.transparent,
                child: Center(
                  child: ListTile(
                    onTap: null,
                    trailing: Transform.translate(
                        offset: const Offset(-10, 0),
                        child: SvgPicture.asset(appBarController.isAccount? "assets/images/chevron-up.svg"  :"assets/images/chevron-down.svg")),
                    leading:  CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.transparent,
                        backgroundImage: _profileImageProvider()),
                    title: Text(
                      _profileName,
                      style: Typographyy.bodyLargeMedium
                          .copyWith(color: notifire.getTextColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
      leadingWidth: isphon? 60 : 150,
      leading: isphon ? InkWell(
          onTap: () {
            Scaffold.of(context).openDrawer();
          },
          child: SizedBox(
              height: 20,
              width: 20,
              child: Center(child: SvgPicture.asset("assets/images/menu-left.svg",height: 20,width: 20,color: notifire.getTextColor,))) ) : Center(child: Text("${controllerr.pageTitle[controllerr.currentcolor]}", style: Typographyy.heading4.copyWith(color: notifire.getTextColor))),
      centerTitle: true,
      title: const SizedBox(),
    );
  }

  PopupMenuItem search(){
    return PopupMenuItem(
      enabled: false,
        child: SizedBox(
          height: 42,
          child: Center(
            child: TextField(
              style: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),
              decoration: InputDecoration(
                  hintStyle: Typographyy.bodyMediumMedium.copyWith(color: notifire.getGry500_600Color),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),borderSide: BorderSide(color: notifire.getGry700_300Color)),
                  hintText: "Search.."
              ),
            ),
          ),
        ));
  }
  PopupMenuItem language(){
    final itemCount = appBarController.lanuage.length;
    const tileHeight = 46.0;
    final height = (itemCount * tileHeight).clamp(tileHeight, 220.0).toDouble();
    return PopupMenuItem(
      padding: EdgeInsets.zero,
        child:
    SizedBox(
      height: height,
      width: 160,
      child: ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        itemCount: appBarController.countryLogo.length,
        itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            if (!appBarController.isCountryAvailable(index)) {
              Get.back();
              Get.snackbar(
                "Coming Soon",
                "${appBarController.lanuage[index]} is not available yet.",
                snackPosition: SnackPosition.BOTTOM,
              );
              return;
            }
            appBarController.selectlanguage(index);
            Future.delayed(const Duration(milliseconds: 200), () {
              Get.back();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: Colors.transparent,
                  child: _assetWidget(
                    appBarController.countryLogo[index],
                    height: 30,
                    width: 30,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    appBarController.lanuage[index],
                    style: Typographyy.bodyLargeMedium
                        .copyWith(color: notifire.getTextColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },),
    ));
  }
  PopupMenuItem account({required bool isphon}) {
    return PopupMenuItem(
      enabled: true,
      padding: EdgeInsets.zero,
        child:  GetBuilder<DrawerControllerr>(
          builder: (controllerr) {
            return StatefulBuilder(
              builder: (context, setState){
                return Padding(
                  padding: const EdgeInsets.all(8),
                  child: SingleChildScrollView(
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                   ListTile(
                     title: Text(
                       _profileName,
                       style: Typographyy.bodyLargeExtraBold
                           .copyWith(color: notifire.getTextColor),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                     ),
                     subtitle: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         if (_profileLoading || _profileEmail.isNotEmpty)
                           Padding(
                             padding: const EdgeInsets.only(top: 4),
                             child: Text(
                               _profileLoading ? "Loading..." : _profileEmail,
                               style: Typographyy.bodySmallMedium
                                   .copyWith(color: notifire.getGry500_600Color),
                               maxLines: 1,
                               overflow: TextOverflow.ellipsis,
                             ),
                           ),
                         Padding(
                           padding: const EdgeInsets.only(top: 4),
                           child: Text(
                             [
                               if (_accountLevelLabel() != null)
                                 'Level: ${_accountLevelLabel()}',
                               'KYC: ${_kycStatusLabel()}',
                             ].join(' | '),
                             style: Typographyy.bodySmallMedium
                                 .copyWith(color: notifire.getGry500_600Color),
                             maxLines: 2,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ),
                       ],
                     ),
                     isThreeLine: true,
                   ),
                   Divider(
                     color: notifire.getGry700_300Color,
                     height: 8,
                   ),
                   ListTile(
                     onTap: () {
                       Get.back();
                        _openSettingsTab(tabIndex: 0, profileTabIndex: 0);
                     },
                     dense: true,
                     leading: SizedBox(
                         height: 22,
                         width: 22,
                         child: SvgPicture.asset("assets/images/user.svg",height: 22,width: 22,color: notifire.getGry500_600Color,)),
                     title: Text("Your details".tr,style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                     subtitle: Text("Important account details".tr,style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color)),
                   ),
                   ListTile(
                     onTap: () {
                       Get.back();
                       _openSettingsTab(tabIndex: 3);
                     },
                     dense: true,
                     leading: SizedBox(
                         height: 22,
                         width: 22,
                         child: SvgPicture.asset("assets/images/fingerprint-viewfinder.svg",height: 22,width: 22,color: notifire.getGry500_600Color,)),

                     subtitle: Text("Setup pin for more security".tr,style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color)),
                     title: Text("pin security".tr,style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                   ),
                   ListTile(
                     onTap: () {
                       Get.back();
                       _openSettingsTab(tabIndex: 1);
                     },
                     dense: true,
                     leading: SizedBox(
                         height: 22,
                         width: 22,
                         child: SvgPicture.asset("assets/images/share.svg",height: 22,width: 22,color: notifire.getGry500_600Color,)),

                     subtitle: Text("Invite your friends and earn rewards".tr,style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color)),
                     title: Text("Referrals".tr,style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                   ),
                   ListTile(
                     onTap: () {
                       Get.back();
                       _openSettingsTab(tabIndex: 0, profileTabIndex: 0);
                     },
                     dense: true,
                     leading: SizedBox(
                         height: 22,
                         width: 22,
                         child: SvgPicture.asset("assets/images/settings.svg",height: 22,width: 22,color: notifire.getGry500_600Color,)),

                     subtitle: Text("View additional settings".tr,style: Typographyy.bodySmallMedium.copyWith(color: notifire.getGry500_600Color)),
                     title: Text("Account settings".tr,style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                   ),
                   const SizedBox(height: 8,),
                   ListTile(
                     onTap: () {
                       Get.back();
                       Get.off(const SingInScreen());
                       controllerr.colorSelecter(value: 8);
                     },
                     dense: true,
                     leading: SizedBox(
                         height: 22,
                         width: 22,
                         child: SvgPicture.asset("assets/images/tabler_logout.svg",height: 22,width: 22,color: notifire.getGry500_600Color,)),
                     title: Text("Log out".tr,style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                   ),
                   Divider(
                     color: notifire.getGry700_300Color,
                     height: 8,
                   ),
                   Consumer<ColorNotifire>(
                     builder: (context, value, child) => ListTile(
                       title: Text("Dark mode",style: Typographyy.bodyMediumSemiBold.copyWith(color: notifire.getTextColor)),
                       trailing: Padding(
                         padding: const EdgeInsets.symmetric(vertical: 8.0),
                         child: CupertinoSwitch(
                           value: notifire.getIsDark,
                           activeColor: Colors.black,
                           offLabelColor: Colors.grey,
                           onChanged: (value) async{
                               await notifire.isavalable(value);
                               Get.back();
                           },),
                       ),
                       ),
                      ),
                    ],
                  ),
                  ),
                );
               }
             );
           }
         )
      );
  }
  PopupMenuItem notification({required bool isphon}) {
    final height = isphon ? 220.0 : 260.0;
    return PopupMenuItem(
      enabled: false,
      padding: EdgeInsets.zero,
      child: Container(
        width: 396,
        height: height,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Text(
          "Notifications are disabled".tr,
          textAlign: TextAlign.center,
          style: Typographyy.bodyMediumExtraBold
              .copyWith(color: notifire.getGry500_600Color),
        ),
      ),
    );
  }

}
