import 'package:get/get.dart';

class ConnectLogic extends GetxController {
  Rx<bool> developerOptionEnabled = false.obs;
  Rx<String> link = "".obs;
  Rx<bool> inProgress = false.obs;
}
