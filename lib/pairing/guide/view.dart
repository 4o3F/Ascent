import 'package:ascent/state.dart';
import 'package:ascent/utils/device_info_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../generated/l10n.dart';

class PairingGuidePage extends StatelessWidget {
  const PairingGuidePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DeviceInfo deviceInfo = DeviceInfo.INSTANCE;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.current.stage_pairing,
            style: const TextStyle(
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                fontSize: 15,
                decoration: TextDecoration.none),
          ),
          Obx(() {
            String guideImageUrl =
                "https://t1.akashadata.com/xstatic/img/3y7.jpeg";
            if (deviceInfo.loadFinished.value) {
              guideImageUrl =
                  "https://feixiaoqiu.com/pairing/guide/${deviceInfo.brand}";
            }
            return Image(
              image: NetworkImage(guideImageUrl),
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  "${S.current.stage_pairing_guide_error}\n${S.current.stage_pairing_guide_error_brand}: ${deviceInfo.brand}\n${S.current.stage_pairing_guide_error_version}: ${deviceInfo.androidSdkVersion}",
                  style: const TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: TextDecoration.none),
                );
              },
            );
          }),
          Row(
            children: [
              Expanded(
                  child: TextButton(
                onPressed: () {
                },
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    backgroundColor: Colors.orangeAccent),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.rocket_launch,
                      color: Colors.white,
                    ),
                    const SizedBox(
                      width: 5.0,
                    ),
                    Text(
                      S.current.stage_pairing_start,
                      style: const TextStyle(color: Colors.white),
                    )
                  ],
                ),
              )),
            ],
          )
        ],
      ),
    );
  }
}
