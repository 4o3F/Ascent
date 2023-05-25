// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "drawer_about": MessageLookupByLibrary.simpleMessage("关于"),
        "drawer_function": MessageLookupByLibrary.simpleMessage("应用"),
        "notification_action": MessageLookupByLibrary.simpleMessage("输入"),
        "service_init": MessageLookupByLibrary.simpleMessage("后台服务启动中"),
        "stage_connecting": MessageLookupByLibrary.simpleMessage("手机连接"),
        "stage_connecting_description": MessageLookupByLibrary.simpleMessage(
            "Ascent将询问你无限调试的端口，此过程不需要再小窗模式下运行，输入正确的端口并连接成功后将自动开始监听祈愿历史记录链接"),
        "stage_connecting_port": MessageLookupByLibrary.simpleMessage("连接端口"),
        "stage_pairing": MessageLookupByLibrary.simpleMessage("手机配对"),
        "stage_pairing_code": MessageLookupByLibrary.simpleMessage("配对码"),
        "stage_pairing_description": MessageLookupByLibrary.simpleMessage(
            "Ascent将发送通知，请开启\n设置=>开发者选项=>无线调试\n然后选择使用配对码配对\n而后将根据通知提示输入端口和配对码\n(该过程只需要执行一次)"),
        "stage_pairing_guide_error":
            MessageLookupByLibrary.simpleMessage("机型教程未找到，请联系开发者"),
        "stage_pairing_guide_error_brand":
            MessageLookupByLibrary.simpleMessage("品牌"),
        "stage_pairing_guide_error_version":
            MessageLookupByLibrary.simpleMessage("版本"),
        "stage_pairing_notification_description_code":
            MessageLookupByLibrary.simpleMessage("请根据提示输入配对码"),
        "stage_pairing_notification_description_port":
            MessageLookupByLibrary.simpleMessage("自动检测配对端口中，您也可以手动在下方输入"),
        "stage_pairing_notification_success":
            MessageLookupByLibrary.simpleMessage("配对成功"),
        "stage_pairing_port": MessageLookupByLibrary.simpleMessage("配对端口"),
        "stage_pairing_start": MessageLookupByLibrary.simpleMessage("开始配对"),
        "stage_pairing_status_done":
            MessageLookupByLibrary.simpleMessage("已配对"),
        "stage_pairing_status_required":
            MessageLookupByLibrary.simpleMessage("未配对"),
        "stage_watching": MessageLookupByLibrary.simpleMessage("监听链接"),
        "stage_watching_description": MessageLookupByLibrary.simpleMessage(
            "Ascent开始监听祈愿历史记录链接，您现在可以打开原神/星穹铁道，当监听到有效的链接时会发送通知"),
        "stages": MessageLookupByLibrary.simpleMessage("Ascent执行步骤"),
        "title": MessageLookupByLibrary.simpleMessage("Ascent")
      };
}
