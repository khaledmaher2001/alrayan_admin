import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alrayan_admin/core/design/ds.dart';

// Translations aren't loaded in widget tests, so `.tr()` returns the key;
// the assertions below check structure and behaviour, not wording.
Widget _app(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  group('DsFormat', () {
    test('money uses thousands separators, Latin digits and up to 2 decimals', () {
      expect(DsFormat.money(50001541), startsWith('50,001,541'));
      expect(DsFormat.money(12.5), startsWith('12.5'));
      expect(DsFormat.money(null), startsWith('0'));
    });

    test('count formats integers', () {
      expect(DsFormat.count(1408), '1,408');
    });

    test('Arabic-Indic digits are converted to 0-9', () {
      expect(dsLatin('١١ أكتوبر ٢٠٢٦'), '11 أكتوبر 2026');
    });
  });

  testWidgets('status badge shows text and icon, not colour alone', (tester) async {
    await tester.pumpWidget(_app(const DsStatusBadge(status: 'pending', label: 'Pending', icon: Icons.access_time_rounded)));
    expect(find.text('Pending'), findsOneWidget);
    expect(find.byIcon(Icons.access_time_rounded), findsOneWidget);
  });

  testWidgets('confirm dialog returns false on cancel and true on confirm', (tester) async {
    bool? result;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await dsConfirm(context, title: 'Move?', message: 'Sure?', confirmLabel: 'Yes'),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Move?'), findsOneWidget);
    await tester.tap(find.text('s_cancel'));
    await tester.pumpAndSettle();
    expect(result, isFalse);

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });

  testWidgets('primary button shows a spinner and ignores taps while loading', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_app(DsButton(label: 'Save', loading: true, onPressed: () => taps++)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.tap(find.byType(TextButton));
    expect(taps, 0);
  });

  testWidgets('message state offers its action', (tester) async {
    var retried = false;
    await tester.pumpWidget(_app(DsMessage(icon: Icons.wifi_off, title: 'Offline', actionLabel: 'Retry', onAction: () => retried = true)));
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
