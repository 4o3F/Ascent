import 'dart:io';

import 'package:ascent/state.dart';
import 'package:flutter/cupertino.dart';

Future<bool> adbPair(int port, String code) async {
  String adbPath = await AscentGlobalState.INSTANCE.getAdbLibPath();
  final pairResult =
      await Process.run(adbPath, ["pair", "127.0.0.1:${port}", code]);
  debugPrint(pairResult.stdout);
  return true;
}
