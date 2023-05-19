import 'package:ascent/about/view.dart';
import 'package:ascent/home/view.dart';
import 'package:ascent/pairing/guide/view.dart';
import 'package:get/get.dart';

class AscentRoutes {
  static final List<GetPage> getPages = [
    GetPage(name: "/", page: () => HomePage()),
    GetPage(name: "/about", page: () => AboutPage()),
    GetPage(name: "/pairing", page: () => PairingGuidePage())
  ];
}
