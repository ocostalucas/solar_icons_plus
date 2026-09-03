// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:async';
import 'dart:html' as html;

// Web implementation: remove the `#flutter-loader` element with a fade.
void hideLoadingScreenImpl() {
  final el = html.document.getElementById('flutter-loader');
  if (el == null) return;
  try {
    el.style.transition = 'opacity 350ms ease';
    el.style.opacity = '0';
  } catch (e) {
    try {
      html.window.console.log('hideLoadingScreenImpl transition error: $e');
    } catch (_) {}
  }
  Future.delayed(Duration(milliseconds: 420), () {
    try {
      el.remove();
    } catch (e) {
      try {
        html.window.console.log('hideLoadingScreenImpl remove error: $e');
      } catch (_) {}
    }
  });
}
