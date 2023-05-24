import 'package:ascent/about/view.dart';
import 'package:ascent/home/view.dart';
import 'package:ascent/pair/guide/view.dart';
import 'package:get/get.dart';

class AscentRoutes {
  static final List<GetPage> getPages = [
    GetPage(name: "/", page: () => const HomePage()),
    GetPage(name: "/about", page: () => const AboutPage()),
    GetPage(name: "/pair", page: () => const PairGuidePage())
  ];
}
