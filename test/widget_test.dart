import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:accesspath/main.dart';
import 'package:accesspath/services/storage_service.dart';
import 'package:accesspath/services/ai_summary_service.dart';
import 'package:accesspath/services/place_repository.dart';

void main() {
  testWidgets('AccessPath main navigation and discover screen smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.create();
    final aiSummaryService = AiSummaryService();
    final repository = PlaceRepository(
      storageService: storageService,
      aiSummaryService: aiSummaryService,
    );
    await repository.initialize();

    await tester.pumpWidget(AccessPathApp(repository: repository));
    await tester.pumpAndSettle();

    // Verify AccessPath branding
    expect(find.text('AccessPath'), findsOneWidget);
    expect(find.text('Every place. More accessible.'), findsOneWidget);

    // Verify search bar exists
    expect(find.text('Search hospitals, colleges, malls...'), findsOneWidget);

    // Verify bottom navigation bar tabs
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Add Review'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap 'Saved' tab
    await tester.tap(find.text('Saved'));
    await tester.pumpAndSettle();
    expect(find.text('Saved Places'), findsOneWidget);

    // Tap 'Profile' tab
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Profile & Preferences'), findsOneWidget);
    expect(find.text('Alex Johnson'), findsOneWidget);

    // Tap back to 'Discover' tab
    await tester.tap(find.text('Discover'));
    await tester.pumpAndSettle();
    expect(find.text('AccessPath'), findsOneWidget);
  });
}
