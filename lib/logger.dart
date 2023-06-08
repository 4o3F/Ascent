import 'dart:io';

import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

class AscentLogger {
  static final AscentLogger INSTANCE = AscentLogger();
  late Logger fileLogger;
  late Logger consoleLogger;

  init() async {
    String logFile =
        "${(await getApplicationDocumentsDirectory()).path}/ascent.log";
    fileLogger = Logger(
        output: AscentLogOutput(logFile),
        filter: AscentLogFilter());
    consoleLogger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        // number of method calls to be displayed
        errorMethodCount: 8,
        // number of method calls if stacktrace is provided
        lineLength: 2048,
        // width of the output
        colors: true,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        printTime: false,
        noBoxingByDefault: true,
      ),
    );
    fileLogger.d("Log file at: $logFile");
  }

  void log(String message) {
    consoleLogger.i(message);
    fileLogger.i(message);
  }
}

class AscentLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return true;
  }
}

class AscentLogOutput extends LogOutput {
  late final File logFile;

  AscentLogOutput(String logFile) {
    this.logFile = File(logFile);
  }

  @override
  void output(OutputEvent event) {
    // 在这里，你可以将日志写入文件或其他适当的输出位置
    print(event.lines.join('\n'));
    logFile.writeAsStringSync('${event.lines.join('\n')}\n',
        mode: FileMode.append);
  }
}
