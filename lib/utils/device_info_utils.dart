import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:get/get.dart';


class DeviceInfo {
  static final DeviceInfo INSTANCE = DeviceInfo();
  Rx<bool> loadFinished = false.obs;
  late String brand;
  late int androidSdkVersion;

  DeviceInfo() {
    DeviceInfoPlugin().androidInfo.then((value) {
        androidSdkVersion = value.version.sdkInt;
        brand = value.brand;
        loadFinished.value = true;
    });
  }
}
