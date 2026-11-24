import 'package:material_ui/material_ui.dart';

import '../../l10n/generated/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';

  String get localeCode => isArabic ? 'ar' : 'en';

  String get appCurrencySymbol => '';
}
