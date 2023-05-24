import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:ascent/pair/pair/pairing.dart';
import 'package:ascent/route.dart';
import 'package:ascent/state.dart';
import 'package:ascent/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import 'constants.dart';
import 'ffi.dart';
import 'generated/l10n.dart';

void main() async {
  // Storage initialize
  await GetStorage.init();
  // Make sure widgets are loaded
  WidgetsFlutterBinding.ensureInitialized();
  // Background service initialize
  await initializeService();

  runApp(const Ascent());
}
Future<void> initializeService() async {
  await S.load(Locale.fromSubtags(languageCode: Platform.localeName.split('_').first));

  final service = FlutterBackgroundService();

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'ascent_channel', // id
    S.current.title, // title
    description: '', // description
    importance: Importance.max, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'ascent_channel',
      initialNotificationTitle: S.current.title,
      initialNotificationContent: S.current.service_init,
      foregroundServiceNotificationId: 233,
    ),
    iosConfiguration: IosConfiguration(),
  );


  // These are used to write global data for all isolates
  await initGlobalData();

  service.startService();
  api.createEvent(address: 'update_stage', payload: 'pair');

}

initGlobalData() async {
  String? nativeLibPath = await getLibPath();
  String dataPath = (await getApplicationDocumentsDirectory()).path;
  await api.writeData(key: AscentConstants.APPLICATION_DATA_PATH, value: dataPath);
  await api.writeData(key: AscentConstants.ADB_LIB_PATH, value: nativeLibPath!);
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  await S.load(Locale.fromSubtags(languageCode: Platform.localeName.split('_').first));

  service.on('update_stage').listen((event) {
    String? stage = event?['stage'].toString();
    debugPrint("Service change stage: ${stage}");
    switch (stage) {
      case "pairing":
        debugPrint(service.hashCode.toString());
        Pairing.getInstance().doPairing();
        break;
    }
  });

  api.registerEventListener().listen((event) {
    debugPrint("Received event: ${event.address}");
    switch(event.address) {
      case 'update_stage':
        Pairing.getInstance().doPairing();
    }
  });

  // api.registerEventListener().listen((event) {
  //   debugPrint("EVENT RECEIVED");
  //   debugPrint(event.address);
  // });
  //
  // debugPrint("Creating eventbus event");
  // await api.createEvent(address: 'EVENTBUS_EVENT', payload: "");

}


class Ascent extends StatelessWidget {
  const Ascent({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
        useMaterial3: true,
      ),
      home: const AscentMain(title: "Ascent"),
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
    );
  }
}

class AscentMain extends StatelessWidget {
  const AscentMain({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final globalState = Get.put(AscentGlobalState.INSTANCE);

    final service = FlutterBackgroundService();
    service.isRunning().then((isRunning) => {
          if (!isRunning) {service.startService()}
        });

    return Scaffold(
      appBar: AppBar(
        title: Text(S.current.title),
        leading: Builder(
            builder: (context) => IconButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                icon: const Icon(Icons.menu))),
      ),
      drawer: Obx(() {
        return NavigationDrawer(
          onDestinationSelected: globalState.changePage,
          selectedIndex: globalState.getPage(),
          children: [
            NavigationDrawerDestination(
              icon: const Icon(Icons.widgets_outlined),
              label: Text(S.current.drawer_function),
              selectedIcon: const Icon(Icons.widgets),
            ),
            NavigationDrawerDestination(
              icon: const Icon(Icons.info_outline),
              label: Text(S.current.drawer_about),
              selectedIcon: const Icon(Icons.info),
            )
          ],
        );
      }),
      body: GetMaterialApp(
        title: 'Ascent',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.cyanAccent),
          useMaterial3: true,
        ),
        initialRoute: "/",
        getPages: AscentRoutes.getPages,
      ),
    );
  }
}