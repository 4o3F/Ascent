import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:ascent/logger.dart';
import 'package:ascent/pair/pair/pairing_notification.dart';
import 'package:ascent/route.dart';
import 'package:ascent/state.dart';
import 'package:ascent/updater.dart';
import 'package:ascent/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'constants.dart';
import 'ffi.dart';
import 'generated/l10n.dart';

void main() async {
  // HttpOverrides.global = MyHttpOverrides();

  // Storage initialize
  await GetStorage.init();

  // Clean up the log file
  await doLogCleaning();

  // Logger initialize
  await AscentLogger.INSTANCE.init();

  // Make sure widgets are loaded
  WidgetsFlutterBinding.ensureInitialized();

  // These are used to write global data for all isolates
  await initGlobalData();

  // Background service initialize
  await initializeService();

  await requestPermission();

  await initUpdater();

  await AscentGlobalState.INSTANCE.initMixPanel();

  runApp(const Ascent());
}



initUpdater() async {
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  String currentVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
  AscentUpdater updater = AscentUpdater(currentVersion);
  updater.checkUpdate();
}

doLogCleaning() async {
  String logFilePath =
      "${(await getApplicationDocumentsDirectory()).path}/ascent.log";
  File(logFilePath).writeAsStringSync("", mode: FileMode.write);
}

Future<void> requestPermission() async {
  Permission alertPermission = Permission.notification;
  if (await alertPermission.status.isDenied) {
    AscentLogger.INSTANCE.log("Notification permission requesting");
    alertPermission.request();
  }
  AscentLogger.INSTANCE.log("Notification permission granted");
}

initializeService() async {
  await S.load(
      Locale.fromSubtags(languageCode: Platform.localeName.split('_').first));

  final service = FlutterBackgroundService();

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

  await initGlobalEventListener();

  api.registerEventListener().listen((event) async {
    switch (event.address) {
      case 'update_stage':
        switch (event.payload) {
          case 'pair':
            await service.configure(
              androidConfiguration: AndroidConfiguration(
                onStart: onServiceStart,
                autoStart: false,
                isForegroundMode: true,
                notificationChannelId: 'ascent_service_channel',
                initialNotificationTitle: S.current.title,
                initialNotificationContent: S.current.service_init,
                foregroundServiceNotificationId: 233,
              ),
              iosConfiguration: IosConfiguration(),
            );
            service.startService();
            break;
        }
        break;
      default:
    }
  });

  // Do ping & pong for service alive check
  Timer.periodic(const Duration(seconds: 3), (timer) {
    api.createEvent(address: AscentConstants.EVENT_SERVICE_PING, payload: '');
  });
}

initGlobalData() async {
  AscentLogger.INSTANCE.log("Init global data");
  String? nativeLibPath = await getLibPath();
  String dataPath = (await getApplicationDocumentsDirectory()).path;
  await api.writeData(
      key: AscentConstants.APPLICATION_DATA_PATH, value: dataPath);
  await api.writeData(key: AscentConstants.ADB_LIB_PATH, value: nativeLibPath!);

  AscentGlobalState.INSTANCE.initPairingStatus();
}

initGlobalEventListener() async {
  AscentLogger.INSTANCE.log("Init Global Event Listener");
  api.registerEventListener().listen((event) {
    //AscentLogger.INSTANCE.log("Global Event Listener received ${event.address}");
    switch (event.address) {
      case AscentConstants.EVENT_SWITCH_UI:
        Get.offAndToNamed(event.payload);
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

  // Logger initialize
  await AscentLogger.INSTANCE.init();

  AscentLogger.INSTANCE.log("Background service init ensured");

  await S.load(
      Locale.fromSubtags(languageCode: Platform.localeName.split('_').first));

  AscentLogger.INSTANCE.log("Background service language loaded");

  service.on('stop').listen((event) {
    AscentLogger.INSTANCE.log("Background service stopping");
    service.stopSelf();
  });
  int identity = Random().nextInt(20);
  Timer.periodic(const Duration(seconds: 30), (timer) {
    AscentLogger.INSTANCE.log("Service identity: $identity");
  });

  PairingNotification.getInstance().doPairing();

  int lastPing = DateTime.now().millisecondsSinceEpoch;

  api.registerEventListener().listen((event) {
    if (event.address == AscentConstants.EVENT_SERVICE_PING) {
      lastPing = DateTime.now().millisecondsSinceEpoch;
    } else if (event.address == AscentConstants.EVENT_STOP_SERVICE) {
      service.stopSelf();
    }
  });

  Timer.periodic(const Duration(seconds: 2), (timer) {
    if (DateTime.now().millisecondsSinceEpoch - lastPing > 5000) {
      AscentLogger.INSTANCE
          .log("Main activity stopped pinging, killing background service");
      service.stopSelf();
    }
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

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}