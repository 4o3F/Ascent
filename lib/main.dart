import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:ascent/route.dart';
import 'package:ascent/state.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'generated/l10n.dart';

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(const Ascent());
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true,

      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'AWESOME SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(),
  );

  service.startService();
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: false,
              actions: <AndroidNotificationAction>[
                const AndroidNotificationAction(
                  "reply",
                  "reply",
                  allowGeneratedReplies: true,
                  inputs: <AndroidNotificationActionInput>[
                    AndroidNotificationActionInput(
                      label: "Input"
                    )
                  ]
                )
              ]
            ),
          ),

        );

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      }
    }

    /// you can see this log in logcat
    print('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
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
      if (!isRunning) {
        service.startService()
      }
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

// class _AscentMainState {
//   Future<String> loadBinary() async {
//     final libpath = await getLibPath();
//     final execPath = libpath! + "/libadb.so";
//     debugPrint(execPath);
//     final result2 = await Process.run("ls", ['-l', (libpath)!]);
//
//     final result3 = await Process.run(execPath, ['pair']);
//     debugPrint(result3.stdout);
//     return result3.stdout;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text("Ascent"),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               'A',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         tooltip: 'Increment',
//         onPressed: () {},
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
