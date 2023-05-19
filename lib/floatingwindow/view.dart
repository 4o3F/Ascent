import 'package:android_window/android_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import '../generated/l10n.dart';
import '../pairing/pair/view.dart';

class FloatingwindowPage extends StatelessWidget {
  const FloatingwindowPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AndroidWindow.setHandler((name, data) async {
      debugPrint("Android window event received: ${name} / ${data}");
      switch (name) {
        case "SWITCH_STAGES":
          switch (data.toString()) {
            case "PAIR":
              Get.toNamed("/pair");
          }
          break;
      }
    });
    debugPrint("Android window event handler registered");
    AndroidWindow.post("REQUEST_STAGE");
    debugPrint("Android window stage request send");
    return AndroidWindow(
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            body: GetMaterialApp(
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
                useMaterial3: true,
              ),
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              debugShowCheckedModeBanner: false,
              initialRoute: "/pair",
              getPages: [GetPage(name: "/pair", page: () => PairingPairPage())],
            ),
          ),
        ));
  }
}
