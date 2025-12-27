import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aiphotokit/config/dependencies.dart';
import 'package:aiphotokit/config/router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';

Future<void> initRevenueCat() async {
  // ignore: deprecated_member_use
  await Purchases.setDebugLogsEnabled(true);

  PurchasesConfiguration configuration = PurchasesConfiguration("");

  if (Platform.isIOS) {
    configuration = PurchasesConfiguration(dotenv.env['REVENUECAT_IOS'] ?? '');
  }

  await Purchases.configure(configuration);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  await initRevenueCat();

  runApp(MultiProvider(providers: defaultProviders, child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AIPhotoKit',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF141414),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.white,
          selectionHandleColor: Colors.grey,
          selectionColor: Colors.white.withValues(alpha: 0.2),
        ),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
          backgroundColor: Color(0xFF141414),
        ),
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFd89c4c),
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Color(0xFFd89c4c)),
            foregroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFd89c4c),
          foregroundColor: Colors.white,
        ),
      ),
      routerConfig: router(),
    );
  }
}
