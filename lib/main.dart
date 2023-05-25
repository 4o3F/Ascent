import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:ascent/pair/pair/pairing_notification.dart';
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
import 'package:permission_handler/permission_handler.dart';

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

  await requestPermission();

  runApp(const Ascent());
}

Future<void> requestPermission() async {
  Permission alertPermission = Permission.notification;
  if(await alertPermission.status.isDenied) {
    debugPrint("Notification permission requesting");
    alertPermission.request();
  }
  debugPrint("Notification permission granted");
}

initializeService() async {
  await S.load(
      Locale.fromSubtags(languageCode: Platform.localeName.split('_').first));

  final service = FlutterBackgroundService();

  if(await service.isRunning()) {
    service.invoke('stop');
  }

  // Create a notification channel used by foreground service to stay alive
  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'ascent_service_channel', // id
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
      onStart: onServiceStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'ascent_service_channel',
      initialNotificationTitle: S.current.title,
      initialNotificationContent: S.current.service_init,
      foregroundServiceNotificationId: 233,
    ),
    iosConfiguration: IosConfiguration(),
  );

  // These are used to write global data for all isolates
  await initGlobalData();

  await initGlobalEventListener();

  service.startService();
}

initGlobalData() async {
  debugPrint("Init global data");
  String? nativeLibPath = await getLibPath();
  String dataPath = (await getApplicationDocumentsDirectory()).path;
  await api.writeData(
      key: AscentConstants.APPLICATION_DATA_PATH, value: dataPath);
  await api.writeData(key: AscentConstants.ADB_LIB_PATH, value: nativeLibPath!);

  AscentGlobalState.INSTANCE.initPairingStatus();
}

initGlobalEventListener() async {
  debugPrint("Init Global Event Listener");
  api.registerEventListener().listen((event) {
    debugPrint("Global Event Listener received ${event.address}");
    switch(event.address) {
      case AscentConstants.EVENT_SWITCH_UI:
        Get.toNamed(event.payload);
        break;
      case AscentConstants.EVENT_TOGGLE_PAIRING_STATUS:
        AscentGlobalState.INSTANCE.togglePairingStatus();
        break;
    }
  });
}

@pragma('vm:entry-point')
void onServiceStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();
  debugPrint("Background service init ensured");

  await S.load(
      Locale.fromSubtags(languageCode: Platform.localeName.split('_').first));

  debugPrint("Background service language loaded");

  debugPrint("Registering event listener from dart background service");
  api.registerEventListener().listen((event) {
    debugPrint("Received event: ${event.address}");
    switch (event.address) {
      case 'update_stage':
        switch(event.payload) {
          case 'pair':
            PairingNotification.getInstance().doPairing();
            break;
        }
        break;
      default:
    }
  });

  service.on('stop').listen((event) {
    debugPrint("Background service stopping");
    service.stopSelf();
  });
  int identity = Random().nextInt(20);
  Timer.periodic(const Duration(seconds: 30), (timer) {
    debugPrint("Service identity: $identity");
  });
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
