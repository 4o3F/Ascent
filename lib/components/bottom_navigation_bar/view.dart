import 'package:ascent/global_state.dart';
import 'package:ascent/routes.dart';
import 'package:easy_localization/easy_localization.dart' show tr;
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';

class BottomNavigationBarComponent extends StatelessWidget {
  const BottomNavigationBarComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Obx(() => BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: Routes.route2index(GlobalState.currentRoute.value),
              onTap: (index) {
                GlobalState.currentRoute.value = Routes.index2route(index);
                FlutterForegroundTask.isRunningService.then((value) => {
                      if (value) {FlutterForegroundTask.stopService()}
                    });
                Get.toNamed(GlobalState.currentRoute.value);
              },
              selectedItemColor: Colors.blueAccent,
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.home),
                  label: tr('navigation.home'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.key),
                  label: tr('navigation.pair'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.link),
                  label: tr('navigation.connect'),
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.info),
                  label: tr('navigation.info'),
                )
              ],
            )));
  }
}
