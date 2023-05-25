import 'dart:io';

import 'package:ascent/constants.dart';
import 'package:flutter/material.dart';

import '../../ffi.dart';
import '../../generated/l10n.dart';

class PairingWindowPage extends StatelessWidget {
  const PairingWindowPage({Key? key}) : super(key: key);

  onStartPairing(String adbPairingPort, String adbPairingCode) async {
    // Get global constant data from global database
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      debugPrint("Exec path: $execPath");
      debugPrint("Data path: $dataPath");

      debugPrint(
          "Pairing to 127.0.0.1:$adbPairingPort $adbPairingCode $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      debugPrint("STD OUT: ${result.stdout}");
      debugPrint("STD ERR: ${result.stderr}");

      Process.run(execPath, [
        'pair',
        '127.0.0.1:$adbPairingPort',
        adbPairingCode,
        dataPath
      ]).then((result) async {
        debugPrint("STD OUT: ${result.stdout}");
        debugPrint("STD ERR: ${result.stderr}");
        if (result.stderr.toString().isEmpty && !result.stdout.toString().startsWith("Failed") && !result.stdout.toString().startsWith("failed")) {
          debugPrint("Background activity sending adb pairing success message");
          await api.createEvent(
              address: AscentConstants.EVENT_TOGGLE_PAIRING_STATUS,
              payload: '');
          await api.createEvent(address: AscentConstants.EVENT_SWITCH_UI, payload: "/connect");
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController adbPairingPort = TextEditingController();
    TextEditingController adbPairingCode = TextEditingController();

    api.registerEventListener().listen((event) {
      switch (event.address) {
        case AscentConstants.EVENT_PAIRING_PORT_DISCOVERED:
          adbPairingPort.text = event.payload;
          break;
        default:
      }
    });

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: adbPairingPort,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S.current.stage_pairing_port,
            ),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: adbPairingCode,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: S.current.stage_pairing_code,
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton.icon(
            onPressed: (() =>
                onStartPairing(adbPairingPort.text, adbPairingCode.text)),
            icon: const Icon(Icons.check),
            label: Text(S.current.stage_pairing_start),
          ),
        ],
      ),
    );
  }
}
