import 'dart:io';

import 'package:ascent/ffi.dart';
import 'package:ascent/global_state.dart';
import 'package:ascent/routes.dart';
import 'package:bruno/bruno.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
import 'package:receive_intent/receive_intent.dart' as intent;
import 'package:uri_to_file/uri_to_file.dart';
import 'components/bottom_navigation_bar/view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load localizations
  await EasyLocalization.ensureInitialized();
  // Set some final global data
  GlobalState.init();
  runApp(
    WithForegroundTask(
      child: EasyLocalization(
        supportedLocales: GlobalState.supportedLocale,
        path: GlobalState.localizationAssetPath,
        fallbackLocale: GlobalState.supportedLocale[0],
        child: const AscentApp(),
      ),
    ),
  );
}

class AscentApp extends StatelessWidget {
  const AscentApp({super.key});

  Future<void> initReceiveIntent() async {
    try {
      final receivedIntent = await intent.ReceiveIntent.getInitialIntent();
      if (receivedIntent != null && receivedIntent.action != null) {
        if (receivedIntent.action == "android.intent.action.SEND" &&
            receivedIntent.extra != null) {
          File file = await toFile(
              receivedIntent.extra?["android.intent.extra.STREAM"]);
          String path = file.path;
          String link = await api.doFilter(filePath: path);
          file.deleteSync();
          Get.dialog(BrnScrollableTextDialog(
            title: tr("connect.link_action.title"),
            contentText: link,
            submitText: tr("connect.link_action.copy_button"),
            submitBgColor: Colors.greenAccent,
            onSubmitClick: () {
              Clipboard.setData(ClipboardData(text: link));
              BrnToast.showInCenter(
                text: tr("connect.link_action.copied"),
                context: Get.context!,
              );
            },
          ));
        }
      }
    } on PlatformException catch (_, e) {}

    GlobalState.intentSubscription ??= intent.ReceiveIntent.receivedIntentStream
        .listen((intent.Intent? receivedIntent) async {
      if (receivedIntent != null && receivedIntent.action != null) {
        if (receivedIntent.action == "android.intent.action.SEND" &&
            receivedIntent.extra != null) {
          File file = await toFile(
              receivedIntent.extra?["android.intent.extra.STREAM"]);
          String path = file.path;
          String link = await api.doFilter(filePath: path);
          file.deleteSync();
          Get.dialog(BrnScrollableTextDialog(
            title: tr("connect.link_action.title"),
            contentText: link,
            submitText: tr("connect.link_action.copy_button"),
            submitBgColor: Colors.greenAccent,
            onSubmitClick: () {
              Clipboard.setData(ClipboardData(text: link));
              BrnToast.showInCenter(
                text: tr("connect.link_action.copied"),
                context: Get.context!,
              );
            },
          ));
        }
      }
    }, onError: (err) {});
  }

  @override
  Widget build(BuildContext context) {
    initReceiveIntent();
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        debugShowCheckedModeBanner: false,
        home: Column(
          children: [
            Expanded(
              child: Scaffold(
                body: GetMaterialApp(
                  initialRoute: Routes.defaultRoute,
                  getPages: Routes.routes,
                  defaultTransition: Transition.fade,
                  debugShowCheckedModeBanner: false,
                  routingCallback: (routing) {
                    // Switch current route, mainly used for updating bottom navigation tab
                    GlobalState.currentRoute.value = routing!.current;
                  },
                ),
              ),
            ),
            BottomNavigationBarComponent()
          ],
        ));
  }
}
