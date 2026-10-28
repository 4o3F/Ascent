import 'dart:io';

/// Minimal root shell helper based on the `su` binary.
/// Works in any isolate, including the foreground service one.
class Root {
  /// Run [cmd] as root, returns the trimmed stdout or null if it failed.
  static Future<String?> exec({required String cmd}) async {
    try {
      final ProcessResult result = await Process.run('su', ['-c', cmd]);
      if (result.exitCode != 0 && (result.stdout as String).isEmpty) {
        return null;
      }
      return (result.stdout as String).trim();
    } on ProcessException {
      // su binary not found
      return null;
    }
  }

  /// Check if root access is available and granted.
  static Future<bool> isRooted() async {
    final String? result = await exec(cmd: 'id -u');
    return result == '0';
  }
}
