import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice/app.dart';
import 'package:invoice/core/storage/storage_provider.dart';
import 'package:invoice/features/home/presentation/dashboard_page.dart';
import 'package:invoice/features/onboarding/presentation/onboarding_page.dart';

import 'helpers.dart';

Future<void> pumpApp(WidgetTester tester) async {
  final prefs = await tester.runAsync(createPrefs);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs!)],
      child: const ScanYarApp(),
    ),
  );
  // Let the splash finish (its logo animates forever, so no pumpAndSettle).
  await tester.pump(const Duration(seconds: 3));
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  setUp(useInMemoryPrefs);

  testWidgets('first launch: splash → onboarding → home', (tester) async {
    await pumpApp(tester);
    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('بارکد را اسکن کنید'), findsOneWidget);

    await tester.tap(find.text('بعدی'));
    await tester.pumpAndSettle();
    expect(find.text('سبد خرید هوشمند'), findsOneWidget);

    await tester.tap(find.text('رد شدن'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardPage), findsOneWidget);
  });

  testWidgets('returning user skips onboarding', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('رد شدن'));
    await tester.pumpAndSettle();

    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);
    expect(find.byType(OnboardingPage), findsNothing);
    expect(find.byType(DashboardPage), findsOneWidget);
  });
}
