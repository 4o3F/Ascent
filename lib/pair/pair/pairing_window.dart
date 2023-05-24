import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'pairing_window/logic.dart';

class Pairing_windowPage extends StatelessWidget {
  const Pairing_windowPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(Pairing_windowLogic());

    return Container();
  }
}
