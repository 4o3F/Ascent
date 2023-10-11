// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Ascent`
  String get title {
    return Intl.message(
      'Ascent',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Background service initializing`
  String get service_init {
    return Intl.message(
      'Background service initializing',
      name: 'service_init',
      desc: '',
      args: [],
    );
  }

  /// `Update needed`
  String get update_needed {
    return Intl.message(
      'Update needed',
      name: 'update_needed',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Update later`
  String get no_update {
    return Intl.message(
      'Update later',
      name: 'no_update',
      desc: '',
      args: [],
    );
  }

  /// `Application`
  String get drawer_function {
    return Intl.message(
      'Application',
      name: 'drawer_function',
      desc: '',
      args: [],
    );
  }

  /// `About/Issues`
  String get drawer_about {
    return Intl.message(
      'About/Issues',
      name: 'drawer_about',
      desc: '',
      args: [],
    );
  }

  /// `Input`
  String get notification_action {
    return Intl.message(
      'Input',
      name: 'notification_action',
      desc: '',
      args: [],
    );
  }

  /// `Ascent Stages`
  String get stages {
    return Intl.message(
      'Ascent Stages',
      name: 'stages',
      desc: '',
      args: [],
    );
  }

  /// `Phone Pairing`
  String get stage_pairing {
    return Intl.message(
      'Phone Pairing',
      name: 'stage_pairing',
      desc: '',
      args: [],
    );
  }

  /// `Guide for your brand can't be found, if you wish to help complete this, please contact developers`
  String get stage_pairing_guide_error {
    return Intl.message(
      'Guide for your brand can\'t be found, if you wish to help complete this, please contact developers',
      name: 'stage_pairing_guide_error',
      desc: '',
      args: [],
    );
  }

  /// `Brand`
  String get stage_pairing_guide_error_brand {
    return Intl.message(
      'Brand',
      name: 'stage_pairing_guide_error_brand',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get stage_pairing_guide_error_version {
    return Intl.message(
      'Version',
      name: 'stage_pairing_guide_error_version',
      desc: '',
      args: [],
    );
  }

  /// `Start Pairing`
  String get stage_pairing_start {
    return Intl.message(
      'Start Pairing',
      name: 'stage_pairing_start',
      desc: '',
      args: [],
    );
  }

  /// `Pairing port`
  String get stage_pairing_port {
    return Intl.message(
      'Pairing port',
      name: 'stage_pairing_port',
      desc: '',
      args: [],
    );
  }

  /// `Pairing code`
  String get stage_pairing_code {
    return Intl.message(
      'Pairing code',
      name: 'stage_pairing_code',
      desc: '',
      args: [],
    );
  }

  /// `Paired`
  String get stage_pairing_status_done {
    return Intl.message(
      'Paired',
      name: 'stage_pairing_status_done',
      desc: '',
      args: [],
    );
  }

  /// `Unpaired`
  String get stage_pairing_status_required {
    return Intl.message(
      'Unpaired',
      name: 'stage_pairing_status_required',
      desc: '',
      args: [],
    );
  }

  /// `Auto detecting pairing port, you can also input it manually below`
  String get stage_pairing_notification_description_port {
    return Intl.message(
      'Auto detecting pairing port, you can also input it manually below',
      name: 'stage_pairing_notification_description_port',
      desc: '',
      args: [],
    );
  }

  /// `Please enter pairing code below`
  String get stage_pairing_notification_description_code {
    return Intl.message(
      'Please enter pairing code below',
      name: 'stage_pairing_notification_description_code',
      desc: '',
      args: [],
    );
  }

  /// `Pairing successful`
  String get stage_pairing_notification_success {
    return Intl.message(
      'Pairing successful',
      name: 'stage_pairing_notification_success',
      desc: '',
      args: [],
    );
  }

  /// `Ascent will send notifications, please enable \nSettings => Developer options => Wireless Debugging\nThen select "Pair with pairing code."\nAfterwards, follow the notification prompts to enter the port and pairing code.\n(This process only needs to be performed once.)`
  String get stage_pairing_description {
    return Intl.message(
      'Ascent will send notifications, please enable \nSettings => Developer options => Wireless Debugging\nThen select "Pair with pairing code."\nAfterwards, follow the notification prompts to enter the port and pairing code.\n(This process only needs to be performed once.)',
      name: 'stage_pairing_description',
      desc: '',
      args: [],
    );
  }

  /// `Phone Connecting`
  String get stage_connecting {
    return Intl.message(
      'Phone Connecting',
      name: 'stage_connecting',
      desc: '',
      args: [],
    );
  }

  /// `Connection status: `
  String get stage_connecting_status {
    return Intl.message(
      'Connection status: ',
      name: 'stage_connecting_status',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get stage_connecting_status_done {
    return Intl.message(
      'Connected',
      name: 'stage_connecting_status_done',
      desc: '',
      args: [],
    );
  }

  /// `Waiting to connect`
  String get stage_connecting_status_waiting {
    return Intl.message(
      'Waiting to connect',
      name: 'stage_connecting_status_waiting',
      desc: '',
      args: [],
    );
  }

  /// `Connection failed`
  String get stage_connecting_status_failed {
    return Intl.message(
      'Connection failed',
      name: 'stage_connecting_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Connect`
  String get stage_connecting_status_required {
    return Intl.message(
      'Connect',
      name: 'stage_connecting_status_required',
      desc: '',
      args: [],
    );
  }

  /// `Repair`
  String get stage_connecting_status_repair {
    return Intl.message(
      'Repair',
      name: 'stage_connecting_status_repair',
      desc: '',
      args: [],
    );
  }

  /// `Ascent will ask you the port for unlimited debugging. This process does not need to be run in the picture in picture mode. After entering the correct port and connecting successfully, it will automatically start watching for the wish history link.`
  String get stage_connecting_description {
    return Intl.message(
      'Ascent will ask you the port for unlimited debugging. This process does not need to be run in the picture in picture mode. After entering the correct port and connecting successfully, it will automatically start watching for the wish history link.',
      name: 'stage_connecting_description',
      desc: '',
      args: [],
    );
  }

  /// `Connect port`
  String get stage_connecting_port {
    return Intl.message(
      'Connect port',
      name: 'stage_connecting_port',
      desc: '',
      args: [],
    );
  }

  /// `Watching for wish link`
  String get stage_watching {
    return Intl.message(
      'Watching for wish link',
      name: 'stage_watching',
      desc: '',
      args: [],
    );
  }

  /// `Ascent starts monitoring the history record links of wishes. You can now open Genshin Impact/Honkai: Star Rail, and when a valid link is detected, a notification will be sent.`
  String get stage_watching_description {
    return Intl.message(
      'Ascent starts monitoring the history record links of wishes. You can now open Genshin Impact/Honkai: Star Rail, and when a valid link is detected, a notification will be sent.',
      name: 'stage_watching_description',
      desc: '',
      args: [],
    );
  }

  /// `Last time fetching wish link: `
  String get stage_watching_last_time {
    return Intl.message(
      'Last time fetching wish link: ',
      name: 'stage_watching_last_time',
      desc: '',
      args: [],
    );
  }

  /// `Restart wish link watch`
  String get stage_watching_restart {
    return Intl.message(
      'Restart wish link watch',
      name: 'stage_watching_restart',
      desc: '',
      args: [],
    );
  }

  /// `Copy wish link to clipboard`
  String get copy_link {
    return Intl.message(
      'Copy wish link to clipboard',
      name: 'copy_link',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get copied {
    return Intl.message(
      'Copied',
      name: 'copied',
      desc: '',
      args: [],
    );
  }

  /// `Wish link`
  String get wish_link {
    return Intl.message(
      'Wish link',
      name: 'wish_link',
      desc: '',
      args: [],
    );
  }

  /// `Upload to Feixiaoqiu`
  String get upload_to_feixiaoqiu {
    return Intl.message(
      'Upload to Feixiaoqiu',
      name: 'upload_to_feixiaoqiu',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
