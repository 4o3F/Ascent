import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:path_provider/path_provider.dart';

class GlobalState {
  static const version = "2.1.3";
  static String discord = "https://discord.gg/6v6HEUaRWk";

  static const platform = MethodChannel('cafe.f403.ascent/main');
  static Rx<String> currentRoute = "/home".obs;
  static late final Directory dataDir;
  static const String localizationAssetPath = "assets/translations";
  static Rx<bool> hasCert = false.obs;
  static late Mixpanel mixpanel;
  static StreamSubscription? intentSubscription;
  static String? locale;

  static const List<Locale> supportedLocale = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  static void init() async {
    dataDir = await getApplicationDocumentsDirectory();
    hasCert.value = File("${dataDir.path}/cert.pem").existsSync();
    if (kDebugMode) {
      print("Data directory: ${dataDir.path}");
    }
    mixpanel = await Mixpanel.init("1bad86a59f59ee1d395c31b61bf9202a",
        trackAutomaticEvents: true);
  }
}
