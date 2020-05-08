import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class I18n {
  static RegExp _parameterRegexp = new RegExp("{(.+)}");
  final Locale locale;

  I18n(this.locale);

  // Helper method to keep the code in the widgets concise
  // Localizations are accessed using an InheritedWidget "of" syntax
  // static I18n of(BuildContext context) {
  //   return Localizations.of<I18n>(context, I18n);
  // }

  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<I18n> delegate = _I18nDelegate();

  Map<String, dynamic> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file from the "lang" folder
    String jsonString =
        await rootBundle.loadString('lib/lang/${locale.languageCode}.json');
    _localizedStrings = json.decode(jsonString);

    // _localizedStrings = jsonMap.map((key, value) {
    //   return MapEntry(key, value.toString());
    // });

    return true;
  }

  static String plural(final BuildContext context, final String translationKey,
      final int pluralValue) {
    final I18n currentInstance = _retrieveCurrentInstance(context);
    final Map<String, dynamic> decodedSubMap =
        _calculateSubmap(currentInstance._localizedStrings, translationKey);
    final String correctKey =
        _findCorrectKey(decodedSubMap, translationKey, pluralValue);
    final String parameterName =
        _findParameterName(decodedSubMap[correctKey.split(".").last]);
    return translate(context, correctKey,
        Map.fromIterables([parameterName], [pluralValue.toString()]));
  }

  static String _findCorrectKey(Map<String, dynamic> decodedSubMap,
      String translationKey, final int pluralValue) {
    final List<String> splittedKey = translationKey.split(".");
    translationKey = splittedKey.removeLast();
    List<int> possiblePluralValues = decodedSubMap.keys
        .where((mapKey) => mapKey.startsWith(translationKey))
        .where((mapKey) => mapKey.split("-").length == 2)
        .map((mapKey) => int.tryParse(mapKey.split("-")[1]))
        .where((mapKeyPluralValue) => mapKeyPluralValue != null)
        .where((mapKeyPluralValue) => mapKeyPluralValue <= pluralValue)
        .toList();
    possiblePluralValues.sort();
    final String lastKeyPart =
        "$translationKey-${possiblePluralValues.length > 0 ? possiblePluralValues.last : ''}";
    splittedKey.add(lastKeyPart);
    return splittedKey.join(".");
  }

  // This method will be called from every widget which needs a localized text
  static String translate(final BuildContext context, final String key,
      [final Map<String, String> translationParams]) {
    String translation = _translateWithKeyFallback(context, key);
    if (translationParams != null) {
      translation = _replaceParams(translation, translationParams);
    }
    return translation;
  }

  static String _translateWithKeyFallback(
      final BuildContext context, final String key) {
    final Map<String, dynamic> decodedStrings =
        _retrieveCurrentInstance(context)._localizedStrings;
    String translation = _decodeFromMap(decodedStrings, key);
    if (translation == null) {
      print("**$key** not found");
      translation = key;
    }
    return translation;
  }

  static I18n _retrieveCurrentInstance(BuildContext context) {
    return Localizations.of<I18n>(context, I18n);
  }

  static String _decodeFromMap(
      Map<String, dynamic> decodedStrings, final String key) {
    final Map<String, dynamic> subMap = _calculateSubmap(decodedStrings, key);
    final String lastKeyPart = key.split(".").last;
    return subMap[lastKeyPart];
  }

  static Map<String, dynamic> _calculateSubmap(
      Map<String, dynamic> decodedMap, final String translationKey) {
    final List<String> translationKeySplitted = translationKey.split(".");
    translationKeySplitted.removeLast();
    translationKeySplitted.forEach((listKey) => decodedMap =
        decodedMap != null && decodedMap[listKey] != null
            ? decodedMap[listKey]
            : new Map());
    return decodedMap;
  }

  static String _findParameterName(final String translation) {
    String parameterName = "";
    if (translation != null && _parameterRegexp.hasMatch(translation)) {
      final Match match = _parameterRegexp.firstMatch(translation);
      parameterName = match.groupCount > 0 ? match.group(1) : "";
    }
    return parameterName;
  }

  static String _replaceParams(
      String translation, final Map<String, String> translationParams) {
    for (final String paramKey in translationParams.keys) {
      translation = translation.replaceAll(
          new RegExp('{$paramKey}'), translationParams[paramKey]);
    }
    return translation;
  }
}

// LocalizationsDelegate is a factory for a set of localized resources
// In this case, the localized strings will be gotten in an AppLocalizations object
class _I18nDelegate extends LocalizationsDelegate<I18n> {
  // This delegate instance will never change (it doesn't even have fields!)
  // It can provide a constant constructor.
  const _I18nDelegate();

  @override
  bool isSupported(final Locale locale) {
    // Include all of your supported language codes here
    return ['es', 'en'].contains(locale.languageCode);
  }

  @override
  Future<I18n> load(final Locale locale) async {
    // AppLocalizations class is where the JSON loading actually runs
    I18n localizations = new I18n(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_I18nDelegate old) => false;
}
