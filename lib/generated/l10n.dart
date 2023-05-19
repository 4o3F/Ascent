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

  /// `Application`
  String get drawer_function {
    return Intl.message(
      'Application',
      name: 'drawer_function',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get drawer_about {
    return Intl.message(
      'About',
      name: 'drawer_about',
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

  /// `Guide for your brand can't be found, please contact developers`
  String get stage_pairing_guide_error {
    return Intl.message(
      'Guide for your brand can\'t be found, please contact developers',
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

  /// `Port`
  String get stage_pairing_port {
    return Intl.message(
      'Port',
      name: 'stage_pairing_port',
      desc: '',
      args: [],
    );
  }

  /// `Pairing Code`
  String get stage_pairing_code {
    return Intl.message(
      'Pairing Code',
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

  /// `Ascent will enter picture-in-picture mode. Please go to Settings => Developer options => Enable wireless debugging. Then select "Pair with pairing code" and enter the port and pairing code in their respective fields in the picture-in-picture window.\n(This action only needs to be run once)`
  String get stage_pairing_description {
    return Intl.message(
      'Ascent will enter picture-in-picture mode. Please go to Settings => Developer options => Enable wireless debugging. Then select "Pair with pairing code" and enter the port and pairing code in their respective fields in the picture-in-picture window.\n(This action only needs to be run once)',
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

  /// `Ascent will ask you the port for unlimited debugging. This process does not need to be run in the picture in picture mode. After entering the correct port and connecting successfully, it will automatically start watching for the wish history link.`
  String get stage_connecting_description {
    return Intl.message(
      'Ascent will ask you the port for unlimited debugging. This process does not need to be run in the picture in picture mode. After entering the correct port and connecting successfully, it will automatically start watching for the wish history link.',
      name: 'stage_connecting_description',
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
