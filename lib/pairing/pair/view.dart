import 'package:ascent/utils/adb_utils.dart';
import 'package:flutter/material.dart';

import '../../generated/l10n.dart';

class PairingPairPage extends StatelessWidget {
  const PairingPairPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController pairingPort = TextEditingController();
    TextEditingController pairingCode = TextEditingController();
    return Column(
      children: [
        TextField(
          controller: pairingPort,
          keyboardType: const TextInputType.numberWithOptions(
              signed: false, decimal: true),
          decoration: InputDecoration(
            labelText: S.current.stage_pairing_port,
          ),
        ),
        TextField(
          controller: pairingCode,
          keyboardType: const TextInputType.numberWithOptions(
              signed: false, decimal: true),
          decoration: InputDecoration(
            labelText: S.current.stage_pairing_code,
          ),
        ),
        Row(
          children: [
            Expanded(
                child: ElevatedButton(
              onPressed: () {
                debugPrint(pairingPort.value.text);
                adbPair(int.parse(pairingPort.text), pairingCode.text);
              },
              child: Text(S.current.stage_pairing),
            )),
          ],
        ),
      ],
    );
  }
}
