import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alrayan_admin/core/design/ds.dart';
import 'package:alrayan_admin/features/home/presentation/views/widgets/home_dashboard_v2.dart';

Widget _host(Widget child) => MaterialApp(home: Scaffold(body: DsGroup(children: [child])));

void main() {
  testWidgets('needs-action row shows a formatted count in its tone and opens its target', (tester) async {
    var taps = 0;
    await tester.pumpWidget(_host(DashboardActionRow(
      icon: Icons.shopping_bag_outlined,
      title: 'New orders',
      count: 1350,
      tone: DsColor.warning,
      toneBg: DsColor.warningBg,
      onTap: () => taps++,
    )));

    final count = tester.widget<Text>(find.text('1,350'));
    expect(count.style?.color, DsColor.warning);
    await tester.tap(find.text('New orders'));
    expect(taps, 1);
  });

  testWidgets('a zero count stays quiet (muted, no tinted pill)', (tester) async {
    await tester.pumpWidget(_host(const DashboardActionRow(icon: Icons.inventory_2_outlined, title: 'Low stock', count: 0)));

    final count = tester.widget<Text>(find.text('0'));
    expect(count.style?.color, DsColor.textSubtle);
  });
}
