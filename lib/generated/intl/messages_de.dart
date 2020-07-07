// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'de';

  final messages = _notInlinedMessages(_notInlinedMessages);
  static _notInlinedMessages(_) => <String, Function> {
    "artist" : MessageLookupByLibrary.simpleMessage("Band:"),
    "configStream" : MessageLookupByLibrary.simpleMessage("Stream wählen"),
    "enterASong" : MessageLookupByLibrary.simpleMessage("Bitte einen Song eingeben"),
    "enterArtist" : MessageLookupByLibrary.simpleMessage("Bitte eine Band eingeben"),
    "enterYourName" : MessageLookupByLibrary.simpleMessage("Bitte Deinen Namen eingeben"),
    "greetings" : MessageLookupByLibrary.simpleMessage("Grüße an:"),
    "makeAWish" : MessageLookupByLibrary.simpleMessage("Schick uns einen Wunsch"),
    "ourWebsite" : MessageLookupByLibrary.simpleMessage("Mehr auf unserer Website"),
    "send" : MessageLookupByLibrary.simpleMessage("Senden"),
    "songName" : MessageLookupByLibrary.simpleMessage("Dein Wunschsong:"),
    "wishError" : MessageLookupByLibrary.simpleMessage("Fehler beim Verschicken"),
    "wishSent" : MessageLookupByLibrary.simpleMessage("Wunsch verschickt"),
    "yourName" : MessageLookupByLibrary.simpleMessage("Dein Name:")
  };
}
