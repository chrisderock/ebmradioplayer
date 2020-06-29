// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars

class S {
  S();
  
  static S current;
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      S.current = S();
      
      return S.current;
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Please enter your name`
  String get enterYourName {
    return Intl.message(
      'Please enter your name',
      name: 'enterYourName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a song`
  String get enterASong {
    return Intl.message(
      'Please enter a song',
      name: 'enterASong',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a artist`
  String get enterArtist {
    return Intl.message(
      'Please enter a artist',
      name: 'enterArtist',
      desc: '',
      args: [],
    );
  }

  /// `Make a wish`
  String get makeAWish {
    return Intl.message(
      'Make a wish',
      name: 'makeAWish',
      desc: '',
      args: [],
    );
  }

  /// `Your name:`
  String get yourName {
    return Intl.message(
      'Your name:',
      name: 'yourName',
      desc: '',
      args: [],
    );
  }

  /// `Songname:`
  String get songName {
    return Intl.message(
      'Songname:',
      name: 'songName',
      desc: '',
      args: [],
    );
  }

  /// `Artist:`
  String get artist {
    return Intl.message(
      'Artist:',
      name: 'artist',
      desc: '',
      args: [],
    );
  }

  /// `Greetings:`
  String get greetings {
    return Intl.message(
      'Greetings:',
      name: 'greetings',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get send {
    return Intl.message(
      'Send',
      name: 'send',
      desc: '',
      args: [],
    );
  }

  /// `Wish sent`
  String get wishSent {
    return Intl.message(
      'Wish sent',
      name: 'wishSent',
      desc: '',
      args: [],
    );
  }

  /// `Visit our Website`
  String get ourWebsite {
    return Intl.message(
      'Visit our Website',
      name: 'ourWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Choose Stream`
  String get configStream {
    return Intl.message(
      'Choose Stream',
      name: 'configStream',
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
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'fr'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}