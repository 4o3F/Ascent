import 'dart:io';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

class GlobalState {
  static const platform = MethodChannel('cafe.f403.ascent/main');
  static Rx<String> currentRoute = "/home".obs;
  static late final Directory dataDir;
  static const String localizationAssetPath = "assets/translations";

  static const List<Locale> supportedLocale = [
    Locale('en', 'US'),
    Locale('zh', 'CN'),
  ];

  static void init() async {
    dataDir = await getApplicationDocumentsDirectory();
  }
}
