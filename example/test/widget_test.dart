import 'package:flutter_test/flutter_test.dart';
import 'package:solar_icons_plus_example/main.dart';

void main() {
  testWidgets('renders the searchable gallery', (tester) async {
    await tester.pumpWidget(const SolarIconsGallery());

    expect(find.text('Solar Icons Plus'), findsOneWidget);
    expect(find.text('7608 results'), findsOneWidget);
  });
}
