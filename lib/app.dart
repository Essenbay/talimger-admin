import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:increatorkz_admin/extentions/context.dart';
import 'package:increatorkz_admin/pages/splash.dart';
import 'package:increatorkz_admin/providers/language_provider.dart';
import 'package:provider/provider.dart' as provider;
import 'configs/app_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) => provider.Consumer<LanguageProvider>(
        builder: (context, provider, child) {
          final locale = provider.state.locale;
          return MaterialApp(
            navigatorKey: ref.read(navigatorKeyProvider),
            home: const SplashScreen(),
            title: 'Admin Panel',
            debugShowCheckedModeBanner: false,
            scrollBehavior: TouchAndMouseScrollBehavior(),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            theme: ThemeData(
              useMaterial3: false,
              fontFamily: 'Montserrat',
              primaryColor: AppConfig.themeColor,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
          );
        },
      ),
    );
  }
}

class TouchAndMouseScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices =>
      {PointerDeviceKind.touch, PointerDeviceKind.mouse};
}
