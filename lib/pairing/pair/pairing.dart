import 'dart:async';
import 'dart:io';

import 'package:ascent/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../../ffi.dart';
import '../../generated/l10n.dart';

@pragma('vm:entry-point')
handleNotificationAction(NotificationResponse response) async {
  debugPrint("Notification response received");

  if (response.actionId == "pairing_port") {
    int? port = int.tryParse(response.input!);
    if (port != null) {
      await api.writeData(
          key: AscentConstants.ADB_PAIRING_PORT, value: port.toString());

      await Pairing.getInstance().flutterLocalNotificationsPlugin.cancelAll();
      Pairing.getInstance().sendCodeNotification();
    } else {
      Pairing.getInstance().sendPortNotification();
    }
  } else if (response.actionId == "pairing_code") {
    String code = response.input!;
    await api.writeData(key: AscentConstants.ADB_PAIRING_CODE, value: code);
    Pairing.getInstance().doPairShell();
    await Pairing.getInstance().flutterLocalNotificationsPlugin.cancelAll();
  }
}

class Pairing {
  static Pairing? _instance;

  Pairing._();

  static Pairing getInstance() {
    _instance ??= Pairing._();
    return _instance!;
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void doPairing(ServiceInstance serviceInstance) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ascent_channel', // id
      S.current.title, // title
      description: '', // description
      importance: Importance.max, // importance must be at low or higher level
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    startPairingProcess();
  }

  void startPairingProcess() {
    debugPrint("Start pairing process");
    flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('ic_bg_service_small')),
        onDidReceiveNotificationResponse: handleNotificationAction,
        onDidReceiveBackgroundNotificationResponse: handleNotificationAction);
    sendPortNotification();
    api
        .writeData(key: AscentConstants.ADB_PAIRING_PORT_STATUS, value: "false")
        .then((value) => {waitMDns()});
  }

  void sendPortNotification() {
    debugPrint("Send port notification");
    S
        .load(Locale.fromSubtags(
            languageCode: Platform.localeName.split('_').first))
        .then((_) => {
              flutterLocalNotificationsPlugin.show(
                233,
                S.current.title,
                S.current.stage_pairing_notification_description_port,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                      'ascent_channel', 'ascent',
                      icon: 'ic_bg_service_small',
                      ongoing: true,
                      actions: <AndroidNotificationAction>[
                        AndroidNotificationAction(
                            "pairing_port", S.current.notification_action,
                            allowGeneratedReplies: true,
                            inputs: <AndroidNotificationActionInput>[
                              AndroidNotificationActionInput(
                                  label: S.current.notification_action)
                            ],
                            cancelNotification: true)
                      ]),
                ),
              )
            });
  }

  void sendCodeNotification() {
    debugPrint("Send code notification");

    S
        .load(Locale.fromSubtags(
            languageCode: Platform.localeName.split('_').first))
        .then((_) => {
              flutterLocalNotificationsPlugin.show(
                233,
                S.current.title,
                S.current.stage_pairing_notification_description_code,
                NotificationDetails(
                  android: AndroidNotificationDetails(
                      'ascent_channel', 'ascent',
                      icon: 'ic_bg_service_small',
                      ongoing: true,
                      actions: <AndroidNotificationAction>[
                        AndroidNotificationAction(
                            "pairing_code", S.current.notification_action,
                            allowGeneratedReplies: true,
                            inputs: <AndroidNotificationActionInput>[
                              AndroidNotificationActionInput(
                                  label: S.current.notification_action)
                            ],
                            cancelNotification: true)
                      ]),
                ),
              )
            });
  }

  Future<void> waitMDns() async {
    final MDnsClient mDnsClient = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool? reuseAddress, bool? reusePort, int? ttl}) {
      return RawDatagramSocket.bind(host, port,
          reuseAddress: true, reusePort: false, ttl: ttl!);
    });
    await mDnsClient.start();
    const String adbTlsMdns = "_adb-tls-pairing._tcp";
    debugPrint("mDns started");

    while (await api.getData(key: AscentConstants.ADB_PAIRING_PORT_STATUS) ==
        "false") {
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(adbTlsMdns))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          debugPrint('Observed ADB TLS pairing instance at :${srv.port}');
          await api.writeData(
              key: AscentConstants.ADB_PAIRING_PORT,
              value: srv.port.toString());
          await api.writeData(
              key: AscentConstants.ADB_PAIRING_PORT_STATUS, value: "true");
          await flutterLocalNotificationsPlugin.cancelAll();
          sendCodeNotification();
          mDnsClient.stop();
          return;
        }
      }
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void doPairShell() {
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "${adbLibPath}/libadb.so";
      int pairingPort =
          int.parse(await api.getData(key: AscentConstants.ADB_PAIRING_PORT));
      String pairingCode =
          await api.getData(key: AscentConstants.ADB_PAIRING_CODE);

      String dataPath = await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      debugPrint("Exec path: $execPath");
      debugPrint("Data path: $dataPath");


      Process.run(execPath, ['pair', '127.0.0.1:$pairingPort', pairingCode, dataPath])
          .then((result) => {debugPrint(result.stdout),debugPrint(result.stderr)});
    });
  }
}
