import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ja', ''),
    Locale('en', ''),
    Locale('vi', ''),
  ];

  Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('assets/i18n/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }

  String get appTitle => translate('app_title');
  String get qrTitle => translate('qr_title');
  String get qrInstruction => translate('qr_instruction');
  String get amountLabel => translate('amount_label');
  String get waitingPayment => translate('waiting_payment');
  String get processingPayment => translate('processing_payment');
  String get paymentSuccess => translate('payment_success');
  String get paymentFailed => translate('payment_failed');
  String get paymentTimeout => translate('payment_timeout');
  String get cancelPayment => translate('cancel_payment');
  String get retryPayment => translate('retry_payment');
  String get loading => translate('loading');
  String get errorQrGeneration => translate('error_qr_generation');
  String get errorNetwork => translate('error_network');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['ja', 'en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}