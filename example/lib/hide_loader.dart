// Conditional import: use the web implementation when running on web,
// otherwise include a no-op stub so calling `hideLoadingScreen()` is safe.
import 'hide_loader_stub.dart' if (dart.library.html) 'hide_loader_web.dart';

/// Hides the HTML loading screen (web) or does nothing on other platforms.
void hideLoadingScreen() => hideLoadingScreenImpl();
