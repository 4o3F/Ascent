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

  debugPrint(response.notificationResponseType.name);
  debugPrint("Notification response payload: ${response.payload}");

  if (response.input == null) {
    debugPrint("Notification action response without input");
    return;
  }

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

class PairingNotification {
  static PairingNotification? _instance;

  PairingNotification._();

  static PairingNotification getInstance() {
    _instance ??= PairingNotification._();
    return _instance!;
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String adbPairingPort = "";
  String adbPairingCode = "";

  void doPairing() async {

    if(adbPairingPort.isNotEmpty || adbPairingCode.isNotEmpty) {
      debugPrint("Clearing adb pairing data");
      // Not empty meaning the service has started and user has tried to do something once, reset all
      adbPairingPort = "";
      adbPairingCode = "";
      sendPortNotification();
      waitMDns();
      return;
    }


    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'ascent_channel',
      S.current.title,
      description: '',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    flutterLocalNotificationsPlugin.initialize(
        const InitializationSettings(
            android: AndroidInitializationSettings('ic_bg_service_small')),
        onDidReceiveNotificationResponse: handleNotificationAction,
        onDidReceiveBackgroundNotificationResponse: handleNotificationAction);

    debugPrint("Registering event listener from dart pairing service");
    api.registerEventListener().listen((event) async {
      debugPrint("Pairing Background received event ${event.address}");
      switch (event.address) {
        case AscentConstants.EVENT_PAIRING_PORT_RECEIVED:
          await flutterLocalNotificationsPlugin.cancelAll();
          adbPairingPort = event.payload;
          debugPrint("Adb pairing port set to $adbPairingPort");
          sendCodeNotification();
          break;
        case AscentConstants.EVENT_PAIRING_CODE_RECEIVED:
          await flutterLocalNotificationsPlugin.cancelAll();
          adbPairingCode = event.payload;
          debugPrint("Adb pairing code set to $adbPairingCode");
          doPairShell();
          break;
        default:
      }
    });

    sendPortNotification();
    waitMDns();
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
      debugPrint("ADB pairing mDNS listening...");
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(adbTlsMdns))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          debugPrint('Observed ADB TLS pairing instance at :${srv.port}');
          adbPairingPort = srv.port.toString();
          await flutterLocalNotificationsPlugin.cancelAll();

          await api.createEvent(address: AscentConstants.EVENT_PAIRING_PORT_DISCOVERED, payload: adbPairingPort);
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

      debugPrint("Pairing to 127.0.0.1:$adbPairingPort $adbPairingCode $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      debugPrint("STD OUT: ${result.stdout}");
      debugPrint("STD ERR: ${result.stderr}");

      Process.run(execPath, [
        'pair',
        '127.0.0.1:$adbPairingPort',
        adbPairingCode,
        dataPath
      ]).then((result) {
        debugPrint("STD OUT: ${result.stdout}");
        debugPrint("STD ERR: ${result.stderr}");
        if (result.stderr.toString().isEmpty) {
          sendSuccessNotification();
          debugPrint("Background activity sending adb pairing success message");
          api.createEvent(address: AscentConstants.EVENT_TOGGLE_PAIRING_STATUS, payload: '');
        }
      });
    });
  }
}