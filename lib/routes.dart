import 'package:ascent/pages/connect/view.dart';
import 'package:ascent/pages/home/view.dart';
import 'package:ascent/pages/info/view.dart';
import 'package:ascent/pages/pair/view.dart';
import 'package:get/get.dart';

class Routes {
  static const String defaultRoute = "/home";
  static final List<GetPage> routes = [
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/pair', page: () => PairPage()),
    GetPage(name: '/connect', page: () => ConnectPage()),
    GetPage(name: '/info', page: () => InfoPage()),
  ];

  static int route2index(String route) {
    switch (route) {
      case '/home':
        return 0;
      case '/pair':
        return 1;
      case '/connect':
        return 2;
      case '/info':
        return 3;
      default:
        return 0;
    }
  }

  static String index2route(int index) {
    switch (index) {
      case 0:
        return '/home';
      case 1:
        return '/pair';
      case 2:
        return '/connect';
      case 3:
        return '/info';
      default:
        return '/home';
    }
  }
}
