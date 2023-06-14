import 'dart:io';

import 'package:ascent/utils/common_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import 'logger.dart';

enum AscentStage { LAUNCH, PAIR, CONNECT, WATCHING, FINISHED }

enum AscentPages { FUNCTION, ABOUT }

enum PairingStatus { REQUIRED, DONE }

class AscentGlobalState extends GetxController {
  static AscentGlobalState INSTANCE = AscentGlobalState();
  Rx<AscentStage> ascentStage = AscentStage.LAUNCH.obs;
  Rx<AscentPages> ascentPage = AscentPages.FUNCTION.obs;

  Rx<PairingStatus> pairingStatus = PairingStatus.REQUIRED.obs;

  Rx<String> adbLibraryPath = "".obs;

  Mixpanel? mixpanel;

  final String pairingStatusKey = "pairing_status";

  void changePage(int destination) {
    ascentPage.value = AscentPages.values[destination];
    switch (destination) {
      case 0:
        Get.toNamed("/");
        break;
      case 1:
        Get.toNamed("/about");
    }
  }

  int getPage() {
    return ascentPage.value.index;
  }

  void initPairingStatus() {
    String? pairingStatus = GetStorage().read("pairing_status");
    if (pairingStatus != null) {
      switch (pairingStatus) {
        case "REQUIRED":
          this.pairingStatus.value = PairingStatus.REQUIRED;
        case "DONE":
          this.pairingStatus.value = PairingStatus.DONE;
      }
    } else {
      this.pairingStatus.value = PairingStatus.REQUIRED;
    }
  }

  void togglePairingStatus() {
    AscentLogger.INSTANCE.log("Toggling pairing status");
    switch(pairingStatus.value) {
      case PairingStatus.REQUIRED:
        AscentLogger.INSTANCE.log("Toggling pairing status to DONE");
        pairingStatus.value = PairingStatus.DONE;
        GetStorage().write(pairingStatusKey, "DONE");
        break;
      case PairingStatus.DONE:
        AscentLogger.INSTANCE.log("Toggling pairing status to REQUIRED");
        pairingStatus.value = PairingStatus.REQUIRED;
        GetStorage().write(pairingStatusKey, "REQUIRED");
      default:
    }

    // String? pairingStatus = GetStorage().read(pairingStatusKey);
    // if (pairingStatus != null) {
    //   switch (pairingStatus) {
    //     case "REQUIRED":
    //       this.pairingStatus.value = PairingStatus.DONE;
    //       GetStorage().write(pairingStatusKey, "DONE");
    //       break;
    //     case "DONE":
    //       this.pairingStatus.value = PairingStatus.REQUIRED;
    //       GetStorage().write(pairingStatusKey, "REQUIRED");
    //       break;
    //   }
    // } else {
    //   this.pairingStatus.value = PairingStatus.DONE;
    //   GetStorage().write(pairingStatusKey, "DONE");
    // }
  }

  Future<String> getAdbLibPath() async {
    if (adbLibraryPath.value.isEmpty) {
      final libPath = await getLibPath();
      final execPath = "${libPath!}/libadb.so";
      adbLibraryPath.value = execPath;
      return execPath;
    } else {
      return adbLibraryPath.value;
    }
  }

  initMixPanel() async {
    Mixpanel mixpanel = await Mixpanel.init("e82ee944685ea82f6e3684468fdb48bd",
        trackAutomaticEvents: true);
    this.mixpanel = mixpanel;
  }
}
