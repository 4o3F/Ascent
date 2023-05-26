import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../constants.dart';
import '../ffi.dart';
import '../generated/l10n.dart';

class ConnectLogic extends GetxController {
  Rx<int> connectPort = 0.obs;
  Rx<String> wishLink = "".obs;
  Rx<String> connectStatus = "".obs;
  Rx<String> lastWishLinkFetchTime = "".obs;
}

class ConnectPage extends StatelessWidget {
  const ConnectPage({Key? key}) : super(key: key);

  Future<void> waitMDns(ConnectLogic logic) async {
    final MDnsClient mDnsClient = MDnsClient(rawDatagramSocketFactory:
        (dynamic host, int port,
            {bool? reuseAddress, bool? reusePort, int? ttl}) {
      return RawDatagramSocket.bind(host, port,
          reuseAddress: true, reusePort: false, ttl: ttl!);
    });
    await mDnsClient.start();
    const String adbTlsMdns = "_adb-tls-connect._tcp";
    debugPrint("mDns started");

    while (logic.connectPort.value == 0) {
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(adbTlsMdns))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          debugPrint('Observed ADB TLS connect instance at :${srv.port}');
          logic.connectPort.value = srv.port;
          mDnsClient.stop();
          return;
        }
      }
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  onStartConnecting(ConnectLogic logic) async {
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      debugPrint("Exec path: $execPath");
      debugPrint("Data path: $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      debugPrint("STD OUT: ${result.stdout}");
      debugPrint("STD ERR: ${result.stderr}");

      Process.run(execPath, [
        'connect',
        '127.0.0.1:${logic.connectPort.value}',
      ]).then((result) async {
        debugPrint("STD OUT: ${result.stdout}");
        debugPrint("STD ERR: ${result.stderr}");
        if (result.stderr.toString().isEmpty &&
            !result.stdout.toString().contains("Failed") &&
            !result.stdout.toString().contains("failed")) {
          debugPrint(
              "Background activity sending adb connecting success message");
          logic.connectStatus.value = "CONNECTED";
          startGetWishLink(logic);
        } else {
          logic.connectStatus.value = "FAILED";
        }
      });
    });
  }

  startGetWishLink(ConnectLogic logic) async {
    debugPrint("Start getting wish link");
    debugPrint("Current wish link: ${logic.wishLink.value}");
    while (logic.wishLink.value.isEmpty) {
      debugPrint("Current wish link: ${logic.wishLink.value}");
      onGetWishLink(logic);
      DateTime now = DateTime.now();
      logic.lastWishLinkFetchTime.value = DateFormat('HH:mm:ss').format(now);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  onGetWishLink(ConnectLogic logic) async {
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      debugPrint("Exec path: $execPath");
      debugPrint("Data path: $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      debugPrint("STD OUT: ${result.stdout}");
      debugPrint("STD ERR: ${result.stderr}");

      Process.run(
              execPath,
              [
                'shell',
                'logcat -d | grep \'https://webstatic.mihoyo.com\' | tail -n 1'
              ],
              runInShell: false)
          .then((result) async {
        debugPrint("STD OUT: ${result.stdout}");
        debugPrint("STD ERR: ${result.stderr}");
        if (result.stderr.toString().isEmpty &&
            !result.stdout.toString().startsWith("Failed") &&
            !result.stdout.toString().startsWith("failed")) {
          RegExp regex = RegExp(r'https://(.+)');
          Match? match = regex.firstMatch(result.stdout);
          if (match != null) {
            String url = match.group(0)!;
            logic.wishLink.value = url;
          } else {
            debugPrint('No match found.');
          }
        } else {}
      });
    });
  }

  checkConnectionStatus(ConnectLogic logic) {
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      debugPrint("Exec path: $execPath");
      debugPrint("Data path: $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      debugPrint("STD OUT: ${result.stdout}");
      debugPrint("STD ERR: ${result.stderr}");

      Process.run(execPath, ['devices'], runInShell: false)
          .then((result) async {
        debugPrint("STD OUT: ${result.stdout}");
        debugPrint("STD ERR: ${result.stderr}");
        if (result.stdout.toString().contains("127.0.0.1") &&
            !result.stdout.toString().contains("offline")) {
          logic.connectStatus.value = "CONNECTED";
        }
      });
    });
  }

  doRepair() {
    Get.toNamed("/pair");
  }

  String getConnectingStatusStr(ConnectLogic logic) {
    switch (logic.connectStatus.value) {
      case "CONNECTED":
        return S.current.stage_connecting_status_done;
      case "FAILED":
        return S.current.stage_connecting_status_failed;
      default:
        return S.current.stage_connecting_status_waiting;
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(ConnectLogic());

    TextEditingController adbConnectingPort = TextEditingController();

    TextEditingController wishLink = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (logic.connectPort.value != 0) {
        adbConnectingPort.text = logic.connectPort.value.toString();
      }

      logic.connectPort.listen((p0) {
        adbConnectingPort.text = logic.connectPort.value.toString();
      });

      logic.wishLink.listen((p0) {
        wishLink.text = logic.wishLink.value.toString();
      });

      adbConnectingPort.addListener(() {
        logic.connectPort.value = int.tryParse(adbConnectingPort.text)!;
      });

      checkConnectionStatus(logic);
      debugPrint("Connection status: ${logic.connectStatus.value}");
      if (logic.connectStatus.value != "CONNECTED") {
        waitMDns(logic);
      } else {
        startGetWishLink(logic);
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: adbConnectingPort,
            onChanged: (text) {
              debugPrint(
                  "Setting adb connect port to ${adbConnectingPort.text}");
              adbConnectingPort.text = text;
            },
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S.current.stage_connecting_port,
            ),
          ),
          const SizedBox(height: 16.0),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: S.current.stage_connecting_status,
                    style: const TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text: getConnectingStatusStr(logic),
                    style: const TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  )
                ]))
              ],
            );
          }),
          const SizedBox(height: 16.0),
          Obx(() {
            switch (logic.connectStatus.value) {
              case "FAILED":
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: (() => onStartConnecting(logic)),
                      icon: const Icon(Icons.start),
                      label: Text(S.current.stage_connecting_status_required),
                    ),
                    ElevatedButton.icon(
                      onPressed: (() => doRepair()),
                      icon: const Icon(Icons.send),
                      label: Text(S.current.stage_connecting_status_repair),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.redAccent),
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white)),
                    ),
                  ],
                );
              case "CONNECTED":
                return ElevatedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.start),
                  label: Text(S.current.stage_connecting_status_done),
                );
              default:
                return ElevatedButton.icon(
                  onPressed: (() => onStartConnecting(logic)),
                  icon: const Icon(Icons.start),
                  label: Text(S.current.stage_connecting_status_required),
                );
            }
          }),
          const SizedBox(height: 16.0),
          Obx(() {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                    text: S.current.stage_watching_last_time +
                        logic.lastWishLinkFetchTime.value,
                    style: const TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.bold),
                  )
                ]))
              ],
            );
          }),
          TextField(
            controller: wishLink,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: S.current.wish_link,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: (() {
                  logic.wishLink.value = "";
                  startGetWishLink(logic);
                }),
                icon: const Icon(Icons.start),
                label: Text(S.current.stage_watching_restart),
              ),
              ElevatedButton.icon(
                onPressed: (() async {
                  await Clipboard.setData(ClipboardData(text: logic.wishLink.value)).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(S.current.copied)));
                  });
                }),
                icon: const Icon(Icons.send),
                label: Text(S.current.copy_link),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Colors.greenAccent),
                    foregroundColor:
                    MaterialStateProperty.all<Color>(Colors.white)),
              ),
            ],
          )
        ],
      ),
    );
  }
}
