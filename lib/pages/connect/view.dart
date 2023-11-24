import 'package:ascent/foreground/connect.dart';
import 'package:ascent/global_state.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class ConnectPage extends StatelessWidget {
  ConnectPage({Key? key}) : super(key: key);

  final logic = Get.put(ConnectLogic());
  ConnectForegroundTask connectForegroundTask = ConnectForegroundTask();

  Future<void> doConnect() async {
    logic.inProgress.value = true;
    bool result = await connectForegroundTask.startConnectForegroundTask(logic);
  }

  @override
  Widget build(BuildContext context) {
    GlobalState.platform.invokeMethod('getDeveloperOptionEnabled').then(
        (value) =>
            logic.developerOptionEnabled.value = (value.toString() == "true"));
    return Material(
      child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Obx(
            () => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'connect.guide.prepare_guide',
                  style: TextStyle(fontSize: 20),
                ).tr(),
                const SizedBox(height: 20),
                BrnBigMainButton(
                  title: logic.inProgress.value ? tr('connect.guide.in_progress') : tr('connect.guide.connect'),
                  bgColor: Colors.blueAccent.withOpacity(0.8),
                  isEnable: (logic.developerOptionEnabled.value &&
                      GlobalState.hasCert.value && !logic.inProgress.value),
                  onTap: () {
                    doConnect();
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          )),
    );
  }
}
