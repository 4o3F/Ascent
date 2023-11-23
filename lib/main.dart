import 'package:ascent/global_state.dart';
import 'package:ascent/routes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
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
