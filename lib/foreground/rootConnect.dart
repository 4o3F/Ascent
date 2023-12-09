import 'dart:io';

import 'package:ascent/global_state.dart';
import 'package:ascent/pages/connect/logic.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge.dart';
import 'package:get/get.dart';
import 'package:root/root.dart';

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(RootConnectTaskHandler());
}

enum ConnectStatus { WAIT_PORT, WAIT_LINK }

class RootConnectTaskHandler extends TaskHandler {
  String link = "";
  SendPort? sendPort;

  Future<void> loadTranslations() async {
    //this will only set EasyLocalizationController.savedLocale
    await EasyLocalizationController.initEasyLocation();

    final controller = EasyLocalizationController(
      saveLocale: true,
      //mandatory to use EasyLocalizationController.savedLocale
      fallbackLocale: GlobalState.supportedLocale[0],
      supportedLocales: GlobalState.supportedLocale,
      assetLoader: const RootBundleAssetLoader(),
      useOnlyLangCode: false,
      useFallbackTranslations: true,
      path: GlobalState.localizationAssetPath,
      onLoadError: (FlutterError e) {},
    );

    //Load translations from assets
    await controller.loadTranslations();

    //load translations into exploitable data, kept in memory
    Localization.load(controller.locale,
        translations: controller.translations,
        fallbackTranslations: controller.fallbackTranslations);
  }

  Future<void> waitLink() async {
    FlutterForegroundTask.updateService(
      notificationText: tr('connect.notification_description.waiting'),
    );

    while (link.isEmpty) {
      String? data = await Root.exec(
          cmd:
              "logcat -d | grep -E \'https://(webstatic|hk4e-api|webstatic-sea|hk4e-api-os|api-takumi|api-os-takumi|gs).(mihoyo\\.com|hoyoverse\\.com)\' | grep -i \'gacha\' | tail -n 1");
      if (data != null) {
        link = data;
        sendPort?.send(link);
      }
      Future.delayed(const Duration(milliseconds: 500));
    }
    // await Root.exec(cmd: "logcat 403f.cafeakjsbdkajs");

    String errorMessage = "";
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    loadTranslations();
    GlobalState.init();
    this.sendPort = sendPort;
    waitLink();
  }
}

class RootConnectForegroundTask {
  Future<void> requestPermission() async {
    // Android 12 or higher, there are restrictions on starting a foreground service.
    //
    // To restart the service on device reboot or unexpected problem, you need to allow below permission.
    if (!await FlutterForegroundTask.isIgnoringBatteryOptimizations) {
      // This function requires `android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS` permission.
      await FlutterForegroundTask.requestIgnoreBatteryOptimization();
    }

    // Android 13 and higher, you need to allow notification permission to expose foreground service notification.
    final NotificationPermission notificationPermissionStatus =
        await FlutterForegroundTask.checkNotificationPermission();
    if (notificationPermissionStatus != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }

  Future<bool> startRootConnectForegroundTask(ConnectLogic logic) async {
    GlobalState.mixpanel.track("Root Connect Begin");
    GlobalState.mixpanel.flush();
    await requestPermission();
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }
    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    if (receivePort == null) {
      return false;
    }
    receivePort.listen((dynamic data) {
      if (data is String) {
        if (data.startsWith("error.other#")) {
          logic.inProgress.value = false;
          String errorMessage = data.replaceFirst("error.other#", "");
          Get.dialog(BrnScrollableTextDialog(
            title: tr("error.title"),
            contentText: errorMessage,
            submitText: tr("error.copy"),
            submitBgColor: Colors.orangeAccent,
            onSubmitClick: () {
              Clipboard.setData(ClipboardData(text: errorMessage));
              BrnToast.showInCenter(
                text: tr("error.copied"),
                context: Get.context!,
              );
            },
          ));
        } else {
          RegExp regex = RegExp(r'https://(.+)');
          Match? match = regex.firstMatch(data);
          if (match != null) {
            logic.link.value = match.group(0)!;
            logic.inProgress.value = false;
            Get.dialog(BrnScrollableTextDialog(
              title: tr("connect.link_action.title"),
              contentText: logic.link.value,
              submitText: tr("connect.link_action.copy_button"),
              submitBgColor: Colors.greenAccent,
              onSubmitClick: () {
                Clipboard.setData(ClipboardData(text: logic.link.value));
                BrnToast.showInCenter(
                  text: tr("connect.link_action.copied"),
                  context: Get.context!,
                );
              },
            ));
            GlobalState.mixpanel.track("Connect Complete", properties: {
              'Game': logic.link.value.contains('hkrpg') ? 'hkrpg' : 'gs',
            });
            GlobalState.mixpanel.flush();
          }
        }
      }
    });

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'ascent_foreground_service',
        channelName: 'Ascent Foreground Service',
        channelImportance: NotificationChannelImportance.HIGH,
        priority: NotificationPriority.HIGH,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        allowWakeLock: true,
        autoRunOnBoot: false,
        allowWifiLock: true,
      ),
    );
    await FlutterForegroundTask.startService(
      notificationTitle: tr('root_connect.notification_title'),
      notificationText: tr('root_connect.notification_description.waiting'),
      callback: startCallback,
    );
    return true;
  }
}
