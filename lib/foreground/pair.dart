import 'dart:isolate';

import 'package:ascent/ffi.dart';
import 'package:ascent/global_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:easy_localization/src/easy_localization_controller.dart';
import 'package:easy_localization/src/localization.dart';

// Top level callback function, will run in isolated
@pragma('vm:entry-point')
void startCallback() {
  // The setTaskHandler function must be called to handle the task in the background.
  FlutterForegroundTask.setTaskHandler(PairTaskHandler());
}

enum PairStatus { WAIT_PORT, WAIT_CODE }

// This will run in the foreground service isolated
class PairTaskHandler extends TaskHandler {
  PairStatus status = PairStatus.WAIT_PORT;
  String port = "";
  String code = "";
  final MDnsClient mDnsClient = MDnsClient();
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

  Future<void> startMDNS() async {
    print("Start listening to mDNS");
    await mDnsClient.start();
    while (status == PairStatus.WAIT_PORT) {
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer('_adb-tls-pairing._tcp'))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          port = srv.port.toString();
          status = PairStatus.WAIT_CODE;
          waitCode();
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  // This is called when pairing port has been set already
  Future<void> waitCode() async {
    // Stop mDnsClient for it has no use
    mDnsClient.stop();
    FlutterForegroundTask.updateService(
      notificationTitle:
          "${tr('pair.notification_title')} ${tr('pair.notification_description.pair_port')} $port",
      notificationText: tr('pair.notification_description.guide_code'),
    );
  }

  Future<void> doPair() async {
    await api.doPair(
        port: port, code: code, dataFolder: GlobalState.dataDir.path);
    FlutterForegroundTask.updateService(
      notificationTitle: tr('pair.notification_title'),
      notificationText: tr('pair.notification_description.pair_success'),
    );
    sendPort?.send('pair_complete');
  }

  @override
  void onDestroy(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {}

  @override
  void onStart(DateTime timestamp, SendPort? sendPort) {
    loadTranslations();
    GlobalState.init();
    // Start mdns listener
    startMDNS();
    this.sendPort = sendPort;
  }

  @override
  void onNotificationReplied(String id, String reply) {
    switch (status) {
      case PairStatus.WAIT_PORT:
        if (int.tryParse(reply) != null) {
          port = reply;
          status = PairStatus.WAIT_CODE;
          waitCode();
        }
        break;
      case PairStatus.WAIT_CODE:
        code = reply;
        doPair();
        break;
    }
  }
}

class PairForegroundTask {
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

  Future<bool> startPairForegroundTask() async {
    GlobalState.mixpanel.track("Pair Begin");
    GlobalState.mixpanel.flush();
    // Request permission
    await requestPermission();
    // Stop any foreground service still running
    if (await FlutterForegroundTask.isRunningService) {
      await FlutterForegroundTask.stopService();
    }

    final ReceivePort? receivePort = FlutterForegroundTask.receivePort;
    if (receivePort == null) {
      return false;
    }
    receivePort.listen((dynamic data) {
      if (data is String) {
        switch (data) {
          case 'pair_complete':
            WidgetsBinding.instance.addPostFrameCallback((_) {
              GlobalState.hasCert.value = true;
              GlobalState.mixpanel.track("Pair Complete");
              GlobalState.mixpanel.flush();
            });
        }
      }
    });

    // Init foreground task
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
          ]),
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

    // Start task
    await FlutterForegroundTask.startService(
      notificationTitle: tr('pair.notification_title'),
      notificationText: tr('pair.notification_description.guide_port'),
      callback: startCallback,
    );
    return true;
  }
}
