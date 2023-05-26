import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../constants.dart';
import '../ffi.dart';
import '../generated/l10n.dart';

class ConnectLogic extends GetxController {
  Rx<int> connectPort = 0.obs;
  Rx<String> wishLink = "".obs;
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
        if (result.stderr.toString().isEmpty && !result.stdout.toString().startsWith("Failed") && !result.stdout.toString().startsWith("failed")) {
          debugPrint(
              "Background activity sending adb connecting success message");
          onGetWishLink(logic);
        } else {
          await api.createEvent(
              address: AscentConstants.EVENT_TOGGLE_PAIRING_STATUS,
              payload: '');
          await api.createEvent(
              address: AscentConstants.EVENT_SWITCH_UI, payload: "/pair");
        }
      });
    });
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

      Process.run(execPath, [
        'shell',
        'logcat -d | grep \'url:https://webstatic.mihoyo.com\' | tail -n 1'
      ],runInShell: false).then((result) async {
        debugPrint("STD OUT: ${result.stdout}");
        debugPrint("STD ERR: ${result.stderr}");
        if (result.stderr.toString().isEmpty && !result.stdout.toString().startsWith("Failed") && !result.stdout.toString().startsWith("failed")) {
          RegExp regex = RegExp(r'https://(.+)');
          Match? match = regex.firstMatch(result.stdout);
          if (match != null) {
            String url = match.group(0)!;
            logic.wishLink.value = url;
          } else {
            debugPrint('No match found.');
          }
        } else {
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(ConnectLogic());

    TextEditingController adbConnectingPort = TextEditingController();

    TextEditingController wishLink = TextEditingController();

    if(logic.connectPort.value != 0) {
      adbConnectingPort.text = logic.connectPort.value.toString();
    }

    logic.connectPort.listen((p0) {
      adbConnectingPort.text = logic.connectPort.value.toString();
    });

    logic.wishLink.listen((p0) {
      wishLink.text = logic.wishLink.value.toString();
    });

    waitMDns(logic);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: adbConnectingPort,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S.current.stage_connecting_port,
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: wishLink,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: S.current.wish_link,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: (() => onStartConnecting(logic)),
            icon: const Icon(Icons.check),
            label: Text(S.current.stage_connecting),
          ),
        ],
      ),
    );
  }
}
