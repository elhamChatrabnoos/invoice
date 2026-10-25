import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_logo.dart';

class ScanYarApp extends ConsumerWidget {
  const ScanYarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: ref.watch(routerProvider),
      locale: const Locale('fa', 'IR'),
      supportedLocales: const [Locale('fa', 'IR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
    );
  }
}
