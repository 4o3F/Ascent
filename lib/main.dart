import 'package:ascent/route.dart';
import 'package:ascent/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'generated/l10n.dart';

// @pragma('vm:entry-point')
// void androidWindow() {
//   runApp(const AndroidWindowApp());
// }

void main() async {
  await GetStorage.init();
  runApp(const Ascent());
}

class Ascent extends StatelessWidget {
  const Ascent({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ascent',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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

class AscentMainState extends GetxController {}

class AscentMain extends StatelessWidget {
  const AscentMain({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final state = Get.put(AscentMainState());
    final globalState = Get.put(AscentGlobalState());
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
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
