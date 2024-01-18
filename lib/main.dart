import 'package:flutter/material.dart';
import 'package:ascent/src/rust/api/simple.dart';
import 'package:ascent/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
        body: Center(
          child: Text(
              'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:ascent/src/rust/api/simple.dart';
// import 'package:ascent/src/rust/frb_generated.dart';
//
// Future<void> main() async {
//   await RustLib.init();
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text('flutter_rust_bridge quickstart')),
//         body: Center(
//           child: Text(
//               'Action: Call Rust `greet("Tom")`\nResult: `${greet(name: "Tom")}`'),
//         ),
//       ),
//     );
//   }
// }
//
//
// // import 'dart:convert';
// // import 'dart:io';
// //
// // import 'package:ascent/ffi.dart';
// // import 'package:ascent/global_state.dart';
// // import 'package:ascent/routes.dart';
// // import 'package:bruno/bruno.dart';
// // import 'package:easy_localization/easy_localization.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_foreground_task/flutter_foreground_task.dart';
// // import 'package:get/get.dart';
// // import 'package:pub_semver/pub_semver.dart';
// // import 'package:receive_intent/receive_intent.dart' as intent;
// // import 'package:uri_to_file/uri_to_file.dart';
// // import 'package:url_launcher/url_launcher.dart';
// // import 'components/bottom_navigation_bar/view.dart';
// // import 'package:http/http.dart' as http;
// //
// // void main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   // Load localizations
// //   await EasyLocalization.ensureInitialized();
// //   // Set some final global data
// //   GlobalState.init();
// //   runApp(
// //     WithForegroundTask(
// //       child: EasyLocalization(
// //         supportedLocales: GlobalState.supportedLocale,
// //         path: GlobalState.localizationAssetPath,
// //         fallbackLocale: GlobalState.supportedLocale[0],
// //         child: const AscentApp(),
// //       ),
// //     ),
// //   );
// // }
// //
// // Future<void> checkUpdate() async {
// //   String url = GlobalState.locale == "zh_CN"
// //       ? "https://gist.gitmirror.com/4o3F/d44252ab04227a81b8270fe85a50691a/raw"
// //       : "https://gist.github.com/4o3F/d44252ab04227a81b8270fe85a50691a/raw";
// //   http.Response response = await http.get(Uri.parse(url));
// //   Map parsed = json.decode(response.body);
// //   String version = parsed['version'];
// //   String discord = parsed['discord'];
// //   GlobalState.discord = discord;
// //   Version newVersion = Version.parse(version);
// //   Version currentVersion = Version.parse(GlobalState.version);
// //   if (newVersion > currentVersion) {
// //     String updateInfo =
// //         parsed['info'][GlobalState.locale] ?? parsed['info']['en_US'];
// //     Uri url = Uri.parse(GlobalState.locale == "zh_CN"
// //         ? parsed['url']['backup']
// //         : parsed['url']['main']);
// //     BrnEnhanceOperationDialog dialog = BrnEnhanceOperationDialog(
// //       context: Get.context!,
// //       titleText: tr('update.title') + version,
// //       descText: updateInfo,
// //       mainButtonText: tr('update.ok'),
// //       secondaryButtonText: tr('update.cancel'),
// //       onMainButtonClick: () async {
// //         if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
// //           await launchUrl(url);
// //         }
// //       },
// //       onSecondaryButtonClick: () {
// //         Get.back(closeOverlays: true);
// //       },
// //     );
// //     dialog.show();
// //   }
// // }
// //
// // class AscentApp extends StatelessWidget {
// //   const AscentApp({super.key});
// //
// //   Future<void> initReceiveIntent() async {
// //     try {
// //       final receivedIntent = await intent.ReceiveIntent.getInitialIntent();
// //       if (receivedIntent != null && receivedIntent.action != null) {
// //         if (receivedIntent.action == "android.intent.action.SEND" &&
// //             receivedIntent.extra != null) {
// //           File file = await toFile(
// //               receivedIntent.extra?["android.intent.extra.STREAM"]);
// //           String path = file.path;
// //           String link = await api.doFilter(filePath: path);
// //           file.deleteSync();
// //           GlobalState.mixpanel.track("System Trace Complete", properties: {
// //             'Game': link.contains('hkrpg') ? 'hkrpg' : 'gs',
// //           });
// //           Get.dialog(BrnScrollableTextDialog(
// //             title: tr("connect.link_action.title"),
// //             contentText: link,
// //             submitText: tr("connect.link_action.copy_button"),
// //             submitBgColor: Colors.greenAccent,
// //             onSubmitClick: () {
// //               Clipboard.setData(ClipboardData(text: link));
// //               BrnToast.showInCenter(
// //                 text: tr("connect.link_action.copied"),
// //                 context: Get.context!,
// //               );
// //             },
// //           ));
// //           GlobalState.mixpanel.flush();
// //         }
// //       }
// //     } on PlatformException catch (_, e) {
// //       GlobalState.mixpanel
// //           .track('Platform error', properties: {'error': e.toString()});
// //     }
// //
// //     GlobalState.intentSubscription ??= intent.ReceiveIntent.receivedIntentStream
// //         .listen((intent.Intent? receivedIntent) async {
// //       if (receivedIntent != null && receivedIntent.action != null) {
// //         if (receivedIntent.action == "android.intent.action.SEND" &&
// //             receivedIntent.extra != null) {
// //           File file = await toFile(
// //               receivedIntent.extra?["android.intent.extra.STREAM"]);
// //           String path = file.path;
// //           String link = await api.doFilter(filePath: path);
// //           file.deleteSync();
// //           GlobalState.mixpanel.track("System Trace Complete", properties: {
// //             'Game': link.contains('hkrpg') ? 'hkrpg' : 'gs',
// //           });
// //           Get.dialog(BrnScrollableTextDialog(
// //             title: tr("connect.link_action.title"),
// //             contentText: link,
// //             submitText: tr("connect.link_action.copy_button"),
// //             submitBgColor: Colors.greenAccent,
// //             onSubmitClick: () {
// //               Clipboard.setData(ClipboardData(text: link));
// //               BrnToast.showInCenter(
// //                 text: tr("connect.link_action.copied"),
// //                 context: Get.context!,
// //               );
// //             },
// //           ));
// //           GlobalState.mixpanel.flush();
// //         }
// //       }
// //     }, onError: (err) {
// //       GlobalState.mixpanel
// //           .track('Platform error', properties: {'error': err.toString()});
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     initReceiveIntent();
// //     GlobalState.locale = context.deviceLocale.toString();
// //     checkUpdate();
// //     api.initLogger();
// //     return MaterialApp(
// //         localizationsDelegates: context.localizationDelegates,
// //         supportedLocales: context.supportedLocales,
// //         locale: context.locale,
// //         debugShowCheckedModeBanner: false,
// //         home: Column(
// //           children: [
// //             Expanded(
// //               child: Scaffold(
// //                 body: GetMaterialApp(
// //                   initialRoute: Routes.defaultRoute,
// //                   getPages: Routes.routes,
// //                   defaultTransition: Transition.fade,
// //                   debugShowCheckedModeBanner: false,
// //                   routingCallback: (routing) {
// //                     // Switch current route, mainly used for updating bottom navigation tab
// //                     GlobalState.currentRoute.value = routing!.current;
// //                   },
// //                 ),
// //               ),
// //             ),
// //             BottomNavigationBarComponent()
// //           ],
// //         ));
// //   }
// // }
// //
