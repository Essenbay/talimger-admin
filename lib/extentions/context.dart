import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension BuildContextX on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;

  ThemeData get theme => Theme.of(this);

  AppLocalizations get localized => AppLocalizations.of(this)!;

  // AppLocalizations get defaultLocale =>
  //     lookupAppLocalizations(Languages.eng.locale);
}

final buildContextProvider = Provider<BuildContext>((ref) {
  // Access the BuildContext from the nearest Navigator
  final navigator = ref.watch(navigatorKeyProvider);
  final context = navigator.currentContext;
  assert(context != null,
      'BuildContext is null. Make sure to wrap your widget tree with MaterialApp or CupertinoApp.');
  return context!;
});

final navigatorKeyProvider =
    Provider<GlobalKey<NavigatorState>>((ref) => GlobalKey<NavigatorState>());
