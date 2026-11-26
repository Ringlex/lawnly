import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lawnly/presentation/guide/guide_widgets.dart';

void main() {
  testWidgets('kafelki rosną z treścią zamiast ją ucinać', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    Widget tile(String text) => Container(
      padding: const EdgeInsets.all(14),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 10,
        children: [const SizedBox.square(dimension: 36), Text(text)],
      ),
    );

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.3)),
        child: MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(20),
              child: GuideTileGrid(
                children: [
                  tile('Zabiegi\nWertykulacja, aeracja, dosiewka i inne'),
                  tile('Nawożenie'),
                  tile('Koszenie'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    final first = tester.getSize(find.text('Nawożenie'));
    expect(first.height, greaterThan(0));
    final heights = tester
        .widgetList<Container>(find.byType(Container))
        .map((c) => tester.getSize(find.byWidget(c)).height)
        .toList();
    expect(heights[0], heights[1]);
  });
}
