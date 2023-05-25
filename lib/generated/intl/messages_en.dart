// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "drawer_about": MessageLookupByLibrary.simpleMessage("About"),
        "drawer_function": MessageLookupByLibrary.simpleMessage("Application"),
        "notification_action": MessageLookupByLibrary.simpleMessage("Input"),
        "service_init": MessageLookupByLibrary.simpleMessage(
            "Background service initializing"),
        "stage_connecting":
            MessageLookupByLibrary.simpleMessage("Phone Connecting"),
        "stage_connecting_description": MessageLookupByLibrary.simpleMessage(
            "Ascent will ask you the port for unlimited debugging. This process does not need to be run in the picture in picture mode. After entering the correct port and connecting successfully, it will automatically start watching for the wish history link."),
        "stage_connecting_port":
            MessageLookupByLibrary.simpleMessage("Connect port"),
        "stage_pairing": MessageLookupByLibrary.simpleMessage("Phone Pairing"),
        "stage_pairing_code":
            MessageLookupByLibrary.simpleMessage("Pairing code"),
        "stage_pairing_description": MessageLookupByLibrary.simpleMessage(
            "Ascent will send notifications, please enable \nSettings => Developer options => Wireless Debugging\nThen select \"Pair with pairing code.\"\nAfterwards, follow the notification prompts to enter the port and pairing code.\n(This process only needs to be performed once.)"),
        "stage_pairing_guide_error": MessageLookupByLibrary.simpleMessage(
            "Guide for your brand can\'t be found, please contact developers"),
        "stage_pairing_guide_error_brand":
            MessageLookupByLibrary.simpleMessage("Brand"),
        "stage_pairing_guide_error_version":
            MessageLookupByLibrary.simpleMessage("Version"),
        "stage_pairing_notification_description_code":
            MessageLookupByLibrary.simpleMessage(
                "Please enter pairing code below"),
        "stage_pairing_notification_description_port":
            MessageLookupByLibrary.simpleMessage(
                "Auto detecting pairing port, you can also input it manually below"),
        "stage_pairing_notification_success":
            MessageLookupByLibrary.simpleMessage("Pairing successful"),
        "stage_pairing_port":
            MessageLookupByLibrary.simpleMessage("Pairing port"),
        "stage_pairing_start":
            MessageLookupByLibrary.simpleMessage("Start Pairing"),
        "stage_pairing_status_done":
            MessageLookupByLibrary.simpleMessage("Paired"),
        "stage_pairing_status_required":
            MessageLookupByLibrary.simpleMessage("Unpaired"),
        "stage_watching":
            MessageLookupByLibrary.simpleMessage("Watching for wish link"),
        "stage_watching_description": MessageLookupByLibrary.simpleMessage(
            "Ascent starts monitoring the history record links of wishes. You can now open Genshin Impact/Honkai: Star Rail, and when a valid link is detected, a notification will be sent."),
        "stages": MessageLookupByLibrary.simpleMessage("Ascent Stages"),
        "title": MessageLookupByLibrary.simpleMessage("Ascent")
      };
}
