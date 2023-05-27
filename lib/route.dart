import 'package:ascent/about/about.dart';
import 'package:ascent/connect/connecting.dart';
import 'package:ascent/home/view.dart';
import 'package:ascent/pair/guide/pairing_guide.dart';
import 'package:ascent/pair/pair/pairing_window.dart';
import 'package:get/get.dart';

class AscentRoutes {
  static final List<GetPage> getPages = [
    GetPage(name: "/", page: () => const HomePage()),
    GetPage(name: "/about", page: () => const AboutPage()),
    GetPage(name: "/pair", page: () => const PairGuidePage()),
    GetPage(name: "/pairing_window", page: () => const PairingWindowPage()),
    GetPage(name: "/connect", page: () => const ConnectPage()),
  ];
}
