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
  runApp(
    WithForegroundTask(
      child: EasyLocalization(
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('zh', 'CN'),
        ],
        path: 'assets/translations',
        fallbackLocale: const Locale('en', 'US'),
        child: AscentApp(),
      ),
    ),
  );
}

class AscentApp extends StatelessWidget {
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
              child: GetMaterialApp(
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
            BottomNavigationBarComponent()
          ],
        ));
  }
}
