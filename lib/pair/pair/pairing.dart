import 'dart:async';
import 'dart:io';

import 'package:ascent/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../../ffi.dart';
import '../../generated/l10n.dart';

@pragma('vm:entry-point')
handleNotificationAction(NotificationResponse response) async {
  debugPrint("Notification response received");

  if (response.actionId == "pairing_port") {
    // Used to check if the input is correct or not
    int? port = int.tryParse(response.input!);
    if (port != null) {
      await api.createEvent(
          address: AscentConstants.EVENT_PAIRING_PORT_RECEIVED,
          payload: port.toString());
    }
  } else if (response.actionId == "pairing_code") {
    String code = response.input!;
    await api.createEvent(
        address: AscentConstants.EVENT_PAIRING_CODE_RECEIVED, payload: code);
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

  String adbPairingPort = "";
  String adbPairingCode = "";

  void doPairing() async {
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

    api.registerEventListener().listen((event) async {
      switch (event.address) {
        case AscentConstants.EVENT_PAIRING_PORT_RECEIVED:
          await flutterLocalNotificationsPlugin.cancelAll();
          adbPairingPort = event.payload;
          sendCodeNotification();
          break;
        case AscentConstants.EVENT_PAIRING_CODE_RECEIVED:
          await flutterLocalNotificationsPlugin.cancelAll();
          adbPairingCode = event.payload;
          doPairShell();
          break;
        default:
      }
    });

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

  void sendSuccessNotification() {
    debugPrint("Send success notification");

    S
        .load(Locale.fromSubtags(
            languageCode: Platform.localeName.split('_').first))
        .then((_) => {
              flutterLocalNotificationsPlugin.show(
                233,
                S.current.title,
                S.current.stage_pairing_notification_success,
                const NotificationDetails(
                  android: AndroidNotificationDetails(
                      'ascent_channel', 'ascent',
                      icon: 'ic_bg_service_small', ongoing: true),
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

    while (adbPairingPort.isEmpty) {
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(adbTlsMdns))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          debugPrint('Observed ADB TLS pairing instance at :${srv.port}');
          adbPairingPort = srv.port.toString();
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
    // Get global constant data from global database
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      debugPrint("Exec path: $execPath");
      debugPrint("Data path: $dataPath");

      Process.run(execPath, [
        'pair',
        '127.0.0.1:$adbPairingPort',
        adbPairingCode,
        dataPath
      ]).then((result) => {
            if (result.stderr.toString().isEmpty)
              {
                sendSuccessNotification(),
                debugPrint(
                    "Background activity sending adb pairing success message"),
              }
          });
    });
  }
}
