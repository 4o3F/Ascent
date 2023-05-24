import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multicast_dns/multicast_dns.dart';

import '../ffi.dart';
import 'logic.dart';

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
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(ConnectLogic());
    waitMDns(logic);
    return Container();
  }
}
