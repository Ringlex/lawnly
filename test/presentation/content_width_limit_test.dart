import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/core/theme/app_theme.dart';
import 'package:lawnly/presentation/common/content_width_limit.dart';

void main() {
  Future<void> pumpAt(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme().theme(LightPalette()),
        home: const ContentWidthLimit(child: SizedBox.expand(key: Key('content'))),
      ),
    );
  }

  testWidgets('na szerokim ekranie treść nie rozciąga się ponad limit', (tester) async {
    await pumpAt(tester, const Size(1200, 800));

    expect(tester.getSize(find.byKey(const Key('content'))).width, ContentWidthLimit.maxWidth);
  });

  testWidgets('na wąskim ekranie treść wypełnia całą szerokość', (tester) async {
    await pumpAt(tester, const Size(360, 800));

    expect(tester.getSize(find.byKey(const Key('content'))).width, 360);
  });
}
