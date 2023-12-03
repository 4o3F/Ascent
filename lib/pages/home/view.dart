import 'dart:io';

import 'package:ascent/global_state.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'logic.dart';

class HomePage extends StatelessWidget {
  HomePage({Key? key}) : super(key: key);

  final logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    GlobalState.platform.invokeMethod('getDeveloperOptionEnabled').then(
            (value) =>
        logic.developerOptionEnabled.value = (value.toString() == "true"));

    return Material(
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Obx(() => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "home.developer_option.status",
                      style: TextStyle(fontSize: 20),
                    ).tr(),
                    logic.developerOptionEnabled.value
                        ? const Text(
                            "home.developer_option.enabled",
                            style: TextStyle(
                                color: Colors.lightGreenAccent, fontSize: 20),
                          ).tr()
                        : const Text(
                            "home.developer_option.disabled",
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 20),
                          ).tr(),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "home.pairing.status",
                      style: TextStyle(fontSize: 20),
                    ).tr(),
                    GlobalState.hasCert.value
                        ? const Text(
                            "home.pairing.paired",
                            style: TextStyle(
                                color: Colors.lightGreenAccent, fontSize: 20),
                          ).tr()
                        : const Text(
                            "home.pairing.wait_pairing",
                            style: TextStyle(
                                color: Colors.redAccent, fontSize: 20),
                          ).tr(),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                BrnBigMainButton(
                  title: tr('home.pairing.name'),
                  bgColor: Colors.cyan.withOpacity(0.8),
                  isEnable: (logic.developerOptionEnabled.value &&
                      !GlobalState.hasCert.value),
                  onTap: () {
                    Get.toNamed("/pair");
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                BrnBigMainButton(
                  title: tr('home.connect.name'),
                  bgColor: Colors.indigoAccent.withOpacity(0.8),
                  isEnable:
                  (logic.developerOptionEnabled.value && GlobalState.hasCert.value),
                  onTap: () {
                    Get.toNamed("/connect");
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                BrnBigGhostButton(
                  title: tr('home.star'),
                  onTap: () async {
                    final Uri url = Uri.parse("https://github.com/4o3F");
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      await launchUrl(url);
                    }
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                BrnBigGhostButton(
                  bgColor: Colors.orangeAccent.withOpacity(0.8),
                  titleColor: Colors.white,
                  title: tr('home.support'),
                  onTap: () async {
                    final Uri url = Uri.parse("https://discord.gg/AhrW25ksQT");
                    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                      await launchUrl(url);
                    }
                  },
                ),
              ],
            )),
      ),
    );
  }
}
