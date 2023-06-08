import 'package:ascent/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_autoupdate/flutter_autoupdate.dart';
import 'package:version/version.dart';

import 'constants.dart';

class AscentUpdater {
  late String currentVersion;

  AscentUpdater(this.currentVersion);

  Future<void> checkUpdate() async {
    UpdateManager updater =
        UpdateManager(versionUrl: AscentConstants.UPDATE_URL);

    var result = await updater.fetchUpdates();
    AscentLogger.INSTANCE.log("Build: ${result!.latestVersion}");
    AscentLogger.INSTANCE.log("Download URL: ${result.downloadUrl}");
    AscentLogger.INSTANCE.log("Latest version: ${result.latestVersion}");
    AscentLogger.INSTANCE.log("Current version: ${Version.parse(currentVersion)}");

    if (result.latestVersion > (Version.parse(currentVersion))) {
      AscentLogger.INSTANCE.log("Need update");
      // Get update stream controller
      var update = await result.initializeUpdate();
      update.stream.listen((event) async {
        AscentLogger.INSTANCE
            .log("Downloading: ${event.receivedBytes} / ${event.totalBytes}");
        if (event.completed) {
          AscentLogger.INSTANCE.log('Download completed');

          await update.close();

          await result.runUpdate(event.path, autoExit: true, exitDelay: 5000);
        }
      });
    }
  }
}
