import 'dart:convert';
import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../constants.dart';
import '../ffi.dart';
import '../logger.dart';

class AboutLogic extends GetxController {}

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  onGetWishLink() async {
    api.getData(key: AscentConstants.ADB_LIB_PATH).then((adbLibPath) async {
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      AscentLogger.INSTANCE.log("Exec path: $execPath");
      AscentLogger.INSTANCE.log("Data path: $dataPath");

      var result = await Process.run(execPath, ['start-server', dataPath]);

      AscentLogger.INSTANCE.log("STD OUT: ${result.stdout}");
      AscentLogger.INSTANCE.log("STD ERR: ${result.stderr}");

      Process.run(execPath, ['shell', 'logcat -d'], runInShell: false)
          .then((result) async {
        AscentLogger.INSTANCE.log("STD OUT: ${result.stdout}");
        AscentLogger.INSTANCE.log("STD ERR: ${result.stderr}");
      });
    });
  }

  shareLog() async {
    await getApplicationDocumentsDirectory().then((value) async {
      String adbLibPath = await api.getData(key: AscentConstants.ADB_LIB_PATH);
      String execPath = "$adbLibPath/libadb.so";

      String dataPath =
          await api.getData(key: AscentConstants.APPLICATION_DATA_PATH);

      Share.shareXFiles([XFile("${value.path}/ascent.log")]);
      return;

      AscentLogger.INSTANCE.log("Exec path: $execPath");
      AscentLogger.INSTANCE.log("Data path: $dataPath");

      ProcessResult result =
          await Process.run(execPath, ['start-server', dataPath]);

      AscentLogger.INSTANCE.log("STD OUT: ${result.stdout}");
      AscentLogger.INSTANCE.log("STD ERR: ${result.stderr}");

      result = await Process.run(execPath, ['shell', 'logcat -d'],
          runInShell: false, stdoutEncoding: null);
      String logcatLogs = utf8.decode(result.stdout, allowMalformed: true);
      AscentLogger.INSTANCE.log("LOGCAT LOG: ${result.stdout}");
    });
  }

  @override
  Widget build(BuildContext context) {
    final logic = Get.put(AboutLogic());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
              text: TextSpan(children: [
            const TextSpan(
                text: "Developed by ",
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.normal)),
            TextSpan(
                text: "403F",
                style: const TextStyle(
                    color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrlString("https://403f.cafe",
                        mode: LaunchMode.externalApplication);
                  }),
          ])),
          RichText(
              text: TextSpan(children: [
                const TextSpan(
                    text: "QQ Group: ",
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.normal)),
                TextSpan(
                    text: "855857816",
                    style: const TextStyle(
                        color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrlString("http://qm.qq.com/cgi-bin/qm/qr?_wv=1027&k=_Z-TH87QJHYhYCHjRkIk9580cCpMF_Mg&authKey=HgHsa4RtYARy4ITUdRevW4KeK4ogBm0%2Ffqi8GOxEs4NNeBmgi34WeQZ4Q1%2FxPch9&noverify=0&group_code=817701820",
                            mode: LaunchMode.externalApplication);
                      }),
              ])),
          RichText(
              text: TextSpan(children: [
            const TextSpan(
                text: "GitHub: ",
                style: TextStyle(
                    color: Colors.blueAccent, fontWeight: FontWeight.normal)),
            TextSpan(
                text: "4o3F\n",
                style: const TextStyle(
                    color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    launchUrlString("https://github.com/4o3F");
                  }),
            const TextSpan(
              text: "Email: ",
              style: TextStyle(
                  color: Colors.blueAccent, fontWeight: FontWeight.normal),
            ),
            TextSpan(
              text: "4o3f@proton.me",
              style: const TextStyle(
                  color: Colors.orangeAccent, fontWeight: FontWeight.bold),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrlString("mailto:4o3f@proton.me");
                },
            ),
          ])),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                  onPressed: shareLog,
                  icon: const Icon(Icons.file_copy),
                  label: const Text("Share log"))
            ],
          )
        ],
      ),
    );
  }
}
