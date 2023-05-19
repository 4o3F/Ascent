import 'dart:io';

import 'package:ascent/utils/common_utils.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum AscentStage { LAUNCH, PAIR, CONNECT, WATCHING, FINISHED }

enum AscentPages { FUNCTION, ABOUT }

enum PairingStatus { REQUIRED, DONE }

class AscentGlobalState extends GetxController {
  static AscentGlobalState INSTANCE = AscentGlobalState();
  Rx<AscentStage> ascentStage = AscentStage.LAUNCH.obs;
  Rx<AscentPages> ascentPage = AscentPages.FUNCTION.obs;

  Rx<String> adbLibraryPath = "".obs;

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

  PairingStatus getPairingStatus() {
    String? pairingStatus = GetStorage().read("pairing_status");
    if (pairingStatus != null) {
      switch (pairingStatus) {
        case "REQUIRED":
          return PairingStatus.REQUIRED;
        case "DONE":
          return PairingStatus.DONE;
      }
    }
    return PairingStatus.REQUIRED;
  }

  void togglePairingStatus() {
    String? pairingStatus = GetStorage().read(pairingStatusKey);
    if (pairingStatus != null) {
      switch (pairingStatus) {
        case "REQUIRED":
          GetStorage().write(pairingStatusKey, "DONE");
          break;
        case "DONE":
          GetStorage().write(pairingStatusKey, "REQUIRED");
          break;
      }
    } else {
      GetStorage().write(pairingStatusKey, "DONE");
    }
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
}
