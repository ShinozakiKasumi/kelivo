import 'package:Kelivo/features/home/widgets/floating_pill_app_bar.dart';
import 'package:Kelivo/features/home/widgets/floating_pill_input_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('floating input capsule follows theme brightness', (
    tester,
  ) async {
    await _pumpWithTheme(
      tester,
      ThemeData.light(),
      const FloatingPillInputBox(
        leading: SizedBox(width: 24, height: 24),
        input: Text('Input'),
        trailing: SizedBox(width: 24, height: 24),
      ),
    );
    final lightColor = _capsuleColor(tester, FloatingPillInputBox);
    expect(lightColor, isNot(FloatingPillInputBox.darkBackground));

    await _pumpWithTheme(
      tester,
      ThemeData.dark(),
      const FloatingPillInputBox(
        leading: SizedBox(width: 24, height: 24),
        input: Text('Input'),
        trailing: SizedBox(width: 24, height: 24),
      ),
    );
    final darkColor = _capsuleColor(tester, FloatingPillInputBox);
    expect(
      darkColor,
      FloatingPillInputBox.darkBackground.withValues(alpha: 0.96),
    );
  });

  testWidgets('floating app bar capsule follows theme brightness', (
    tester,
  ) async {
    final appBar = FloatingPillAppBar(
      title: 'Assistant',
      subtitle: 'Model',
      menuSemanticLabel: 'Menu',
      toolsSemanticLabel: 'Tools',
      onMenuTap: () {},
      onTitleTap: () {},
      onToolsTap: () {},
    );

    await _pumpWithTheme(tester, ThemeData.light(), appBar);
    final lightColor = _capsuleColor(tester, FloatingPillAppBar);
    expect(lightColor, isNot(FloatingPillInputBox.darkBackground));

    await _pumpWithTheme(tester, ThemeData.dark(), appBar);
    final darkColor = _capsuleColor(tester, FloatingPillAppBar);
    expect(
      darkColor,
      FloatingPillInputBox.darkBackground.withValues(alpha: 0.96),
    );
  });
}

Future<void> _pumpWithTheme(
  WidgetTester tester,
  ThemeData theme,
  Widget child,
) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      darkTheme: theme,
      themeMode: theme.brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      themeAnimationDuration: Duration.zero,
      home: Scaffold(body: child),
    ),
  );
}

Color _capsuleColor(WidgetTester tester, Type rootType) {
  final boxes = find.descendant(
    of: find.byType(rootType),
    matching: find.byType(DecoratedBox),
  );
  for (final element in boxes.evaluate()) {
    final box = element.widget as DecoratedBox;
    final decoration = box.decoration;
    if (decoration is! BoxDecoration) continue;
    if (decoration.borderRadius != BorderRadius.circular(50)) continue;
    final color = decoration.color;
    if (color != null) return color;
  }
  fail('No floating capsule decoration found for $rootType');
}
