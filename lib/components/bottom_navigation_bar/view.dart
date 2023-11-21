import 'package:ascent/global_state.dart';
import 'package:ascent/routes.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart' as easy_localization;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class BottomNavigationBarComponent extends StatelessWidget {
  BottomNavigationBarComponent({Key? key}) : super(key: key);

  final logic = Get.put(BottomNavigationBarLogic());

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Obx(() => BrnBottomTabBar(
              currentIndex: Routes.route2index(GlobalState.currentRoute.value),
              onTap: (index) {
                GlobalState.currentRoute.value = Routes.index2route(index);
                Get.toNamed(GlobalState.currentRoute.value);
              },
              fixedColor: Colors.blueAccent,
              isInkResponse: true,
              items: [
                BrnBottomTabBarItem(
                  icon: const Icon(Icons.home),
                  title: const Text('navigation.home').tr(),
                ),
                BrnBottomTabBarItem(
                  icon: const Icon(Icons.key),
                  title: const Text('navigation.pair').tr(),
                ),
                BrnBottomTabBarItem(
                  icon: const Icon(Icons.link),
                  title: const Text('navigation.connect').tr(),
                ),
                BrnBottomTabBarItem(
                  icon: const Icon(Icons.info),
                  title: const Text('navigation.info').tr(),
                )
              ],
            )));
  }
}
