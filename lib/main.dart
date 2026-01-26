import 'dart:async';
import 'dart:ui';

import 'package:nirvista/ConstData/string_file.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

import 'ConstData/colorprovider.dart';
import 'ConstData/routes2.dart';
Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    setPathUrlStrategy();
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(ColorNotifire.themePreferenceKey) ?? false;
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('Uncaught platform error: $error');
      return true; // prevent crash by marking as handled
    };
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return const Scaffold(
        body: Center(
          child: Text(
            "Something went wrong.\nPlease restart the app.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    };
    runApp(MyApp(initialIsDark: isDark));
  }, (error, stack) {
    debugPrint('Uncaught zone error: $error');
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialIsDark});

  final bool initialIsDark;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Flurorouter.setupRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ColorNotifire(initialIsDark: widget.initialIsDark),
        ),
      ],
      child: GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        debugShowCheckedModeBanner: false,
        initialRoute: '/dashboard',
        onGenerateRoute: Flurorouter.router.generator,
        title: 'Nirvista',
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
        theme: ThemeData(
          fontFamily: "Gilroy-Regular",
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          dividerColor: Colors.transparent,
          colorScheme: ColorScheme.fromSwatch().copyWith(
            primary: const Color(0xff0B7D7B),
          ),
        ),
      ),
    );
  }
}

class NoThumbScrollBehavior extends ScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.stylus,
      };
 }
