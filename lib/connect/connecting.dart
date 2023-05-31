import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:multicast_dns/multicast_dns.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants.dart';
import '../ffi.dart';
import '../generated/l10n.dart';
import '../logger.dart';

class ConnectLogic extends GetxController {
  Rx<String> connectStatus = "".obs;
  Rx<String> lastWishLinkFetchTime = "".obs;
  TextEditingController adbConnectingPort = TextEditingController();
  TextEditingController wishLink = TextEditingController();
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
    AscentLogger.INSTANCE.log("mDns started");

    while (logic.adbConnectingPort.text.isEmpty) {
      await for (final PtrResourceRecord ptr
          in mDnsClient.lookup<PtrResourceRecord>(
              ResourceRecordQuery.serverPointer(adbTlsMdns))) {
        await for (final SrvResourceRecord srv
            in mDnsClient.lookup<SrvResourceRecord>(
                ResourceRecordQuery.service(ptr.domainName))) {
          AscentLogger.INSTANCE
              .log('Observed ADB TLS connect instance at :${srv.port}');
          logic.adbConnectingPort.text = srv.port.toString();
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

      AscentLogger.INSTANCE.log("Exec path: $execPath");
      AscentLogger.INSTANCE.log("Data path: $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      AscentLogger.INSTANCE.log("STD OUT: ${result.stdout}");
      AscentLogger.INSTANCE.log("STD ERR: ${result.stderr}");

      Process.run(execPath, [
        'connect',
        '127.0.0.1:${logic.adbConnectingPort.text}',
      ]).then((result) async {
        AscentLogger.INSTANCE.log("STD OUT: ${result.stdout}");
        AscentLogger.INSTANCE.log("STD ERR: ${result.stderr}");
        if (result.stderr.toString().isEmpty &&
            !result.stdout.toString().contains("Failed") &&
            !result.stdout.toString().contains("failed")) {
          AscentLogger.INSTANCE.log(
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
    AscentLogger.INSTANCE.log("Start getting wish link");
    AscentLogger.INSTANCE.log("Current wish link: ${logic.wishLink.text}");
    while (logic.wishLink.text.isEmpty &&
        logic.connectStatus.value == "CONNECTED") {
      AscentLogger.INSTANCE.log("Current wish link: ${logic.wishLink.text}");
      await onGetWishLink(logic);
      DateTime now = DateTime.now();
      logic.lastWishLinkFetchTime.value = DateFormat('HH:mm:ss').format(now);
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  onGetWishLink(ConnectLogic logic) async {
    String adbLibPath = await api.getData(key: AscentConstants.ADB_LIB_PATH);
    String execPath = "$adbLibPath/libadb.so";

    String dataPath =
        await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

    ProcessResult result =
        await Process.run(execPath, ['start-server', dataPath]);

    AscentLogger.INSTANCE.log(
        "START SERVER\nSTD OUT: ${result.stdout}\nSTD ERR: ${result.stderr}");

    result = await Process.run(
        execPath,
        [
          'shell',
          'logcat -d | grep -E \'https://webstatic.mihoyo.com|https://api-os-takumi.mihoyo.com|https://webstatic-sea.mihoyo.com\' | tail -n 1'
        ],
        runInShell: false);
    AscentLogger.INSTANCE.log(
        "LOGCAT GREP\nSTD OUT: ${result.stdout}\nSTD ERR: ${result.stderr}");
    if (result.stderr.toString().isEmpty &&
        !result.stdout.toString().contains("Failed") &&
        !result.stdout.toString().contains("failed")) {
      RegExp regex = RegExp(r'https://(.+)');
      Match? match = regex.firstMatch(result.stdout);
      if (match != null) {
        String url = match.group(0)!;
        logic.wishLink.text = url;
      } else {
        AscentLogger.INSTANCE.log('No matching wish link found');
      }
    } else {
      logic.connectStatus.value = "FAILED";
    }
  }

  checkConnectionStatus(ConnectLogic logic) async {
    String adbLibPath = await api.getData(key: AscentConstants.ADB_LIB_PATH);
    String execPath = "$adbLibPath/libadb.so";

    String dataPath =
        await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

    ProcessResult result =
        await Process.run(execPath, ['start-server', dataPath]);

    AscentLogger.INSTANCE.log(
        "START SERVER\nSTD OUT: ${result.stdout}\nSTD ERR: ${result.stderr}");

    result = await Process.run(execPath, ['devices'], runInShell: false);
    AscentLogger.INSTANCE.log(
        "GET DEVICES\nSTD OUT: ${result.stdout}\nSTD ERR: ${result.stderr}");
    if (result.stdout.toString().contains("127.0.0.1") &&
        !result.stdout.toString().contains("offline")) {
      logic.connectStatus.value = "CONNECTED";
    }
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

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await checkConnectionStatus(logic);
      AscentLogger.INSTANCE
          .log("Connection status: ${logic.connectStatus.value}");
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
            controller: logic.adbConnectingPort,
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
            controller: logic.wishLink,
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
                  logic.wishLink.text = "";
                  startGetWishLink(logic);
                }),
                icon: const Icon(Icons.start),
                label: Text(S.current.stage_watching_restart),
              ),
              ElevatedButton.icon(
                onPressed: (() async {
                  await Clipboard.setData(
                          ClipboardData(text: logic.wishLink.text))
                      .then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(S.current.copied)));
                  });
                }),
                icon: const Icon(Icons.send),
                label: Text(S.current.copy_link),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.greenAccent),
                    foregroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
              ),
              ElevatedButton.icon(
                onPressed: (() async {
                  Uri uri = Uri.parse(logic.wishLink.value.text);
                  String path = "";
                  Map<String, String> params = {};
                  if (uri.queryParameters["game_biz"]!.startsWith("hk4e")) {
                    path = "/rank_url_upload_init/";
                    params["region"] = uri.queryParameters["region"]!;
                  } else {
                    path = "/n/#/xt";
                  }

                  params["game_biz"] = uri.queryParameters["game_biz"]!;
                  params["autoKey"] = uri.queryParameters["authkey"]!;

                  Uri feixiaoqiu = Uri(
                    scheme: "https",
                    host: "feixiaoqiu.com",
                    path: path,
                    queryParameters: params
                  );

                  String url = feixiaoqiu.toString();
                  AscentLogger.INSTANCE.log(url);
                  url = url.replaceAll("n/%23/xt", "n/#/xt");
                  AscentLogger.INSTANCE.log(url);

                  launchUrlString(url,
                      mode: LaunchMode.externalApplication);
                }),
                icon: const Icon(Icons.cloud_upload),
                label: Text(S.current.upload_to_feixiaoqiu),
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.greenAccent),
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
