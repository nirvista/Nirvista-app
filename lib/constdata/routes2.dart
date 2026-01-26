import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import '../screens/authscreens/spalshscreen.dart';
import '../screens/authscreens/singin.dart';
import '../screens/authscreens/signup_disabled.dart';
import '../screens/authscreens/ekyc.dart';
import '../screens/authscreens/signup_otp_screen.dart';
import '../screens/authscreens/signup_pin_screen.dart';
import '../screens/homepage.dart';
import '../screens/drawerpagess/bank_details_page.dart';
import '../screens/drawerpagess/bank_edit.dart';
import '../screens/drawerpagess/bank_edit_otp.dart';
import '../screens/drawerpagess/withdrawal.dart';

class Flurorouter {


  static final FluroRouter router = FluroRouter();

  static final Handler _splashHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const SplashScreen());

  static final Handler _mainHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) {
    return HomePage(page: params['name'][0]);});

  static final Handler _mainHandler2 = Handler(handlerFunc: (context, Map<String, dynamic> params) => HomePage(page: params['name'][0]));

  static final Handler _signInHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const SingInScreen());
static final Handler _signUpHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const SignupDisabledScreen());
  static final Handler _ekycHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const KycPage());
  static final Handler _signUpOtpHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const SignupOtpScreen());
  static final Handler _signUpPinHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const SignupPinScreen());
  static final Handler _bankDetailsHandler = Handler(
      handlerFunc: (context, Map<String, dynamic> params) =>
          const BankDetailsPage());
  static final Handler _bankEditOtpHandler = Handler(
      handlerFunc: (context, Map<String, dynamic> params) =>
          const BankEditOtpPage());
  static final Handler _bankEditHandler = Handler(
      handlerFunc: (context, Map<String, dynamic> params) {
    final args =
        context == null ? null : ModalRoute.of(context)?.settings.arguments;
    String? otpValue;
    if (args is Map<String, dynamic>) {
      final otp = args['otp'];
      if (otp is String && otp.isNotEmpty) {
        otpValue = otp;
      } else if (otp != null) {
        otpValue = otp.toString();
      }
    }
    return BankEditPage(otp: otpValue);
  });
  static final Handler _withdrawalHandler = Handler(handlerFunc: (context, Map<String, dynamic> params) => const WithdrawalPage());

  static void setupRouter(){
    router.define(
      '/',
      handler: _splashHandler,
    );
    router.define(
      '/signin',
      handler: _signInHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/signup',
      handler: _signUpHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/signup/otp',
      handler: _signUpOtpHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/signup/pin',
      handler: _signUpPinHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/ekyc',
      handler: _ekycHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/bankDetails',
      handler: _bankDetailsHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/bankEditOtp',
      handler: _bankEditOtpHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/bankEdit',
      handler: _bankEditHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/withdrawal',
      handler: _withdrawalHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/:name',
      handler: _mainHandler,
      transitionType: TransitionType.fadeIn,
    );
    router.define(
      '/:name/:extra',
      handler: _mainHandler2,
      transitionType: TransitionType.fadeIn,
    );

    router.notFoundHandler = Handler(
        handlerFunc: (BuildContext? context, Map<String, dynamic> params) {
          return const Scaffold(backgroundColor: Colors.white,body: Center(child: Text("something wrong !!!!!",style: TextStyle(color: Colors.red),)),);
        });

  }

}
