// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:moodtracker/main.dart';

void main() {
  testWidgets('App loads and shows dashboard with welcome message', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MoodTrackerApp());

    // Verify that the dashboard page loads with welcome text in app bar
    expect(find.text('WELCOME USER'), findsOneWidget);

    // Wait for initial rendering
    await tester.pump();
  });

  testWidgets('App shows loading state initially', (WidgetTester tester) async {
    await tester.pumpWidget(const MoodTrackerApp());

    // Immediately after build, we should see loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading your mood data...'), findsOneWidget);
  });
}
