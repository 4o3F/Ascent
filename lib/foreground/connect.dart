import 'dart:io';

import 'package:ascent/ffi.dart';
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
import 'package:multicast_dns/multicast_dns.dart';

@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(ConnectTaskHandler());
}

enum ConnectStatus { WAIT_PORT, WAIT_LINK }

class ConnectTaskHandler extends TaskHandler {
  String port = "";
  String link = "";
  final MDnsClient mDnsClient = MDnsClient();
  SendPort? sendPort;
  ConnectStatus status = ConnectStatus.WAIT_PORT;

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

  Future<void> startMDNS() async {
    print("Start listening to mDNS");
    await mDnsClient.start();
    while (status == ConnectStatus.WAIT_PORT) {
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer('_adb-tls-connect._tcp'))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          port = srv.port.toString();
          status = ConnectStatus.WAIT_LINK;
          waitLink();
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  Future<void> waitLink() async {
    mDnsClient.stop();
    FlutterForegroundTask.updateService(
      notificationText: tr('connect.notification_description.waiting'),
    );

    String errorMessage = "";
    api
        .doConnect(port: port, dataFolder: GlobalState.dataDir.path)
        .catchError((error) {
      if (error is FrbAnyhowException) {
        errorMessage = error.anyhow;
      } else {
        errorMessage = error.toString();
      }
      if (errorMessage.contains("error.pair_cert_invalid")) {
        sendPort?.send("error.pair_cert_invalid#$errorMessage");
        return "error.pair_cert_invalid";
      } else {
        sendPort?.send("error.other#$errorMessage");
        return "error.other";
      }
    }).then((value) {
      if (!value.startsWith("error")) {
        link = value;
        FlutterForegroundTask.updateService(
          notificationText: tr('connect.notification_description.success'),
        );
        sendPort?.send(link);
      } else {
        if (value == "error.pair_cert_invalid") {
          FlutterForegroundTask.updateService(
            notificationText: tr('connect.notification_description.repair'),
          );
        } else {
          FlutterForegroundTask.updateService(
            notificationText:
                tr('connect.notification_description.fail') + errorMessage,
          );
        }
      }
    });
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    loadTranslations();
    GlobalState.init();
    startMDNS();
    this.sendPort = sendPort;
  }

  @override
  void onNotificationReplied(String id, String reply) {
    if (status == ConnectStatus.WAIT_PORT) {
      if (int.tryParse(reply) != null) {
        port = reply;
        status = ConnectStatus.WAIT_LINK;
        waitLink();
      }
    }
  }
}

class ConnectForegroundTask {
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

  Future<bool> startConnectForegroundTask(ConnectLogic logic) async {
    GlobalState.mixpanel.track("Connect Begin");
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
        } else if (data.startsWith("error.pair_cert_invalid#")) {
          logic.inProgress.value = false;
          File("${GlobalState.dataDir.path}/cert.pem").deleteSync();
          File("${GlobalState.dataDir.path}/pkey.pem").deleteSync();
          GlobalState.hasCert.value = false;
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
        buttons: [
          NotificationButton(
            id: 'replyButton',
            text: tr("pair.notification_reply_button"),
            isReply: true,
          )
        ],
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
      notificationTitle: tr('connect.notification_title'),
      notificationText: tr('connect.notification_description.connecting'),
      callback: startCallback,
    );
    return true;
  }
}
