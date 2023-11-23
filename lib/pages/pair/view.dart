import 'dart:io';
import 'dart:math';

import 'package:android_intent_plus/android_intent.dart';
import 'package:ascent/global_state.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

import '../../foreground/pair.dart';
import 'logic.dart';

class PairPage extends StatelessWidget {
  PairPage({Key? key}) : super(key: key);

  final logic = Get.put(PairLogic());
  PairForegroundTask pairForegroundTask = PairForegroundTask();

  Future<void> doPair() async {
    // TODO: Call out developer option intent
    AndroidIntent intent = const AndroidIntent(
      action: 'android.settings.APPLICATION_DEVELOPMENT_SETTINGS',
    );
    bool result = await pairForegroundTask.startPairForegroundTask();
    if (!result) {
      logic.foregroundServiceStartResult.value = false;
    }
    await intent.launch();
  }

  Future<void> resetPair() async {
    File("${GlobalState.dataDir.path}/cert.pem").deleteSync();
    File("${GlobalState.dataDir.path}/pkey.pem").deleteSync();
    GlobalState.hasCert.value = false;
  }

  @override
  Widget build(BuildContext context) {
    GlobalState.hasCert.value =
        File("${GlobalState.dataDir.path}/cert.pem").existsSync();
    GlobalState.platform.invokeMethod('getDeveloperOptionEnabled').then(
        (value) =>
            logic.developerOptionEnabled.value = (value.toString() == "true"));

    logic.foregroundServiceStartResult.listen((result) {
      if (!result) {
        BrnToast.showInCenter(
            text: tr('pair.notification_description.error_init'),
            context: context);
      }
    });
    return Material(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Obx(
          () => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'pair.guide.prepare_guide',
                style: TextStyle(fontSize: 20),
              ).tr(),
              const SizedBox(
                height: 20,
              ),
              BrnBigMainButton(
                title: tr('pair.guide.pair'),
                bgColor: Colors.indigoAccent.withOpacity(0.8),
                isEnable: (logic.developerOptionEnabled.value &&
                    !GlobalState.hasCert.value),
                onTap: () {
                  doPair();
                },
              ),
              const SizedBox(
                height: 20,
              ),
              BrnBigMainButton(
                title: tr('pair.guide.reset'),
                bgColor: Colors.orangeAccent.withOpacity(0.8),
                isEnable: (logic.developerOptionEnabled.value &&
                    GlobalState.hasCert.value),
                onTap: () {
                  resetPair();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
